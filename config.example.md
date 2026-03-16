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

### Work-Tree Project Map (v1.1.0+)

Create `work-tree.md` in your workspace root to enable cross-project navigation:

```markdown
# My Workspace Work-Tree

| Project | Path | work_logs | Description |
|---------|------|-----------|-------------|
| my-app | `projects/my-app/` | O | Main application |
| api-server | `projects/api-server/` | O | Backend API |
| docs | `projects/docs/` | X | Documentation |
```

Or create a master index at `~/work-tree.md` for all workspaces.

`/session-start` searches: current dir → parent (3 levels) → `~/work-tree.md`

### Obsidian CLI (v4, optional)

If you use Obsidian with [Obsidian CLI](https://github.com/anthropics/obsidian-cli):
- `/session-end` will append session summary to your Daily Note
- Reports vault-wide unfinished task count
- Fails silently if CLI unavailable

No configuration needed — auto-detected at runtime.

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
