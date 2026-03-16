---
allowed-tools: [Read, Write, Edit, Bash, Glob]
description: "Initialize work_logs structure + register in work-tree.md"
---

# /init-worklog v2 - Initialize Project Work Logs + Register in Project Map

## Purpose
Create the work_logs/ directory structure in the current project and register it in work-tree.md.
Existing files are never overwritten — only missing files are created.
**v2**: Auto-register project in parent work-tree.md and master ~/work-tree.md.

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

### 4. Register in work-tree.md (v2)

After creating work_logs/, register the project in work-tree.md for cross-project navigation.

#### 4-1. Find parent work-tree.md

Search upward from current directory (max 3 levels):
```
Example: /Users/you/projects/my-app/
  → Level 1: /Users/you/projects/work-tree.md  ← register here if exists
  → Level 2: /Users/you/work-tree.md           ← also register here
```

#### 4-2. Add row to parent work-tree.md

If a work-tree.md table exists in a parent directory, add a project row.
Skip if already registered (duplicate check by project name or path).

**Row format**:
```
| {Project Name} | `{relative-path}/` | O | {description} |
```

#### 4-3. Add row to master ~/work-tree.md

Also register in the master `~/work-tree.md`:
- Find the appropriate section based on the absolute path
- If no matching section, add under `## Other`

**Row format**:
```
| {Project Name} | `{home-relative-path}/` | O | {description} |
```

#### 4-4. Duplicate check

Before adding, check existing tables for matching project name or path.
If already listed with `work_logs = X`, update to `O`.

### 5. Completion report
- List created files
- List skipped files (already existed)
- Show work-tree.md registration result (which files were updated)
