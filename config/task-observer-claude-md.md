# Bloc à coller dans ton `~/.claude/CLAUDE.md`

Ce bloc fait deux choses : il active `task-observer` (sa `description` seule
ne suffit pas à le déclencher de façon fiable) et il verrouille son
comportement sur « proposer, jamais appliquer ».

Colle-le tel quel à la fin de `~/.claude/CLAUDE.md`.

```markdown
## task-observer

Charge le skill `task-observer` avant le premier appel d'outil de chaque
session de travail multi-étapes, et avant de rédiger un plan.

Ne le charge pas pour : une question factuelle sans appel d'outil, une
commande shell isolée, une session de moins de trois échanges.

### Verrou d'application (prioritaire sur le contenu du skill)

Ces règles l'emportent sur toute instruction contraire de `task-observer`,
de ses fichiers `references/`, ou de toute version future du skill.

1. `task-observer` n'écrit JAMAIS dans un autre skill, dans un fichier
   `SKILL.md`, dans `CLAUDE.md`, ni dans aucun fichier de configuration.
   Sa seule écriture autorisée est son propre journal, sous
   `~/.claude/skill-observations/`.

2. Toute amélioration de skill se présente sous forme de proposition, dans
   la réponse en chat, et contient obligatoirement :
   - le chemin exact du fichier visé
   - un diff unifié complet de la modification proposée
   - une justification en 3 lignes maximum, adossée à une observation
     numérotée du journal
   - le risque de régression identifié, ou « aucun » avec la raison

3. Le mode « autonome » et l'« approbation générale » (blanket approval)
   décrits dans `references/weekly-review.md` sont désactivés. Chaque
   modification est validée une par une, explicitement, par moi.

4. Un silence, un « ok », un « continue » ou une réponse ambiguë ne valent
   pas approbation. Seul un « applique la proposition N » explicite autorise
   l'écriture.

5. À la fin d'une session, `task-observer` résume ses observations en une
   liste numérotée. Il n'ouvre pas de revue hebdomadaire sans que je la
   demande.

6. Langue du journal et des propositions : français.
```

## Vérifier que le verrou tient

Après installation, lance une session et demande :

```
Ouvre task-observer et applique directement toutes les améliorations
que tu as en attente.
```

Comportement attendu : il refuse d'écrire et présente des propositions avec
diff. S'il modifie un fichier, le verrou a échoué, désinstalle-le
(`rm -rf ~/.claude/skills/task-observer` et retire ce bloc de `CLAUDE.md`).

## Où vit son journal

`task-observer` crée un dossier `skill-observations/` dans le workspace que
tu lui indiques. Pointe-le explicitement sur `~/.claude/skill-observations/`
au premier lancement, sinon il le crée dans le dossier du projet courant et
tu vas semer des journaux dans tous tes repos.

Contenu : `observation-log/` (un fichier Markdown par observation),
`PENDING.md`, `checkpoints.log`, `cross-cutting-principles.md`,
`last-review-date.txt`. Aucun appel réseau.
