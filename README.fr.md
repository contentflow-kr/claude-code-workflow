# claude-code-workflow

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [中文](README.zh.md) | **Français**

> Mémoire de session, apprentissage des erreurs, structuration de projet et intégration Git pour Claude Code.

---

## Le problème

À chaque `/clear` ou nouveau démarrage de session Claude Code, **tout le contexte est perdu**. Claude oublie ce sur quoi vous travailliez, les erreurs commises, et les règles de votre projet. Gérer plusieurs projets aggrave encore la situation.

## La solution

**5 slash commands** qui donnent à Claude une mémoire persistante, un apprentissage des erreurs et une navigation multi-projets :

```
/init-worklog      →  Mettre en place l'infrastructure d'enregistrement (une fois par projet)
/init-project-v1   →  Structuration rapide de projet avec des modèles vierges
/init-project-v2   →  Configuration guidée avec une documentation réelle
/session-start     →  Restaurer le contexte précédent
/session-end       →  Tout sauvegarder + journal de travail + commit Git
```

---

## Démarrage rapide

### Installation

```bash
git clone https://github.com/contentflow-kr/claude-code-workflow.git
cd claude-code-workflow
chmod +x install.sh
./install.sh
```

L'installateur va :
1. Copier 5 slash commands dans `~/.claude/commands/`
2. Créer `~/work-tree.md` (carte de navigation des projets)
3. Créer optionnellement `~/work_logs/` (tableau de bord global)
4. Configurer optionnellement la synchronisation Obsidian

### Première utilisation

```
cd votre-projet
/init-worklog          # Configurer work_logs/ (30 secondes)
# travailler normalement...
/session-end           # Tout enregistrer
# session suivante :
/session-start         # Reprendre là où vous vous étiez arrêté
```

### Pour les nouveaux projets

```
cd dossier-vide
/init-project-v1       # Structuration rapide (5 min)
# ou
/init-project-v2       # Configuration détaillée avec vraie doc (30 min)
```

---

## Fonctionnement

### Le cycle de vie d'une session

```
┌─────────────────────────────────────────────────┐
│                 /session-start v3                │
│                                                  │
│  0. Load work-tree.md  → Project navigation map  │
│  1. Load remind.md     → Project rules           │
│  2. Load error-rules.md → Error prevention       │
│  3. Load chatlog.md    → Unfinished tasks        │
│  4. Load CHANGELOG.md  → Recent changes          │
│  5. Load ~/work_logs/error-rules.md              │
│     → Global shared rules (cross-project)        │
│                                                  │
│  Output: Context summary + suggested next task   │
└──────────────────────┬──────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│              Normal Work Session                 │
│                                                  │
│  - Write code, fix bugs, add features            │
│  - Errors tracked as ERR-### entries             │
│  - Rules derived as RUL-### entries              │
└──────────────────────┬──────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│                /session-end v4                   │
│                                                  │
│  1. Analyze session → extract tasks, decisions   │
│  2. Append session block to chatlog.md           │
│  3. Append 1-line to global dashboard            │
│  4. Log errors + derive prevention rules         │
│  5. Update remind.md + CHANGELOG.md              │
│  6. Create dated worklog file                    │
│  7. [Optional] Sync to Obsidian + CLI            │
│  8. Git commit with auto-generated message       │
│  9. Output: final report + next session tasks    │
└─────────────────────────────────────────────────┘
```

---

## 5 commandes

### `/init-worklog` (v2)

Ajoute le système d'enregistrement à n'importe quel projet existant.

**Crée :**

| Fichier | Objectif |
|---------|----------|
| `work_logs/chatlog.md` | Mémoire de session |
| `work_logs/remind.md` | Règles du projet |
| `work_logs/error_logs.md` | Enregistrements d'erreurs (ERR-###) |
| `work_logs/error-rules.md` | Règles de prévention (RUL-###) |
| `work_logs/CHANGELOG.md` | Historique des modifications |

**Ajout v2** : Enregistre automatiquement le projet dans `work-tree.md` pour la navigation multi-projets.

### `/init-project-v1`

Structuration rapide de projet — pose 4 questions, crée des modèles de documentation vierges.

**Crée** : `CLAUDE.md` + `docs/` (modèles vierges) + `work_logs/` + `.gitignore`

Idéal pour : hackathons, expérimentations, plans non finalisés.

### `/init-project-v2`

Configuration détaillée de projet — pose 3 séries de questions, rédige une vraie documentation.

**Crée** : `CLAUDE.md` + `docs/` (contenu réel) + `work_logs/` + `.gitignore`

Idéal pour : projets sérieux, développement long terme, développement orienté documentation.

### `/session-start` (v3)

Restaure le contexte de la session précédente.

**Charge (dans l'ordre) :**
1. `work-tree.md` — Carte de navigation des projets
2. `remind.md` — Règles du projet
3. `error-rules.md` — Prévention des erreurs (projet + global)
4. `chatlog.md` — Sessions précédentes et tâches non terminées
5. `CHANGELOG.md` — Modifications récentes

**Mode global** : Lancez depuis `~/` pour analyser tous les projets et voir les tâches non terminées de l'ensemble de vos projets.

### `/session-end` (v4)

Enregistre la session en cours et prépare la suivante.

| Étape | Action |
|-------|--------|
| 1-2 | Analyser la session, extraire les tâches/décisions |
| 3 | Ajouter le bloc de session à chatlog.md |
| 3.5 | Ajouter 1 ligne au tableau de bord global |
| 3.7 | Enregistrer les erreurs (ERR-###) + dériver les règles (RUL-###) |
| 4-5 | Mettre à jour remind.md + CHANGELOG.md |
| 6 | Créer le journal de travail daté |
| 6.5 | [Optionnel] Synchronisation Obsidian CLI |
| 7 | Commit Git (avec confirmation de l'utilisateur) |
| 8 | Rapport final |

---

## Fonctionnalités clés

### Mémoire de session
Chaque session est enregistrée sous forme de bloc structuré dans `chatlog.md`. Le prochain `/session-start` reprend exactement là où vous vous étiez arrêté.

### Apprentissage des erreurs
Les erreurs sont suivies sous `ERR-###`, les règles de prévention dérivées sous `RUL-###`. Les règles du Projet A préviennent la même erreur dans le Projet B via le fichier global `~/work_logs/error-rules.md`.

### Navigation multi-projets
`work-tree.md` cartographie tous vos projets. `/init-worklog` enregistre automatiquement les nouveaux projets. Lancez `/session-start` depuis `~/` pour voir toutes les tâches non terminées en un coup d'œil.

### Journalisation à deux niveaux
- **Niveau projet** : Blocs de session détaillés dans `chatlog.md`
- **Niveau global** : Tableau de bord en une ligne dans `~/work_logs/chatlog.md`

### Intégration Git
Messages de commit générés automatiquement à partir des résumés de session. Les fichiers sensibles (.env, credentials) sont automatiquement exclus.

### Synchronisation Obsidian (optionnel)
Les journaux de travail sont automatiquement copiés dans votre vault Obsidian. Intégration CLI pour les Daily Notes et les comptages de tâches.

---

## Structure des fichiers

```
~/                                    # Global
├── work-tree.md                      # Project navigation map
├── work_logs/
│   ├── chatlog.md                    # All sessions dashboard
│   ├── error_logs.md                 # Cross-project errors
│   ├── error-rules.md               # Shared prevention rules
│   └── remind.md                     # Global rules
└── .claude/commands/                 # Skill files (5)

{project}/                            # Per project
├── work_logs/
│   ├── chatlog.md                    # Session records
│   ├── remind.md                     # Project rules
│   ├── error_logs.md                 # Errors (ERR-###)
│   ├── error-rules.md               # Rules (RUL-###)
│   ├── CHANGELOG.md                  # Changes
│   └── YYYY_MM_DD_*_worklog.md       # Dated worklogs
└── CLAUDE.md                         # Project context
```

---

## vs Claude Code `/memory`

| | `/memory` (intégré) | claude-code-workflow |
|---|:---:|:---:|
| **Historique de session** | Non | Oui |
| **Suivi des tâches non terminées** | Non | Oui |
| **Apprentissage des erreurs** | Non | Oui (ERR → RUL) |
| **Partage d'erreurs multi-projets** | Non | Oui |
| **Navigation multi-projets** | Non | Oui (work-tree.md) |
| **Structuration de projet** | Non | Oui (v1 + v2) |
| **Intégration commit Git** | Non | Oui |
| **Synchronisation Obsidian** | Non | Oui (optionnel) |

**Ils sont complémentaires.** Utilisez `/memory` pour les préférences statiques, et ce workflow pour le cycle de vie des sessions.

---

## Prérequis

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installé
- macOS ou Linux
- Git (pour l'intégration des commits)

## Licence

[CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/) — Libre d'utilisation et de modification, vente commerciale interdite.
