# CONTRAT GLOBAL — 200 RÈGLES (LinuxIA / Agents / Macros / PandaMiner)
Version: 1.0
Statut: Source de vérité (append-only)

## Définitions rapides
- “Macro” = entrée → exécution → sortie (zéro magie).
- “Preuve” = log/commande/diff/fichier/checksum/capture.
- “PandaMiner” = worker GPU (alias possible: PinderMiner).

---

1. Définir le but exact de la session en 1 phrase (livrable mesurable).
2. Écrire les contraintes non négociables (OS, réseau, sécurité, interdits, etc.).
3. Lister les machines cibles (Proxmox, VM100, VM101, VM102, VM103, PandaMiner).
4. Assigner une responsabilité par machine (aucun mélange flou).
5. Déclarer que tout “intelligent” = macro (entrée → exécution → sortie), jamais “magie”.
6. Fixer un format d’entrées standard : TASK, CONTEXT, CONSTRAINTS, DONE_CRITERIA.
7. Fixer un format de sortie standard : RESULT, EVIDENCE, RISKS, NEXT.
8. Refuser toute sortie sans preuve (commande, log, fichier, checksum, diff).
9. Refuser toute action qui n’améliore pas autonomie/clarté/reproductibilité.
10. Choisir un point stable de départ (état actuel documenté).
11. Créer un dossier “session” (date + objectif) pour centraliser les artefacts.
12. Créer un fichier SESSION.md (but, périmètre, hypothèses, décisions).
13. Créer un fichier TODO.md (liste ordonnée des actions à faire).
14. Créer un fichier RISKS.md (risques + mitigations).
15. Créer un fichier ROLLBACK.md (comment revenir en arrière).
16. Définir une règle d’arrêt : si 2 incertitudes critiques → retour au dernier point stable.
17. Définir une règle “1 problème à la fois” : pas de multi-chantiers.
18. Définir une convention de nommage (VM, services, dossiers, ports).
19. Définir une convention de logs (JSONL, horodatage ISO, append-only).
20. Valider l’accès (SSH/console) à chaque machine cible.
21. Vérifier l’identité de chaque machine (hostname, IP, rôle).
22. Vérifier l’espace disque disponible sur chaque machine.
23. Vérifier l’horloge et le timezone (cohérence des logs).
24. Vérifier que le stockage externe/données est monté là où prévu.
25. Vérifier qu’aucun disque “data” n’est monté en double simultané (risque corruption).
26. Documenter le schéma de stockage (disques, partitions, points de montage).
27. Documenter le schéma réseau (LAN, bridges, isolation interne).
28. Vérifier les règles firewall minimales (rien d’ouvert sans raison).
29. Vérifier que les identifiants/clefs SSH sont en place.
30. Si mot de passe SSH actif, planifier sa réduction (durcissement progressif).
31. Appliquer un baseline SSH (clé publique, restrictions, logs).
32. Vérifier les logs SSH contre bruteforce (scan rapide).
33. Si indicateurs d’intrusion, stopper et passer en mode IR (quarantaine).
34. Vérifier cron/systemd pour persistance suspecte.
35. Vérifier binaires/liaisons système anormales.
36. Confirmer que l’hôte Proxmox est sain avant d’orchestrer quoi que ce soit.
37. Confirmer que VM100 (Factory) est le pivot humain ↔ agents ↔ stockage.
38. Confirmer que VM101/VM102 sont dédiées aux rôles (analyse / outils).
39. Définir “Chef” (source de vérité finale) et “Recherchistes” (divergence).
40. Définir “Orchestrateur” (coordination + logs) comme composant central.
41. Définir “Tool” (exécution contrôlée) comme agent à risque → isolement strict.
42. Définir “Macro-Runner” (exécuteur de macros) comme service séparé.
43. Définir “PandaMiner-Worker” comme agent de force (macros lourdes GPU).
44. Définir les limites de PandaMiner (ports, accès, quotas, jobs max).
45. Définir les macros disponibles (résumé, extraction, plan, critique, test, RPA, build).
46. Définir les tools autorisés (shell, git, tests, parsing).
47. Définir une liste de prompts/consignes macro versionnée (pas de freestyle).
48. Ajouter un champ VERSION à chaque macro.
49. Ajouter un champ INPUT_SCHEMA à chaque macro.
50. Ajouter un champ OUTPUT_SCHEMA à chaque macro.
51. Créer un répertoire macros/ (une macro = un fichier).
52. Créer macros/00_contracts.md (règles globales).
53. Définir macro PLAN: produit étapes + critères de validation.
54. Définir macro EXECUTE: exécute une étape, sort preuves.
55. Définir macro VERIFY: confirme état réel, sort commandes/outputs.
56. Définir macro CRITIQUE: cherche failles, incohérences, risques.
57. Définir macro SUMMARIZE: résume pour humain (court, actionnable).
58. Définir macro LOG_EVENT: écrit une ligne JSONL (append-only).
59. Définir macro ROLLBACK_STEP: décrit retour arrière concret.
60. Définir macro STOP_RULE: déclenche arrêt si conditions dangereuses.
61. Créer un pipeline : PLAN → EXECUTE → VERIFY → CRITIQUE → LOG.
62. Interdire EXECUTE si PLAN ou DONE_CRITERIA manquent.
63. Interdire VERIFY si la machine/terminal cible n’est pas explicitée.
64. Exiger “Machine cible” et “Terminal cible” sur chaque action.
65. Exiger “Fichiers touchés” listés avant modification.
66. Exiger “Backup/diff” avant modification de config.
67. Exiger “Test minimal” après modification.
68. Exiger “Preuve” (sortie de commande) pour valider.
69. Si preuve absente, marquer l’étape “non réalisée”.
70. Centraliser tous logs dans logs/session.jsonl.
71. Enregistrer toutes décisions dans SESSION.md (append-only).
72. Utiliser une numérotation d’étapes persistante (pas de renumérotation).
73. Fixer un identifiant unique de session (timestamp + slug).
74. Fixer un identifiant unique par tâche (UUID ou compteur).
75. Définir l’état d’une tâche : NEW, RUNNING, DONE, FAILED, SKIPPED.
76. Créer un tableau de bord minimal STATUS.md (tâches + états).
77. Règle: jamais plus de 1 tâche RUNNING au début.
78. Définir des checkpoints (A, B, C) où rollback est garanti.
79. Règle: rollback doit être testé une fois par checkpoint.
80. Politique “petites modifications” (changement minimal).
81. Politique “pas d’optimisation prématurée”.
82. Politique “pas d’ajout d’agents tant que base instable”.
83. Définir un répertoire de configs configs/ (copie contrôlée).
84. Définir un répertoire scripts/ (scripts idempotents).
85. Définir un répertoire reports/ (rapports lisibles humains).
86. Définir un répertoire evidence/ (captures, outputs, checksums).
87. Configurer git (repo local) pour versionner macros/, configs/, scripts/.
88. Stratégie de commit : 1 changement = 1 commit.
89. Convention message commit (fix/config/feat/docs).
90. Tag par checkpoint stable.
91. Liste services attendus VM100 (orchestrateur, macro-runner, mémoire).
92. Liste services attendus VM101 (agent divergence/analyse).
93. Liste services attendus VM102 (outils, tests, exécution contrôlée).
94. Liste optionnelle VM103 (charges lourdes locales).
95. Liste attendue PandaMiner (worker GPU, runtime conteneurs).
96. Valider CPU/RAM selon charge visée.
97. Fixer budget de parallélisme (ex: 2 agents max au début).
98. Fixer délais d’orchestration (cooldown par agent).
99. Fixer limite de taille des messages (contrôle du contexte).
100. Stratégie mémoire : logs JSONL + résumé périodique.
101. Installer/valider environnement orchestrateur (Python/Node) à l’emplacement choisi.
102. Vérifier existence /opt/orchestrator (ou équivalent).
103. Vérifier permissions (écriture logs, exécution scripts).
104. Préparer gestion de session si agents web (cookies/profils) si applicable.
105. Stocker secrets/cookies hors repo (permissions strictes).
106. Ajouter rotation simple des logs (taille ou date).
107. Test “ping” orchestrateur: écrire une ligne JSONL.
108. Test “agent loop” (1 message → 1 réponse → log).
109. Test “timeout” (si agent ne répond pas, fail propre).
110. Détection “réponse terminée” si agent web (fin génération/DOM).
111. Gestion erreurs “sélecteurs changeants” (fallback).
112. Gestion “re-login” (si session expire).
113. Limite “max retries” (pas de boucle infinie).
114. Backoff progressif en cas d’échec.
115. Mode dry-run (ne fait que planifier/log).
116. Mode observe (lit seulement, n’écrit rien).
117. Mode execute (fait les actions).
118. Manifest agents (nom, rôle, endpoints, limites).
119. Valider chaque agent a un rôle unique (pas de doublon).
120. Implémenter tour de parole (séquentiel au début).
121. Implémenter collecte (réponses agrégées par tâche).
122. Implémenter redistribution (Chef reçoit synthèse).
123. Implémenter critique croisée (agent B critique agent A).
124. Implémenter décision simple (Chef choisit meilleure option).
125. Implémenter vérification outillage (Tool exécute tests).
126. Écriture d’un rapport Markdown par tâche.
127. Signature de rapport (date, commit, host).
128. Stockage persistant logs/artefacts (disque externe si prévu).
129. Vérifier montages persistants après reboot.
130. Vérifier partages respectent modèle choisi (sécuritaire).
131. Déployer runtime de macros sur VM100 (service principal).
132. Déployer runtime de macros sur PandaMiner (worker GPU) mode “jobs”.
133. Protocole job : JOB_ID, MACRO_NAME, INPUT, DEADLINE, LIMITS.
134. Protocole result : JOB_ID, STATUS, OUTPUT, EVIDENCE, METRICS.
135. File de jobs (simple: dossier spool / queue légère).
136. Mécanisme ack/retry (idempotence).
137. Limite jobs simultanés côté PandaMiner.
138. Limite temps max par job (timeout dur).
139. Limite mémoire max par job (cgroup/containers).
140. Limite disque max par job (workspace nettoyé).
141. Workspace par job (répertoire isolé).
142. Net policy par job (internet fermé si non requis).
143. Artifact policy (où déposer outputs).
144. Evidence policy (logs + checksums).
145. Healthcheck PandaMiner (ping + capacité + file vide).
146. Fallback: PandaMiner down → mode réduit VM103/VM100.
147. Safe mode (exécution read-only).
148. Liste blanche actions autorisées (macro allowlist).
149. Interdire actions destructrices sans double validation interne.
150. Scan écarts config (diff vs baseline).
151. Si RPA: périmètre strict (UI stable, fenêtres, résolutions).
152. Si RPA: commencer par détection simple (pixel/image) avant OCR.
153. Si RPA: pauses et timeouts (anti boucle folle).
154. Si RPA: log chaque clic/étape (preuve).
155. Si RPA: kill switch (arrêt immédiat).
156. Vérifier architecture reste simple avant complexifier.
157. Geler la v1 (minimal viable orchestration).
158. Exécuter test complet v1 sur tâche jouet.
159. Capturer preuves (logs, rapport, outputs).
160. Corriger seulement ce qui casse, pas “ce qui pourrait être mieux”.
161. Prendre une tâche réelle (petite) du projet LinuxIA.
162. Écrire TASK en 3 lignes maximum.
163. Définir DONE_CRITERIA avec preuves exigées.
164. Lancer macro PLAN et vérifier cohérence.
165. Lancer macro CRITIQUE sur le plan (chercher trous).
166. Ajuster le plan (petit diff, versionné).
167. Lancer EXECUTE étape 1 (une seule action).
168. Lancer VERIFY étape 1 (preuve).
169. Log événement (JSONL).
170. Répéter EXECUTE→VERIFY→LOG pour étape 2.
171. Après 5 étapes, produire résumé stable (1 page max).
172. Comparer résumé vs but initial (écart?).
173. Si écart, stopper et re-planifier (retour au point stable).
174. Si OK, continuer jusqu’au DONE_CRITERIA.
175. Fin: critique globale (risques restants).
176. Rapport final Markdown (résultat + preuves + prochaines).
177. Section “ce qui a été changé” (liste fichiers/services).
178. Section “comment rollback” (instructions claires).
179. Tag checkpoint stable (git tag).
180. Sauvegarder SESSION.md, STATUS.md, logs/, reports/.
181. Vérifier qu’un humain peut reproduire sans orchestrateur (test mental).
182. Si non, ajouter doc manquante (actions concrètes seulement).
183. Fermer session avec “état final” (OK/KO + raison).
184. Écrire prochaine tâche prioritaire (une seule).
185. Règle: pas nouvelle techno avant 2 cycles stables.
186. Règle: pas plus d’agents tant que logs incomplets.
187. Règle: chaque incident sécurité déclenche IR immédiat.
188. Règle: chaque changement réseau est documenté.
189. Règle: chaque montage disque est documenté + vérifié.
190. Règle: aucun secret dans le repo.
191. Règle: aucune action sans terminal/machine explicitée.
192. Règle: aucune preuve = étape non faite.
193. Règle: si confusion, retour au dernier checkpoint stable.
194. Règle: orchestration simple avant sophistiquée.
195. Règle: pas de solution “magique” non comprise.
196. Règle: logs append-only, jamais réécrits.
197. Règle: chaque macro a version + tests.
198. Règle: chaque service a healthcheck.
199. L’objectif prime sur l’élégance.
200. Terminer en générant une checklist exécutable (3 à 10 items) pour la prochaine session.
