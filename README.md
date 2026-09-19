# SKILS — configuration Claude Code

Ma configuration Claude Code globale : trois hooks, et mes skills personnelles.

Le principe : **une skill ou un hook ne vaut que ce qu'il apprend à l'agent et qu'il
ne pouvait pas deviner.** Les patterns génériques (« utilise les fixtures pytest »,
« voici les hooks React ») sont déjà dans le modèle. Les payer en contexte à chaque
session est une perte sèche. Ce dépôt ne contient donc que du spécifique et de
l'outillage, pas de catalogue.

## Installation

```bash
git clone https://github.com/Edanllr/SKILS.git && cd SKILS && ./install.sh
```

Puis redémarrer Claude Code. Pour retirer : `./uninstall.sh` (ne touche à aucun
autre hook déjà configuré).

Installe au niveau **user** (`~/.claude/settings.json`) : actif dans tous les projets.
Prérequis : `python3` sur le PATH. S'il manque, les hooks ne font rien plutôt que
d'échouer.

## Les trois hooks

| Hook | Événement | Ce qu'il fait |
|---|---|---|
| `guard_config.py` | PreToolUse `Edit\|Write\|MultiEdit` | Refuse la modification des configs de lint / format / types |
| `track_edits.py` | PostToolUse `Edit\|Write\|MultiEdit` | Note les fichiers modifiés dans la session |
| `verify.py` | Stop | Formate et vérifie ces fichiers avant que l'agent s'arrête |

### `guard_config.py`

Quand un check échoue, le réflexe le moins cher est d'assouplir la règle. Ça échange
un problème visible contre un problème caché. Ce hook bloque `eslint.config.*`,
`biome.json`, `.prettierrc*`, `tsconfig*.json`, `ruff.toml`, `mypy.ini`, `.flake8`,
`rustfmt.toml`, `.golangci.yml`, `.editorconfig` et consorts.

`pyproject.toml` et `package.json` ne sont **pas** bloqués : les dépendances et les
scripts y vivent aussi.

Quand modifier la config *est* la tâche : `CLAUDE_ALLOW_CONFIG_EDIT=1`.

### `verify.py` — la vraie valeur

Sans lui, l'agent écrit du code, annonce que c'est fait, et le problème sort en CI.
Avec lui, un check qui casse revient en message que l'agent doit traiter avant de
rendre la main.

Quatre garde-fous qui le rendent vivable :

1. **Limité aux fichiers modifiés dans la session.** Les erreurs préexistantes
   ailleurs ne déclenchent jamais rien.
2. **N'utilise que les outils déjà présents** dans le projet. Rien d'installé, rien
   d'exécuté — silence.
3. **Le typecheck ne tourne que si le projet déclare un script** `typecheck` /
   `type-check` / `check-types`. C'est le lent. `SKILS_NO_TYPECHECK=1` le coupe.
4. **Une seule relance par session** (`stop_hook_active`) : un check impossible à
   satisfaire ne peut pas boucler.

Couvre aujourd'hui : Biome/Prettier + typecheck npm (JS/TS), ruff (Python),
gofmt + go vet (Go), rustfmt (Rust). Ajouter un langage = une fonction de ~8 lignes
dans `verify.py`.

## Coût

Zéro token de contexte : les hooks tournent dans le harnais, jamais dans le prompt.
Un process `python3` (~30 ms) sur les appels Edit/Write et à chaque Stop.

À comparer aux ~41 500 tokens permanents d'un gros catalogue de skills — chiffre
donné par `claude plugin details <plugin>`, à lancer avant d'installer quoi que ce soit.

## Skills

Voir [`skills/README.md`](skills/README.md). `install.sh` lie automatiquement chaque
`skills/<nom>/SKILL.md` dans `~/.claude/skills/`.
