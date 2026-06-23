#!/bin/bash

function build_ios() {
  local export_options="$PROJECT_ROOT/ios/ExportOptions.plist"

  cd "$PROJECT_ROOT"

  build_flutter_common_args "ios" "$FLAVOR"

  if [ -f "$export_options" ]; then
    BUILD_ARGS+=(--export-options-plist "$export_options")
  fi

  echo "🍎 Building iOS IPA for environment: ${ENV:-default}"
  echo "   dart-define-from-file: $ENV_FILE"
  if has_ios_flavor "$FLAVOR"; then
    echo "   flavor: $FLAVOR"
  fi

  $FLUTTER_CMD build ipa "${BUILD_ARGS[@]}"

  IOS_IPA_LOCAL="$(ios_ipa_output_path)"

  if [ ! -f "$IOS_IPA_LOCAL" ]; then
    echo "❌ Error: IPA not found at '$IOS_IPA_LOCAL'"
    exit 1
  fi

  echo "✅ iOS IPA ready: $IOS_IPA_LOCAL"
}
