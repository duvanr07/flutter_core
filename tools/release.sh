#!/bin/bash
set -e

###############################################################################
# Upload compiled artifacts and create a GitHub release.
# Must run after build.sh.
#
# Usage:
#   ./release.sh
#   ./release.sh staging
#   ./release.sh staging --upload-only
#   ./release.sh staging --github-only
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

REQUESTED_ENV=""
UPLOAD=true
GITHUB_RELEASE=true

for arg in "$@"; do
  case "$arg" in
    --upload-only)
      UPLOAD=true
      GITHUB_RELEASE=false
      ;;
    --github-only)
      UPLOAD=false
      GITHUB_RELEASE=true
      ;;
    --*)
      echo "❌ Unknown option: $arg"
      echo "Usage: $0 [default|dev|sandbox|staging|production] [--upload-only|--github-only]"
      exit 1
      ;;
    *)
      REQUESTED_ENV="$arg"
      ;;
  esac
done

# shellcheck disable=SC1091
source "$SCRIPT_DIR/deploy.utils.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/upload.android.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/upload.ios.sh"

read_build_manifest

if [ -n "$REQUESTED_ENV" ] && [ "$REQUESTED_ENV" != "$ENV" ]; then
  echo "❌ Environment mismatch: requested '$REQUESTED_ENV' but manifest is for '$ENV'."
  echo "   Run ./build.sh $REQUESTED_ENV or ./release.sh $ENV"
  exit 1
fi

setup_deploy_env "$ENV"

echo "🚀 Starting release for environment: $ENV"

if [ "$UPLOAD" = true ]; then
  if [ "$BUILT_ANDROID" = true ]; then
    upload_android "$ANDROID_APK_LOCAL" "$ANDROID_S3_KEY"
  else
    echo "⏭️  Skipping Android upload (not built in this manifest)."
  fi

  if [ "$BUILT_IOS" = true ]; then
    upload_ios "$IOS_IPA_LOCAL" "$IOS_S3_KEY"
  else
    echo "⏭️  Skipping iOS upload (not built in this manifest)."
  fi
fi

if [ "$GITHUB_RELEASE" = true ]; then
  resolve_release_metadata
  create_github_release
fi

echo "✅ Release completed for environment: $ENV"
