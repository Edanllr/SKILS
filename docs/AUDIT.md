# Audit de sécurité des 5 outils

Réalisé le 19/09/2026. Méthode : clone Git complet de chaque dépôt, lecture
des `SKILL.md`, des hooks et des scripts, recherche ciblée sur les appels
réseau, les écritures disque et l'exécution de code.

## Tableau de synthèse

| Outil | Dépôt | Auteur | Dernier commit | Licence | Réseau | Écriture disque | Verdict |
|---|---|---|---|---|---|---|---|
| find-skills | [vercel-labs/skills](https://github.com/vercel-labs/skills) | Vercel Labs | 2026-09-17 | MIT | aucun | aucune | OK |
| stop-slop | [hardikpandya/stop-slop](https://github.com/hardikpandya/stop-slop) | Hardik Pandya | 2026-03-18 | MIT | aucun | aucune | OK |
| ui-ux-pro-max | [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | nextlevelbuilder | 2026-09-19 | MIT | aucun | aucune | OK |
| task-observer | [rebelytics/one-skill-to-rule-them-all](https://github.com/rebelytics/one-skill-to-rule-them-all) | Eoghan Henn | 2026-09-11 | CC BY 4.0 | aucun | journal local | OK sous conditions |
| claude-mem | [thedotmack/claude-mem](https://github.com/thedotmack/claude-mem) | Alex Newman | 2026-09-18 (v13.25.2) | Apache-2.0 | oui, plusieurs flux | base SQLite + config | à valider en connaissance de cause |

**Nombre d'étoiles GitHub : non vérifié.** Le proxy réseau de la session
d'audit bloquait `api.github.com` (HTTP 403). Les chiffres relayés par les
agrégateurs tiers se contredisent (2,8k et 9,8k annoncés pour le même dépôt
par la même source). Ne pas s'y fier. Les dates de commit et le contenu des
fichiers ci-dessus proviennent de clones directs et sont fiables.

## find-skills

Un seul fichier, `SKILL.md`, 141 lignes, aucun script. Il apprend à l'agent à
interroger le catalogue skills.sh via `npx skills find` au lieu de réinventer
une solution. Aucun appel réseau propre : c'est l'agent qui lancera `npx`
quand tu déclencheras le skill, ce qui touche alors le registre npm et
skills.sh.

Installation : `npx -y skills add vercel-labs/skills --skill find-skills
--agent claude-code --global`. Crée aussi `skills-lock.json` qui épingle la
source et le hash du contenu.

## stop-slop

Quatre fichiers Markdown : `SKILL.md` plus `references/phrases.md`,
`references/structures.md`, `references/examples.md`. Zéro code exécutable,
zéro appel réseau, zéro écriture.

**Il cible exclusivement l'anglais.** Ses listes portent sur « delve »,
« leverage », « it's worth noting », « here's the thing ». Inutilisable tel
quel sur du contenu francophone. Voir `skills/stop-slop-fr/` dans ce repo
pour l'adaptation.

## ui-ux-pro-max

Base de données locale interrogeable : 79 styles, 192 palettes, 74
appariements de polices, 119 règles UX, 105 icônes, 25 types de graphiques,
22 stacks techniques. Deux scripts Python actifs, `search.py` (177 lignes) et
`core.py` (993 lignes).

Recherche sur `urllib|requests|http|socket|subprocess|os.system|open(...,'w')
|shutil|rmtree|eval|exec` dans les scripts du skill : **aucune occurrence**.
Le seul `urllib` du dépôt sert à analyser des URL Google Fonts dans un
validateur de données, pas à émettre une requête.

Poids : 3,6 Mo pour le skill seul. Le dépôt en propose sept au total
(`design`, `brand`, `design-system`, `slides`, `banner-design`, `ui-styling`
à 5,8 Mo). N'installe que celui dont tu as besoin.

## task-observer

Skill unique plus sept fichiers `references/` et deux scripts Python.
`migrate-log.py` convertit un ancien format de journal, `validate-skill-bundle.py`
vérifie un skill avant livraison. Recherche réseau sur les deux scripts :
aucune occurrence.

Écritures : un dossier `skill-observations/` dans le workspace choisi, avec
un fichier Markdown par observation, `PENDING.md` et `checkpoints.log`.

### Réserve 1 : auto-activation

Sa `description` contient l'instruction « invoke this skill before the FIRST
tool call of any session and before writing or proposing a plan ». Sa
documentation pousse à ajouter une ligne dans `CLAUDE.md` ou un hook
`SessionStart`. Conséquence : il consomme du contexte à chaque session, y
compris sur des tâches sans rapport.

### Réserve 2 : application automatique en mode autonome

En mode interactif il demande l'accord avant d'appliquer
(`references/weekly-review.md`, lignes 120-122 et 158). En mode autonome il
applique. Le verrou fourni dans `config/task-observer-claude-md.md` désactive
ce mode et impose diff plus justification.

## claude-mem

Version 13.25.2, dépôt de 277 Mo, développement très actif.

### Ce qu'il stocke et où

| Chemin | Contenu |
|---|---|
| `~/.claude-mem/claude-mem.db` | Base SQLite des mémoires compressées |
| `~/.claude-mem/settings.json` | Configuration |
| `~/.claude-mem/.env` | Clés API du provider de compression |
| `~/.claude-mem/transcript-watch.json` | Liste des transcripts surveillés |
| `~/.claude/plugins/cache/thedotmack/claude-mem/<version>/` | Code du plugin |
| `~/.claude/settings.json` | Entrée `enabledPlugins` et variable `CLAUDE_CODE_DISABLE_AUTO_MEMORY` |

### Hooks ajoutés

Sept points d'accroche, chacun exécutant un one-liner bash d'environ 1 500
caractères qui résout le chemin du plugin puis lance
`node .../worker-service.cjs` :

| Hook | Déclencheur | Rôle |
|---|---|---|
| `Setup` | installation | vérification de version |
| `SessionStart` | startup, resume, clear, compact | démarre le worker, injecte le contexte |
| `UserPromptSubmit` | chaque prompt | initialisation de session |
| `PostToolUse` | `*` (tous les outils), async | capture d'observation |
| `PreToolUse` | `Read`, async | contexte de fichier |
| `Stop` | fin de réponse, async | résumé |
| `SessionEnd` | fin de session, async | clôture |

Tout le code exécuté est local, dans le cache du plugin. Aucune exécution de
code distant. Mais la surface est large : ça tourne après chaque appel
d'outil.

### Sorties réseau

1. **Télémétrie PostHog**, `https://us.i.posthog.com`, **activée par défaut**
   (opt-out). `src/services/telemetry/scrub.ts` applique une liste blanche
   stricte de clés : `version`, `os`, `os_version`, `arch`, `runtime`,
   `duration_ms`, `outcome`, `error_category`, `locale`, `is_ci`. Commentaire
   du fichier : « Everything else — paths, project names, prompts, queries,
   emails, IPs, env values — is dropped silently ». Pas de contenu
   utilisateur. Désactivation : `CLAUDE_MEM_TELEMETRY=0` et
   `CLAUDE_MEM_TELEMETRY_ERRORS=0`.

2. **Provider de compression.** Compresser une session demande un LLM. Selon
   le provider retenu, le contenu de tes sessions part vers le service hébergé
   de claude-mem, OpenRouter, Google Generative Language, DeepSeek, ou
   l'API Anthropic. **C'est le vrai point de décision.** L'option Anthropic
   est la seule neutre : Anthropic voit déjà tes sessions Claude Code.

3. **Synchro cloud**, `sync.cmem.ai` : **désactivée par défaut**,
   `CLAUDE_MEM_CLOUD_SYNC_HUB_URL` vaut chaîne vide
   (`src/shared/SettingsDefaultsManager.ts:243`).

### Recouvrement avec la mémoire native et CLAUDE.md

L'installateur écrit `"CLAUDE_CODE_DISABLE_AUTO_MEMORY": "1"` dans le bloc
`env` de `~/.claude/settings.json` (`src/npx-cli/commands/install.ts:254`).
Tu ne cumules pas les deux mémoires, tu remplaces la native.

`CLAUDE.md` n'est pas modifié et reste lu normalement. Il reste donc deux
couches de contexte injectées à chaque session : ton `CLAUDE.md` statique et
les mémoires claude-mem. Elles se recoupent et consomment du contexte en
double si tu écris dans `CLAUDE.md` des choses que claude-mem capture déjà.

### Verdict

Pas malveillant. Licence Apache-2.0, code lisible, scrubber de télémétrie
honnête et documenté, synchro cloud désactivée par défaut. Le risque n'est
pas l'exfiltration, c'est le couplage : sept hooks, un worker permanent, la
mémoire native désactivée, et un provider LLM tiers à choisir.
