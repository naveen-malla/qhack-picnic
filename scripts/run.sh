#!/bin/zsh
set -euo pipefail

SCRIPT_DIR=${0:A:h}
ROOT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
SIM_ID=$("$SCRIPT_DIR/select_simulator.sh")
FLUTTER_BIN=$("$SCRIPT_DIR/resolve_flutter.sh")

if [[ -z "$SIM_ID" ]]; then
  echo "No available iPhone simulator found."
  exit 1
fi

if [[ ! -f "$ROOT_DIR/pubspec.yaml" ]]; then
  echo "No pubspec.yaml found in $ROOT_DIR. Create the Flutter app first." >&2
  exit 1
fi

"$SCRIPT_DIR/boot_simulator.sh"

cd "$ROOT_DIR"
"$FLUTTER_BIN" --suppress-analytics pub get
"$FLUTTER_BIN" --suppress-analytics build ios --simulator --debug --no-pub

APP_PATH=$(find "$ROOT_DIR/build/ios/iphonesimulator" -maxdepth 1 -name '*.app' -type d | sort | head -n 1 || true)
if [[ -z "$APP_PATH" || ! -d "$APP_PATH" ]]; then
  echo "Build succeeded but no simulator .app was found under $ROOT_DIR/build/ios/iphonesimulator." >&2
  exit 1
fi

INFO_PLIST="$APP_PATH/Info.plist"
if [[ ! -f "$INFO_PLIST" ]]; then
  echo "Built app is missing Info.plist at $INFO_PLIST" >&2
  exit 1
fi

BUNDLE_ID=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$INFO_PLIST" 2>/dev/null || true)
if [[ -z "$BUNDLE_ID" ]]; then
  echo "Could not read CFBundleIdentifier from $INFO_PLIST" >&2
  exit 1
fi

xcrun simctl install "$SIM_ID" "$APP_PATH"
xcrun simctl launch "$SIM_ID" "$BUNDLE_ID"
