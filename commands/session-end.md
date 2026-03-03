---
allowed-tools: [Read, Edit, Write, Bash, AskUserQuestion]
description: "End session: update chatlog + create worklog + optional Obsidian sync + Git commit"
---

# /session-end v3 - Session End with Git Commit

## Purpose
Record all work from the current session to chatlog.md, create a dated worklog,
optionally sync to Obsidian, and commit changes to Git.

## Execution

### 1. Load chatlog.md
- Read existing chatlog.md
- Calculate current session number (existing sessions + 1)

### 2. Analyze current session
Review the conversation to extract:
- Tasks completed
- Files changed
- New issues discovered
- Key decisions made
- User preferences (newly identified)

### 3. Append new session to chatlog.md

Insert above the `<!-- Add new session above -->` comment:

```markdown
## Session {N} ({today's date}) - {topic summary}

### Tasks Completed
- Task description

### Files Changed
- `filepath` - Change description

### Unfinished Tasks (next session)
- [ ] Unfinished item

### Key Decisions
- Decision description

### Git
- Commit: `{hash 7 chars}` - {commit message} (or "No changes" / "Skipped")

---
```

### 3.5. Append to global dashboard (if configured)

If `~/work_logs/chatlog.md` exists, append a one-line summary using Bash `>>`:

```bash
echo "| {date} | {project} | Session {N} | {1-line summary} | {status} |" >> ~/work_logs/chatlog.md
```

**Important**: Use Bash `>>` (not Write/Edit) to prevent conflicts with concurrent sessions.

### 3.7. Error logging (if errors occurred)

Only if errors occurred during the session. Skip if no errors.

**1) Append to project error_logs.md:**
```bash
echo "| ERR-{num} | {date} | {error summary} | {resolution} | {rule ID or -} |" >> work_logs/error_logs.md
```

**2) Append to global error_logs.md (if exists):**
```bash
echo "| ERR-{num} | {date} | {project} | {error summary} | {resolution} | {rule ID or -} |" >> ~/work_logs/error_logs.md
```

**3) If a new prevention rule is derived, append to error-rules.md:**
```bash
echo "| RUL-{num} | {rule description} | ERR-{cause ID} |" >> work_logs/error-rules.md
echo "| RUL-{num} | {rule description} | ERR-{cause ID} |" >> ~/work_logs/error-rules.md
```

**ERR/RUL numbering**: Last ID in file + 1 (use global file as reference)

### 4. Update remind.md (if needed)
- Add newly discovered caveats
- Remove or mark resolved items

### 5. Update CHANGELOG.md (if code changed)
- Summarize changed files and their modifications

### 6. Create dated worklog [OPTIONAL: Obsidian sync]

**Filename**: `YYYY_MM_DD_[task-name]_worklog.md`
- Task name: concise description (2-5 words)
- Example: `2026_03_03_auth_bug_fix_worklog.md`

**Create in project**: `work_logs/YYYY_MM_DD_[task-name]_worklog.md`

**[OPTIONAL] Obsidian sync**:
If `OBSIDIAN_PATH` is configured in your CLAUDE.md or project settings:
- Also write the worklog to `{OBSIDIAN_PATH}/YYYY_MM_DD_[task-name]_worklog.md`
- Use the **Write tool** (not cp — may fail on cloud-synced directories)
- If same date has multiple sessions, create separate files (different task names)

If Obsidian is not configured, skip this step.

**Worklog content**: Copy the session content from chatlog.md with a project header:
```markdown
# {Project Name} Worklog - {today's date}

{Session content from chatlog.md}
```

### 7. Git Commit (v3)

**Condition**: Only if current directory is a git repo. If not, skip to step 8.

#### 7-1. Check git status
```bash
git status
git diff --stat
```

#### 7-2. No changes → skip
- If `nothing to commit, working tree clean` → record "No changes" in chatlog Git section, go to step 8.

#### 7-3. Changes found → ask user

Use AskUserQuestion:

**"Commit session changes to Git?"**

| Option | Description |
|--------|-------------|
| Commit all (Recommended) | Stage and commit all changed files |
| Selective commit | Choose which files to commit |
| Skip | Don't commit this time |

#### 7-4. Execute commit

**Auto-generate commit message** (based on session summary):

```bash
git commit -m "$(cat <<'EOF'
Session {N}: {topic summary}

- {task 1}
- {task 2}
- {task 3}

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

**Commit all**: `git add -A` → `git commit`
- Warn and exclude sensitive files (.env, credentials, .key)

**Selective commit**:
- Show file list from `git status`
- Let user choose files via AskUserQuestion
- `git add {selected files}` → `git commit`

#### 7-5. Record commit result
- Get hash from `git log --oneline -1`
- Record in chatlog Git section

#### 7-6. Important notes
- **No push** — commit only (user pushes manually)
- **Sensitive file warning** — .env, credentials flagged
- **Pre-commit hook failure** — show error, fix, then new commit

### 8. Final report
- Summary of all recorded items
- Worklog file path(s)
- Git commit result (hash + message, or skip status)
- Suggested tasks for next session
