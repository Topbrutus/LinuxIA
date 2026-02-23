# MODE D'EMPLOI — LinuxIA README + Showcase (NEXT GPT / Copilot)

## Objectif
- README GitHub: header animé + texte + placeholders.
- Showcase: page HTML/CSS/JS pour vidéos + audio + photos empilées.
- Zéro secret en clair.

## Fichiers clés
- README: `README.md`
- Banner animé: `assets/readme/banner-linuxia.svg`
- Showcase: `showcase/index.html`, `showcase/style.css`, `showcase/app.js`
- Médias:
  - Photos: `assets/media/photos/LinuxIA_01.jpg ... LinuxIA_12.jpg`
  - Vidéos: `assets/media/videos/Trailer_01.mp4 ...`
  - Audio:  `assets/media/audio/Theme_01.mp3`

## Règles GitHub
- Dans README: images OK, SVG en `<img>` OK.
- Vidéo/audio intégrés dans README: pas fiable → on met des liens.
- La lecture "wow" (vidéo/audio/drag) se fait dans `showcase/`.

## Procédure ajout médias
1. Convertir images en JPG (ou PNG), idéal: 1920px de large.
2. Nommer: `LinuxIA_01.jpg` ... `LinuxIA_12.jpg`.
3. Dropper dans `assets/media/photos/`.
4. Vidéos: MP4 H.264, 1080p max si possible.
5. Audio: MP3.
6. Tester via serveur local.

## Test local
```bash
cd showcase
python3 -m http.server 8799
# http://127.0.0.1:8799
```

## Publication (option GitHub Pages)
- Activer GitHub Pages sur le repo.
- Dossier conseillé: `/showcase` (selon réglage Pages).
- Vérifier que les chemins relatifs vers `../assets/...` fonctionnent.

## Checklist finale
- README s'affiche (banner OK)
- Showcase: vidéos loop, audio loop, photos draggable OK
- Aucun secret commité
