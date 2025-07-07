# Mojo-Solo Developer Guide - Claude Code Standards

Welcome to Mojo-Solo! We use Claude Code hooks to maintain code quality automatically.

## For New Projects

When creating a new repository:

1. Go to https://github.com/organizations/Mojo-Solo/repositories/new
2. Select **"mojo-solo-template"** from the "Repository template" dropdown
3. Name your repo and create it
4. Clone and start coding - hooks are already set up!

## For Existing Projects

If your repo doesn't have CC hooks yet:

```bash
# One command to add all hooks:
curl -sL https://raw.githubusercontent.com/Mojo-Solo/mojo-solo-template/main/scripts/quick-setup.sh | bash
```

## What The Hooks Do For You

### Pre-commit Hook
Automatically prevents:
- ❌ Console.logs in production code
- ❌ TODOs without issue numbers  
- ❌ Hardcoded API keys/secrets
- ❌ Large files that should use Git LFS

### Commit Message Hook
Automatically:
- ✅ Formats your commit messages
- ✅ Adds ticket numbers from branch names
- ✅ Updates CHANGELOG.md

## Common Scenarios

### "My commit was blocked!"

The hook found an issue. Common fixes:

**Console.log found:**
```javascript
// ❌ Bad
console.log('debugging', data);

// ✅ Good - Remove it or use proper logging
logger.debug('debugging', data);
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

### "I need to bypass the hook" (Emergency only!)

```bash
git commit --no-verify -m "emergency: fixing production"
```

⚠️ Use sparingly - the hooks are there to protect us!

## Working with Claude Code

The hooks integrate seamlessly with Claude Code:

```bash
# Start Claude Code in your repo
claude

# Claude will see the hooks and use them automatically
# It will also run the appropriate commands based on CLAUDE.md
```

## Questions?

- Check the hooks: `.claude/hooks/`
- Read the docs: `CLAUDE.md`
- Ask in #dev-help Slack channel

Remember: The hooks are here to help, not hinder. They catch the stuff we all forget!