#!/usr/bin/env bash
# Mojo Solo Team Quick Start - One command to rule them all!

set -e

echo "🚀 Setting up Mojo Solo standards..."
echo "   This will take about 30 seconds"
echo ""

# Check if we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not in a git repository!"
    echo "   Please run this from your project root."
    exit 1
fi

PROJECT_NAME=$(basename "$PWD")

# Download and run the full setup
echo "📥 Downloading setup script..."
curl -sL https://raw.githubusercontent.com/Mojo-Solo/mojo-solo-template/main/scripts/mojo-setup.sh -o .mojo-setup-temp.sh
chmod +x .mojo-setup-temp.sh

echo "🔧 Installing hooks and tools..."
./.mojo-setup-temp.sh

# Clean up
rm .mojo-setup-temp.sh

# Quick test
echo ""
echo "🧪 Testing installation..."
if [ -f "./bob" ] && [ -d ".claude/hooks" ]; then
    echo "✅ Installation successful!"
else
    echo "❌ Something went wrong. Please contact #dev-help"
    exit 1
fi

# Show next steps
echo ""
echo "✨ You're all set! Here's what you can do now:"
echo ""
echo "   ./bob lint          Check your code"
echo "   ./bob test          Run tests"
echo "   ./bob run dev       Start development"
echo "   ./bob help          See all commands"
echo ""
echo "💡 Try making a commit - the hooks will guide you!"
echo ""
echo "📚 Full guide: https://github.com/Mojo-Solo/mojo-solo-template"