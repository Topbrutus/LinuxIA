# Session — Diagnostic Samba Disk Issue
Date: 2026-03-12
Machine cible: VM100 (vm100-factory)
Session ID: 20260312_samba-disk-diagnostic

## But de la session
Diagnostiquer une panne de disque dur Samba suite à une probable erreur lors d'un agrandissement de partition et déplacement de blocs. Identifier la nature exacte du problème et fournir un plan de récupération.

## Périmètre
- Analyse de la configuration actuelle des disques (sdb, sdc)
- Vérification de l'intégrité des partitions NTFS
- Vérification de la configuration Samba
- Comparaison avec l'état de checkpoint A (2026-02-08)
- Analyse des logs système pour indices

## Hypothèses initiales
1. L'utilisateur a tenté d'agrandir une partition
2. Un bloc a potentiellement été déplacé incorrectement
3. Le système fonctionnait correctement le 2026-02-08 (checkpoint A validé)
4. Les disques concernés: DATA_1TB_A (/dev/sdb) et/ou DATA_1TB_B (/dev/sdc)

## Contraintes
- Mode lecture seule (diagnostic uniquement, pas de réparation sans approbation)
- Aucune modification de données sans backup préalable
- Respecter les règles anti-fausse preuve (VM100 only)
- Pas d'accès root depuis cette session GitHub Actions

## Décisions
- [2026-03-12 00:55 UTC] Créer script diagnostic complet
- [2026-03-12 00:55 UTC] Analyser les logs système récents
- [2026-03-12 00:55 UTC] Vérifier l'état des partitions vs snapshot précédent
