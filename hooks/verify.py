#!/usr/bin/env python3
"""Stop: format and type-check the files edited this session, before the agent stops.

This is the feedback loop. Without it the agent writes code, declares success, and
the problem surfaces later in CI or in your terminal. With it, a failing check comes
back as a message the agent has to act on.

Design constraints that keep it usable:
  - Scoped to files edited this session. Pre-existing errors elsewhere never fire.
  - Only runs tools the project already has. No tool -> silent no-op.
  - Type-checking runs only when the project declares a typecheck script (it is the
    slow one). Disable with SKILS_NO_TYPECHECK=1.
  - Interrupts at most once per session, so a check the agent cannot satisfy can
    never loop.

Contract: exit 2 blocks the stop and hands stderr to the model. Anything else exits 0.
"""

import json
import os
import shutil
import subprocess
import sys

STATE_DIR = os.path.expanduser("~/.claude/state/skils")
TIMEOUT = 120
TYPECHECK_SCRIPTS = ("typecheck", "type-check", "check-types", "tsc")


def run(cmd, cwd):
    try:
        p = subprocess.run(
            cmd, cwd=cwd, capture_output=True, text=True, timeout=TIMEOUT
        )
        return p.returncode, (p.stdout or "") + (p.stderr or "")
    except Exception:
        return 0, ""  # a tool that will not run is not a finding


def has_bin(name, cwd):
    return shutil.which(name) is not None or os.path.exists(
        os.path.join(cwd, "node_modules", ".bin", name)
    )


def node_bin(name, cwd):
    local = os.path.join(cwd, "node_modules", ".bin", name)
    return [local] if os.path.exists(local) else [name]


def check_js(files, cwd, problems):
    if not files:
        return
    if os.path.exists(os.path.join(cwd, "biome.json")) or has_bin("biome", cwd):
        code, out = run(node_bin("biome", cwd) + ["check", "--write"] + files, cwd)
        if code != 0:
            problems.append(("biome check", out))
    elif has_bin("prettier", cwd):
        run(node_bin("prettier", cwd) + ["--write"] + files, cwd)

    if os.environ.get("SKILS_NO_TYPECHECK") == "1":
        return
    pkg_path = os.path.join(cwd, "package.json")
    if not os.path.exists(pkg_path):
        return
    try:
        scripts = json.load(open(pkg_path, encoding="utf-8")).get("scripts") or {}
    except Exception:
        return
    script = next((s for s in TYPECHECK_SCRIPTS if s in scripts), None)
    if not script:
        return
    code, out = run(["npm", "run", "--silent", script], cwd)
    if code != 0:
        # Keep only the lines naming a file edited this session.
        edited = {os.path.basename(f) for f in files}
        lines = [ln for ln in out.splitlines() if any(e in ln for e in edited)]
        if lines:
            problems.append((f"npm run {script}", "\n".join(lines[:20])))


def check_python(files, cwd, problems):
    if not files or not has_bin("ruff", cwd):
        return
    run(["ruff", "format"] + files, cwd)
    code, out = run(["ruff", "check"] + files, cwd)
    if code != 0:
        problems.append(("ruff check", out))


def check_go(files, cwd, problems):
    if not files or not has_bin("gofmt", cwd):
        return
    run(["gofmt", "-w"] + files, cwd)
    code, out = run(["go", "vet"] + sorted({os.path.dirname(f) for f in files}), cwd)
    if code != 0:
        problems.append(("go vet", out))


def check_rust(files, cwd, problems):
    if not files or not has_bin("rustfmt", cwd):
        return
    run(["rustfmt", "--edition", "2021"] + files, cwd)


def main() -> int:
    payload = json.load(sys.stdin)
    if payload.get("stop_hook_active"):
        return 0  # already re-entered once; never loop

    session = payload.get("session_id") or "unknown"
    cwd = payload.get("cwd") or os.getcwd()
    edits_file = os.path.join(STATE_DIR, f"{session}.edits")
    if not os.path.exists(edits_file):
        return 0

    files = []
    seen = set()
    for line in open(edits_file, encoding="utf-8"):
        f = line.strip()
        if f and f not in seen and os.path.exists(f):
            seen.add(f)
            files.append(f)
    os.remove(edits_file)  # consumed: the next response starts from a clean list
    if not files:
        return 0

    def by_ext(exts):
        return [f for f in files if f.endswith(exts)]

    problems = []
    check_js(by_ext((".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs")), cwd, problems)
    check_python(by_ext((".py",)), cwd, problems)
    check_go(by_ext((".go",)), cwd, problems)
    check_rust(by_ext((".rs",)), cwd, problems)

    if not problems:
        return 0

    sys.stderr.write("Les vérifications échouent sur les fichiers modifiés :\n\n")
    for name, out in problems:
        sys.stderr.write(f"--- {name} ---\n{out.strip()[:2000]}\n\n")
    sys.stderr.write("Corrige ces erreurs avant de t'arrêter.\n")
    return 2


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception:
        sys.exit(0)  # fail open
