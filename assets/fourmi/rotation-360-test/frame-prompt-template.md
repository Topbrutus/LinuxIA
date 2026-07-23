# Prompt canonique — une frame à la fois

Utiliser **la même image maîtresse validée** comme référence pour chaque génération.

Remplacer uniquement `{{ANGLE}}` et `{{FILENAME}}`.

```text
À partir de l’image de référence, recrée exactement le même personnage fourminoïde debout sur deux jambes, sans changer son design, sa posture, sa taille, son centre, sa palette ni sa transparence.

Fais uniquement tourner le personnage de {{ANGLE}} degrés autour de son axe vertical. Caméra fixe, légère profondeur constante, aucune déformation, aucun mouvement des bras, jambes ou antennes.

Vrai pixel art net, gros pixels carrés, maximum 8 couleurs fixes, aucun flou, aucun anticrénelage, aucun halo, fond entièrement transparent.

Une seule image carrée. Nom attendu : {{FILENAME}}.
```

## Exemples

```text
{{ANGLE}} = 0
{{FILENAME}} = frame-000-v1.png
```

```text
{{ANGLE}} = 10
{{FILENAME}} = frame-010-v1.png
```

## Règle

Après validation de la première image, toutes les suivantes doivent utiliser la même référence maîtresse. Une frame refusée n’est pas ajoutée au jeu canonique.
