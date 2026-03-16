---
allowed-tools: [Read, Write, Edit, Bash, Glob, AskUserQuestion]
description: "Initialize work_logs structure + register in work-tree.md + optional hooks"
---

# /init-worklog v3 - Initialize Project Work Logs + Project Map + Hooks

## Purpose
Create the work_logs/ directory structure in the current project and register it in work-tree.md.
Existing files are never overwritten — only missing files are created.
**v2**: Auto-register project in parent work-tree.md and master ~/work-tree.md.
**v3**: Optional session protection hooks setup (PreCompact / Stop reminder).

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

### 5. Session protection hooks (v3)

Ask the user with AskUserQuestion:

**"Set up session protection hooks?"**

| Option | What it does |
|--------|-------------|
| **A. Minimal** | PreCompact only — suggests `/session-end` before context compression |
| **B. Stop reminder** | Stop hook only — reminds based on token usage (fires when Claude finishes responding) |
| **C. Full (A+B)** | Both PreCompact + Stop reminder |
| **D. Skip** | No hooks setup |

#### If A or C selected: PreCompact hook

Add to `.claude/settings.json` (create if not exists, merge if exists):

```json
{
  "hooks": {
    "PreCompact": [
      {
        "type": "prompt",
        "prompt": "Context is about to be compressed. Check if meaningful work was done in this session (file changes, decisions, errors). If yes, ask the user: 'Context is about to compress. Run /session-end to save your work first?' If no meaningful work, proceed silently."
      }
    ]
  }
}
```

#### If B or C selected: Stop reminder hook

Add to `.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "type": "prompt",
        "prompt": "Check the conversation context usage. If it appears that significant work has been done (multiple file edits, key decisions, error resolutions), briefly remind the user: '💡 Consider running /session-end to save this session.' Only remind once per session — if you already reminded, stay silent."
      }
    ]
  }
}
```

#### Settings merge logic

- If `.claude/settings.json` doesn't exist → create with hooks config
- If it exists but has no `hooks` key → add `hooks` key
- If it exists with `hooks` → merge new hook entries into existing arrays
- **Never overwrite existing hooks** — append only

### 6. Completion report
- List created files
- List skipped files (already existed)
- Show work-tree.md registration result (which files were updated)
- Show hooks setup result (which hooks were configured, or skipped)
