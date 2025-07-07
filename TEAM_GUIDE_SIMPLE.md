# Mojo Solo Quick Guide 🚀

## Install (30 seconds)

```bash
curl -sL https://raw.githubusercontent.com/Mojo-Solo/mojo-solo-template/main/scripts/team-quick-start.sh | bash
```

## Daily Commands

```bash
./bob lint       # Check code
./bob test       # Run tests  
./bob run dev    # Start dev server
```

## When Commits Get Blocked

### "Found console.log"
```js
// ❌ Bad
console.log('debug', data);

// ✅ Good - Remove it or use logger
logger.debug('debug', data);
```

### "TODO without issue number"
```js
// ❌ Bad
// TODO: Fix this

// ✅ Good
// TODO: Fix validation #123
```

### "Found secrets"
```js
// ❌ Bad
const API_KEY = 'sk-1234';

// ✅ Good
const API_KEY = process.env.API_KEY;
```

## Need Help?

- Slack: #dev-help
- Emergency bypass: `git commit --no-verify -m "emergency"`

That's it! The hooks work automatically in the background.