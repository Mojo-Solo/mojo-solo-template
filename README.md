# Mojo-Solo Development Standards Template 🚀

Automated code quality enforcement for the Mojo-Solo organization. No more console.logs in production, no more hardcoded secrets, no more broken builds.

## ⚡ Quick Start (30 seconds)

For any Mojo-Solo repository:

```bash
curl -sL https://raw.githubusercontent.com/Mojo-Solo/mojo-solo-template/main/scripts/team-quick-start.sh | bash
```

That's it! Hooks are now active and will prevent sloppy code from being committed.

## 🛡️ What Gets Blocked

### Pre-commit Checks
- ❌ **Console.logs** in production code
- ❌ **TODOs** without issue numbers
- ❌ **Hardcoded secrets** (API keys, tokens)
- ❌ **Docker** usage (per MojoDevProcess.md)
- ❌ **Wrong branch names** (must be feat/TICKET-123)
- ❌ **Forbidden tools** (Doppler, Vault - AWS Secrets only)
- ❌ **Linting errors** (runs automatically)

### What Gets Added
- ✅ **Commit formatting** (conventional commits)
- ✅ **Changelog updates** (automatic)
- ✅ **BOB CLI** for all operations
- ✅ **GitHub Actions** CI/CD pipeline

## 🎯 For Developers

### Daily Commands

```bash
./bob lint       # Check your code
./bob test       # Run tests
./bob run dev    # Start dev environment
./bob e2e        # Run Playwright tests
./bob help       # See all commands
```

### When Commits Get Blocked

**Console.log found:**
```javascript
// ❌ Remove this
console.log('debug', data);

// ✅ Or use proper logging
logger.debug('debug', data);
```

**TODO without issue:**
```javascript
// ❌ Bad
// TODO: Fix this later

// ✅ Good  
// TODO: Fix validation logic #123
```

**Hardcoded secret:**
```javascript
// ❌ Bad
const API_KEY = 'sk-1234567890';

// ✅ Good
const API_KEY = process.env.API_KEY;
```

## 🚀 For Team Leads

### Mass Rollout

Deploy to multiple repos at once:

```bash
git clone https://github.com/Mojo-Solo/mojo-solo-template
cd mojo-solo-template
./scripts/team-rollout.sh
```

Options:
1. Single repository
2. Top 5 active repos
3. All repos (last 30 days)
4. Custom list

### Track Adoption

```bash
./scripts/adoption-tracker.sh --details
```

Shows:
- Which repos have standards installed
- Adoption percentage with progress bar
- Recent commits that were saved by hooks

## 📁 Repository Structure

```
mojo-solo-template/
├── .claude/
│   ├── hooks/
│   │   ├── pre-commit.sh         # Code quality checks
│   │   ├── pre-commit-mojo.sh    # Mojo-specific standards
│   │   └── prepare-commit-msg.sh # Commit formatting
│   └── CLAUDE-ORG-RULES.mdc      # Organization standards
├── .github/
│   └── workflows/                 # CI/CD pipelines
├── scripts/
│   ├── bob                        # CLI wrapper (required)
│   ├── team-quick-start.sh        # 30-second setup
│   ├── team-rollout.sh            # Mass deployment
│   ├── adoption-tracker.sh        # Progress monitoring
│   └── mojo-setup.sh              # Full setup script
├── docs/
│   └── templates/                 # Postmortem, ADR templates
└── MojoDevProcess.md              # Complete standards (v1.1)
```

## 🔧 Features

### BOB CLI Wrapper
The **only** way to run commands (per MojoDevProcess.md):
- Consistent interface across all projects
- Handles environment setup
- AWS Secrets Manager integration
- Prevents ad-hoc scripts

### GitHub Actions
Complete CI/CD pipeline:
- `required-ci.yml` - Lint, type-check, tests
- `security-scan.yml` - Gitleaks, dependency scanning  
- `e2e-playwright.yml` - Cross-browser E2E tests

### Branch Protection
Enforced naming conventions:
- `main` - Production (protected)
- `staging` - Pre-production
- `feat/TICKET-123` - Features
- `hotfix/TICKET-456` - Emergency fixes

## 📊 Success Metrics

Track the impact:
- Commits blocked (security saves)
- Build failures prevented
- Time saved on PR reviews
- Developer satisfaction

## 🆘 Troubleshooting

### "Command not found: bob"
```bash
chmod +x ./bob
# Or add to PATH
export PATH="$PATH:$(pwd)"
```

### "Hooks not running"
```bash
# Check if executable
ls -la .claude/hooks/
# Should show -rwxr-xr-x
```

### Emergency Bypass
```bash
# Use sparingly!
git commit --no-verify -m "emergency: fixing production"
```

## 📚 Documentation

- [Team Announcement](TEAM_ANNOUNCEMENT.md) - Share with your team
- [Simple Guide](TEAM_GUIDE_SIMPLE.md) - Quick reference
- [Developer Guide](MOJO_SOLO_DEVELOPER_GUIDE.md) - Detailed docs
- [Testing Guide](TESTING_GUIDE.md) - How to test
- [MojoDevProcess.md](MojoDevProcess.md) - Complete standards

## 🤝 Contributing

1. Fork the template repository
2. Create feature branch (`feat/JIRA-123`)
3. Follow all standards (hooks will enforce!)
4. Submit PR with tests

## 📈 Adoption Status

Check current adoption across Mojo-Solo:
```bash
./scripts/adoption-tracker.sh
```

## 🎉 Ready to Ship Clean Code?

1. **Developers**: Run the quick start command above
2. **Team Leads**: Use the rollout script for mass deployment
3. **Everyone**: Enjoy cleaner, more secure code!

---

Built with ❤️ for Mojo-Solo by developers who were tired of console.logs in production.