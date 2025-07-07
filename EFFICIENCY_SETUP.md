# Mojo Solo Efficiency Setup 🚀

This guide adds advanced automation to make your development process ultra-efficient.

## 1. Vercel Toolbar for Frontend Feedback

### Setup Vercel Integration

Add to your frontend projects:

```json
// vercel.json
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
```

### Enable Visual Feedback

```typescript
// src/main.tsx or App.tsx
if (import.meta.env.VITE_VERCEL_ENV) {
  // Enable Vercel toolbar
  window.__VERCEL_TOOLBAR_ENABLED__ = true;
}
```

### Environment Setup

```bash
# .env.production
VITE_VERCEL_ENV=1
VITE_VERCEL_COMMENTS=1
```

## 2. GitHub Teams Configuration

### Create Team Structure

```yaml
# .github/CODEOWNERS
# Global owners
* @Mojo-Solo/core-team

# Frontend
/src/ @Mojo-Solo/frontend-team
/components/ @Mojo-Solo/frontend-team
*.tsx @Mojo-Solo/frontend-team
*.css @Mojo-Solo/frontend-team

# Backend
/api/ @Mojo-Solo/backend-team
/services/ @Mojo-Solo/backend-team
*.php @Mojo-Solo/backend-team

# Infrastructure
/.github/ @Mojo-Solo/devops-team
/scripts/ @Mojo-Solo/devops-team
*.yml @Mojo-Solo/devops-team
```

### Team Permissions Script

```bash
#!/usr/bin/env bash
# scripts/setup-teams.sh

echo "Setting up GitHub teams for Mojo-Solo..."

# Create teams if they don't exist
gh api orgs/Mojo-Solo/teams -X POST -f name="core-team" -f privacy="closed" || true
gh api orgs/Mojo-Solo/teams -X POST -f name="frontend-team" -f privacy="closed" || true
gh api orgs/Mojo-Solo/teams -X POST -f name="backend-team" -f privacy="closed" || true
gh api orgs/Mojo-Solo/teams -X POST -f name="devops-team" -f privacy="closed" || true

echo "Teams created! Add members via GitHub UI"
```

## 3. Enhanced GitHub Actions with Auto-Fix

### Auto-Linting Workflow

```yaml
# .github/workflows/auto-lint.yml
name: Auto-Fix Linting

on:
  pull_request:
    types: [opened, synchronize]

permissions:
  contents: write
  pull-requests: write

jobs:
  auto-fix:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          ref: ${{ github.head_ref }}

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run auto-fix
        run: |
          npm run lint:fix || true
          npm run format || true

      - name: Check for changes
        id: check-changes
        run: |
          if [[ -n $(git status --porcelain) ]]; then
            echo "changes=true" >> $GITHUB_OUTPUT
          else
            echo "changes=false" >> $GITHUB_OUTPUT
          fi

      - name: Commit fixes
        if: steps.check-changes.outputs.changes == 'true'
        run: |
          git config --local user.email "bot@mojo-solo.com"
          git config --local user.name "Mojo Bot"
          git add -A
          git commit -m "🤖 Auto-fix: Lint and format code"
          git push
```

### PR Comment Bot

```yaml
# .github/workflows/pr-feedback.yml
name: PR Feedback

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  feedback:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run checks
        id: checks
        run: |
          # Count various metrics
          echo "files=$(git diff --name-only origin/main..HEAD | wc -l)" >> $GITHUB_OUTPUT
          echo "additions=$(git diff --stat origin/main..HEAD | tail -1 | awk '{print $4}')" >> $GITHUB_OUTPUT
          echo "deletions=$(git diff --stat origin/main..HEAD | tail -1 | awk '{print $6}')" >> $GITHUB_OUTPUT

      - name: Comment PR
        uses: actions/github-script@v7
        with:
          script: |
            const { files, additions, deletions } = ${{ toJson(steps.checks.outputs) }};
            
            const body = `## 📊 PR Summary
            
            - **Files changed**: ${files}
            - **Lines added**: ${additions || 0}
            - **Lines removed**: ${deletions || 0}
            
            ### ✅ Automated Checks
            - Pre-commit hooks: Passed
            - Linting: Auto-fixed
            - Tests: Running...
            
            ### 🔗 Preview Links
            - Vercel: Deploying...
            - Storybook: Building...
            
            ### 👀 Review Checklist
            - [ ] Code follows Mojo Solo standards
            - [ ] Tests are passing
            - [ ] Documentation updated
            - [ ] No console.logs in production code`;
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: body
            });
```

## 4. Branch Protection Rules

### Automated Setup Script

```bash
#!/usr/bin/env bash
# scripts/setup-branch-protection.sh

REPO=$1
if [ -z "$REPO" ]; then
  echo "Usage: ./setup-branch-protection.sh <repo-name>"
  exit 1
fi

echo "🔒 Setting up branch protection for $REPO..."

# Protect main branch
gh api repos/Mojo-Solo/$REPO/branches/main/protection -X PUT \
  --raw-field='
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "Lint + Type Check",
      "Unit + Integration Tests",
      "Security Scan",
      "E2E Tests (Playwright)"
    ]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismissal_restrictions": {
      "users": [],
      "teams": ["core-team"]
    },
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true,
    "required_approving_review_count": 1,
    "require_last_push_approval": true
  },
  "restrictions": {
    "users": [],
    "teams": ["core-team"],
    "apps": []
  },
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": true,
  "lock_branch": false,
  "allow_fork_syncing": false
}'

# Protect staging branch
gh api repos/Mojo-Solo/$REPO/branches/staging/protection -X PUT \
  --raw-field='
{
  "required_status_checks": {
    "strict": false,
    "contexts": [
      "Lint + Type Check",
      "Unit + Integration Tests"
    ]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}'

echo "✅ Branch protection configured!"
```

## 5. Complete Efficiency Package

### Add to package.json

```json
{
  "scripts": {
    "lint": "eslint . --ext ts,tsx --report-unused-disable-directives --max-warnings 0",
    "lint:fix": "eslint . --ext ts,tsx --fix",
    "format": "prettier --write \"src/**/*.{ts,tsx,js,jsx,json,css,md}\"",
    "typecheck": "tsc --noEmit",
    "precommit": "lint-staged",
    "prepare": "husky install"
  },
  "lint-staged": {
    "*.{ts,tsx,js,jsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{json,css,md}": [
      "prettier --write"
    ]
  },
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged"
    }
  }
}
```

### Prettier Config

```javascript
// .prettierrc.js
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
```

### VS Code Settings

```json
// .vscode/settings.json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "typescript.preferences.importModuleSpecifier": "relative",
  "files.eol": "\n"
}
```

## 6. Automated PR Workflow

### Dependabot Config

```yaml
# .github/dependabot.yml
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
    open-pull-requests-limit: 10
    groups:
      development:
        patterns:
          - "@types/*"
          - "eslint*"
          - "prettier*"
```

### Auto-merge for Dependencies

```yaml
# .github/workflows/auto-merge.yml
name: Auto-merge Dependabot

on:
  pull_request:
    types: [opened, synchronize]

permissions:
  contents: write
  pull-requests: write

jobs:
  auto-merge:
    runs-on: ubuntu-latest
    if: github.actor == 'dependabot[bot]'
    steps:
      - name: Auto-merge patch updates
        uses: actions/github-script@v7
        with:
          script: |
            const pr = context.payload.pull_request;
            const updateType = pr.title.match(/bump .* from .* to (.*)/)?.[1];
            
            if (updateType && updateType.match(/^\d+\.\d+\.\d+$/)) {
              const [major1, minor1, patch1] = pr.title.match(/from (\d+)\.(\d+)\.(\d+)/).slice(1);
              const [major2, minor2, patch2] = pr.title.match(/to (\d+)\.(\d+)\.(\d+)/).slice(1);
              
              // Auto-merge patch and minor updates
              if (major1 === major2) {
                await github.rest.pulls.merge({
                  owner: context.repo.owner,
                  repo: context.repo.repo,
                  pull_number: pr.number,
                  merge_method: 'squash'
                });
              }
            }
```

## 7. Monitoring Dashboard

### Status Badge Setup

Add to README.md:

```markdown
![CI Status](https://github.com/Mojo-Solo/repo-name/workflows/Required%20CI%20Checks/badge.svg)
![Security](https://github.com/Mojo-Solo/repo-name/workflows/Security%20Scan/badge.svg)
![Coverage](https://codecov.io/gh/Mojo-Solo/repo-name/branch/main/graph/badge.svg)
![Uptime](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/Mojo-Solo/status/main/api/repo-name/uptime.json)
```

## Quick Implementation

Run this to add all efficiency features:

```bash
# In your repo
curl -sL https://raw.githubusercontent.com/Mojo-Solo/mojo-solo-template/main/scripts/efficiency-setup.sh | bash
```

This will:
1. ✅ Add Vercel configuration
2. ✅ Create CODEOWNERS file
3. ✅ Set up auto-fixing workflows
4. ✅ Configure branch protection
5. ✅ Add PR automation
6. ✅ Install formatting tools

Your team will love how smooth this makes development!