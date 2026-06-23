#!/bin/bash
set -e

###############################################################################
# Compile mobile artifacts for the selected environment.
#
# Usage:
#   ./build.sh
#   ./build.sh staging
#   ./build.sh production --android-only
#   ./build.sh staging --ios-only
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ENV="default"
BUILD_ANDROID=true
BUILD_IOS=true

for arg in "$@"; do
  case "$arg" in
    --android-only)
      BUILD_ANDROID=true
      BUILD_IOS=false
      ;;
    --ios-only)
      BUILD_ANDROID=false
      BUILD_IOS=true
      ;;
    --*)
      echo "❌ Unknown option: $arg"
      echo "Usage: $0 [default|dev|sandbox|staging|production] [--android-only|--ios-only]"
      exit 1
      ;;
    *)
      ENV="$arg"
      ;;
  esac
done

echo "🔨 Starting build for environment: $ENV"

# shellcheck disable=SC1091
source "$SCRIPT_DIR/deploy.utils.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/build.android.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/build.ios.sh"

setup_deploy_env "$ENV"

BUILT_ANDROID=false
BUILT_IOS=false
ANDROID_APK_LOCAL=""
IOS_IPA_LOCAL=""

if [ "$BUILD_ANDROID" = true ]; then
  build_android
  BUILT_ANDROID=true
fi

if [ "$BUILD_IOS" = true ]; then
  build_ios
  BUILT_IOS=true
fi

echo "✅ Build completed for environment: $ENV"
if [ "$BUILT_ANDROID" = true ]; then
  echo "   Android APK: $ANDROID_APK_LOCAL"
fi
if [ "$BUILT_IOS" = true ]; then
  echo "   iOS IPA: $IOS_IPA_LOCAL"
fi
