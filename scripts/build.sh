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

cd "$ROOT_DIR"
"$FLUTTER_BIN" --suppress-analytics pub get
"$FLUTTER_BIN" --suppress-analytics build ios --simulator --debug --no-pub
