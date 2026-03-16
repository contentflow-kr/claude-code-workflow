# claude-code-workflow

> Session memory, error learning, project scaffolding, and Git integration for Claude Code.

**English** | [한국어](README.ko.md) | [日本語](README.ja.md) | [中文](README.zh.md) | [Français](README.fr.md)

---

## The Problem

Every time you `/clear` or start a new Claude Code session, **all context is lost**. Claude forgets what you worked on, what mistakes were made, and what rules your project follows. Managing multiple projects makes it even worse.

## The Solution

**5 slash commands** that give Claude persistent memory, error learning, and multi-project navigation:

```
/init-worklog      →  Set up recording infrastructure (once per project)
/init-project-v1   →  Quick project scaffolding with blank templates
/init-project-v2   →  Guided setup with real documentation
/session-start     →  Restore previous context
/session-end       →  Save everything + worklog + Git commit
```

---

## Quick Start

### Install

```bash
git clone https://github.com/contentflow-kr/claude-code-workflow.git
cd claude-code-workflow
chmod +x install.sh
./install.sh
```

The installer will:
1. Copy 5 slash commands to `~/.claude/commands/`
2. Create `~/work-tree.md` (project navigation map)
3. Optionally create `~/work_logs/` (global dashboard)
4. Optionally configure Obsidian sync

### First Use

```
cd your-project
/init-worklog          # Set up work_logs/ (30 seconds)
# work normally...
/session-end           # Record everything
# next session:
/session-start         # Pick up where you left off
```

### For New Projects

```
cd empty-folder
/init-project-v1       # Quick scaffolding (5 min)
# or
/init-project-v2       # Detailed setup with real docs (30 min)
```

---

## How It Works

### The Session Lifecycle

```
┌─────────────────────────────────────────────────┐
│                 /session-start v3                │
│                                                  │
│  0. Load work-tree.md  → Project navigation map  │
│  1. Load remind.md     → Project rules           │
│  2. Load error-rules.md → Error prevention       │
│  3. Load chatlog.md    → Unfinished tasks        │
│  4. Load CHANGELOG.md  → Recent changes          │
│  5. Load ~/work_logs/error-rules.md              │
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
│  - Errors tracked as ERR-### entries             │
│  - Rules derived as RUL-### entries              │
└──────────────────────┬──────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│                /session-end v4                   │
│                                                  │
│  1. Analyze session → extract tasks, decisions   │
│  2. Append session block to chatlog.md           │
│  3. Append 1-line to global dashboard            │
│  4. Log errors + derive prevention rules         │
│  5. Update remind.md + CHANGELOG.md              │
│  6. Create dated worklog file                    │
│  7. [Optional] Sync to Obsidian + CLI            │
│  8. Git commit with auto-generated message       │
│  9. Output: final report + next session tasks    │
└─────────────────────────────────────────────────┘
```

---

## 5 Commands

### `/init-worklog` (v2)

Add the recording system to any existing project.

**Creates:**

| File | Purpose |
|------|---------|
| `work_logs/chatlog.md` | Session memory |
| `work_logs/remind.md` | Project rules |
| `work_logs/error_logs.md` | Error records (ERR-###) |
| `work_logs/error-rules.md` | Prevention rules (RUL-###) |
| `work_logs/CHANGELOG.md` | Change history |

**v2 addition**: Auto-registers the project in `work-tree.md` for cross-project navigation.

### `/init-project-v1`

Quick project scaffolding — asks 4 questions, creates blank template docs.

**Creates**: `CLAUDE.md` + `docs/` (blank templates) + `work_logs/` + `.gitignore`

Best for: hackathons, experiments, plans not finalized.

### `/init-project-v2`

Detailed project setup — asks 3 rounds of questions, writes real documentation.

**Creates**: `CLAUDE.md` + `docs/` (real content) + `work_logs/` + `.gitignore`

Best for: serious projects, long-term development, documentation-driven development.

### `/session-start` (v3)

Restores context from the previous session.

**Loads (in order):**
1. `work-tree.md` — Project navigation map
2. `remind.md` — Project rules
3. `error-rules.md` — Error prevention (project + global)
4. `chatlog.md` — Previous sessions and unfinished tasks
5. `CHANGELOG.md` — Recent changes

**Global mode**: Run from `~/` to scan all projects and see unfinished tasks across everything.

### `/session-end` (v4)

Records the current session and prepares for the next one.

| Step | Action |
|------|--------|
| 1-2 | Analyze session, extract tasks/decisions |
| 3 | Append session block to chatlog.md |
| 3.5 | Append 1-line to global dashboard |
| 3.7 | Log errors (ERR-###) + derive rules (RUL-###) |
| 4-5 | Update remind.md + CHANGELOG.md |
| 6 | Create dated worklog |
| 6.5 | [Optional] Obsidian CLI sync |
| 7 | Git commit (with user confirmation) |
| 8 | Final report |

---

## Key Features

### Session Memory
Every session is recorded as a structured block in `chatlog.md`. Next `/session-start` picks up exactly where you left off.

### Error Learning
Errors tracked as `ERR-###`, prevention rules derived as `RUL-###`. Rules from Project A prevent the same mistake in Project B via global `~/work_logs/error-rules.md`.

### Multi-Project Navigation
`work-tree.md` maps all your projects. `/init-worklog` auto-registers new projects. Run `/session-start` from `~/` to see all unfinished tasks at once.

### Two-Layer Logging
- **Project level**: Detailed session blocks in `chatlog.md`
- **Global level**: One-line dashboard in `~/work_logs/chatlog.md`

### Git Integration
Auto-generated commit messages from session summaries. Sensitive files (.env, credentials) auto-excluded.

### Obsidian Sync (Optional)
Worklogs auto-copied to your Obsidian vault. CLI integration for Daily Notes and task counts.

---

## File Structure

```
~/                                    # Global
├── work-tree.md                      # Project navigation map
├── work_logs/
│   ├── chatlog.md                    # All sessions dashboard
│   ├── error_logs.md                 # Cross-project errors
│   ├── error-rules.md               # Shared prevention rules
│   └── remind.md                     # Global rules
└── .claude/commands/                 # Skill files (5)

{project}/                            # Per project
├── work_logs/
│   ├── chatlog.md                    # Session records
│   ├── remind.md                     # Project rules
│   ├── error_logs.md                 # Errors (ERR-###)
│   ├── error-rules.md               # Rules (RUL-###)
│   ├── CHANGELOG.md                  # Changes
│   └── YYYY_MM_DD_*_worklog.md       # Dated worklogs
└── CLAUDE.md                         # Project context
```

---

## vs Claude Code `/memory`

| | `/memory` (built-in) | claude-code-workflow |
|---|:---:|:---:|
| **Session history** | No | Yes |
| **Unfinished task tracking** | No | Yes |
| **Error learning** | No | Yes (ERR → RUL) |
| **Cross-project error sharing** | No | Yes |
| **Multi-project navigation** | No | Yes (work-tree.md) |
| **Project scaffolding** | No | Yes (v1 + v2) |
| **Git commit integration** | No | Yes |
| **Obsidian sync** | No | Yes (optional) |

**They're complementary.** Use `/memory` for static preferences, workflow for session lifecycle.

---

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed
- macOS or Linux
- Git (for commit integration)

## License

[CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/) — Free to use and modify, commercial sale prohibited.
