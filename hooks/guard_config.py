#!/usr/bin/env python3
"""PreToolUse(Edit|Write|MultiEdit): refuse edits to linter/formatter/type-checker config.

Rationale: when a check fails, the cheap fix is to loosen the rule. That trades a
real problem for a hidden one. This hook makes the agent fix the code instead.

Escape hatch: set CLAUDE_ALLOW_CONFIG_EDIT=1 (env in ~/.claude/settings.json, or
export it before launching Claude Code) when the config change is the actual task.

Contract: exit 2 blocks the tool and shows stderr to the model. Any other failure
exits 0 (fail open) so a bug here can never wedge a session.
"""

import json
import os
import sys

# Pure quality-gate config. Files that legitimately change for other reasons
# (pyproject.toml holds dependencies, package.json holds scripts) stay out.
BLOCKED_NAMES = {
    ".editorconfig",
    ".eslintrc",
    ".eslintrc.js",
    ".eslintrc.cjs",
    ".eslintrc.json",
    ".eslintrc.yml",
    ".eslintrc.yaml",
    "eslint.config.js",
    "eslint.config.mjs",
    "eslint.config.cjs",
    "eslint.config.ts",
    "biome.json",
    "biome.jsonc",
    ".prettierrc",
    ".prettierrc.json",
    ".prettierrc.yml",
    ".prettierrc.yaml",
    ".prettierrc.js",
    "prettier.config.js",
    "prettier.config.mjs",
    "ruff.toml",
    ".ruff.toml",
    "mypy.ini",
    ".mypy.ini",
    "pyrightconfig.json",
    ".flake8",
    "setup.cfg",
    "tox.ini",
    ".pylintrc",
    "pylintrc",
    "rustfmt.toml",
    ".rustfmt.toml",
    "clippy.toml",
    ".clippy.toml",
    ".golangci.yml",
    ".golangci.yaml",
    ".golangci.toml",
    ".rubocop.yml",
    ".swiftlint.yml",
    ".checkstyle.xml",
    "detekt.yml",
}
BLOCKED_PREFIXES = ("tsconfig",)  # tsconfig.json, tsconfig.build.json, ...


def main() -> int:
    if os.environ.get("CLAUDE_ALLOW_CONFIG_EDIT") == "1":
        return 0

    payload = json.load(sys.stdin)
    tool_input = payload.get("tool_input") or {}
    path = tool_input.get("file_path") or tool_input.get("path") or ""
    if not path:
        return 0

    name = os.path.basename(path)
    blocked = name in BLOCKED_NAMES or (
        name.startswith(BLOCKED_PREFIXES) and name.endswith(".json")
    )
    if not blocked:
        return 0

    sys.stderr.write(
        f"BLOQUÉ : {name} est une config de qualité (lint / format / types).\n"
        "Relâcher une règle pour faire passer un check échange un problème visible "
        "contre un problème caché. Corrige le code à la place.\n"
        "Si modifier cette config EST la tâche demandée, dis-le à l'utilisateur et "
        "demande-lui de définir CLAUDE_ALLOW_CONFIG_EDIT=1.\n"
    )
    return 2


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception:
        sys.exit(0)  # fail open
