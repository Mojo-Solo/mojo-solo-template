#!/usr/bin/env bash

# Use Claude Code's ripgrep if available
RG="/opt/homebrew/lib/node_modules/@anthropic-ai/claude-code/vendor/ripgrep/arm64-darwin/rg"
if [ ! -x "$RG" ]; then
    RG="rg"  # Fall back to system ripgrep
fi

echo "🔍 Running pre-commit checks..."

ISSUES_FOUND=0

# Check for console.logs
echo "📋 Checking for console.log statements..."
CONSOLE_FOUND=$($RG "console\.(log|debug|info)" --type js . 2>/dev/null || echo "")
if [ -n "$CONSOLE_FOUND" ]; then
    echo "$CONSOLE_FOUND"
    echo "❌ Found console.log statements - remove these before committing!"
    ISSUES_FOUND=1
fi

# Check for TODOs without issue numbers
echo "📋 Checking for TODOs without issue numbers..."
TODOS_FOUND=$($RG "TODO|FIXME" --glob '!*.md' . 2>/dev/null | grep -v "#[0-9]" || echo "")
if [ -n "$TODOS_FOUND" ]; then
    echo "$TODOS_FOUND"
    echo "❌ Found TODO/FIXME without issue numbers - add issue numbers!"
    ISSUES_FOUND=1
fi

# Check for secrets
echo "🔐 Checking for potential secrets..."
SECRETS_FOUND=$($RG -i "API_KEY.*=.*['\"]" . 2>/dev/null || echo "")
if [ -n "$SECRETS_FOUND" ]; then
    echo "$SECRETS_FOUND"
    echo "❌ Found potential secrets in code!"
    ISSUES_FOUND=1
fi

if [ $ISSUES_FOUND -eq 0 ]; then
    echo "✅ All checks passed!"
else
    echo ""
    echo "❌ Pre-commit failed! Fix the issues above and try again."
    exit 1
fi