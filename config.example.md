# Configuration Guide

## Required Setup

After running `install.sh`, the skill commands are ready to use. No additional configuration needed.

## Optional Features

### Global Dashboard (`~/work_logs/`)

Track all sessions across all projects in a single table.

**Enable**: Select "yes" during `install.sh`, or manually:
```bash
mkdir -p ~/work_logs
```

Then create `~/work_logs/chatlog.md`:
```markdown
# Global Work Dashboard
> One row per session across all projects. Append only.

| Date | Project | Session | Summary | Status |
|------|---------|---------|---------|--------|
```

### Obsidian Sync

Automatically write worklogs to your Obsidian vault.

**Enable**: Add this section to your project's `CLAUDE.md`:
```markdown
### Obsidian Sync
- OBSIDIAN_PATH: /path/to/your/vault/worklogs
```

**Important**: Use the `Write` tool for Obsidian files (not `cp` — may fail on cloud-synced directories like iCloud).

### Git Commit Convention

Default convention is used in `/session-end`:

| Prefix | Use |
|--------|-----|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `docs:` | Documentation |
| `refactor:` | Code improvement |
| `test:` | Tests |
| `chore:` | Config/build |

`/session-end` commits use `Session {N}: {summary}` format.

To customize, modify the Git section in your project's `CLAUDE.md`.
