# Development

This file owns local environment and simulator workflow.

## Requirements
- Flutter SDK
- Xcode
- iOS Simulator
- CocoaPods

## Standard Commands
- Boot simulator:
  - `./scripts/boot_simulator.sh`
- Build the Flutter iOS app for simulator:
  - `./scripts/build.sh`
- Run Flutter tests:
  - `./scripts/test.sh`
- Build, install, and launch the iOS app in Simulator:
  - `./scripts/run.sh`

## How The Scripts Work
- `scripts/select_simulator.sh` picks `iPhone 14 Pro` when available.
- If `iPhone 14 Pro` is unavailable, it picks the newest available iPhone runtime.
- `scripts/resolve_flutter.sh` finds a usable Flutter SDK.
- `scripts/build.sh` runs `flutter build ios --simulator`.
- `scripts/test.sh` runs `flutter test`.
- `scripts/run.sh` builds `build/ios/iphonesimulator/Runner.app`, installs it with `simctl`, reads the bundle ID from `Info.plist`, and launches it in the selected simulator.

## Override Variables
Use this if Flutter is not on `PATH`:

- `FLUTTER_BIN`: absolute path to the Flutter executable

Example:

```bash
FLUTTER_BIN=$HOME/.local/flutter/bin/flutter ./scripts/run.sh
```

## Failure Policy
- If no iPhone simulator is available, the scripts exit with a clear error.
- If no Flutter SDK can be resolved, the scripts exit with a clear error.
- If `pubspec.yaml` is missing, the scripts exit with a clear error.
- Do not silently guess a macOS destination or a random bundle identifier.
