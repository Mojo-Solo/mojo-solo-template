#!/usr/bin/env bash
set -e

echo "🚀 Setting up Claude Code hooks for cleaner repos!"
echo ""

# Check if we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not in a git repository. Please run from your project root."
    exit 1
fi

# Create .claude directory if it doesn't exist
mkdir -p .claude/hooks

# Copy hooks from template
TEMPLATE_DIR="$(dirname "$0")/.."
cp -r "$TEMPLATE_DIR/.claude/hooks/"* .claude/hooks/ 2>/dev/null || true

# Make hooks executable
chmod +x .claude/hooks/*.sh 2>/dev/null || true

# Create basic CHANGELOG if it doesn't exist
if [ ! -f "CHANGELOG.md" ]; then
    echo "# Changelog" > CHANGELOG.md
    echo "" >> CHANGELOG.md
    echo "## [Unreleased]" >> CHANGELOG.md
    echo "" >> CHANGELOG.md
fi

# Add .claude to .gitignore if not already there
if [ -f ".gitignore" ]; then
    if ! grep -q "^\.claude/settings\.local\.json" .gitignore; then
        echo "" >> .gitignore
        echo "# Claude Code local settings" >> .gitignore
        echo ".claude/settings.local.json" >> .gitignore
    fi
fi

echo "✅ Claude Code hooks installed!"
echo ""
echo "What you just got:"
echo "  🔍 Pre-commit checks (linting, tests, security)"
echo "  📝 Automatic commit message formatting"
echo "  📋 Automatic changelog updates"
echo ""
echo "Next steps:"
echo "1. Make a test commit to see it in action"
echo "2. Customize hooks in .claude/hooks/ for your needs"
echo "3. Run 'claude code' to start using Claude with these hooks"
echo ""
echo "🎉 No more sloppy commits!"