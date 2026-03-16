# Workflow Architecture

## Lifecycle

```
New project
    │
    ▼
/init-worklog (once)          ← Install recording infrastructure
or /init-project-v1/v2        ← Full project setup (includes init-worklog)
    │
    ▼
/session-start (every time)   ← Restore previous context
    │
    ▼
Work normally
    │
    ▼
/session-end (every time)     ← Record + worklog + Git commit
```

## 5 Skills

| Skill | Version | Purpose | When to use |
|-------|---------|---------|-------------|
| `/init-worklog` | v2 | Create work_logs/ + register in work-tree.md | Add recording to existing project |
| `/init-project-v1` | v1 | Blank template scaffolding | Quick start, hackathon |
| `/init-project-v2` | v1 | Guided questions → real docs | Serious project setup |
| `/session-start` | v3 | Restore previous context | Every session start |
| `/session-end` | v4 | Record + worklog + Obsidian + Git | Every session end |

### init skills relationship

```
/init-worklog    = work_logs/ only (30 seconds)
/init-project-v1 = scaffolding + work_logs/ (5 minutes)
/init-project-v2 = design + docs/ + work_logs/ (30 minutes)
                   └── includes /init-worklog internally
```

## Two-Layer File System

### Global layer (~/home)

```
~/
├── work-tree.md              # Master project navigation map
├── work_logs/
│   ├── chatlog.md            # One row per session (all projects)
│   ├── error_logs.md         # Cross-project error index
│   ├── error-rules.md        # Shared prevention rules
│   └── remind.md             # Global work rules
└── .claude/commands/         # Skill files
```

### Project layer

```
{project}/
├── work_logs/
│   ├── chatlog.md            # Detailed session records
│   ├── remind.md             # Project-specific rules
│   ├── error_logs.md         # Project errors (ERR-###)
│   ├── error-rules.md        # Project rules (RUL-###)
│   ├── CHANGELOG.md          # Change history
│   └── YYYY_MM_DD_*_worklog.md  # Dated worklogs
└── CLAUDE.md                 # Project context (auto-loaded)
```

## Auto-loading

| File | Loaded by | When |
|------|-----------|------|
| `~/.claude/CLAUDE.md` | Claude Code (auto) | Session start |
| `{project}/CLAUDE.md` | Claude Code (auto) | Enter project dir |
| `work-tree.md` | /session-start | Skill execution |
| `remind.md` | /session-start | Skill execution |
| `error-rules.md` | /session-start | Skill execution |
| `chatlog.md` | /session-start | Skill execution |

## Version History

| Skill | Current | Changes |
|-------|---------|---------|
| `/init-worklog` | **v3** | v1: create work_logs → v2: + work-tree.md → v3: + hooks setup |
| `/init-project-v1` | v1 | Blank template scaffolding |
| `/init-project-v2` | v1 | Guided setup with real docs |
| `/session-start` | **v3** | v1: basic → v2: global mode → v3: + work-tree.md |
| `/session-end` | **v5** | v1: basic → v2: two-layer → v3: + Git → v4: + Obsidian CLI → v5: + tags |
