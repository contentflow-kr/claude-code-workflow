# claude-code-workflow

> Session memory, error learning, and Git integration for Claude Code.

[한국어 README](README.ko.md)

---

## The Problem

Every time you `/clear` or start a new Claude Code session, **all context is lost**. Claude forgets what you worked on, what mistakes were made, and what rules your project follows.

## The Solution

Three slash commands that give Claude **persistent memory across sessions**:

```
/session-start   →  Restores context from last session
(work normally)
/session-end     →  Saves everything + Git commit
```

---

## Key Features

### 1. Session Memory
`/session-start` loads your project's chatlog, rules, and error prevention rules. Even after `/clear`, Claude picks up exactly where you left off.

### 2. Error Learning System
When errors occur, they're tracked as `ERR-###` entries. Prevention rules (`RUL-###`) are derived and automatically loaded in future sessions — **across all projects**.

```
Session 3: ERR-001 — DB connection pool not initialized
           → RUL-001: Always verify pool before queries

Session 4: Claude automatically checks pool (learned from RUL-001)
```

### 3. Git Commit Integration
`/session-end` asks whether to commit changes, auto-generates a commit message from the session summary, and records the commit hash in the chatlog.

### 4. Two-Layer Logging
- **Project level**: Detailed session blocks in `work_logs/chatlog.md`
- **Global level** (optional): One-line-per-session dashboard in `~/work_logs/chatlog.md`

---

## Quick Start

### Option 1: Automated Install

```bash
git clone https://github.com/contentflow-kr/claude-code-workflow.git
cd claude-code-workflow
chmod +x install.sh
./install.sh
```

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

## Usage

### Start of session
```
You: /session-start
```
Claude loads chatlog.md + remind.md + error-rules.md and shows a context summary.

### End of session
```
You: /session-end
```
Claude records all work, creates a worklog, and optionally commits to Git.

### Initialize a new project
```
You: /init-worklog
```
Creates the `work_logs/` directory with all template files.

---

## File Structure

After running `/init-worklog` in a project:

```
your-project/
└── work_logs/
    ├── chatlog.md        # Session memory (cross-session context)
    ├── remind.md         # Project rules (loaded every session)
    ├── error_logs.md     # Error records (ERR-###)
    ├── error-rules.md    # Prevention rules (RUL-###)
    └── CHANGELOG.md      # Change history
```

Optional global dashboard:

```
~/work_logs/
├── chatlog.md            # One row per session (all projects)
├── error_logs.md         # Cross-project error index
└── error-rules.md        # Shared prevention rules
```

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
Track all sessions across all projects. Enable during install or manually create `~/work_logs/`.

### Obsidian Sync
Auto-write worklogs to your Obsidian vault. See [config.example.md](config.example.md) for setup.

---

## Templates

The `templates/` directory contains starter files:
- **CLAUDE.md** — Project settings template with workflow rules and commit conventions
- **chatlog.md, remind.md, error_logs.md, error-rules.md** — Work log templates

---

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed
- macOS or Linux
- Git (for commit integration)

---

## License

[CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/) — Free to use and modify, **commercial sale prohibited**.
