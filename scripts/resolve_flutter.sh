#!/bin/zsh
set -euo pipefail

ROOT_DIR=$(cd "${0:A:h}/.." && pwd)

if [[ -n "${FLUTTER_BIN:-}" ]]; then
  if [[ -x "$FLUTTER_BIN" ]]; then
    echo "$FLUTTER_BIN"
    exit 0
  fi

  echo "Configured FLUTTER_BIN is not executable: $FLUTTER_BIN" >&2
  exit 1
fi

declare -a candidates=(
  "$ROOT_DIR/.fvm/flutter_sdk/bin/flutter"
  "$HOME/.local/flutter/bin/flutter"
  "/opt/homebrew/bin/flutter"
  "/opt/homebrew/share/flutter/bin/flutter"
)

for candidate in "${candidates[@]}"; do
  if [[ -x "$candidate" ]]; then
    echo "$candidate"
    exit 0
  fi
done

if command -v flutter >/dev/null 2>&1; then
  command -v flutter
  exit 0
fi

echo "Flutter SDK not found. Set FLUTTER_BIN or install Flutter." >&2
exit 1
