# AGENTS.md

## Project Intent
This repo is for the `qhack-picnic` iOS app.
Keep workflow simple, simulator-first, and easy to run from a fresh chat.

## Default Workflow
- Read this file first.
- Then read `README.md` and `DEVELOPMENT.md` if they are relevant to the task.
- Prefer the smallest correct change.
- Fail loudly with actionable errors instead of guessing when local project setup is incomplete.

## Testing And Running
- Use iOS Simulator for all local app verification.
- Prefer `iPhone 14 Pro` if available; otherwise use the newest available iPhone simulator.
- Do not use macOS destinations for app verification.
- When asked to build, test, or run the app, use the repo scripts instead of ad-hoc commands:
  - `./scripts/boot_simulator.sh`
  - `./scripts/build.sh`
  - `./scripts/test.sh`
  - `./scripts/run.sh`
- The simulator destination must come from `./scripts/select_simulator.sh`.
- If the Xcode project, workspace, or scheme cannot be resolved, stop with a clear error that explains what is missing.

## Run Expectations
- `run in simulator` means:
  1. boot the preferred iPhone simulator
  2. build the app for that simulator
  3. install the built `.app`
  4. launch it in Simulator
- `test` means run XCTest on the simulator, not just build.

## Project Detection
- The helper scripts auto-detect the first `.xcworkspace` or `.xcodeproj` in the repo.
- The helper scripts auto-detect the first shared scheme if `APP_SCHEME` is not set.
- If auto-detection becomes ambiguous, set one or more of:
  - `APP_WORKSPACE`
  - `APP_PROJECT`
  - `APP_SCHEME`

## Documentation
- Keep `README.md` focused on quick start and repo entrypoint info.
- Keep `DEVELOPMENT.md` focused on build/test/run workflow and environment details.
