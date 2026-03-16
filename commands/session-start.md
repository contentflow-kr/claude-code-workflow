---
allowed-tools: [Read, Glob, Bash]
description: "Restore session context by loading chatlog.md + remind.md"
---

# /session-start v3 - Restore Session Context

## Purpose
Quickly restore previous work context at the start of a new session.
Load chatlog.md for unfinished tasks, remind.md for project rules.
**v3**: Auto-load `work-tree.md` for cross-project navigation.

## Execution

### 0. Load work-tree.md (project map)

Search for `work-tree.md` to build a project map for cross-project navigation:
1. Check current directory for `work-tree.md`
2. If not found, check parent directories (up to 3 levels)
3. If still not found, check `~/work-tree.md` (master index)

> work-tree.md maps all sub-projects with their paths, work_logs status, and .env locations.
> When the user requests work on a different project mid-session, use this map to locate
> the target project's `work_logs/remind.md` and load it before starting.

### 1. Discover project work_logs
```
Glob: work_logs/{chatlog,remind,CHANGELOG,error-rules}.md
```

### 2. Load core files (in order)
1. **remind.md** — Read project rules
2. **error-rules.md** (if exists) — Read error prevention rules
3. **chatlog.md** — Find unfinished tasks from last session
4. **CHANGELOG.md** (if exists) — Recent changes
5. **Global** `~/work_logs/error-rules.md` (if exists) — Shared error rules across projects

### 3. Output context summary

```
## Session Context Restored

### Project Map (work-tree.md)
- Loaded from: {path}
- Sub-projects: {n} total ({m} with work_logs)

### Previous Session Summary
- Last session: {date} - {topic}
- Key work done: {summary}

### Unfinished Tasks ({n})
- [ ] Item 1
- [ ] Item 2

### Project Rules (remind.md)
- Key rules summary

### Error Prevention Rules (error-rules.md)
- Project + global rules summary

### Recent Changes (CHANGELOG)
- Recent changes summary
```

### 4. Suggest next actions
- Recommend highest priority unfinished task
- Suggest agent delegation if applicable
