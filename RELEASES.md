# Releases

## v1.1.0 (2026-03-17) — Work-Tree Project Map + session-end v4

### New Features
- **`work-tree.md` support**: `/session-start` now auto-loads `work-tree.md` for cross-project navigation
  - Searches current dir → parent (up to 3 levels) → `~/work-tree.md` (master index)
  - Maps all sub-projects with paths, work_logs status, and .env locations
  - Enables mid-session project switching without losing context
- **`/session-start` v3**: Added Step 0 (work-tree.md loading) before existing workflow
- **`/session-end` v4**: Obsidian CLI integration
  - Daily Note append with session summary
  - Vault-wide unfinished task count report
  - Worklog property setting (status, session, project)
  - Fails silently if CLI unavailable — file-based recording always takes priority

### Updated Files
- `commands/session-start.md` — v3 (work-tree.md support)
- `README.md` / `README.ko.md` — diagrams + docs for both v3 and v4
- `examples/session-flow.md` — work-tree.md + Obsidian CLI steps
- `config.example.md` — work-tree.md + Obsidian CLI configuration
- `templates/CLAUDE.md` — session-start v3 + session-end v4 references

### How to use
1. Create `work-tree.md` in your workspace root (or `~/work-tree.md` for global)
2. List sub-projects with paths and work_logs availability
3. `/session-start` will auto-detect and load it

### Migration
- No breaking changes. Existing setups work without `work-tree.md`.
- Obsidian CLI is optional — no setup required if not using Obsidian.
- To upgrade: `cp commands/session-start.md ~/.claude/commands/`

---

## v1.0.0 (2026-03-04) — Initial Public Release

### Core Features
- **`/session-start`**: Restore context by loading chatlog + remind + error-rules
- **`/session-end` v3**: Record session + create worklog + Git commit with user confirmation
- **`/init-worklog`**: Initialize work_logs/ structure in any project
- **Error Learning System**: ERR-### error tracking + RUL-### prevention rules (cross-project)
- **Two-Layer Logging**: Project-level detail + optional global dashboard
- **Git Commit Integration**: Session-end commit with auto-generated messages (commit all / selective / skip)

### Optional Features
- Global dashboard (`~/work_logs/`) for cross-project session tracking
- Obsidian sync for worklogs

### Included
- 3 skill commands (`commands/`)
- 5 template files (`templates/`)
- CLAUDE.md template with commit conventions and workflow rules
- Automated installer (`install.sh`)
- Usage examples (`examples/`)

---

## Version Rules

| Change Type | Version | Example |
|-------------|---------|---------|
| New feature/skill | Major (x.0.0) | Add error learning system |
| Improve existing skill | Minor (0.x.0) | Add field to session-end |
| Bug fix/typo | Patch (0.0.x) | Fix path typo |
