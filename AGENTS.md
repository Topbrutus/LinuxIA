# LINUXIA — CONTRAT PERMANENT CODEx (Agents + Macros + PandaMiner)
Version: 1.0
Langue: Français uniquement.

Codex lit ce fichier avant toute action. S’il y a conflit, ce contrat prime. :contentReference[oaicite:1]{index=1}

## 0) Objectif du système (effet “magique” = discipline)
Créer une orchestration reproductible où tout comportement “intelligent” est une MACRO explicitée (entrée → exécution → sortie) + preuve, jamais de magie.

## 1) Règles non négociables (hard stop)
- Aucune action sans: TASK + CONTEXT + CONSTRAINTS + DONE_CRITERIA.
- Aucune sortie sans: RESULT + EVIDENCE + RISKS + NEXT.
- Aucune preuve = étape NON faite (même si “ça semble OK”).
- 1 problème à la fois. 1 tâche RUNNING maximum au début.
- Interdit: secrets dans le repo, actions destructrices sans double validation interne, changements non versionnés.
- Si 2 incertitudes critiques OU signe sécurité suspect: STOP + retour au dernier point stable.

## 2) Cibles et responsabilités (pas de mélange)
Chaque action doit mentionner: MACHINE_CIBLE + TERMINAL_CIBLE + FICHIERS_TOUCHÉS.
- Proxmox: hyperviseur/supervision
- VM100: pivot humain ↔ orchestrateur ↔ stockage (source d’exécution principale)
- VM101: analyse/divergence/critique
- VM102: outils/tests/exécution contrôlée
- VM103: charge lourde locale optionnelle (fallback)
- PandaMiner (alias PinderMiner): worker GPU jobs (exécution lourde, quotas stricts)

## 3) Contrat “Macros partout”
Toute décision doit être formulée comme une macro versionnée.
- Une macro = un fichier dans `macros/`
- Chaque macro doit contenir: VERSION, INPUT_SCHEMA, OUTPUT_SCHEMA, ALLOWLIST, RISKS, EVIDENCE_REQUIRED
Pipeline obligatoire: PLAN → EXECUTE → VERIFY → CRITIQUE → LOG_EVENT

## 4) Politique d’exécution (safe-by-default)
- Mode par défaut: DRY-RUN (plan + commandes proposées).
- EXECUTE interdit si PLAN ou DONE_CRITERIA manquent.
- VERIFY interdit si MACHINE_CIBLE/TERMINAL_CIBLE non explicités.
- Avant toute modif config: backup + diff. Après: test minimal + preuve.

## 5) Artefacts de session (toujours)
À chaque nouvelle session, créer `session/<YYYYMMDD>_<slug>/` avec:
- SESSION.md (append-only: but, périmètre, hypothèses, décisions)
- TODO.md (liste ordonnée)
- RISKS.md (risques + mitigations)
- ROLLBACK.md (retour arrière concret)
- STATUS.md (tâches + états)
- logs/session.jsonl (append-only)

## 6) Logs et preuves
- Logs JSONL append-only, horodatage ISO, chaque événement signé par: SESSION_ID, TASK_ID.
- Preuves acceptées: sortie de commande, fichier, checksum, diff, log, capture.
- Sans preuve: marquer SKIPPED/FAILED.

## 7) Versioning (Git)
- `macros/`, `configs/`, `scripts/` versionnés.
- 1 changement = 1 commit (fix/config/feat/docs).
- Tags aux checkpoints stables.

## 8) Références contractuelles
- Les 200 règles complètes sont dans `macros/00_contracts.md` (source de vérité).
- Les gabarits sont dans `templates/`:
  - templates/TASK.md
  - templates/RESULT.md

## 9) Format d’échange obligatoire (entrée/sortie)
### Entrée
TASK:
CONTEXT:
CONSTRAINTS:
DONE_CRITERIA:

### Sortie
RESULT:
EVIDENCE:
RISKS:
NEXT:

## 10) Règle “Plan long”
Si la tâche dépasse ~10 minutes, implique plusieurs fichiers ou plusieurs étapes: produire un plan écrit dans `PLANS/<TASK_ID>.md` avant EXECUTE. :contentReference[oaicite:2]{index=2}
