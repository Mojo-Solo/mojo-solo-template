#!/usr/bin/env bash

echo "🚀 Claude Code Hooks Demo"
echo "========================"
echo ""

# Create example files if they don't exist
if [ ! -f "src/sloppy-example.js" ]; then
    mkdir -p src
    cat > src/sloppy-example.js << 'EOF'
// Example sloppy code
function loginUser(username, password) {
    console.log('Logging in user:', username);  // Left console.log
    
    // TODO: Add validation
    // FIXME: Security issue
    
    const API_KEY = 'sk-1234567890';  // Hardcoded secret!
    
    if (username == 'admin') {  // Should use ===
        return true;
    }
}
EOF
fi

if [ ! -f "src/clean-example.js" ]; then
    cat > src/clean-example.js << 'EOF'
// Clean code that passes all checks
function loginUser(username, password) {
    // TODO: Add validation #123
    // FIXME: Security issue #456
    
    const apiKey = process.env.API_KEY;  // Use env variable
    
    if (username === 'admin') {  // Strict equality
        return true;
    }
}
EOF
fi

echo "📋 Step 1: Developer tries to commit sloppy code"
echo "================================================"
echo "$ cat src/sloppy-example.js"
cat src/sloppy-example.js
echo ""

echo "$ git add src/sloppy-example.js"
echo "$ git commit -m 'added login feature'"
echo ""

echo "🔍 Running pre-commit hook..."
echo ""

# Simulate the hook output
echo "📋 Checking for console.log statements..."
echo "./src/sloppy-example.js:3:    console.log('Logging in user:', username);"
echo "❌ Found console.log statements - remove these before committing!"
echo ""
echo "📋 Checking for TODOs without issue numbers..."
echo "./src/sloppy-example.js:5:    // TODO: Add validation"
echo "./src/sloppy-example.js:6:    // FIXME: Security issue"
echo "❌ Found TODO/FIXME without issue numbers - add issue numbers!"
echo ""
echo "🔐 Checking for potential secrets..."
echo "./src/sloppy-example.js:8:    const API_KEY = 'sk-1234567890';"
echo "❌ Found potential secrets in code!"
echo ""
echo "❌ Pre-commit failed! Fix the issues above and try again."
echo ""

echo "📝 Step 2: Developer fixes the code"
echo "==================================="
echo "$ cat src/clean-example.js"
cat src/clean-example.js
echo ""

echo "✅ Step 3: Clean code passes all checks"
echo "======================================="
echo "$ git add src/clean-example.js"
echo "$ git commit -m 'added login feature'"
echo ""
echo "🔍 Running pre-commit checks..."
echo "📋 Checking for console.log statements..."
echo "📋 Checking for TODOs without issue numbers..."
echo "🔐 Checking for potential secrets..."
echo "✅ All checks passed!"
echo ""
echo "[main abc1234] feat: added login feature"
echo " 1 file changed, 10 insertions(+)"
echo ""

echo "🎉 Summary"
echo "=========="
echo "The pre-commit hook automatically prevented:"
echo "  ❌ Debug code (console.log) from reaching production"
echo "  ❌ Untracked work (TODOs without issue numbers)"
echo "  ❌ Security vulnerabilities (hardcoded secrets)"
echo ""
echo "All without any manual code review or CI/CD pipeline!"