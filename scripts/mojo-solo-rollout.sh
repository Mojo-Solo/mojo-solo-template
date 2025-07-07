#!/usr/bin/env bash

# Mojo-Solo Organization Claude Code Hooks Rollout Script
# This script helps deploy CC hooks across multiple repositories

set -e

echo "🚀 Mojo-Solo Claude Code Hooks Rollout"
echo "======================================"
echo ""

# Configuration
ORG="Mojo-Solo"
TEMPLATE_REPO="mojo-solo-template"
SETUP_SCRIPT_URL="https://raw.githubusercontent.com/$ORG/$TEMPLATE_REPO/main/scripts/quick-setup.sh"

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is required but not installed."
    echo "Install it from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub CLI"
    echo "Run: gh auth login"
    exit 1
fi

# Function to install hooks in a repo
install_hooks() {
    local repo=$1
    echo "📦 Installing hooks in $repo..."
    
    # Clone the repo
    temp_dir=$(mktemp -d)
    gh repo clone "$ORG/$repo" "$temp_dir/$repo" -- --quiet
    
    cd "$temp_dir/$repo"
    
    # Run the setup script
    curl -sL "$SETUP_SCRIPT_URL" | bash
    
    # Commit the changes
    if git diff --quiet; then
        echo "✅ $repo already has hooks installed"
    else
        git add -A
        git commit -m "feat: Add Claude Code hooks for better code quality

- Pre-commit hooks for linting, testing, and security checks
- Automatic commit message formatting
- Changelog automation

Part of org-wide standardization initiative"
        
        git push origin main
        echo "✅ Hooks installed in $repo"
    fi
    
    cd - > /dev/null
    rm -rf "$temp_dir"
}

# Menu for different rollout options
echo "Choose rollout option:"
echo "1. Install in specific repositories (comma-separated list)"
echo "2. Install in all active repositories (pushed to in last 30 days)"
echo "3. Install in top N repositories by activity"
echo "4. Show repositories without hooks installed"
echo ""
read -p "Enter choice (1-4): " choice

case $choice in
    1)
        read -p "Enter repository names (comma-separated): " repos
        IFS=',' read -ra REPO_ARRAY <<< "$repos"
        for repo in "${REPO_ARRAY[@]}"; do
            repo=$(echo "$repo" | xargs) # Trim whitespace
            install_hooks "$repo"
        done
        ;;
    
    2)
        echo "🔍 Finding active repositories..."
        active_repos=$(gh repo list "$ORG" --limit 100 --json name,pushedAt \
            --jq '.[] | select(.pushedAt > (now - 30*24*60*60 | strftime("%Y-%m-%dT%H:%M:%SZ"))) | .name')
        
        echo "Found active repos:"
        echo "$active_repos"
        echo ""
        read -p "Install hooks in all these repos? (y/N): " confirm
        
        if [[ $confirm == "y" || $confirm == "Y" ]]; then
            while IFS= read -r repo; do
                install_hooks "$repo"
            done <<< "$active_repos"
        fi
        ;;
    
    3)
        read -p "How many repos to update? " num
        echo "🔍 Finding top $num repositories by activity..."
        
        top_repos=$(gh repo list "$ORG" --limit "$num" --json name --jq '.[].name')
        
        echo "Will install in:"
        echo "$top_repos"
        echo ""
        read -p "Continue? (y/N): " confirm
        
        if [[ $confirm == "y" || $confirm == "Y" ]]; then
            while IFS= read -r repo; do
                install_hooks "$repo"
            done <<< "$top_repos"
        fi
        ;;
    
    4)
        echo "🔍 Checking which repos need hooks..."
        all_repos=$(gh repo list "$ORG" --limit 100 --json name --jq '.[].name')
        
        echo "Repositories without Claude Code hooks:"
        while IFS= read -r repo; do
            # Check if .claude directory exists
            if ! gh api "repos/$ORG/$repo/contents/.claude" &> /dev/null; then
                echo "❌ $repo"
            fi
        done <<< "$all_repos"
        ;;
    
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "🎉 Rollout complete!"
echo ""
echo "Next steps:"
echo "1. Monitor repos for any issues"
echo "2. Share wins with the team (blocked commits, saved time)"
echo "3. Customize hooks based on team feedback"