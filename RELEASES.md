# Releases

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
