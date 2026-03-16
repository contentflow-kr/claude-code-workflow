# {Project Name} - Claude Code Settings

## Core Rules

- Read files before editing (never modify without reading first)
- Use absolute paths only
- No auto-commits during work (only via /session-end with user confirmation)
- Run independent tool calls in parallel
- Follow existing project patterns/conventions
- Before code changes: search (Glob/Grep) → plan → execute → verify

### Sub-Agent Model Selection

| Model | Use Case | Examples |
|-------|----------|---------|
| `haiku` | Conversation, Q&A, simple explanations | Concept questions, comparisons |
| `sonnet` | Code work, file editing, search | Bug fixes, refactoring, pattern matching |
| `opus` | Planning, design, deep analysis | Architecture review, security audit |

Escalation: haiku detects complexity → delegate to opus / sonnet needs full impact analysis → delegate to opus

---

## Work Log System (Required)

### Session Start (`/session-start` v3)
1. Load `work-tree.md` project map (current dir → parent 3 levels → `~/work-tree.md`)
2. Check `work_logs/` exists → if not, run `/init-worklog`
3. Read `chatlog.md` + `remind.md` + `error-rules.md`
4. Read global `~/work_logs/error-rules.md` (if exists)
5. Resume unfinished tasks first

### Session End (`/session-end` v4)
1. Append session content to project `chatlog.md`
2. If errors occurred: update `error_logs.md` (ERR-###) + `error-rules.md` (RUL-###)
3. Append 1-line summary to `~/work_logs/chatlog.md` dashboard (if exists)
4. Create `YYYY_MM_DD_[task-name]_worklog.md` in work_logs/
5. [Optional] Obsidian CLI — Daily Note append + task count report
6. **Git commit** — with user confirmation (commit all / selective / skip)

### File Structure

```
{project}/work_logs/
├── chatlog.md        # [Required] Cross-session context
├── remind.md         # [Required] Project rules
├── error_logs.md     # [Required] Error records (ERR-###)
├── error-rules.md    # [Required] Error prevention rules (RUL-###)
├── CHANGELOG.md      # [Recommended] Change history
└── YYYY_MM_DD_[task]_worklog.md

~/work_logs/            # [Optional] Global dashboard
├── chatlog.md        # Table summary (1 row = 1 session)
├── error_logs.md     # Error index
└── error-rules.md    # Shared error rules
```

### Two-Layer Logging
- **Global** (`~/work_logs/chatlog.md`): Table dashboard, `>>` append only (no conflicts)
- **Project** (`{project}/work_logs/chatlog.md`): Detailed Session N blocks

### During Work
- Error occurs → Add ERR-### to `error_logs.md` + RUL-### to `error-rules.md`
- Code changes → Update `CHANGELOG.md`
- User requests → Add to `remind.md`

### [Optional] Obsidian Sync
- Set `OBSIDIAN_PATH` in your settings to enable
- Worklogs will be written to `{OBSIDIAN_PATH}/` via Write tool
- Use Write tool only (cp may fail on cloud-synced directories)

---

## Git Commit Convention

| Prefix | Use | Example |
|--------|-----|---------|
| `feat:` | New feature | `feat: add Telegram channel integration` |
| `fix:` | Bug fix | `fix: handle token expiration` |
| `docs:` | Documentation | `docs: update API spec` |
| `refactor:` | Code improvement (no behavior change) | `refactor: extract auth logic` |
| `test:` | Add/modify tests | `test: add payment E2E test` |
| `chore:` | Config, build, dependencies | `chore: update eslint config` |
| `style:` | Formatting | `style: fix indentation` |

- `/session-end` commits use: `Session {N}: {topic summary}` format
- Commit body: focus on **why**, include Co-Authored-By

---

## Custom Skill Commands

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/init-worklog` | Initialize work_logs/ structure | Adding work_logs to existing project |
| `/session-start` | Load work-tree + chatlog + remind + error-rules (v3) | Start of session |
| `/session-end` | Log session + worklog + Obsidian CLI + Git commit (v4) | Before ending session |

---

## Token Efficiency

- Short answers for simple questions, show only changed code
- Prefer Glob/Grep (minimize agent spawning), parallel independent calls
- Suggest `--uc` mode for large-scale analysis
- Suggest `/sc:spawn` agent delegation when >5 files to modify

---

## CLAUDE.md Size Management

- Keep this file **under 200 lines** (Anthropic recommendation)
- Delegate detailed rules to skill files (~/.claude/commands/) or work_logs/
