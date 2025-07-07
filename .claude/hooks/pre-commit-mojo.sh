#!/usr/bin/env bash

# Mojo Solo Pre-commit Hook - Enforces organizational standards
# Based on MojoDevProcess.md v1.1

echo "🔍 Running Mojo Solo pre-commit checks..."

# Use Claude Code's ripgrep if available
RG="/opt/homebrew/lib/node_modules/@anthropic-ai/claude-code/vendor/ripgrep/arm64-darwin/rg"
if [ ! -x "$RG" ]; then
    RG="rg"
fi

ISSUES_FOUND=0

# 1. Check branch naming convention
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ ! "$CURRENT_BRANCH" =~ ^(main|staging|feat/[A-Z]+-[0-9]+.*|hotfix/[A-Z]+-[0-9]+.*)$ ]]; then
    echo "❌ Branch name doesn't follow Mojo Solo convention: feat/<ticket> or hotfix/<id>"
    echo "   Current branch: $CURRENT_BRANCH"
    ISSUES_FOUND=1
fi

# 2. Standard code quality checks
echo "📋 Running code quality checks..."

# Console.logs (exclude test files, utils, and logger service)
CONSOLE_FOUND=$($RG "console\.(log|debug|info)" --type js --type ts \
    --glob '!*.test.*' --glob '!*.spec.*' --glob '!**/tests/**' --glob '!**/utils/**' \
    --glob '!test-*.js' --glob '!test-*.ts' --glob '!**/contexts/**' --glob '!**/logger.*' . 2>/dev/null || echo "")
if [ -n "$CONSOLE_FOUND" ]; then
    echo "$CONSOLE_FOUND"
    echo "❌ Found console.log statements - remove these before committing!"
    ISSUES_FOUND=1
fi

# TODOs without issue numbers (only check staged files)
STAGED_FILES=$(git diff --cached --name-only --diff-filter=AM | grep -E '\.(js|ts|tsx|jsx|php|py)$' || echo "")
TODOS_FOUND=""
if [ -n "$STAGED_FILES" ]; then
    TODOS_FOUND=$(echo "$STAGED_FILES" | xargs -r $RG "TODO|FIXME" 2>/dev/null | grep -v "#[0-9]" || echo "")
fi
if [ -n "$TODOS_FOUND" ]; then
    echo "$TODOS_FOUND"
    echo "❌ Found TODO/FIXME without issue numbers!"
    ISSUES_FOUND=1
fi

# 3. Security checks per Mojo Solo standards
echo "🔐 Running security checks..."

# Check for hardcoded secrets (only staged files)
SECRETS_FOUND=""
if [ -n "$STAGED_FILES" ]; then
    SECRETS_FOUND=$(echo "$STAGED_FILES" | xargs -r $RG -i "(api[_-]?key|api[_-]?secret|private[_-]?key|aws[_-]?access).*=.*['\"]" 2>/dev/null || echo "")
fi
if [ -n "$SECRETS_FOUND" ]; then
    echo "$SECRETS_FOUND"
    echo "❌ Found potential secrets! Use AWS Secrets Manager instead."
    ISSUES_FOUND=1
fi

# Check for non-AWS secret management tools (forbidden per MojoDevProcess)
FORBIDDEN_SECRETS=$($RG -i "doppler|vault|1password" --glob '!*.md' --glob '!bob' --glob '!**/scripts/**' . 2>/dev/null || echo "")
if [ -n "$FORBIDDEN_SECRETS" ]; then
    echo "$FORBIDDEN_SECRETS"
    echo "❌ Found forbidden secret management tools! Only AWS Secrets Manager is allowed."
    ISSUES_FOUND=1
fi

# 4. Check for Docker usage (forbidden per directive)
echo "📦 Checking for forbidden technologies..."
DOCKER_FOUND=$($RG -i "dockerfile|docker-compose" . 2>/dev/null || echo "")
if [ -n "$DOCKER_FOUND" ]; then
    echo "$DOCKER_FOUND"
    echo "❌ Docker is forbidden! Use native binaries with systemd or Forge scripts."
    ISSUES_FOUND=1
fi

# 5. Run BOB lint if available
if command -v bob &> /dev/null; then
    echo "🧹 Running bob lint..."
    if ! bob lint; then
        echo "❌ BOB lint failed!"
        ISSUES_FOUND=1
    fi
elif [ -f "package.json" ]; then
    # Fallback to standard linting
    echo "🧹 Running linter..."
    if npm run lint --if-present >/dev/null 2>&1; then
        npm run lint || { echo "❌ Linting failed"; ISSUES_FOUND=1; }
    fi
fi

# 6. Check for required files per Mojo Solo standards
echo "📄 Checking required files..."

# Check for health endpoint in API files
if [ -d "app" ] || [ -d "src" ]; then
    HEALTH_ENDPOINT=$($RG "/(health|healthz)" --type js --type ts --type php . 2>/dev/null || echo "")
    if [ -z "$HEALTH_ENDPOINT" ]; then
        echo "⚠️  Warning: No health endpoint found. All apps must have /health endpoint."
    fi
fi

# 7. Asset size checks (performance standards)
echo "📏 Checking asset sizes..."
if [ -d "public/build" ] || [ -d "dist" ]; then
    LARGE_JS=$(find public/build dist -name "*.js" -size +250k 2>/dev/null || true)
    if [ -n "$LARGE_JS" ]; then
        echo "⚠️  Warning: JS bundles exceed 250KB limit:"
        echo "$LARGE_JS"
    fi
fi

# 8. Check for .cursor rules (forbidden - must use .claude)
CURSOR_FOUND=$(find . -name ".cursorrules" -o -name ".cursor" 2>/dev/null || echo "")
if [ -n "$CURSOR_FOUND" ]; then
    echo "$CURSOR_FOUND"
    echo "❌ Found .cursor rules! Use .claude/*.mdc instead."
    ISSUES_FOUND=1
fi

# Final status
if [ $ISSUES_FOUND -eq 0 ]; then
    echo "✅ All Mojo Solo pre-commit checks passed!"
else
    echo ""
    echo "❌ Pre-commit failed! Fix the issues above and try again."
    echo ""
    echo "📚 See MojoDevProcess.md for full standards."
    exit 1
fi