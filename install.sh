#!/bin/bash
# claude-code-workflow installer
# Copies skill commands to ~/.claude/commands/

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"

echo "=== claude-code-workflow installer ==="
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
        echo "  [SKIP] $filename (already exists)"
    else
        cp "$file" "$COMMANDS_DIR/$filename"
        echo "  [OK]   $filename"
    fi
done

echo ""

# Optional: Global work_logs dashboard
read -p "Enable global dashboard (~/work_logs/)? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
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

    echo "  Global dashboard enabled."
fi

echo ""

# Optional: Obsidian sync
read -p "Enable Obsidian sync? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter your Obsidian vault path (e.g., ~/Documents/Obsidian/Vault): " OBSIDIAN_PATH
    OBSIDIAN_PATH="${OBSIDIAN_PATH/#\~/$HOME}"

    if [ -d "$OBSIDIAN_PATH" ]; then
        echo ""
        echo "  Obsidian path: $OBSIDIAN_PATH"
        echo "  Add this to your project's CLAUDE.md:"
        echo ""
        echo "    ### [Optional] Obsidian Sync"
        echo "    - OBSIDIAN_PATH: $OBSIDIAN_PATH"
        echo ""
    else
        echo "  Warning: Path not found: $OBSIDIAN_PATH"
        echo "  You can configure this later in your CLAUDE.md"
    fi
fi

echo ""
echo "=== Installation complete ==="
echo ""
echo "Usage:"
echo "  /session-start    - Restore context at session start"
echo "  /session-end      - Record session + Git commit"
echo "  /init-worklog     - Initialize work_logs/ in a project"
echo ""
echo "For more info: https://github.com/contentflow-kr/claude-code-workflow"
