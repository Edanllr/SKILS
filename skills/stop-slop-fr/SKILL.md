---
name: stop-slop-fr
description: >
  Supprime les marqueurs d'écriture IA dans un texte en français. À utiliser
  pour rédiger, réécrire ou relire tout contenu francophone : post LinkedIn,
  page de vente, email de prospection, script vidéo, dossier scolaire, note
  de synthèse. Se déclenche aussi sur "relis ce texte", "ça fait IA",
  "réécris ça", "rends ça plus naturel".
metadata:
  langue: français
  base: stop-slop de Hardik Pandya (MIT) — https://github.com/hardikpandya/stop-slop
  adaptation: français, avec couche anti-ton-motivationnel
---

# Stop Slop FR

Un texte écrit par une IA se repère en français à des marqueurs différents de
l'anglais. Traduire les règles anglaises ne suffit pas : « delve » n'existe
pas en français, mais « il convient de souligner » sévit partout.

Ce skill supprime ces marqueurs. Il s'applique à la prose destinée à un
lecteur humain, pas au code ni à la documentation technique.

## Les 6 interdictions dures

Ces six règles ne souffrent aucune exception. Si une seule apparaît dans le
texte final, le travail n'est pas fini.

### 1. Tiret cadratin et demi-cadratin

Le caractère `—` (U+2014) et le caractère `–` (U+2013) sont bannis du corps
du texte. Ils sont le marqueur IA le plus visible en français, où la
typographie courante utilise la virgule, le deux-points ou le point.

| À bannir | Remplacer par |
|---|---|
| `Le prix — 49 euros — reste bas.` | `Le prix, 49 euros, reste bas.` |
| `Une seule chose compte — la marge.` | `Une seule chose compte : la marge.` |
| `Il a refusé — deux fois.` | `Il a refusé deux fois.` |

Le tiret court `-` reste autorisé dans les mots composés (`week-end`,
`chiffre-clé`) et dans les listes à puces.

### 2. « De plus » et la famille des connecteurs de remplissage

Un connecteur en tête de phrase signale presque toujours que la phrase
précédente n'a pas fini son travail. Supprime le connecteur, garde l'idée.

À bannir en tête de phrase : *De plus, En outre, Par ailleurs, En effet,
Ainsi, De surcroît, Qui plus est, À noter que, Notons que, Précisons que.*

| À bannir | Remplacer par |
|---|---|
| `De plus, le coût logistique augmente.` | `Le coût logistique augmente aussi.` |
| `Par ailleurs, il faut relancer les prospects.` | `Il reste 40 prospects à relancer.` |
| `En effet, la marge est faible.` | `La marge tombe à 8 %.` |

*Mais*, *donc* et *pourtant* restent autorisés : ils portent une vraie
relation logique.

### 3. « Il convient de souligner » et les formules d'annonce

Annoncer qu'une chose est importante coûte une phrase et ne prouve rien.
Dis la chose.

À bannir : *Il convient de souligner / de noter / de préciser / de rappeler,
Il est important de noter, Il est essentiel de comprendre, Force est de
constater, Notons enfin, On ne peut que constater, Il va sans dire que.*

| À bannir | Remplacer par |
|---|---|
| `Il convient de souligner que la trésorerie est tendue.` | `La trésorerie couvre 3 semaines.` |
| `Il est important de noter que le délai est court.` | `Tu as jusqu'au 12.` |

### 4. « Non seulement… mais aussi » et les fausses oppositions

Ces structures fabriquent du suspense là où il n'y en a pas. Énonce
directement la partie affirmative.

À bannir : *non seulement X mais aussi Y, il ne s'agit pas de X mais de Y,
la question n'est pas X mais Y, loin d'être X, c'est Y, ce n'est pas X, c'est
Y, tant X que Y, que ce soit X ou Y, X n'est pas le problème, Y l'est.*

| À bannir | Remplacer par |
|---|---|
| `Non seulement il vend, mais il fidélise aussi.` | `Il vend et il fidélise.` |
| `Ce n'est pas un coût, c'est un investissement.` | `Ça rapporte 3 euros par euro dépensé.` |
| `La question n'est pas le prix, c'est la valeur.` | `Le prix passe si la valeur est démontrée.` |

### 5. Ton conférence motivationnelle

Le registre le plus contaminé en français, parce que c'est celui du contenu
business sur les réseaux. Il se reconnaît à cinq signes : l'impératif
vibrant, la phrase nominale courte en cascade, la maxime universelle, la
question rhétorique suivie de sa réponse, et l'emoji de ponctuation.

À bannir :

- `Le succès n'est pas un accident.`
- `Chaque échec est une leçon.`
- `Sors de ta zone de confort.`
- `La discipline bat le talent.`
- `Tout commence par une décision.`
- `Et ça change tout.`
- `Résultat ? 40 % de plus.`
- `Pourquoi ? Parce que personne ne le fait.`
- `Le secret ? La régularité.`
- Titres et puces ouverts par 🚀 ✨ 💡 🔥 ou ➡️

Test opérationnel : si la phrase peut être imprimée sur une affiche sans rien
perdre, elle ne dit rien sur ton sujet. Coupe-la.

| À bannir | Remplacer par |
|---|---|
| `La régularité, c'est la clé. Chaque jour compte.` | `J'ai publié 5 jours sur 7 pendant 4 mois.` |
| `Résultat ? Une croissance explosive.` | `Le chiffre d'affaires est passé de 800 à 2 400 euros par mois.` |

### 6. Phrases creuses

Une phrase creuse annonce une conclusion sans la contenir. Elle survit à la
suppression de son sujet, ce qui prouve qu'elle n'en a pas.

À bannir : *Les enjeux sont considérables. Les implications sont profondes.
Les raisons sont structurelles. Cela change la donne. C'est un véritable
atout. Une opportunité à saisir. Un incontournable du secteur. Dans un monde
où tout va plus vite. À l'ère du numérique. Aujourd'hui plus que jamais.*

| À bannir | Remplacer par |
|---|---|
| `Les enjeux sont considérables.` | `Une erreur ici coûte 2 000 euros de stock mort.` |
| `C'est un véritable atout pour l'entreprise.` | `Ça fait gagner 4 heures par semaine au commercial.` |

## Règles de fond

7. **Voix active, sujet humain.** Chaque phrase a quelqu'un qui fait quelque
   chose. Bannis le passif (`il a été décidé`, `il est recommandé de`) et le
   `on` impersonnel quand un acteur existe. Voir
   [references/structures.md](references/structures.md).

8. **Pas de fausse agentivité.** Les chiffres ne « parlent » pas, le marché
   ne « récompense » pas, la donnée ne « nous dit » rien. Une personne lit,
   décide, achète. Nomme-la.

9. **Supprime les adverbes en -ment.** *Réellement, véritablement, notamment,
   particulièrement, littéralement, simplement, clairement, efficacement,
   rapidement.* Si l'adverbe porte l'information, remplace-le par un chiffre.

10. **Supprime les périphrases molles.** `permet de`, `se doit de`, `a pour
    objectif de`, `la mise en place de`, `la réalisation de`. Écris le verbe :
    `la mise en place d'un CRM` devient `installer un CRM`.

11. **Sois spécifique.** Un nombre, une date, un nom propre, un montant. Tout
    superlatif sans chiffre est une phrase creuse déguisée.

12. **Varie le rythme.** Deux éléments valent mieux que trois. La triade
    (`rigueur, méthode et discipline`) est un tic IA en français. Alterne les
    longueurs de phrase.

13. **Typographie française.** Guillemets `« »` et non `""`. Espace insécable
    avant `: ; ? !`. Pas de majuscule décorative en milieu de phrase.

## Contrôle avant livraison

Passe cette liste dans l'ordre. Chaque ligne se vérifie par une recherche
littérale dans le texte.

- [ ] Recherche `—` et `–` : zéro occurrence
- [ ] Recherche `De plus`, `Par ailleurs`, `En outre`, `En effet` : zéro en tête de phrase
- [ ] Recherche `il convient`, `il est important de noter`, `force est de` : zéro
- [ ] Recherche `non seulement`, `il ne s'agit pas`, `ce n'est pas` suivi de `c'est` : zéro
- [ ] Recherche `ment ` (adverbes) : justifier chaque survivant
- [ ] Recherche `permet de`, `se doit de`, `la mise en place` : zéro
- [ ] Recherche `?` suivi d'une réponse dans la même ligne : zéro
- [ ] Recherche emoji : zéro hors citation
- [ ] Chaque paragraphe contient au moins un élément vérifiable (chiffre, date, nom)
- [ ] Aucune phrase ne survit au test de l'affiche
- [ ] Trois phrases consécutives de même longueur : en couper une
- [ ] Guillemets `« »`, espaces insécables en place

## Notation

Note de 1 à 10 sur chaque axe. En dessous de 35/50, réécris.

| Axe | Question |
|---|---|
| Franchise | Le texte affirme ou il annonce qu'il va affirmer ? |
| Rythme | Varié ou métronomique ? |
| Confiance | Traite le lecteur en adulte ? |
| Concret | Combien de faits vérifiables par paragraphe ? |
| Densité | Que reste-t-il si on coupe 20 % ? |

## Références

- [references/expressions.md](references/expressions.md) : la liste complète des expressions à supprimer
- [references/structures.md](references/structures.md) : les structures de phrase à casser
- [references/exemples.md](references/exemples.md) : transformations avant/après

## Licence et attribution

Adaptation française de [stop-slop](https://github.com/hardikpandya/stop-slop)
par Hardik Pandya, sous licence MIT. Le texte original est en anglais ; cette
version reprend sa structure et remplace l'intégralité des marqueurs
linguistiques par leurs équivalents français, et ajoute la couche
anti-ton-motivationnel absente de l'original. Licence MIT conservée, voir
[LICENSE](LICENSE).
