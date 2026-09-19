#!/usr/bin/env bash
# Installation des skills Claude Code — Edan Leulier
# Chaque action demande confirmation. Rien ne s'exécute sans un "o" explicite.
# Usage : ./install.sh [backup|find-skills|stop-slop-fr|ui-ux-pro-max|task-observer|claude-mem|verify|all]

set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

bold() { printf '\033[1m%s\033[0m\n' "$1"; }
ok()   { printf '  \033[32mOK\033[0m %s\n' "$1"; }
warn() { printf '  \033[33m!\033[0m  %s\n' "$1"; }
err()  { printf '  \033[31mKO\033[0m %s\n' "$1"; }

confirm() {
  local reponse=""
  local sur_tty=0
  printf '\n\033[1m%s\033[0m\n' "$1"
  # npx et les CLI interactives avalent stdin : on lit sur le terminal quand
  # il est réellement ouvrable, pas seulement present dans /dev.
  if [[ -e /dev/tty ]] && (exec 3</dev/tty) 2>/dev/null; then
    sur_tty=1
  fi
  if (( sur_tty )); then
    read -r -p "  Continuer ? [o/N] " reponse < /dev/tty || reponse=""
  else
    read -r -p "  Continuer ? [o/N] " reponse || reponse=""
  fi
  [[ "$reponse" == "o" || "$reponse" == "O" ]]
}

require_node() {
  if ! command -v npx >/dev/null 2>&1; then
    err "npx introuvable. Installe Node.js 18 ou plus récent, puis relance."
    return 1
  fi
}

# --------------------------------------------------------------------------
do_backup() {
  local dest="$HOME/.claude-backup-$(date +%Y-%m-%d-%H%M)"
  if [[ ! -d "$CLAUDE_DIR" ]]; then
    warn "$CLAUDE_DIR n'existe pas encore, rien à sauvegarder."
    return 0
  fi
  confirm "SAUVEGARDE : copier $CLAUDE_DIR vers $dest" || return 1
  cp -a "$CLAUDE_DIR" "$dest" && ok "Sauvegarde : $dest ($(du -sh "$dest" | cut -f1))"
}

# --------------------------------------------------------------------------
do_find_skills() {
  require_node || return 1
  confirm "1/5 find-skills (niveau UTILISATEUR, ~/.claude/skills/)
  Source   : vercel-labs/skills, MIT
  Contenu  : 1 fichier SKILL.md, aucun script
  Réseau   : aucun en propre
  Disque   : ~/.claude/skills/find-skills/ (5 Ko)" || return 1

  npx -y skills add vercel-labs/skills --skill find-skills \
      --agent claude-code --global --yes < /dev/null \
    && ok "find-skills installé dans $CLAUDE_DIR/skills/find-skills/"
}

# --------------------------------------------------------------------------
do_stop_slop_fr() {
  local src="$REPO/skills/stop-slop-fr"
  local dest="$CLAUDE_DIR/skills/stop-slop-fr"
  [[ -d "$src" ]] || { err "Introuvable : $src"; return 1; }

  confirm "2/5 stop-slop-fr (niveau UTILISATEUR)
  Source   : adaptation française de hardikpandya/stop-slop, MIT
  Contenu  : 4 fichiers Markdown, aucun script
  Réseau   : aucun
  Disque   : $dest" || return 1

  if [[ -d "$dest" ]]; then
    warn "$dest existe déjà."
    confirm "  L'écraser ?" || return 1
    rm -rf "$dest"
  fi
  mkdir -p "$CLAUDE_DIR/skills"
  cp -a "$src" "$dest" && ok "stop-slop-fr installé dans $dest"

  warn "L'original anglais n'est PAS installé. Si tu écris aussi en anglais :"
  echo "      npx -y skills add hardikpandya/stop-slop --agent claude-code --global"
}

# --------------------------------------------------------------------------
do_ui_ux_pro_max() {
  require_node || return 1
  local portee="projet"
  local flag=""
  local cible="./.claude/skills/ui-ux-pro-max"

  if [[ "${1:-}" == "--global" ]]; then
    portee="utilisateur"; flag="--global"; cible="$CLAUDE_DIR/skills/ui-ux-pro-max"
  fi

  confirm "3/5 ui-ux-pro-max (niveau ${portee^^})
  Source   : nextlevelbuilder/ui-ux-pro-max-skill, MIT
  Contenu  : base de données locale + 2 scripts Python
  Réseau   : aucun (vérifié par lecture de search.py et core.py)
  Disque   : $cible (3,6 Mo)
  Conseil  : portée PROJET. Sa description se charge à chaque session,
             et la plupart de tes sessions ne touchent pas à de l'UI." || return 1

  if [[ "$portee" == "projet" ]]; then
    echo "  Dossier courant : $(pwd)"
    confirm "  Installer dans CE dossier ?" || return 1
  fi

  npx -y skills add nextlevelbuilder/ui-ux-pro-max-skill --skill ui-ux-pro-max \
      --agent claude-code $flag --yes < /dev/null \
    && ok "ui-ux-pro-max installé dans $cible"
}

# --------------------------------------------------------------------------
do_task_observer() {
  require_node || return 1
  confirm "4/5 task-observer (niveau UTILISATEUR)
  Source   : rebelytics/one-skill-to-rule-them-all, CC BY 4.0
  Contenu  : SKILL.md + 7 références + 2 scripts Python locaux
  Réseau   : aucun
  Disque   : $CLAUDE_DIR/skills/task-observer/
             + un journal skill-observations/ créé au premier usage
  ATTENTION: il s'auto-active à chaque session et consomme du contexte.
             Le verrou 'proposer, jamais appliquer' est OBLIGATOIRE." || return 1

  npx -y skills add rebelytics/one-skill-to-rule-them-all \
      --agent claude-code --global --yes < /dev/null \
    && ok "task-observer installé dans $CLAUDE_DIR/skills/task-observer/"

  echo
  bold "Étape manuelle obligatoire"
  echo "  Colle le bloc de verrouillage dans $CLAUDE_DIR/CLAUDE.md :"
  echo "      $REPO/config/task-observer-claude-md.md"
  echo "  Sans ce bloc, le skill peut modifier tes autres skills en mode autonome."
  echo
  confirm "  L'ajouter automatiquement à $CLAUDE_DIR/CLAUDE.md maintenant ?" || {
    warn "Bloc non ajouté. Fais-le à la main avant d'utiliser le skill."
    return 0
  }
  mkdir -p "$CLAUDE_DIR"
  {
    echo
    sed -n '/^```markdown$/,/^```$/p' "$REPO/config/task-observer-claude-md.md" \
      | sed '1d;$d'
  } >> "$CLAUDE_DIR/CLAUDE.md"
  ok "Bloc ajouté à $CLAUDE_DIR/CLAUDE.md"
}

# --------------------------------------------------------------------------
do_claude_mem() {
  bold "5/5 claude-mem — installation NON scriptée, volontairement"
  cat <<'TXT'

  Ce n'est pas une skill, c'est un plugin. Il ajoute 7 hooks, lance un worker
  permanent, et DÉSACTIVE la mémoire native de Claude Code en écrivant
  "CLAUDE_CODE_DISABLE_AUTO_MEMORY": "1" dans ~/.claude/settings.json.

  Lis docs/AUDIT.md avant. Trois décisions à prendre AVANT d'installer :

  1. Provider de compression. Tes sessions sont envoyées à un LLM pour être
     compressées. Choisis "plan Anthropic" : c'est le seul qui n'ajoute pas
     un tiers qui ne voit pas déjà tes sessions.

  2. Télémétrie. Activée par défaut, vers us.i.posthog.com. Aucun contenu
     utilisateur n'est envoyé (liste blanche stricte dans scrub.ts), mais
     personne ne te demande ton avis. Pour couper, avant d'installer :
         export CLAUDE_MEM_TELEMETRY=0
         export CLAUDE_MEM_TELEMETRY_ERRORS=0

  3. Doublon avec CLAUDE.md. Après installation, allège ton CLAUDE.md de tout
     ce que claude-mem capture déjà, sinon tu paies le contexte deux fois.

  Installation, dans Claude Code (commandes interactives du CLI) :
      /plugin marketplace add thedotmack/claude-mem
      /plugin install claude-mem

  Désinstallation complète :
      npx claude-mem uninstall
      rm -rf ~/.claude-mem
      grep -r "claude-mem" ~/.claude/settings.json ~/.claude/plugins/ 2>/dev/null

TXT
}

# --------------------------------------------------------------------------
do_verify() {
  bold "État de l'installation"
  echo
  echo "Skills niveau utilisateur  ($CLAUDE_DIR/skills/) :"
  if [[ -d "$CLAUDE_DIR/skills" ]]; then
    for d in "$CLAUDE_DIR"/skills/*/; do
      [[ -d "$d" ]] || continue
      [[ -f "$d/SKILL.md" ]] && printf '  %-22s %-8s %s\n' \
        "$(basename "$d")" "$(du -sh "$d" | cut -f1)" "$d"
    done
  else
    echo "  (aucun)"
  fi
  echo
  echo "Skills niveau projet  ($(pwd)/.claude/skills/) :"
  if [[ -d ./.claude/skills ]]; then
    for d in ./.claude/skills/*/; do
      [[ -f "$d/SKILL.md" ]] && printf '  %-22s %s\n' "$(basename "$d")" "$(du -sh "$d" | cut -f1)"
    done
  else
    echo "  (aucun)"
  fi
  echo
  echo "Plugins :"
  local plugins
  plugins=$(find "$CLAUDE_DIR/plugins" -maxdepth 4 -name 'plugin.json' 2>/dev/null)
  if [[ -n "$plugins" ]]; then
    echo "$plugins" | sed 's|^|  |'
  else
    echo "  (aucun)"
  fi
  echo
  echo "Hooks déclarés dans $CLAUDE_DIR/settings.json :"
  if [[ -f "$CLAUDE_DIR/settings.json" ]]; then
    grep -oE '"(SessionStart|UserPromptSubmit|PreToolUse|PostToolUse|Stop|SessionEnd|Setup)"' \
      "$CLAUDE_DIR/settings.json" 2>/dev/null | sort -u | sed 's|^|  |' || echo "  (aucun)"
    echo
    echo "Variables d'environnement notables :"
    grep -oE '"CLAUDE_(CODE|MEM)_[A-Z_]+"\s*:\s*"[^"]*"' "$CLAUDE_DIR/settings.json" 2>/dev/null \
      | sed 's|^|  |' || echo "  (aucune)"
  else
    echo "  (pas de settings.json)"
  fi
  echo
  echo "Sauvegardes disponibles :"
  ls -d "$HOME"/.claude-backup-* 2>/dev/null | sed 's|^|  |' || echo "  (aucune)"
}

# --------------------------------------------------------------------------
usage() {
  cat <<TXT
Usage : ./install.sh <commande>

  backup           Sauvegarder ~/.claude (fais-le en premier)
  find-skills      1/5  niveau utilisateur
  stop-slop-fr     2/5  niveau utilisateur
  ui-ux-pro-max    3/5  niveau projet (ajoute --global pour utilisateur)
  task-observer    4/5  niveau utilisateur + verrou CLAUDE.md
  claude-mem       5/5  affiche la procédure, n'installe rien
  all              backup puis 1 à 4, claude-mem exclu
  verify           Lister skills, plugins, hooks et chemins

Chaque action demande confirmation avant de s'exécuter.
TXT
}

case "${1:-}" in
  backup)        do_backup ;;
  find-skills)   do_find_skills ;;
  stop-slop-fr)  do_stop_slop_fr ;;
  ui-ux-pro-max) do_ui_ux_pro_max "${2:-}" ;;
  task-observer) do_task_observer ;;
  claude-mem)    do_claude_mem ;;
  verify)        do_verify ;;
  all)
    do_backup
    do_find_skills
    do_stop_slop_fr
    do_ui_ux_pro_max "${2:-}"
    do_task_observer
    echo; do_claude_mem
    echo; do_verify
    ;;
  *) usage ;;
esac
