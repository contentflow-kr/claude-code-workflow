#!/bin/bash
# claude-code-workflow v2.0 installer
# Installs 5 skill commands + global work_logs + work-tree.md

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"

echo "=== claude-code-workflow v2.0 installer ==="
echo ""

# Check if ~/.claude exists
if [ ! -d "$CLAUDE_DIR" ]; then
    echo "Error: ~/.claude/ not found. Is Claude Code installed?"
    echo "Install Claude Code first: https://docs.anthropic.com/en/docs/claude-code"
    exit 1
fi

# Create commands directory if needed
mkdir -p "$COMMANDS_DIR"

# Copy skill commands
echo "Installing skill commands..."
for file in "$SCRIPT_DIR/commands"/*.md; do
    filename=$(basename "$file")
    if [ -f "$COMMANDS_DIR/$filename" ]; then
        echo "  [SKIP] $filename (already exists — use --force to overwrite)"
    else
        cp "$file" "$COMMANDS_DIR/$filename"
        echo "  [OK]   $filename"
    fi
done

# Handle --force flag
if [[ "$1" == "--force" ]]; then
    echo ""
    echo "Force mode: overwriting existing commands..."
    for file in "$SCRIPT_DIR/commands"/*.md; do
        filename=$(basename "$file")
        cp "$file" "$COMMANDS_DIR/$filename"
        echo "  [OK]   $filename (overwritten)"
    done
fi

echo ""

# Create master work-tree.md (if not exists)
if [ ! -f "$HOME/work-tree.md" ]; then
    cp "$SCRIPT_DIR/templates/work-tree.md" "$HOME/work-tree.md"
    echo "[OK] ~/work-tree.md created (project navigation map)"
else
    echo "[SKIP] ~/work-tree.md already exists"
fi

echo ""

# Global work_logs dashboard
read -p "Enable global dashboard (~/work_logs/)? [Y/n] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    mkdir -p "$HOME/work_logs"

    if [ ! -f "$HOME/work_logs/chatlog.md" ]; then
        cat > "$HOME/work_logs/chatlog.md" << 'DASHBOARD'
# Global Work Dashboard
> One row per session across all projects. Append only.

| Date | Project | Session | Summary | Status |
|------|---------|---------|---------|--------|
DASHBOARD
        echo "  [OK] ~/work_logs/chatlog.md (dashboard)"
    fi

    if [ ! -f "$HOME/work_logs/error-rules.md" ]; then
        cat > "$HOME/work_logs/error-rules.md" << 'RULES'
# Global Error Prevention Rules
> Shared across all projects. Auto-loaded at session start.

| ID | Rule | Caused By |
|----|------|-----------|
RULES
        echo "  [OK] ~/work_logs/error-rules.md (shared rules)"
    fi

    if [ ! -f "$HOME/work_logs/error_logs.md" ]; then
        cat > "$HOME/work_logs/error_logs.md" << 'ERRORS'
# Global Error Index
> Cross-project error tracking.

| ID | Date | Project | Error Summary | Resolution | Rule |
|----|------|---------|---------------|------------|------|
ERRORS
        echo "  [OK] ~/work_logs/error_logs.md (error index)"
    fi

    if [ ! -f "$HOME/work_logs/remind.md" ]; then
        cat > "$HOME/work_logs/remind.md" << 'REMIND'
# Global Work Rules
> Rules that apply to all projects.

## Rules
- To be added
REMIND
        echo "  [OK] ~/work_logs/remind.md (global rules)"
    fi

    echo "  Global dashboard enabled."
fi

echo ""

# Optional: Obsidian sync
read -p "Enable Obsidian worklog sync? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter your Obsidian vault worklog path: " OBSIDIAN_PATH
    OBSIDIAN_PATH="${OBSIDIAN_PATH/#\~/$HOME}"

    if [ -d "$OBSIDIAN_PATH" ]; then
        echo ""
        echo "  Add this to your project's CLAUDE.md or ~/.claude/CLAUDE.md:"
        echo ""
        echo "    ### Obsidian Sync"
        echo "    - OBSIDIAN_WORKLOG_PATH: $OBSIDIAN_PATH"
        echo ""
    else
        echo "  Warning: Path not found: $OBSIDIAN_PATH"
        echo "  You can configure this later in your CLAUDE.md"
    fi
fi

echo ""
echo "=== Installation complete ==="
echo ""
echo "Installed 5 skills:"
echo "  /init-worklog      — Add work_logs to existing project + register in work-tree"
echo "  /init-project-v1   — Quick project scaffolding (blank templates)"
echo "  /init-project-v2   — Detailed project setup (real docs content)"
echo "  /session-start     — Restore context at session start"
echo "  /session-end       — Record session + worklog + Git commit"
echo ""
echo "Quick start:"
echo "  1. Open a project in Claude Code"
echo "  2. Run /init-worklog (or /init-project-v1 for new projects)"
echo "  3. Start working, then /session-end when done"
echo "  4. Next session: /session-start to pick up where you left off"
echo ""
echo "For more info: https://github.com/contentflow-kr/claude-code-workflow"
