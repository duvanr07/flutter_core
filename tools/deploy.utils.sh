#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_MANIFEST="$PROJECT_ROOT/build/deploy-manifest.env"

if command -v fvm >/dev/null 2>&1 && { [ -f "$PROJECT_ROOT/.fvmrc" ] || [ -f "$PROJECT_ROOT/.fvm/fvm_config.json" ]; }; then
  FLUTTER_CMD="fvm flutter"
else
  FLUTTER_CMD="flutter"
fi

BUILD_NUMBER=$(date +%s)
BUILD_NAME=$(grep 'version:' "$PROJECT_ROOT/pubspec.yaml" | tail -n1 | awk '{print $2}' | cut -d'+' -f1)

VALID_ENVS="default dev sandbox staging production"

validate_env_name() {
  local env_name="$1"

  case "$env_name" in
    default|dev|sandbox|staging|production) return 0 ;;
    *)
      echo "❌ Invalid environment: $env_name"
      echo "Usage: valid values are $VALID_ENVS"
      return 1
      ;;
  esac
}

resolve_env_file() {
  local env_name="$1"

  case "$env_name" in
    default) echo "$PROJECT_ROOT/.env" ;;
    dev) echo "$PROJECT_ROOT/.env.dev" ;;
    sandbox) echo "$PROJECT_ROOT/.env.sandbox" ;;
    staging) echo "$PROJECT_ROOT/.env.staging" ;;
    production) echo "$PROJECT_ROOT/.env.production" ;;
    *)
      echo ""
      return 1
      ;;
  esac
}

resolve_flavor() {
  local env_name="$1"

  case "$env_name" in
    dev|sandbox|staging|production) echo "$env_name" ;;
    *) echo "" ;;
  esac
}

setup_deploy_env() {
  local env_name="$1"

  validate_env_name "$env_name" || exit 1

  ENV="$env_name"
  ENV_FILE="$(resolve_env_file "$ENV")"
  FLAVOR="$(resolve_flavor "$ENV")"
  export ENV ENV_FILE FLAVOR

  if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: Environment file '$ENV_FILE' not found"
    exit 1
  fi

  echo "✅ Loading environment file: $ENV_FILE"
  # shellcheck disable=SC1090
  source "$ENV_FILE"
}

has_android_flavors() {
  grep -q 'productFlavors' "$PROJECT_ROOT/android/app/build.gradle.kts" 2>/dev/null
}

has_ios_flavor() {
  local flavor="$1"
  [ -n "$flavor" ] && [ -f "$PROJECT_ROOT/ios/Runner.xcodeproj/xcshareddata/xcschemes/${flavor}.xcscheme" ]
}

build_flutter_common_args() {
  local platform="$1"
  local flavor="$2"

  BUILD_ARGS=(
    --dart-define-from-file="$ENV_FILE"
    --build-name "$BUILD_NAME"
    --build-number "$BUILD_NUMBER"
  )

  if [ "$platform" = "android" ] && has_android_flavors && [ -n "$flavor" ]; then
    BUILD_ARGS+=(--flavor "$flavor")
  fi

  if [ "$platform" = "ios" ] && has_ios_flavor "$flavor"; then
    BUILD_ARGS+=(--flavor "$flavor")
  fi
}

android_apk_output_path() {
  local flavor="$1"

  if has_android_flavors && [ -n "$flavor" ]; then
    echo "$PROJECT_ROOT/build/app/outputs/flutter-apk/app-${flavor}-release.apk"
  else
    echo "$PROJECT_ROOT/build/app/outputs/flutter-apk/app-release.apk"
  fi
}

ios_ipa_output_path() {
  echo "$PROJECT_ROOT/build/ios/ipa/magneto_app.ipa"
}

artifact_s3_keys() {
  ANDROID_S3_KEY="apk/magneto365-${ENV}-${BUILD_NAME}.apk"
  IOS_S3_KEY="ipa/magneto365-${ENV}-${BUILD_NAME}.ipa"
  export ANDROID_S3_KEY IOS_S3_KEY
}

write_build_manifest() {
  mkdir -p "$PROJECT_ROOT/build"

  artifact_s3_keys

  cat > "$BUILD_MANIFEST" <<EOF
ENV=$ENV
BUILD_NAME=$BUILD_NAME
BUILD_NUMBER=$BUILD_NUMBER
ANDROID_APK_LOCAL=$ANDROID_APK_LOCAL
IOS_IPA_LOCAL=$IOS_IPA_LOCAL
ANDROID_S3_KEY=$ANDROID_S3_KEY
IOS_S3_KEY=$IOS_S3_KEY
BUILT_ANDROID=$BUILT_ANDROID
BUILT_IOS=$BUILT_IOS
EOF

  echo "📝 Build manifest written to: $BUILD_MANIFEST"
}

read_build_manifest() {
  if [ ! -f "$BUILD_MANIFEST" ]; then
    echo "❌ No build manifest found at '$BUILD_MANIFEST'."
    echo "   Run ./build.sh first to compile the app."
    exit 1
  fi

  # shellcheck disable=SC1090
  source "$BUILD_MANIFEST"
}

resolve_release_metadata() {
  if [ "$ENV" = "production" ]; then
    TAG_VERSION="$BUILD_NAME"
    TARGET_BRANCH="main"
    PRERELEASE=false
    GENERATE_NOTES=true
    return 0
  fi

  TAG_VERSION="v${BUILD_NAME}-rc.${BUILD_NUMBER}"

  CURRENT_BRANCH=$(git -C "$PROJECT_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

  if [ -z "$CURRENT_BRANCH" ] || [ "$CURRENT_BRANCH" = "HEAD" ]; then
    echo "❌ Error: Unable to resolve current git branch (detached HEAD or not a git repo)."
    exit 1
  fi

  if ! git -C "$PROJECT_ROOT" ls-remote --exit-code --heads origin "$CURRENT_BRANCH" >/dev/null 2>&1; then
    echo "⚠️  Warning: branch '$CURRENT_BRANCH' does not exist on 'origin'."
    echo "   Make sure to push it before creating the release, otherwise GitHub will reject the target_commitish."
  fi

  TARGET_BRANCH="$CURRENT_BRANCH"
  PRERELEASE=true
  GENERATE_NOTES=false
}

create_github_release() {
  local android_cdn_url="https://${BUCKET_NAME}/${ANDROID_S3_KEY}"
  local ios_cdn_url="https://${BUCKET_NAME}/${IOS_S3_KEY}"

  if [ -z "${GITHUB_TOKEN:-}" ]; then
    echo "❌ Error: GITHUB_TOKEN is not set in the environment file."
    exit 1
  fi

  echo "🏷️ Creating GitHub release..."
  echo "   Tag: $TAG_VERSION"
  echo "   Target branch: $TARGET_BRANCH"
  echo "   Prerelease: $PRERELEASE"

  curl -s -X POST \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: token $GITHUB_TOKEN" \
    https://api.github.com/repos/magneto365/magneto_app/releases \
    -d "{
      \"tag_name\": \"${TAG_VERSION}\",
      \"target_commitish\": \"${TARGET_BRANCH}\",
      \"name\": \"${TAG_VERSION}\",
      \"body\": \"🚀 Release ${ENV}\n\n📥 Download IPA:\n${ios_cdn_url}\n\n📥 Download APK:\n${android_cdn_url}\",
      \"draft\": false,
      \"prerelease\": ${PRERELEASE},
      \"generate_release_notes\": ${GENERATE_NOTES}
    }"
}
