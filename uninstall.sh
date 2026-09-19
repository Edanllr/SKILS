#!/usr/bin/env bash
# Removes everything install.sh added. Leaves any other hook you configured alone.
set -euo pipefail

python3 - <<'PY'
import json, os, shutil

settings_path = os.path.expanduser("~/.claude/settings.json")
try:
    settings = json.load(open(settings_path, encoding="utf-8"))
except Exception:
    settings = {}

removed = 0
hooks = settings.get("hooks", {})
for event in list(hooks):
    before = len(hooks[event])
    hooks[event] = [
        m for m in hooks[event]
        if not any("hooks/skils/" in h.get("command", "") for h in m.get("hooks", []))
    ]
    removed += before - len(hooks[event])
    if not hooks[event]:
        del hooks[event]
if not hooks:
    settings.pop("hooks", None)

json.dump(settings, open(settings_path, "w", encoding="utf-8"), indent=2)
shutil.rmtree(os.path.expanduser("~/.claude/hooks/skils"), ignore_errors=True)
shutil.rmtree(os.path.expanduser("~/.claude/state/skils"), ignore_errors=True)
print(f"{removed} hooks retirés, ~/.claude/hooks/skils supprimé.")
PY

# Remove only the skill links that point back into this repo.
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for link in "$HOME/.claude/skills"/*; do
  [ -L "$link" ] || continue
  case "$(readlink "$link")" in "$SRC"/*) rm -f "$link"; echo "lien retiré : $(basename "$link")";; esac
done
