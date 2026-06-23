#!/bin/bash

function build_android() {
  cd "$PROJECT_ROOT"

  build_flutter_common_args "android" "$FLAVOR"

  echo "🤖 Building Android APK for environment: ${ENV:-default}"
  echo "   dart-define-from-file: $ENV_FILE"
  if has_android_flavors && [ -n "$FLAVOR" ]; then
    echo "   flavor: $FLAVOR"
  fi

  $FLUTTER_CMD pub get
  $FLUTTER_CMD build apk "${BUILD_ARGS[@]}"

  ANDROID_APK_LOCAL="$(android_apk_output_path "$FLAVOR")"

  if [ ! -f "$ANDROID_APK_LOCAL" ]; then
    echo "❌ Error: APK not found at '$ANDROID_APK_LOCAL'"
    exit 1
  fi

  echo "✅ Android APK ready: $ANDROID_APK_LOCAL"
}
