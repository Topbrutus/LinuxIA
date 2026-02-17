# Security Policy

## 🛡️ Scope

LinuxIA est un projet de recherche en sécurité système. Nous prenons la sécurité au sérieux, mais **ce n'est pas un produit production-ready**.

## 🔐 Reporting a vulnerability

**Si tu trouves une vulnérabilité critique** (RCE, escalade de privilèges, fuite de secrets):

1. **N'ouvre PAS d'issue publique**
2. Contacte [@Topbrutus](https://github.com/Topbrutus) en privé via:
   - GitHub Security Advisory (bouton "Report a vulnerability")
   - Email (si disponible sur le profil)
3. Inclus:
   - Description détaillée (étapes de reproduction)
   - Impact potentiel (CVSS si applicable)
   - Suggestion de correctif (si tu en as une)

## ⏱️ Réponse

- **Accusé réception:** < 72h
- **Fix + disclosure coordonnée:** selon gravité (7-90 jours)

## 📦 Versions supportées

Seule la branche `main` est activement maintenue. Les branches expérimentales (`phase4-observability`, etc.) ne bénéficient d'aucune garantie de sécurité.

## 🚨 Exceptions

**Vulns acceptées (by design):**
- Accès SSH non restreint (c'est un lab de recherche)
- Stockage non-chiffré dans `data/` (documenté dans README)
- Absence de rate-limiting sur les agents LLM (WIP)

Si tu as un doute → demande avant de signaler !

---

**Merci de contribuer à la sécurité de LinuxIA !** 🙏
