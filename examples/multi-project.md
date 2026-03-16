# Multi-Project Management Example

## Scenario

You're working on 3 projects simultaneously:
- `my-api` — Backend API (FastAPI)
- `my-frontend` — Web app (SvelteKit)
- `my-blog` — WordPress blog

## Setup

### 1. Initialize each project

```
cd ~/projects/my-api
/init-worklog          ← Creates work_logs/ + registers in ~/work-tree.md

cd ~/projects/my-frontend
/init-worklog

cd ~/projects/my-blog
/init-worklog
```

### 2. Your ~/work-tree.md now looks like:

```markdown
# Project Work Tree (Master)

| Project | Path | work_logs | Description |
|---------|------|-----------|-------------|
| my-api | `projects/my-api/` | O | Backend API |
| my-frontend | `projects/my-frontend/` | O | Web app |
| my-blog | `projects/my-blog/` | O | WordPress blog |
```

### 3. Session workflow

```
# Morning: work on API
cd ~/projects/my-api
/session-start         ← Loads work-tree.md + my-api context
(work on API)
/session-end           ← Records to my-api/work_logs/ + global dashboard

# Afternoon: switch to frontend
cd ~/projects/my-frontend
/session-start         ← Loads work-tree.md + my-frontend context
(work on frontend)
/session-end

# Quick fix on blog
cd ~/projects/my-blog
/session-start
(fix something)
/session-end
```

### 4. Check all projects at once

From home directory:
```
cd ~
/session-start         ← Global mode: scans all projects

Output:
  📁 my-api (last: 2026-03-17)
  - [ ] Add rate limiting
  - [ ] Write tests

  📁 my-frontend (last: 2026-03-17)
  - [ ] Fix mobile layout

  📁 my-blog (last: 2026-03-17)
  - (no unfinished tasks)

  Total: 3 unfinished tasks across 2 projects
```

### 5. Global dashboard (~/work_logs/chatlog.md)

```markdown
| Date | Project | Session | Summary | Status |
|------|---------|---------|---------|--------|
| 2026-03-17 | my-api | Session 5 | Added auth middleware | Done |
| 2026-03-17 | my-frontend | Session 3 | Fixed responsive layout | Done |
| 2026-03-17 | my-blog | Session 1 | Updated SEO tags | Done |
```

## Error Learning Across Projects

An error in `my-api` generates a rule that's shared globally:

```
my-api Session 3:
  ERR-001 — Forgot to close DB connection in test
  → RUL-001: Always use context manager for DB connections

my-frontend Session 5:
  Claude auto-loads RUL-001 from ~/work_logs/error-rules.md
  → Applies the same pattern when writing frontend API calls
```
