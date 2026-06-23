#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

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
  echo "$PROJECT_ROOT/build/ios/ipa/app-release.ipa"
}
