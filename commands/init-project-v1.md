---
allowed-tools: [Read, Write, Bash, Glob, Edit, AskUserQuestion]
description: "Quick project scaffolding — blank templates + work_logs + CLAUDE.md"
---

# /init-project-v1 - Quick Project Scaffolding

## Purpose
Generate all project structure at once with blank template docs.
Fill in the content as you develop. Best for hackathons, experiments, or when plans aren't finalized.

> Difference from v2: v1 asks 4 questions + blank templates. v2 asks 3 rounds + writes actual content.

---

## Phase 0: Gather Project Info

Ask the user with AskUserQuestion:

### Question 1: Basic info
- **Project name**: e.g., "MyApp", "RecoverFlow"
- **One-line description**: e.g., "AI-powered emotion analysis platform"

### Question 2: Project type
- `fullstack` — Backend + Frontend (Django/FastAPI/Next.js etc.)
- `mvp-html` — Single HTML MVP (no server)
- `library` — Library/package
- `script` — Scripts/utilities

### Question 3: Tech stack
- Main language/frameworks (free input)
- e.g., "Python, FastAPI, PostgreSQL, React"

### Question 4: Project path
- Use current directory or specify a path

---

## Phase 1: Create CLAUDE.md

Project context file. Loaded automatically by Claude Code.
Keep under 200 lines (Anthropic recommendation).

```markdown
# {Project Name} - Project Context

## Overview
{One-line description}. {Tech stack summary}.

## Architecture
{Based on project type}

## Core Tech Stack
- **Language**: {language}
- **Framework**: {framework}
- **DB**: {database} (if applicable)

## Key File Locations
- `{path}` - {description}

## Conventions & Rules

### Security (absolute rules)
- No hardcoded secrets (use environment variables)
- Never commit .env files

### Development
- {Project-specific rules}

## Work Logs
- `work_logs/chatlog.md` - Session memory
- `work_logs/remind.md` - Project rules
- `work_logs/CHANGELOG.md` - Change history

## Current Status ({today's date})
- Project initialized
```

---

## Phase 2: Create docs/ (blank templates)

Adjust folder count based on project type.
Each file is a **blank template** — fill in content as you develop.

### fullstack (12+ folders)
```
docs/
├── 00_OVERVIEW/          → PROJECT_SUMMARY.md, SYSTEM_ARCHITECTURE.md
├── 01_DESIGN/            → UX_SPEC.md
├── 02_BACKEND/           → API_SPEC.md, DB_SCHEMA.md
├── 03_FRONTEND/          → COMPONENT_SPEC.md, STATE_MANAGEMENT.md
├── 04_INFRA/             → DOCKER_GUIDE.md, CI_CD.md
├── 05_SECURITY/          → SECURITY_RULES.md, AUTH_SPEC.md
├── 09_TESTING/           → TEST_STRATEGY.md
├── 11_DEV_RULES/         → CODE_STYLE_GUIDE.md
└── 99_ARCHIVE/           → (old docs)
```

### mvp-html / library / script (smaller)
```
docs/
├── 00_OVERVIEW/          → PROJECT_SUMMARY.md
├── 05_SECURITY/          → SECURITY_RULES.md
├── 09_TESTING/           → TEST_STRATEGY.md
└── 11_DEV_RULES/         → CODE_STYLE_GUIDE.md
```

### Template for each .md file
```markdown
# {Filename (without extension)}
> {Project Name} — {folder purpose}

## Overview
{To be filled during development}

---
*Last updated: {today's date}*
```

---

## Phase 3: Create .gitignore

Apply type-specific .gitignore template.

---

## Phase 4: Initialize work_logs

Run `/init-worklog` logic (v2 — includes work-tree.md registration).
Skip if work_logs/ already exists.

Creates:
1. `chatlog.md` — Session memory
2. `remind.md` — Project rules
3. `CHANGELOG.md` — Change history
4. `error_logs.md` — Error records
5. `error-rules.md` — Error prevention rules
+ Registers in work-tree.md

---

## Phase 5: Completion report

Output:
- List of all created files (grouped by phase)
- Summary stats: {N} files in {M} directories
- Next steps suggestion
- Remind user to run `/session-start` to begin working

---

## Important Notes

1. **Never overwrite existing files** — only create missing ones
2. **docs/ files are blank templates** — content is added during development
3. **CLAUDE.md under 200 lines** — Anthropic recommendation
4. **work_logs created via /init-worklog v2** — includes work-tree.md auto-registration
