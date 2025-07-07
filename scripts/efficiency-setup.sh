#!/usr/bin/env bash
# Mojo Solo Efficiency Setup - Adds advanced automation features

set -e

echo "🚀 Mojo Solo Efficiency Setup"
echo "============================="
echo ""

# Check if in git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not in a git repository!"
    exit 1
fi

PROJECT_NAME=$(basename "$PWD")

echo "📦 Installing efficiency features for $PROJECT_NAME..."
echo ""

# 1. Vercel Configuration
if [ -f "package.json" ] && grep -q "vite\|next\|react" package.json; then
    echo "1️⃣ Setting up Vercel configuration..."
    
    cat > vercel.json << 'EOF'
{
  "framework": "vite",
  "buildCommand": "npm run build",
  "outputDirectory": "dist",
  "installCommand": "npm install",
  "devCommand": "npm run dev",
  "github": {
    "enabled": true,
    "autoAlias": true
  },
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "X-Vercel-Toolbar",
          "value": "1"
        }
      ]
    }
  ]
}
EOF
    echo "   ✅ Vercel config created"
fi

# 2. CODEOWNERS
echo "2️⃣ Setting up CODEOWNERS..."
mkdir -p .github
cat > .github/CODEOWNERS << 'EOF'
# Mojo Solo Code Ownership
# Default owners for everything
* @Mojo-Solo/core-team

# Frontend
/src/ @Mojo-Solo/frontend-team
/components/ @Mojo-Solo/frontend-team
/pages/ @Mojo-Solo/frontend-team
*.tsx @Mojo-Solo/frontend-team
*.jsx @Mojo-Solo/frontend-team
*.css @Mojo-Solo/frontend-team
*.scss @Mojo-Solo/frontend-team

# Backend
/api/ @Mojo-Solo/backend-team
/server/ @Mojo-Solo/backend-team
/services/ @Mojo-Solo/backend-team
*.php @Mojo-Solo/backend-team
*.py @Mojo-Solo/backend-team

# Infrastructure & DevOps
/.github/ @Mojo-Solo/devops-team
/scripts/ @Mojo-Solo/devops-team
*.yml @Mojo-Solo/devops-team
*.yaml @Mojo-Solo/devops-team
Dockerfile @Mojo-Solo/devops-team
docker-compose.yml @Mojo-Solo/devops-team

# Documentation
*.md @Mojo-Solo/core-team
/docs/ @Mojo-Solo/core-team
EOF
echo "   ✅ CODEOWNERS configured"

# 3. Auto-fix workflows
echo "3️⃣ Adding auto-fix workflows..."
cp -r "$(dirname "$0")/../.github/workflows/auto-lint.yml" .github/workflows/ 2>/dev/null || true
cp -r "$(dirname "$0")/../.github/workflows/pr-feedback.yml" .github/workflows/ 2>/dev/null || true
echo "   ✅ Workflows added"

# 4. Prettier configuration
if [ -f "package.json" ]; then
    echo "4️⃣ Setting up Prettier..."
    
    # Add prettier config
    cat > .prettierrc.js << 'EOF'
module.exports = {
  semi: true,
  trailingComma: 'es5',
  singleQuote: true,
  printWidth: 100,
  tabWidth: 2,
  useTabs: false,
  arrowParens: 'always',
  endOfLine: 'lf',
};
EOF

    # Add prettier ignore
    cat > .prettierignore << 'EOF'
node_modules
dist
build
coverage
.next
.nuxt
*.min.js
*.min.css
EOF

    # Update package.json scripts
    if ! grep -q "format" package.json; then
        npm pkg set scripts.format="prettier --write \"src/**/*.{ts,tsx,js,jsx,json,css,md}\""
        npm pkg set scripts.lint:fix="eslint . --ext ts,tsx,js,jsx --fix"
    fi
    
    echo "   ✅ Prettier configured"
fi

# 5. VS Code settings
echo "5️⃣ Adding VS Code settings..."
mkdir -p .vscode
cat > .vscode/settings.json << 'EOF'
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "typescript.preferences.importModuleSpecifier": "relative",
  "files.eol": "\n",
  "typescript.tsdk": "node_modules/typescript/lib",
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  ]
}
EOF

# VS Code extensions recommendations
cat > .vscode/extensions.json << 'EOF'
{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "eamodio.gitlens",
    "github.copilot",
    "ms-vscode.vscode-typescript-next",
    "bradlc.vscode-tailwindcss"
  ]
}
EOF
echo "   ✅ VS Code configured"

# 6. Dependabot
echo "6️⃣ Setting up Dependabot..."
cat > .github/dependabot.yml << 'EOF'
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
    assignees:
      - "Mojo-Solo/core-team"
    labels:
      - "dependencies"
      - "bot"
    open-pull-requests-limit: 10
    groups:
      development:
        patterns:
          - "@types/*"
          - "eslint*"
          - "prettier*"
          - "*-dev"

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "monthly"
    labels:
      - "ci/cd"
      - "bot"
EOF
echo "   ✅ Dependabot configured"

# 7. PR and Issue templates
echo "7️⃣ Adding PR and Issue templates..."
mkdir -p .github/ISSUE_TEMPLATE

# Bug report template
cat > .github/ISSUE_TEMPLATE/bug_report.md << 'EOF'
---
name: Bug report
about: Create a report to help us improve
title: '[BUG] '
labels: 'bug, needs-triage'
assignees: ''
---

## Bug Description
A clear and concise description of what the bug is.

## Steps to Reproduce
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

## Expected Behavior
What you expected to happen.

## Actual Behavior
What actually happened.

## Screenshots
If applicable, add screenshots.

## Environment
- Browser: [e.g. Chrome 91]
- OS: [e.g. macOS 11.4]
- Version: [e.g. 1.0.0]

## Additional Context
Add any other context about the problem here.
EOF

# Feature request template
cat > .github/ISSUE_TEMPLATE/feature_request.md << 'EOF'
---
name: Feature request
about: Suggest an idea for this project
title: '[FEATURE] '
labels: 'enhancement, needs-triage'
assignees: ''
---

## Problem Statement
A clear description of the problem you're trying to solve.

## Proposed Solution
Your suggested solution.

## Alternatives Considered
Other solutions you've considered and why you prefer your proposal.

## Additional Context
Any other context, mockups, or examples.
EOF

# PR template
cat > .github/pull_request_template.md << 'EOF'
## Summary
Brief description of what this PR does.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] I have tested locally
- [ ] I have added tests that prove my fix/feature works
- [ ] New and existing unit tests pass locally

## Checklist
- [ ] My code follows the Mojo Solo style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] Any dependent changes have been merged and published

## Screenshots (if appropriate)
Add screenshots to help explain your changes.

## Related Issues
Closes #(issue number)
EOF
echo "   ✅ Templates added"

# 8. Create efficiency commands in BOB
echo "8️⃣ Updating BOB with efficiency commands..."
if [ -f "./bob" ]; then
    # Add new commands to BOB (would need to modify the actual file)
    echo "   ℹ️  BOB already exists - manual update needed for new commands"
fi

# Final message
echo ""
echo "✅ Efficiency setup complete!"
echo ""
echo "🎯 What's been added:"
echo "   • Vercel configuration for preview deployments"
echo "   • CODEOWNERS for automatic review assignment"
echo "   • Auto-fixing GitHub Actions"
echo "   • PR feedback bot"
echo "   • Prettier formatting"
echo "   • VS Code settings"
echo "   • Dependabot for dependencies"
echo "   • Issue and PR templates"
echo ""
echo "📝 Next steps:"
echo "   1. Commit these changes: git add -A && git commit -m 'feat: Add efficiency tools'"
echo "   2. Set up branch protection: ./scripts/setup-branch-protection.sh $PROJECT_NAME"
echo "   3. Install prettier: npm install --save-dev prettier"
echo "   4. Configure Vercel project at vercel.com"
echo ""
echo "🚀 Your development workflow is now supercharged!"