---
allowed-tools: [Read, Write, Bash, Glob, Edit, AskUserQuestion]
description: "Detailed project setup — guided questions + real docs content + work_logs"
---

# /init-project-v2 - Documentation-Driven Project Setup

## Purpose
Generate complete project structure with **real documentation content** (not blank templates).
Ask detailed questions, then write docs that serve as the Single Source of Truth for development.

> Difference from v1: v2 asks 3 rounds of questions and writes actual content in docs/.
> Claude reads these docs to understand the project and write code accordingly.

---

## Phase 0: Gather Project Info (Detailed)

### Round 1: Basic info

| Item | Example |
|------|---------|
| Project name (English) | FlowFace |
| One-line description | AI-powered facial expression analysis for emotion insights |
| Target users | Mobile app users interested in emotional wellness |
| Core problem to solve | People struggle to understand their own emotional patterns |

### Round 2: Technical details

| Item | Example |
|------|---------|
| Project type | fullstack / mvp-html / library / script |
| Frontend | React, Next.js, SvelteKit, etc. |
| Backend | FastAPI, Django, Express, etc. |
| Database | PostgreSQL, SQLite, MongoDB, etc. |
| Key integrations | OpenAI API, Stripe, Firebase, etc. |
| Deployment target | Docker, Vercel, AWS, local only |

### Round 3: Architecture & scope

| Item | Example |
|------|---------|
| Key features (3-5) | Emotion detection, pattern tracking, daily reports |
| API endpoints (main ones) | POST /analyze, GET /history, GET /report |
| Data models (main ones) | User, EmotionRecord, DailyReport |
| MVP scope | Just emotion detection + basic history |
| Phase 2+ ideas | Social features, therapist dashboard |

---

## Phase 1: Create CLAUDE.md (with real content)

Write a complete CLAUDE.md based on the gathered info.
Include architecture diagram, tech stack, file locations, conventions.
Keep under 200 lines.

---

## Phase 2: Create docs/ (with real content)

**Key principle**: Every doc file must have **actual content**, not "to be added" placeholders.

### Required docs (all project types)

```
docs/
├── 00_OVERVIEW/
│   ├── PROJECT_SUMMARY.md     # Vision, goals, target users, MVP scope
│   └── SYSTEM_ARCHITECTURE.md # Architecture diagram, service map, data flow
│
├── 01_DESIGN/
│   ├── UX_SPEC.md             # Screen list, user flows, interaction patterns
│   └── USER_FLOW_DIAGRAM.md   # Step-by-step user journey
│
├── 02_BACKEND/  (if applicable)
│   ├── API_SPEC.md            # Endpoints, request/response schemas
│   └── DB_SCHEMA.md           # Tables, relations, indexes
│
├── 03_FRONTEND/  (if applicable)
│   └── COMPONENT_SPEC.md      # Component tree, state management plan
│
├── 05_SECURITY/
│   └── SECURITY_RULES.md      # Auth flow, data protection, secrets handling
│
└── 09_TESTING/
    └── TEST_STRATEGY.md       # Testing approach, coverage goals
```

### Writing guidelines
- Write from the **gathered project info** — real architecture decisions, real API designs
- Use diagrams (ASCII art or Mermaid) where helpful
- Include concrete examples (sample API requests, data model fields)
- Mark uncertain items with `[TBD]` — but minimize these

---

## Phase 3: Create .gitignore

Type-specific .gitignore (Python, Node, etc.)

---

## Phase 4: Initialize work_logs

Run `/init-worklog` logic (v2 — includes work-tree.md registration).
Skip if work_logs/ already exists.

---

## Phase 5: Completion report

Output:
- List of all created files with line counts
- Summary: {N} files, {M} directories, {L} total lines of documentation
- Architecture overview (1-paragraph summary)
- Suggested first coding task based on the docs
- Remind user: "Docs are your SSOT. Update docs when architecture changes."

---

## Important Notes

1. **Never overwrite existing files**
2. **Docs must have real content** — no "to be added" placeholders (use [TBD] sparingly)
3. **CLAUDE.md under 200 lines**
4. **Documentation-Driven Development**: Write docs first → Claude reads docs → Claude writes code
5. **work_logs created via /init-worklog v2** — includes work-tree.md auto-registration
