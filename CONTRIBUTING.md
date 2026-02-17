# Contribuer à LinuxIA

Merci ❤️

## Comment aider rapidement
- Prends une issue `good first issue` / `help wanted`
- Propose une PR petite, "preuve-first"
- Ajoute des logs/commandes reproductibles

## Règles repo (importantes)
- Pas de scripts interactifs dans les instructions (on donne des commandes à exécuter)
- Toujours fournir une preuve: `git status`, logs, sortie de commande
- Ne jamais casser la compat: ajouts incrémentaux

## Dev quickstart
```bash
cd /opt/linuxia
bash -n scripts/*.sh
bash scripts/verify-platform.sh
```
