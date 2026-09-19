# SKILS

Outillage Claude Code : audit, adaptation française et installation contrôlée
de cinq extensions.

## Pourquoi ce repo existe

Les cinq outils ont été audités avant installation : dépôt officiel
identifié, code lu, appels réseau et écritures disque recensés. Deux ont
demandé un travail supplémentaire. `stop-slop` ne cible que l'anglais, donc
il a fallu l'adapter. `task-observer` peut modifier d'autres skills en mode
autonome, donc il a fallu le verrouiller.

Résultat : l'audit dans `docs/`, l'adaptation française dans `skills/`, le
verrou dans `config/`, et un script qui installe le tout avec une
confirmation par étape.

## Installation

```bash
git clone https://github.com/Edanllr/SKILS.git
cd SKILS
./install.sh backup          # d'abord, toujours
./install.sh find-skills
./install.sh stop-slop-fr
./install.sh ui-ux-pro-max   # dans le dossier du projet visé
./install.sh task-observer
./install.sh claude-mem      # affiche la procédure, n'installe rien
./install.sh verify
```

`./install.sh all` enchaîne les quatre premiers. Chaque action affiche source,
licence, réseau, disque, puis attend un `o`.

## Contenu

| Chemin | Rôle |
|---|---|
| `install.sh` | Installation avec confirmation par outil, plus `verify` |
| `skills/stop-slop-fr/` | Adaptation française de stop-slop, prête à copier |
| `config/task-observer-claude-md.md` | Verrou « proposer, jamais appliquer » |
| `docs/AUDIT.md` | Audit des cinq outils : réseau, disque, hooks, licences |
| `docs/DESINSTALLATION.md` | Procédure de retrait complète, outil par outil |
| `.claude/skills/find-skills/` | find-skills en portée projet |

## Les cinq outils

| Outil | Portée conseillée | Verdict d'audit |
|---|---|---|
| [find-skills](https://github.com/vercel-labs/skills) | utilisateur | aucun script, aucun réseau |
| [stop-slop](https://github.com/hardikpandya/stop-slop) → `stop-slop-fr` | utilisateur | Markdown seul, adapté en français |
| [ui-ux-pro-max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | **projet** | 3,6 Mo, scripts Python sans réseau |
| [task-observer](https://github.com/rebelytics/one-skill-to-rule-them-all) | utilisateur | verrou obligatoire, voir `config/` |
| [claude-mem](https://github.com/thedotmack/claude-mem) | à décider | 7 hooks, télémétrie, désactive la mémoire native |

Détail complet dans [docs/AUDIT.md](docs/AUDIT.md).

## Pourquoi ui-ux-pro-max en portée projet

Sa description se charge dans chaque session, y compris celles qui ne
touchent à aucune interface. Elle pèse 3,6 Mo sur le disque et un bloc de
contexte à chaque démarrage. En portée projet, elle vit dans le Git du projet
concerné, donc elle est reproductible et supprimable projet par projet.

Passe-la en `--global` seulement si tu construis des interfaces en continu.

## Ce que `stop-slop-fr` bloque

Six interdictions dures : le tiret cadratin, les connecteurs de remplissage
(`De plus`, `Par ailleurs`, `En effet`), les formules d'annonce
(`il convient de souligner`), les fausses oppositions
(`non seulement... mais aussi`), le ton conférence motivationnelle, et les
phrases creuses. Plus sept règles de fond sur la voix active, la fausse
agentivité, les adverbes en `-ment` et la typographie française.

Test rapide après installation :

```
Relis ce texte avec stop-slop-fr : "De plus, il convient de souligner que
notre solution permet non seulement d'optimiser vos process — mais aussi de
réduire vos coûts. Le résultat ? Une performance accrue."
```

Attendu : tous les marqueurs signalés, une réécriture sans aucun d'entre eux.

## Licences

`skills/stop-slop-fr/` dérive de
[hardikpandya/stop-slop](https://github.com/hardikpandya/stop-slop), MIT,
copyright Hardik Pandya, licence conservée dans le dossier. Le reste du repo
suit la licence de son dépôt d'origine, référencée dans `docs/AUDIT.md`.
