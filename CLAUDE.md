# SKILS

Configuration Claude Code personnelle : hooks globaux + skills.

## Structure

- `hooks/*.py` — hooks Claude Code. Copiés dans `~/.claude/hooks/skils/` par `install.sh`.
- `skills/<nom>/SKILL.md` — skills personnelles, liées dans `~/.claude/skills/`.
- `install.sh` / `uninstall.sh` — pose et retire la config au niveau user, de façon
  idempotente, sans toucher aux autres hooks présents.

## Règles pour ce dépôt

- **Les hooks échouent ouverts.** Toute exception non prévue sort en code 0. Un bug
  ici bloquerait toutes mes sessions Claude Code, dans tous mes projets.
- **Seul le code 2 bloque.** `guard_config.py` (PreToolUse) et `verify.py` (Stop)
  l'utilisent délibérément ; leur message stderr est lu par l'agent, écris-le comme
  une instruction actionnable.
- **`verify.py` reste limité aux fichiers modifiés dans la session.** Ne jamais le
  faire vérifier le repo entier : il remonterait des erreurs préexistantes et
  l'agent perdrait son temps sur du bruit.
- **Pas de skill générique.** Voir `skills/README.md` : si le modèle connaît déjà la
  réponse, la skill est un coût sans contrepartie.

## Tester un hook

Les hooks lisent un JSON sur stdin et communiquent par code de sortie :

```bash
echo '{"tool_name":"Edit","tool_input":{"file_path":"/x/tsconfig.json"}}' \
  | python3 hooks/guard_config.py; echo "exit=$?"   # attendu : 2

echo '{"session_id":"t","cwd":"'$PWD'","stop_hook_active":false}' \
  | python3 hooks/verify.py; echo "exit=$?"
```

Tester les deux chemins avant de commit : le cas qui doit bloquer, et le cas qui
doit passer.
