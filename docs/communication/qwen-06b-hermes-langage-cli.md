# Qwen 0.6B — relais Hermès et commande `/langage`

Je veux utiliser **Qwen 0.6B**, le plus petit modèle, uniquement comme première couche de communication.

Son rôle serait très limité :

- recevoir la première phrase de l’utilisateur;
- répondre brièvement au besoin;
- transmettre directement la demande au **System Job**;
- le System Job envoie ensuite la demande à **Hermès**, qui fait le vrai travail de réflexion.

Qwen ne doit donc pas être le cerveau principal. Il sert surtout d’accueil léger et de relais.

Je veux aussi ajouter une commande personnalisée dans le CLI pour contrôler la longueur des réponses :

- `/langage court`
- `/langage normal`
- `/langage long`
- `/langage auto`

Le mode `/langage auto` laisse le système choisir automatiquement la longueur appropriée selon la situation.

L’objectif est d’avoir nos propres commandes CLI, simples et différentes de celles qu’on voit habituellement ailleurs.
