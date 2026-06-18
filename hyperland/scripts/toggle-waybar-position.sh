#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-paths.sh
source "$SCRIPT_DIR/lib/project-paths.sh"
resolve_project_paths "$SCRIPT_DIR"

STATE_FILE="$HOME/.cache/hypr/waybar-position.json"
WAYBAR_CONFIG="$HOME/.config/waybar/config"
USER_OPTIONS="$HOME/.config/ignis/user_options.json"
REPO_WAYBAR_CONFIG="$CONFIG_ROOT/waybar/config"

mkdir -p "$(dirname "$STATE_FILE")"

export REPO_WAYBAR_CONFIG

if find_github_repo_root && [ -n "$GITHUB_REPO_ROOT" ]; then
  export GITHUB_WAYBAR_CONFIG="$GITHUB_REPO_ROOT/waybar/config"
else
  export GITHUB_WAYBAR_CONFIG=""
fi

python3 <<'PY'
import json
import os
import re
from pathlib import Path

state_file = Path.home() / ".cache/hypr/waybar-position.json"
waybar_config = Path.home() / ".config/waybar/config"
user_options = Path.home() / ".config/ignis/user_options.json"
repo_config = Path(os.environ["REPO_WAYBAR_CONFIG"])
github_config = Path(os.environ.get("GITHUB_WAYBAR_CONFIG") or "")

if state_file.is_file():
    try:
        state = json.loads(state_file.read_text())
    except json.JSONDecodeError:
        state = {"position": "top"}
else:
    state = {"position": "top"}

current = state.get("position", "top")
new_pos = "bottom" if current == "top" else "top"
state["position"] = new_pos
state_file.write_text(json.dumps(state, indent=2) + "\n")

def patch_config(path: Path) -> None:
    if not path.is_file():
        return
    text = path.read_text()
    text = re.sub(
        r'("position"\s*:\s*")(?:top|bottom)(")',
        rf"\g<1>{new_pos}\g<2>",
        text,
        count=1,
    )
    path.write_text(text)

patch_config(waybar_config)
patch_config(repo_config)
if github_config and str(github_config) != str(repo_config):
    patch_config(github_config)

if user_options.exists():
    try:
        opts = json.loads(user_options.read_text())
    except json.JSONDecodeError:
        opts = {}
else:
    opts = {}
opts.setdefault("bar", {})["position"] = new_pos
opts.setdefault("bar", {}).setdefault("height", 26)
user_options.parent.mkdir(parents=True, exist_ok=True)
user_options.write_text(json.dumps(opts, indent=2) + "\n")

print(new_pos)
PY

killall waybar 2>/dev/null || true
sleep 0.4
waybar &>/dev/null &
