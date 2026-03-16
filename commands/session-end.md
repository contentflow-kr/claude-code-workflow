---
allowed-tools: [Read, Edit, Write, Bash, AskUserQuestion]
description: "End session: update chatlog + create worklog + optional Obsidian sync + Git commit"
---

# /session-end v4 - Session End with Obsidian CLI + Git Commit

## Purpose
Record all work from the current session to chatlog.md, create a dated worklog,
optionally sync to Obsidian, and commit changes to Git.
**v3**: Git commit integration with user confirmation.
**v4**: Optional Obsidian CLI integration (Daily Note + task count).

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

### 6. Create dated worklog + Optional Obsidian sync

**Filename**: `YYYY_MM_DD_[task-name]_worklog.md`
- Task name: concise description (2-5 words)
- Example: `2026_03_03_auth_bug_fix_worklog.md`

**Create in project**: `work_logs/YYYY_MM_DD_[task-name]_worklog.md`

**[OPTIONAL] Obsidian sync**:
If `OBSIDIAN_WORKLOG_PATH` is configured in your CLAUDE.md or project settings:
- Also write the worklog to `{OBSIDIAN_WORKLOG_PATH}/YYYY_MM_DD_[task-name]_worklog.md`
- Use the **Write tool** (not cp — may fail on cloud-synced directories)
- If same date has multiple sessions, create separate files (different task names)

If Obsidian is not configured, skip this step silently.

**Worklog content**: Copy the session content from chatlog.md with a project header:
```markdown
# {Project Name} Worklog - {today's date}

{Session content from chatlog.md}
```

### 6.5. Obsidian CLI integration (v4, optional)

**Condition**: Only if Obsidian CLI is in PATH and the app is running. Skip silently on failure.

#### 6.5-1. Append to Daily Note
```bash
obsidian daily:append content="- [x] Claude Code Session {N} — {1-line summary}"
```

#### 6.5-2. Report task count
```bash
VAULT_TODO=$(obsidian tasks todo total 2>/dev/null || echo "N/A")
DAILY_TODO=$(obsidian tasks daily todo total 2>/dev/null || echo "0")
```

Include in final report (step 8).

#### 6.5-3. Set worklog properties
```bash
obsidian property:set name=status value=done path="{worklog path}"
obsidian property:set name=session value={N} type=number path="{worklog path}"
obsidian property:set name=project value="{project}" path="{worklog path}"
```

#### 6.5-4. Important
- CLI failure must NOT interrupt session-end — file recording takes priority
- Use `2>/dev/null || echo "..."` pattern to absorb errors
- If Obsidian app is closed, skip silently

### 7. Git Commit

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
- Obsidian CLI result (if applicable): Daily Note status + task counts
- Suggested tasks for next session
