# claude-code-workflow

> Session memory, error learning, and Git integration framework for Claude Code.

[한국어 README](README.ko.md)

---

## The Problem

Every time you `/clear` or start a new Claude Code session, **all context is lost**. Claude forgets what you worked on, what mistakes were made, and what rules your project follows. You start every session from scratch.

## The Solution

Three slash commands that give Claude **persistent memory across sessions**:

```
/session-start   →  Loads previous context (chatlog + rules + error prevention)
(work normally)
/session-end     →  Saves everything + error learning + Git commit
```

The `/clear` → `/session-start` cycle becomes a **context refresh** instead of a context loss.

---

## How It Works

### The Session Lifecycle

```
┌─────────────────────────────────────────────────┐
│                  /session-start                  │
│                                                  │
│  1. Read remind.md       → Project rules         │
│  2. Read error-rules.md  → Error prevention      │
│  3. Read chatlog.md      → Unfinished tasks      │
│  4. Read CHANGELOG.md    → Recent changes        │
│  5. Read ~/work_logs/error-rules.md              │
│     → Global shared rules (cross-project)        │
│                                                  │
│  Output: Context summary + suggested next task   │
└──────────────────────┬──────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│              Normal Work Session                 │
│                                                  │
│  - Write code, fix bugs, add features            │
│  - Errors auto-tracked as ERR-### entries         │
│  - Rules derived as RUL-### entries               │
│  - All context preserved in conversation          │
└──────────────────────┬──────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│                  /session-end                    │
│                                                  │
│  1. Analyze session → extract tasks, decisions   │
│  2. Append session block to chatlog.md           │
│  3. Append 1-line summary to global dashboard    │
│  4. Log errors (ERR-###) + derive rules (RUL-###)│
│  5. Update remind.md with new project rules      │
│  6. Update CHANGELOG.md                          │
│  7. Create dated worklog file                    │
│  8. [Optional] Sync worklog to Obsidian          │
│  9. Git commit with auto-generated message       │
│ 10. Output: final report + next session tasks    │
└─────────────────────────────────────────────────┘
```

---

## Key Features

### 1. Session Memory (`chatlog.md`)

The core of the system. Every session is recorded as a structured block:

```markdown
## Session 3 (2026-03-04) - Auth bug fix

### Tasks Completed
- Fixed JWT token expiration handling
- Added refresh token rotation

### Files Changed
- `src/auth/token.ts` - Added expiration check
- `src/middleware/auth.ts` - Added refresh logic

### Unfinished Tasks (next session)
- [ ] Add rate limiting to refresh endpoint
- [ ] Write tests for token rotation

### Key Decisions
- Using sliding window for token refresh (not fixed interval)

### Git
- Commit: `a1b2c3d` - fix: JWT token expiration handling
```

When you run `/session-start` next time, Claude reads this and **picks up exactly where you left off** — including unfinished tasks, recent decisions, and file context.

### 2. Error Learning System

Errors are tracked with `ERR-###` IDs and prevention rules are derived as `RUL-###`:

```
Session 3: ERR-001 — DB connection pool not initialized
           → RUL-001: Always verify pool before queries

Session 4: Claude auto-loads RUL-001 and checks the pool
```

**How it works:**

| File | Purpose | Loaded at |
|------|---------|-----------|
| `work_logs/error_logs.md` | Error records with resolution details | Reference |
| `work_logs/error-rules.md` | Prevention rules derived from errors | Every `/session-start` |
| `~/work_logs/error-rules.md` | **Global** rules shared across all projects | Every `/session-start` |

Rules accumulate over time. An error in **Project A** generates a rule that prevents the same mistake in **Project B**.

### 3. Two-Layer Logging

**Project level** — Detailed session blocks in `work_logs/chatlog.md`:
- Full task lists, file changes, decisions, Git hashes
- Complete context for continuing work

**Global level** (optional) — One-line-per-session dashboard in `~/work_logs/chatlog.md`:
- Quick overview across all projects
- Uses `>>` append (safe for concurrent sessions)

```markdown
# Global Session Dashboard

| Date | Project | Session | Summary | Status |
|------|---------|---------|---------|--------|
| 2026-03-04 | my-app | Session 5 | Fixed auth + added tests | Done |
| 2026-03-04 | api-server | Session 12 | Migrated to PostgreSQL | In Progress |
```

### 4. Git Commit Integration

At the end of each session, `/session-end` offers to commit your changes:

1. Checks `git status` and `git diff --stat`
2. If changes exist, asks you:
   - **Commit all** (recommended) — stages and commits everything
   - **Selective commit** — choose which files to include
   - **Skip** — no commit this time
3. Auto-generates a commit message from the session summary
4. Records the commit hash in chatlog.md
5. **Never pushes** — you control when to push

Sensitive files (`.env`, credentials, `.key`) are automatically flagged and excluded.

### 5. Project Rules (`remind.md`)

Rules that Claude must follow for your specific project. Loaded at every session start:

```markdown
## Absolute Rules (MUST)
- Always use TypeScript strict mode
- Never modify migration files directly

## Coding Conventions
- Use camelCase for variables, PascalCase for types
- All API responses use the ApiResponse<T> wrapper

## Warnings
- The legacy auth module is deprecated — use v2
```

New rules discovered during work are automatically added to `remind.md` at session end.

---

## Quick Start

### Option 1: Automated Install

```bash
git clone https://github.com/contentflow-kr/claude-code-workflow.git
cd claude-code-workflow
chmod +x install.sh
./install.sh
```

The installer will:
1. Copy slash commands to `~/.claude/commands/`
2. Optionally create `~/work_logs/` for the global dashboard
3. Optionally configure Obsidian sync path

### Option 2: Manual Install

Copy the command files to your Claude Code commands directory:

```bash
cp commands/*.md ~/.claude/commands/
```

Then initialize work_logs in any project:

```
You: /init-worklog
```

---

## Commands

### `/init-worklog`

Initializes the `work_logs/` directory in your current project.

**What it creates:**

| File | Purpose |
|------|---------|
| `chatlog.md` | Session memory — cross-session context |
| `remind.md` | Project rules — loaded every session |
| `error_logs.md` | Error records in `ERR-###` format |
| `error-rules.md` | Prevention rules in `RUL-###` format |
| `CHANGELOG.md` | Change history |

Existing files are **never overwritten** — only missing files are created.

### `/session-start`

Restores context from the previous session.

**What it loads (in order):**
1. `remind.md` — Project rules
2. `error-rules.md` — Error prevention rules (project-level)
3. `chatlog.md` — Previous sessions and unfinished tasks
4. `CHANGELOG.md` — Recent changes
5. `~/work_logs/error-rules.md` — Global shared rules (if exists)

**What it outputs:**
- Previous session summary
- Unfinished tasks with count
- Active project rules
- Error prevention rules
- Suggested next action

### `/session-end`

Records the current session and prepares for the next one.

**What it does (in order):**

| Step | Action | File |
|------|--------|------|
| 1 | Calculate session number | `chatlog.md` |
| 2 | Analyze conversation | — |
| 3 | Append session block | `chatlog.md` |
| 3.5 | Append 1-line to global dashboard | `~/work_logs/chatlog.md` |
| 3.7 | Log errors + derive rules | `error_logs.md` + `error-rules.md` |
| 4 | Update project rules | `remind.md` |
| 5 | Update changelog | `CHANGELOG.md` |
| 6 | Create dated worklog | `work_logs/YYYY_MM_DD_*.md` |
| 7 | Git commit (with user confirmation) | — |
| 8 | Output final report | — |

---

## File Structure

After running `/init-worklog` in a project:

```
your-project/
└── work_logs/
    ├── chatlog.md             # Session memory (cross-session context)
    ├── remind.md              # Project rules (loaded every session)
    ├── error_logs.md          # Error records (ERR-###)
    ├── error-rules.md         # Prevention rules (RUL-###)
    ├── CHANGELOG.md           # Change history
    └── 2026_03_04_auth_fix_worklog.md  # Dated worklog
```

Optional global dashboard:

```
~/work_logs/
├── chatlog.md                 # One row per session (all projects)
├── error_logs.md              # Cross-project error index
└── error-rules.md             # Shared prevention rules
```

---

## vs Claude Code `/memory`

Claude Code has a built-in `/memory` command that saves notes to `MEMORY.md`. It's a persistent notepad — useful for preferences and reminders, but not a workflow system.

| | `/memory` (built-in) | claude-code-workflow |
|---|:---:|:---:|
| **What it stores** | Unstructured notes | Structured session blocks |
| **Session history** | No | Yes (Session 1, 2, 3...) |
| **Unfinished task tracking** | No | Yes (auto-loaded next session) |
| **Error learning** | No | Yes (ERR-### → RUL-###) |
| **Cross-project error sharing** | No | Yes (global error-rules.md) |
| **Project rules** | No | Yes (remind.md) |
| **Git commit integration** | No | Yes |
| **Global dashboard** | No | Yes (all projects in one table) |
| **Dated worklogs** | No | Yes |
| **Changelog** | No | Yes |

**They're complementary, not competing.** Use `/memory` for static preferences ("always use bun", "API key is in .env.local") and claude-code-workflow for session lifecycle management (what you did, what went wrong, what's next).

---

## Comparison

| Feature | claude-code-workflow | [claude-sessions](https://github.com/iannuttall/claude-sessions) | [Claude Diary](https://rlancemartin.github.io/2025/12/01/claude_diary/) |
|---------|:-------------------:|:---------------:|:------------:|
| Session start/end commands | Yes | Yes | End only |
| Cross-session chatlog | Yes | Partial | No |
| Project rules (remind.md) | Yes | No | No |
| Error learning (ERR/RUL) | Yes | No | No |
| Two-layer logging | Yes | No | No |
| Git commit integration | Yes | No | No |
| Obsidian sync (optional) | Yes | No | No |
| No MCP dependency | Yes | Yes | Yes |

---

## Optional Features

### Global Dashboard

Track all sessions across all projects in a single table. Enable during install or manually create `~/work_logs/`.

### Obsidian Sync

Auto-write worklogs to your Obsidian vault. See [config.example.md](config.example.md) for setup.

**Note**: Uses the Write tool (not `cp`) because `cp` may fail on cloud-synced directories (iCloud, Dropbox).

---

## Templates

The `templates/` directory contains starter files:
- **CLAUDE.md** — Project settings template with workflow rules and commit conventions
- **chatlog.md, remind.md, error_logs.md, error-rules.md** — Work log templates

---

## Customization

### Commit Message Format

By default, commit messages follow this format:

```
Session {N}: {topic summary}

- {task 1}
- {task 2}

Co-Authored-By: Claude <noreply@anthropic.com>
```

You can customize this in your project's `CLAUDE.md`. See `templates/CLAUDE.md` for a full example with Git conventions (feat/fix/docs/refactor/test/chore/style).

### Worklog Filename

Default: `YYYY_MM_DD_[task-name]_worklog.md`

The task name is automatically derived from the session topic (2-5 words, kebab-case).

---

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed
- macOS or Linux
- Git (for commit integration)

---

## License

[CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/) — Free to use and modify, **commercial sale prohibited**.
