#!/usr/bin/env python3
"""PostToolUse(Edit|Write|MultiEdit): record which files this session touched.

verify.py reads this list at Stop so the checks stay scoped to what actually
changed, instead of reporting pre-existing problems elsewhere in the repo.
"""

import json
import os
import sys

STATE_DIR = os.path.expanduser("~/.claude/state/skils")


def main() -> int:
    payload = json.load(sys.stdin)
    tool_input = payload.get("tool_input") or {}
    path = tool_input.get("file_path") or tool_input.get("path")
    session = payload.get("session_id") or "unknown"
    if not path:
        return 0

    cwd = payload.get("cwd") or os.getcwd()
    path = os.path.abspath(os.path.join(cwd, path))

    os.makedirs(STATE_DIR, exist_ok=True)
    with open(os.path.join(STATE_DIR, f"{session}.edits"), "a", encoding="utf-8") as fh:
        fh.write(path + "\n")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception:
        sys.exit(0)  # fail open
