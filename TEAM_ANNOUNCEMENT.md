# 🚀 New Development Standards - Action Required

Hey team! 

We've just rolled out automated code quality checks that will make all our lives easier. No more broken builds from console.logs or hardcoded secrets!

## What's New?

**Automatic checks that prevent:**
- Console.logs in production code
- TODOs without issue numbers
- Hardcoded API keys
- Code that doesn't pass linting

**New tools:**
- `bob` command for all operations
- Automatic commit formatting
- Changelog updates

## Quick Start (30 seconds)

In any Mojo Solo repo, run this ONE command:

```bash
curl -sL https://raw.githubusercontent.com/Mojo-Solo/mojo-solo-template/main/scripts/team-quick-start.sh | bash
```

That's it! The hooks will work automatically in the background.

## What You'll See

When you try to commit sloppy code:
```
❌ Found console.log statements - remove these before committing!
❌ Found TODO without issue numbers!
❌ Pre-commit failed! Fix the issues above and try again.
```

When your code is clean:
```
✅ All checks passed!
```

## Common Commands

```bash
./bob lint       # Check your code
./bob test       # Run tests
./bob run dev    # Start dev server
./bob help       # See all commands
```

## FAQ

**Q: Will this slow me down?**
A: No! It catches issues BEFORE they hit PR review, actually saving time.

**Q: What if I need to bypass?**
A: Emergency only: `git commit --no-verify -m "emergency fix"`

**Q: Who do I ask for help?**
A: Drop a message in #dev-help or check the guide below

## Resources

- [Developer Guide](https://github.com/Mojo-Solo/mojo-solo-template/blob/main/MOJO_SOLO_DEVELOPER_GUIDE.md)
- [Full Documentation](https://github.com/Mojo-Solo/mojo-solo-template)
- MojoDevProcess.md for complete standards

Let's ship cleaner code! 🎉