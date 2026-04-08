#!/bin/zsh
set -euo pipefail

ROOT_DIR=$(cd "${0:A:h}/.." && pwd)

workspace_path=${APP_WORKSPACE:-}
project_path=${APP_PROJECT:-}
scheme_name=${APP_SCHEME:-}

if [[ -n "$workspace_path" && -n "$project_path" ]]; then
  echo "Set only one of APP_WORKSPACE or APP_PROJECT, not both." >&2
  exit 1
fi

if [[ -z "$workspace_path" && -z "$project_path" ]]; then
  workspace_path=$(find "$ROOT_DIR" -maxdepth 3 -name '*.xcworkspace' | sort | head -n 1 || true)
  project_path=$(find "$ROOT_DIR" -maxdepth 3 -name '*.xcodeproj' | sort | head -n 1 || true)

  if [[ -n "$workspace_path" ]]; then
    project_path=""
  fi
fi

if [[ -z "$workspace_path" && -z "$project_path" ]]; then
  echo "No .xcworkspace or .xcodeproj found in $ROOT_DIR. Add the Xcode project first, or set APP_WORKSPACE / APP_PROJECT." >&2
  exit 1
fi

if [[ -n "$workspace_path" && ! -e "$ROOT_DIR/$workspace_path" && ! -e "$workspace_path" ]]; then
  echo "Configured APP_WORKSPACE not found: $workspace_path" >&2
  exit 1
fi

if [[ -n "$project_path" && ! -e "$ROOT_DIR/$project_path" && ! -e "$project_path" ]]; then
  echo "Configured APP_PROJECT not found: $project_path" >&2
  exit 1
fi

if [[ -n "$workspace_path" && -e "$ROOT_DIR/$workspace_path" ]]; then
  workspace_path="$ROOT_DIR/$workspace_path"
fi

if [[ -n "$project_path" && -e "$ROOT_DIR/$project_path" ]]; then
  project_path="$ROOT_DIR/$project_path"
fi

list_json=""
if [[ -z "$scheme_name" ]]; then
  if [[ -n "$workspace_path" ]]; then
    list_json=$(xcodebuild -list -json -workspace "$workspace_path" 2>/dev/null || true)
  else
    list_json=$(xcodebuild -list -json -project "$project_path" 2>/dev/null || true)
  fi

  if [[ -n "$list_json" ]]; then
    scheme_name=$(LIST_JSON="$list_json" python3 - <<'PY'
import json
import os

raw = os.environ.get("LIST_JSON", "")
if not raw:
    raise SystemExit(0)

data = json.loads(raw)
project = data.get("project", {})
workspace = data.get("workspace", {})
schemes = workspace.get("schemes") or project.get("schemes") or []
print(schemes[0] if schemes else "")
PY
)
  fi
fi

if [[ -z "$scheme_name" ]]; then
  echo "Could not resolve an Xcode scheme. Set APP_SCHEME to the app scheme you want to build." >&2
  exit 1
fi

if [[ -n "$workspace_path" ]]; then
  echo "workspace=$workspace_path"
else
  echo "project=$project_path"
fi
echo "scheme=$scheme_name"
