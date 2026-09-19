# Mes skills

Une skill est du contexte chargé à la demande. Elle coûte ~100 tokens en permanence
(sa description, lue à chaque session pour savoir si elle s'applique) et le poids de
son corps quand elle se déclenche.

## La règle

**N'écris une skill que pour ce que l'agent ne peut pas deviner.**

Test à faire avant d'écrire : pose la question à Claude sans la skill. S'il répond
correctement, la skill est du gaspillage.

| Mauvaise skill | Bonne skill |
|---|---|
| « Patterns React » | « Dans ce repo, tout appel API passe par `lib/client.ts`, jamais `fetch` direct » |
| « Bonnes pratiques SQL » | « Nos migrations sont réversibles, testées par `make db-test`, jamais de `DROP` sans ticket » |
| « Comment écrire des tests » | « Les tests d'intégration ont besoin de `docker compose up -d pg` d'abord, sinon ils échouent en silence » |

La colonne de gauche est déjà dans le modèle. La droite ne peut venir que de toi.

## Où va quoi

- **Spécifique à un repo** → `CLAUDE.md` à la racine du repo, pas une skill.
- **Transversal à tes projets** (ta façon de nommer, ton workflow git, ton style de
  revue) → une skill ici.
- **Une procédure que tu relances souvent** (déployer, publier, auditer) → une skill ici.

## Format

```
skills/<nom-en-kebab-case>/SKILL.md
```

```markdown
---
name: nom-en-kebab-case
description: Quand déclencher cette skill. Écrit pour être lu par l'agent qui décide
  s'il la charge — sois concret sur les cas d'usage, cite les mots-clés que tu emploies.
---

# Titre

## Quand l'utiliser
...

## Procédure
1. ...
2. ...

## Pièges
- ...
```

La `description` est la seule partie payée en permanence. C'est elle qui détermine si
la skill se déclenche au bon moment : soigne-la plus que le corps.

## Activer

`./install.sh` à la racine du dépôt lie chaque dossier dans `~/.claude/skills/`.
C'est un lien symbolique : éditer le fichier ici suffit, pas besoin de réinstaller.
