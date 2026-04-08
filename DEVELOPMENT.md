# Development

This file covers local setup, simulator workflow, and the current app surface.

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
- Build the Flutter iOS app for a physical iPhone:
  - `./scripts/build_device.sh`
- Run Flutter tests:
  - `./scripts/test.sh`
- Build, install, and launch the iOS app in Simulator:
  - `./scripts/run.sh`

## Current App Areas

- **Entdecken**
  - main landing screen
  - voice input entry point
  - Smart Basket entry card
  - calendar suggestion strip when `/api/extract` returns items
- **Favoriten**
  - one-tap bulk add flow for a preselected basket
  - extra suggested items that can be toggled before adding
- **Social**
  - recipe card with ingredient add-to-basket action
  - challenge card with starter-kit add-to-basket action
- **Warenkorb**
  - shows items added from favorites, social actions, voice ingestion, or queue-based external inputs

## Integration Points

- `/api/wishlist/next`
  - polled by the app for external hook/plugin items
- `/api/wishlist/confirm`
  - confirms that queue items were consumed
- `/api/voice/ingest`
  - sends recorded audio for extraction and adds returned items directly to the basket
- `/api/extract`
  - used by the calendar flow to turn event text into item suggestions
- Google Calendar read-only access
  - handled through `google_sign_in` and the in-app calendar sync service

## How The Scripts Work

- `scripts/select_simulator.sh` picks `iPhone 14 Pro` when available.
- If `iPhone 14 Pro` is unavailable, it picks the newest available iPhone runtime.
- `scripts/resolve_flutter.sh` finds a usable Flutter SDK.
- `scripts/build.sh` runs `flutter build ios --simulator`.
- `scripts/build_device.sh` runs `flutter build ios --release --no-codesign`.
- `scripts/test.sh` runs `flutter test`.
- `scripts/run.sh` builds `build/ios/iphonesimulator/Runner.app`, installs it with `simctl`, reads the bundle ID from `Info.plist`, and launches it in the selected simulator.

## iPhone Deployment

- The repo can compile for a physical iPhone without code signing.
- To install on a phone, open [ios/Runner.xcworkspace](/Users/naveenmalla/Work/Personal/qhack-picnic/ios/Runner.xcworkspace) in Xcode.
- In Xcode:
  - choose the `Runner` target
  - set your Apple team under Signing & Capabilities if Xcode asks
  - pick the connected iPhone as the destination
  - press Run
- If your Apple account changes, Xcode may rewrite signing settings locally.

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
