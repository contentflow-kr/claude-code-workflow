---
allowed-tools: [Read, Write, Bash, Glob]
description: "Initialize work_logs structure (chatlog.md, remind.md, CHANGELOG.md, error tracking)"
---

# /init-worklog - Initialize Project Work Logs

## Purpose
Create the work_logs/ directory structure in the current project.
Existing files are never overwritten — only missing files are created.

## Execution

### 1. Detect project
- Check current working directory
- Extract project name (from folder name or package.json/pyproject.toml)
- Check if work_logs/ already exists

### 2. Create directory
```bash
mkdir -p work_logs
```

### 3. Create files (only missing ones)

**chatlog.md** (required):
```markdown
# {Project Name} Session Memory (chatlog)
> Cross-session context persistence. Read this file first at the start of each new session.

---

## Session 1 ({today's date}) - Initial Setup

### Tasks Completed
- Initialized work_logs with /init-worklog

### Unfinished Tasks (next session)
- [ ] To be added

### Key Decisions
- To be added

### User Preferences
- To be added

---
<!-- Add new session above this line, using the same format with --- separator -->
```

**remind.md** (required):
```markdown
# {Project Name} Project Rules
> Must-follow rules when working on this project. Check at every session start.

## Absolute Rules (MUST)
- To be added

## Coding Conventions
- To be added

## Warnings
- To be added

## Common Mistake Prevention
- To be added
```

**CHANGELOG.md** (recommended):
```markdown
# {Project Name} Changelog

## [{today's date}] - Initial Setup
### Added
- Initialized work_logs system
```

**error_logs.md** (required):
```markdown
# {Project Name} Error Log
> Track errors in ERR-### format when they occur during sessions.

| ID | Date | Error Summary | Resolution | Rule |
|----|------|---------------|------------|------|
```

**error-rules.md** (required):
```markdown
# {Project Name} Error Prevention Rules
> Auto-loaded at session start. Prevents repeated mistakes.

| ID | Rule | Caused By |
|----|------|-----------|
```

### 4. Completion report
- List created files
- List skipped files (already existed)
