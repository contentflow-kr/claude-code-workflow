---
allowed-tools: [Read, Glob]
description: "Restore session context by loading chatlog.md + remind.md"
---

# /session-start - Restore Session Context

## Purpose
Quickly restore previous work context at the start of a new session.
Load chatlog.md for unfinished tasks, remind.md for project rules.

## Execution

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
