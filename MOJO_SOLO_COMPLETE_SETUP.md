# Mojo Solo Complete Setup Guide

This template now incorporates ALL requirements from MojoDevProcess.md v1.1

## What's Included

### 1. Enhanced Pre-commit Hooks (`pre-commit-mojo.sh`)
- ✅ Branch naming validation (feat/<ticket>, hotfix/<id>)
- ✅ No Docker check (forbidden per standards)
- ✅ AWS Secrets Manager enforcement (no Doppler/Vault)
- ✅ No .cursor rules (must use .claude)
- ✅ Asset size warnings (<250KB JS bundles)
- ✅ Health endpoint reminders

### 2. BOB CLI Wrapper (`scripts/bob`)
The SOLE wrapper CLI as required:
- `bob run dev` - Start dev with AWS Secrets
- `bob lint` - Run all linters
- `bob test` - Run tests
- `bob e2e` - Run Playwright
- `bob storybook` - UI library
- `bob db:backup` - Database backup
- `bob deploy:rollback` - Emergency rollback

### 3. GitHub Actions Workflows
Matching exact CI/CD pipeline requirements:
- `required-ci.yml` - Lint + Type-check + Tests (blocks merge)
- `security-scan.yml` - Gitleaks + Snyk + AWS validation
- `e2e-playwright.yml` - Playwright on Chromium + Firefox
- `storybook-build.yml` - (add based on project)
- `deploy-staging.yml` - (Forge-specific)
- `deploy-prod.yml` - (Forge-specific)

### 4. Organization Rules (`CLAUDE-ORG-RULES.mdc`)
Enforces all Mojo Solo standards in Claude Code

### 5. Required Templates
- Post-mortem template
- ADR (Architecture Decision Record) template

## Deployment Instructions

### Step 1: Update the GitHub Template

```bash
cd /Users/ianmatenaer/projects/template-repo
git add -A
git commit -m "feat: Add complete Mojo Solo development process integration

- Enhanced pre-commit hooks with MojoDevProcess.md standards
- BOB CLI wrapper for all operations
- GitHub Actions workflows matching CI/CD requirements
- Organization rules and templates
- AWS Secrets Manager integration"
git push
```

### Step 2: Create Organization Rules Repository

```bash
# Create the organisation-rules repo
gh repo create Mojo-Solo/organisation-rules --public
git clone https://github.com/Mojo-Solo/organisation-rules
cd organisation-rules
cp /Users/ianmatenaer/projects/template-repo/CLAUDE-ORG-RULES.mdc .
git add -A
git commit -m "feat: Add organization-wide Claude Code rules"
git push
```

### Step 3: Roll Out to Existing Repos

For each Mojo Solo repository:

```bash
# Quick setup
curl -sL https://raw.githubusercontent.com/Mojo-Solo/mojo-solo-template/main/scripts/mojo-setup.sh | bash

# Or manual setup
git clone https://github.com/Mojo-Solo/[repo-name]
cd [repo-name]
./scripts/mojo-setup.sh
```

### Step 4: Configure AWS Secrets Manager

For each project, create secrets at:
- `/mojosolo/<repo>/dev/*`
- `/mojosolo/<repo>/staging/*`
- `/mojosolo/<repo>/prod/*`

Grant GitHub OIDC access via IAM role.

### Step 5: Set Up Branch Protection

For each repo:
1. Settings → Branches → Add rule
2. Branch: `main`
3. Required status checks:
   - Lint + Type Check
   - Unit + Integration Tests
   - Security Scan
   - E2E Tests (Playwright)
4. Require PR reviews: 1
5. Dismiss stale reviews: Yes
6. Restrict push: Yes

### Step 6: Configure Monitoring

Per MojoDevProcess.md requirements:
- New Relic/DataDog APM
- CloudWatch Logs → Slack
- UptimeRobot checks
- Health endpoints

## Verification Checklist

- [ ] BOB commands work (`./bob help`)
- [ ] Pre-commit hooks block sloppy code
- [ ] GitHub Actions run on PRs
- [ ] AWS Secrets Manager connected
- [ ] Branch protection enabled
- [ ] Monitoring configured
- [ ] Team notified of changes

## Support

- MojoDevProcess.md - Full standards document
- #dev-help Slack channel
- Weekly DevOps rotation schedule