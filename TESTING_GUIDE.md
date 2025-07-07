# Mojo Solo Template Testing Guide

## Testing Plan - What We'll Verify

### 1. Pick a Test Repository
Choose one of your Mojo Solo repos that:
- Is actively developed (so we can test real scenarios)
- Has a staging environment
- Ideally has some existing "sloppy" code to catch

### 2. Pre-Testing Checklist
Before we start, check:
- [ ] You have AWS credentials configured (`aws-vault list`)
- [ ] GitHub CLI is authenticated (`gh auth status`)
- [ ] The test repo has a staging branch
- [ ] You have write access to the repo

### 3. Installation Test

```bash
# Clone your test repo
git clone https://github.com/Mojo-Solo/[your-test-repo]
cd [your-test-repo]

# Create a test branch
git checkout -b feat/TEST-123-mojo-standards

# Run the setup
curl -sL https://raw.githubusercontent.com/Mojo-Solo/mojo-solo-template/main/scripts/mojo-setup.sh | bash
```

Expected output:
```
🚀 Setting up Mojo Solo development standards...
📁 Creating Mojo Solo directory structure...
📄 Linking organization rules...
🔧 Installing BOB CLI wrapper...
📝 Creating documentation templates...
✅ Mojo Solo standards installed!
```

### 4. Hook Testing

#### Test 1: Sloppy Code Detection
Create a test file with intentional issues:

```javascript
// test-sloppy.js
function processPayment(amount) {
    console.log("Processing payment:", amount);  // Should catch this
    
    // TODO: Add validation  // Missing issue number
    
    const API_KEY = "sk-1234567890";  // Hardcoded secret
    
    if (amount == 100) {  // Should use ===
        return true;
    }
}
```

Try to commit:
```bash
git add test-sloppy.js
git commit -m "test commit"
```

Expected: Pre-commit hook should block with:
- ❌ Found console.log statements
- ❌ Found TODO/FIXME without issue numbers
- ❌ Found potential secrets! Use AWS Secrets Manager

#### Test 2: Branch Naming
```bash
# Try a bad branch name
git checkout -b my-feature  # Should fail

# Use correct format
git checkout -b feat/JIRA-456
```

#### Test 3: Clean Code
Fix the issues and commit:
```javascript
// test-clean.js
function processPayment(amount) {
    // TODO: Add validation #456
    
    const apiKey = process.env.API_KEY;
    
    if (amount === 100) {
        return true;
    }
}
```

### 5. BOB CLI Testing

Test each command:

```bash
# Test help
./bob help

# Test linting (should use your project's linter)
./bob lint

# Test running dev environment
# First, set up AWS secrets (if not already)
aws-vault exec dev -- ./bob run dev

# Test other commands based on project type
./bob test
./bob storybook  # If UI project
./bob e2e        # If Playwright configured
```

### 6. GitHub Actions Testing

Push your test branch and create a PR:

```bash
git push origin feat/TEST-123-mojo-standards
gh pr create --title "test: Mojo Solo standards" --body "Testing new hooks and workflows"
```

Watch the PR checks - you should see:
- ✅ Lint + Type Check
- ✅ Unit + Integration Tests  
- ✅ Security Scan
- ✅ E2E Tests (if Playwright configured)

### 7. Real-World Scenario Tests

#### Scenario A: Emergency Hotfix
```bash
git checkout main
git pull
git checkout -b hotfix/PROD-789

# Make a quick fix
echo "// hotfix" >> some-file.js
git add -A
git commit -m "fix: Emergency production fix"

# Should pass with proper branch name
```

#### Scenario B: Docker Detection
Create a Dockerfile:
```bash
echo "FROM node:18" > Dockerfile
git add Dockerfile
git commit -m "add docker"

# Should fail with "Docker is forbidden!"
```

#### Scenario C: Wrong Secret Manager
```javascript
// Try using Doppler
const doppler = require('@dopplerhq/node-sdk');
```

Should fail with "Found forbidden secret management tools!"

### 8. Integration Testing

Test the full workflow:
1. Create feature branch: `git checkout -b feat/TEST-789`
2. Make changes following standards
3. Run `./bob lint` before committing
4. Commit with hook validation
5. Push and create PR
6. Verify all CI checks pass
7. Merge to staging
8. Verify deployment workflows trigger

### 9. Performance Testing

If it's a web project:
```bash
# Build the project
npm run build

# Check bundle sizes
find dist -name "*.js" -size +250k -exec ls -lh {} \;

# Should warn about files over 250KB
```

### 10. Rollback Testing

```bash
# Simulate a bad deployment
./bob deploy:rollback --env=staging

# Should show rollback process (even if not fully implemented)
```

## Success Criteria

- [ ] Pre-commit hooks catch all sloppy code
- [ ] BOB commands work for your stack
- [ ] CI/CD pipeline runs on PRs
- [ ] Branch protection enforces standards
- [ ] Team can use without friction
- [ ] No false positives blocking valid code

## Troubleshooting

**Hook not running?**
```bash
# Check if executable
ls -la .claude/hooks/
# Should show -rwxr-xr-x for .sh files
```

**BOB command not found?**
```bash
chmod +x ./bob
# Or add to PATH
export PATH="$PATH:$(pwd)"
```

**AWS Secrets issues?**
```bash
# Test AWS access
aws-vault exec dev -- aws sts get-caller-identity

# Check secret exists
aws-vault exec dev -- aws secretsmanager describe-secret \
  --secret-id /mojosolo/$(basename $PWD)/dev/env
```

## Report Results

After testing, note:
1. What worked immediately
2. What needed adjustment for your stack
3. Any false positives
4. Team feedback
5. Time saved on first real PR

This will help refine the template for all Mojo Solo projects!