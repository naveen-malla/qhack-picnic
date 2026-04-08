# qhack-picnic

Flutter app scaffold with iOS and Android targets plus a simulator-first iOS workflow.

## Quick Start
- Boot simulator: `./scripts/boot_simulator.sh`
- Build the iOS app for simulator: `./scripts/build.sh`
- Run Flutter tests: `./scripts/test.sh`
- Build, install, and launch in simulator: `./scripts/run.sh`

## Flutter Setup
- The repo expects a Flutter SDK to be available.
- Set `FLUTTER_BIN` if Flutter is not on `PATH`.
- Default local lookup also checks:
  - `.fvm/flutter_sdk/bin/flutter`
  - `~/.local/flutter/bin/flutter`
  - `/opt/homebrew/bin/flutter`
  - `/opt/homebrew/share/flutter/bin/flutter`

## Simulator Policy
- Preferred device: `iPhone 14 Pro`
- Fallback: newest available iPhone simulator runtime

## Current State
- The repo now contains a standard Flutter app scaffold at the root.
- `ios/` and `android/` are Flutter-managed platform directories.
- The iOS helper scripts use Flutter for build and test orchestration, then install and launch the generated `.app` with `simctl`.
