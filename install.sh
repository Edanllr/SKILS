#!/usr/bin/env bash
# Installs the hooks into the user-level Claude Code config, so they apply to
# every project. Idempotent: re-running updates in place. Undo with ./uninstall.sh
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.claude/hooks/skils"

mkdir -p "$DEST"
cp "$SRC"/hooks/*.py "$DEST/"
chmod +x "$DEST"/*.py

python3 - "$DEST" <<'PY'
import json, os, sys

dest = sys.argv[1]
settings_path = os.path.expanduser("~/.claude/settings.json")
os.makedirs(os.path.dirname(settings_path), exist_ok=True)

try:
    settings = json.load(open(settings_path, encoding="utf-8"))
except Exception:
    settings = {}


def cmd(script):
    # `if ...; then ...; fi` keeps the script's exit code intact (exit 2 must still
    # block) and no-ops cleanly on a machine without python3.
    p = f"$HOME/.claude/hooks/skils/{script}"
    return f'if command -v python3 >/dev/null 2>&1; then python3 "{p}"; fi'


WANTED = {
    "PreToolUse": [("Edit|Write|MultiEdit", "guard_config.py")],
    "PostToolUse": [("Edit|Write|MultiEdit", "track_edits.py")],
    "Stop": [(None, "verify.py")],
}

hooks = settings.setdefault("hooks", {})
for event, entries in WANTED.items():
    bucket = hooks.setdefault(event, [])
    # Drop our own previous entries; leave anything else untouched.
    bucket[:] = [
        m for m in bucket
        if not any("hooks/skils/" in h.get("command", "") for h in m.get("hooks", []))
    ]
    for matcher, script in entries:
        entry = {"hooks": [{"type": "command", "command": cmd(script)}]}
        if matcher:
            entry["matcher"] = matcher
        bucket.append(entry)

json.dump(settings, open(settings_path, "w", encoding="utf-8"), indent=2)
print(f"hooks installés dans {dest}")
print(f"settings mis à jour : {settings_path}")
PY

# Skills: each skills/<name>/SKILL.md is linked into ~/.claude/skills/, where Claude
# Code loads it for every project. Symlinked, so editing the repo takes effect at
# the next session with no reinstall.
mkdir -p "$HOME/.claude/skills"
linked=0
for dir in "$SRC"/skills/*/; do
  [ -f "${dir}SKILL.md" ] || continue
  name="$(basename "$dir")"
  rm -rf "$HOME/.claude/skills/$name"
  ln -s "${dir%/}" "$HOME/.claude/skills/$name" 2>/dev/null || cp -R "${dir%/}" "$HOME/.claude/skills/$name"
  linked=$((linked+1))
done
echo "$linked skill(s) liée(s) dans ~/.claude/skills"

echo
echo "Actif dans tous tes projets au prochain démarrage de Claude Code."
echo "Pour retirer : $SRC/uninstall.sh"
