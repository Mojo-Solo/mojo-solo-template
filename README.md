# Mojo-Solo Claude Code Template 🚀

Standardized development workflows for the Mojo-Solo organization using Claude Code hooks.

## What This Does

Automatically enforces code quality standards **before** code gets committed:

- ❌ **Blocks** console.logs in production code
- ❌ **Blocks** TODOs without issue numbers
- ❌ **Blocks** hardcoded API keys and secrets
- ✅ **Formats** commit messages automatically
- ✅ **Updates** CHANGELOG.md with every commit

## Quick Start

### For New Projects

1. Click "Use this template" button above
2. Name your new repository
3. Clone and start coding - hooks are pre-installed!

### For Existing Projects

Run this one command in your repo:

```bash
curl -sL https://raw.githubusercontent.com/Mojo-Solo/mojo-solo-template/main/scripts/quick-setup.sh | bash
```

## How It Works

The template includes:

- **`.claude/hooks/`** - Pre-commit and commit message hooks
- **`scripts/`** - Setup and rollout automation
- **`CLAUDE.md`** - Instructions for Claude Code
- **Docs** - Complete guides for developers and deployment

## Examples

### Before Hooks
```bash
$ git commit -m "fixed stuff"
# Commits with console.logs, no changelog update, vague message
```

### After Hooks
```bash
$ git commit -m "fixed login bug"
❌ Found console.log statements - remove these before committing!
❌ Found TODO without issue numbers!
❌ Pre-commit failed! Fix the issues above and try again.

# After fixing:
✅ All checks passed!
📝 Commit formatted as: fix(JIRA-123): fixed login bug
📋 CHANGELOG.md updated automatically
```

## Support

- Read the [Developer Guide](MOJO_SOLO_DEVELOPER_GUIDE.md)
- Check `./demo.sh` for a live demo
- Ask in #dev-help Slack channel

---

Part of Mojo-Solo's commitment to clean, secure, and maintainable code.