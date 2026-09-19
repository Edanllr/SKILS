# Tout désinstaller

Par ordre de difficulté croissante. Chaque commande est indépendante.

## Retour en arrière complet, d'un coup

Si tu as lancé `./install.sh backup` avant tout :

```bash
rm -rf ~/.claude
cp -a ~/.claude-backup-AAAA-MM-JJ-HHMM ~/.claude
```

Ça annule tout, sauf `~/.claude-mem/` qui vit en dehors de `~/.claude`
(voir plus bas).

## Skill par skill

```bash
rm -rf ~/.claude/skills/find-skills
rm -rf ~/.claude/skills/stop-slop-fr
rm -rf ~/.claude/skills/task-observer
rm -rf ./.claude/skills/ui-ux-pro-max        # portée projet
rm -rf ~/.claude/skills/ui-ux-pro-max        # si installé en global
```

Supprime aussi le fichier `skills-lock.json` créé par la CLI `skills` à la
racine du projet, s'il ne référence plus rien.

## task-observer : les deux résidus

```bash
rm -rf ~/.claude/skills/task-observer
rm -rf ~/.claude/skill-observations          # son journal
```

Puis retire le bloc `## task-observer` de `~/.claude/CLAUDE.md`. L'installeur
l'ajoute à la fin du fichier, il commence par `## task-observer` et finit par
la ligne `6. Langue du journal et des propositions : français.`

## claude-mem : la procédure complète

```bash
npx claude-mem uninstall
```

Cette commande fait, d'après `src/npx-cli/commands/uninstall.ts` :

- supprime le répertoire du marketplace et le cache du plugin
- retire `thedotmack` de la liste des marketplaces connus
- retire `claude-mem@thedotmack` des plugins installés
- retire l'entrée dans `enabledPlugins` de `~/.claude/settings.json`
- **restaure la mémoire native** en supprimant
  `env.CLAUDE_CODE_DISABLE_AUTO_MEMORY`
- nettoie les chemins et les logs résiduels

Elle ne supprime pas tes données. Pour ça :

```bash
rm -rf ~/.claude-mem                         # base SQLite, settings, clés API
```

Vérification :

```bash
grep -r "claude-mem" ~/.claude/settings.json ~/.claude/plugins/ 2>/dev/null
grep "CLAUDE_CODE_DISABLE_AUTO_MEMORY" ~/.claude/settings.json
```

Les deux commandes doivent ne rien renvoyer. Si la seconde renvoie quelque
chose, la mémoire native est encore désactivée : retire la ligne à la main du
bloc `env`.

Si tu avais lancé la variante Docker, ajoute :

```bash
docker compose down -v --remove-orphans
```

## Vérifier l'état à tout moment

```bash
./install.sh verify
```

Liste les skills utilisateur et projet avec leur poids et leur chemin, les
plugins, les hooks déclarés, les variables d'environnement `CLAUDE_*`, et les
sauvegardes disponibles.
