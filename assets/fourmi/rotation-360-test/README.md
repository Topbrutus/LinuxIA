# Test canonique — images de la fourmi 360°

Ce dossier conserve le jeu d’images de référence de la fourmi LinuxIA.

## Objectif

Générer **une image à la fois**, toujours à partir de la même image maîtresse, avec un angle différent de **10°** :

`000°, 010°, 020° … 350°`

Les images validées ici deviennent les références permanentes. Elles ne doivent jamais être remplacées silencieusement.

## Règles canoniques

- même personnage;
- même posture;
- même taille;
- même centre de rotation;
- même palette;
- même transparence;
- seul l’angle change;
- chaque image suivante utilise l’image maîtresse validée comme référence;
- toute correction crée une nouvelle version au lieu d’écraser l’ancienne.

## Nommage

```text
frame-000-v1.png
frame-010-v1.png
frame-020-v1.png
...
frame-350-v1.png
```

Une correction devient par exemple :

```text
frame-120-v2.png
```

## Structure prévue

```text
rotation-360-test/
├── README.md
├── frame-prompt-template.md
├── manifest.json
├── reference/
│   └── ant-master-v1.png
└── frames/
    ├── frame-000-v1.png
    ├── frame-010-v1.png
    └── ...
```

## Processus

1. Créer et valider `ant-master-v1.png`.
2. Générer `frame-000-v1.png`.
3. Valider la transparence, la taille, la posture et la palette.
4. Réutiliser la même référence pour générer l’angle suivant.
5. Vérifier chaque image avant de poursuivre.
6. Assembler les 36 images seulement après validation complète.

## Statut initial

- Dossier canonique : créé.
- Image maîtresse : en attente.
- Frames validées : 0 / 36.
- Assemblage 6 × 6 : en attente.

Signé : **Rob**
