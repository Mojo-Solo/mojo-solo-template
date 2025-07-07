#!/usr/bin/env bash
set -e

echo "🚀 Setting up Mojo Solo development standards..."
echo ""

# Check if we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not in a git repository. Please run from your project root."
    exit 1
fi

# Get project name for AWS Secrets path
PROJECT_NAME=$(basename "$PWD")

# Create required directories per MojoDevProcess.md
echo "📁 Creating Mojo Solo directory structure..."
mkdir -p .claude/hooks
mkdir -p docs/templates
mkdir -p mocks
mkdir -p storybook
mkdir -p playwright/tests

# Copy hooks from template
TEMPLATE_DIR="$(dirname "$0")/.."
cp "$TEMPLATE_DIR/.claude/hooks/pre-commit-mojo.sh" .claude/hooks/pre-commit.sh 2>/dev/null || true
cp "$TEMPLATE_DIR/.claude/hooks/prepare-commit-msg.sh" .claude/hooks/ 2>/dev/null || true
chmod +x .claude/hooks/*.sh 2>/dev/null || true

# Create symlink to organization rules
if [ ! -f ".claude/CLAUDE-ORG-RULES.mdc" ]; then
    echo "📄 Linking organization rules..."
    ln -s ../../../organisation-rules/CLAUDE-ORG-RULES.mdc .claude/CLAUDE-ORG-RULES.mdc 2>/dev/null || \
    cp "$TEMPLATE_DIR/CLAUDE-ORG-RULES.mdc" .claude/CLAUDE-ORG-RULES.mdc
fi

# Copy BOB CLI wrapper
echo "🔧 Installing BOB CLI wrapper..."
cp "$TEMPLATE_DIR/scripts/bob" ./bob
chmod +x ./bob

# Create required documentation templates
echo "📝 Creating documentation templates..."

cat > docs/templates/postmortem.md << 'EOF'
# Post-Mortem: [Incident Title]

**Date:** [YYYY-MM-DD]
**Severity:** P[0-3]
**Duration:** [XX minutes/hours]
**Author:** [Name]

## Summary
Brief description of what happened.

## Timeline
- **HH:MM** - Issue detected
- **HH:MM** - Investigation started
- **HH:MM** - Root cause identified
- **HH:MM** - Fix deployed
- **HH:MM** - Issue resolved

## Root Cause
Detailed explanation of what caused the issue.

## Impact
- Number of users affected
- Services impacted
- Data loss (if any)

## Resolution
Steps taken to resolve the issue.

## Lessons Learned
What we learned from this incident.

## Action Items
- [ ] Action 1 (Owner: Name, Due: Date)
- [ ] Action 2 (Owner: Name, Due: Date)
EOF

cat > docs/templates/adr-template.md << 'EOF'
# ADR-[NUMBER]: [Title]

**Status:** [Proposed | Accepted | Deprecated | Superseded]
**Date:** [YYYY-MM-DD]

## Context
What is the issue that we're seeing that is motivating this decision?

## Decision
What is the change that we're proposing and/or doing?

## Consequences
What becomes easier or more difficult to do because of this change?
EOF

# Set up basic health endpoint example
if [ -f "package.json" ] && ! grep -q "/health" src/ 2>/dev/null; then
    echo "⚠️  Remember to implement /health endpoint (required by MojoDevProcess.md)"
fi

# Create basic Playwright config if not exists
if [ ! -f "playwright.config.js" ] && [ ! -f "playwright.config.ts" ]; then
    cat > playwright.config.js << 'EOF'
// Playwright config per Mojo Solo standards
const { defineConfig } = require('@playwright/test');

module.exports = defineConfig({
  testDir: './playwright/tests',
  timeout: 30000,
  retries: process.env.CI ? 2 : 0,
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
  ],
});
EOF
fi

# Add standard .gitignore entries
if [ -f ".gitignore" ]; then
    # Add Mojo Solo specific ignores
    grep -q "\.env\.local" .gitignore || echo ".env.local" >> .gitignore
    grep -q "\.claude/settings\.local\.json" .gitignore || echo ".claude/settings.local.json" >> .gitignore
fi

# Create/update CHANGELOG if needed
if [ ! -f "CHANGELOG.md" ]; then
    echo "# Changelog" > CHANGELOG.md
    echo "" >> CHANGELOG.md
    echo "All notable changes to this project will be documented in this file." >> CHANGELOG.md
    echo "" >> CHANGELOG.md
    echo "## [Unreleased]" >> CHANGELOG.md
    echo "" >> CHANGELOG.md
fi

# Remind about AWS Secrets setup
echo ""
echo "⚠️  AWS Secrets Manager Setup Required:"
echo "   1. Ensure secrets exist at: /mojosolo/$PROJECT_NAME/[dev|staging|prod]/*"
echo "   2. Use 'aws-vault exec dev -- bob run dev' for local development"
echo ""

echo "✅ Mojo Solo standards installed!"
echo ""
echo "What's been set up:"
echo "  📋 Pre-commit hooks (Mojo Solo standards)"
echo "  🔧 BOB CLI wrapper"
echo "  📄 Organization rules (.claude/CLAUDE-ORG-RULES.mdc)"
echo "  📝 Documentation templates"
echo "  🎭 Playwright configuration"
echo ""
echo "Next steps:"
echo "  1. Run './bob lint' to check your code"
echo "  2. Implement /health endpoint"
echo "  3. Set up Storybook if UI project"
echo "  4. Configure AWS Secrets Manager"
echo ""
echo "📚 See MojoDevProcess.md for complete standards"