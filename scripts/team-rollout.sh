#!/usr/bin/env bash
# Automated rollout for Mojo Solo team

set -e

echo "🚀 Mojo Solo Team Rollout Tool"
echo "=============================="
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is required."
    echo "   Install from: https://cli.github.com/"
    exit 1
fi

# Function to install in a repo
install_in_repo() {
    local repo=$1
    echo ""
    echo "📦 Installing in $repo..."
    
    # Clone to temp directory
    temp_dir=$(mktemp -d)
    echo "   Cloning..."
    gh repo clone "Mojo-Solo/$repo" "$temp_dir/$repo" -- --quiet || {
        echo "   ❌ Failed to clone $repo"
        return 1
    }
    
    cd "$temp_dir/$repo"
    
    # Check if already installed
    if [ -f "./bob" ] && [ -d ".claude/hooks" ]; then
        echo "   ✅ Already installed!"
        cd - > /dev/null
        rm -rf "$temp_dir"
        return 0
    fi
    
    # Create branch
    git checkout -b feat/mojo-standards-rollout || git checkout feat/mojo-standards-rollout
    
    # Run setup
    echo "   Installing..."
    curl -sL https://raw.githubusercontent.com/Mojo-Solo/mojo-solo-template/main/scripts/mojo-setup.sh | bash || {
        echo "   ❌ Installation failed"
        cd - > /dev/null
        rm -rf "$temp_dir"
        return 1
    }
    
    # Commit changes
    git add -A
    git commit -m "feat: Add Mojo Solo development standards

- Automated code quality checks
- BOB CLI wrapper for consistent commands  
- Pre-commit hooks for cleaner code
- Follows MojoDevProcess.md standards

One command setup: curl -sL https://raw.githubusercontent.com/Mojo-Solo/mojo-solo-template/main/scripts/team-quick-start.sh | bash" || {
        echo "   ⚠️  No changes to commit"
    }
    
    # Push branch
    echo "   Pushing branch..."
    git push -u origin feat/mojo-standards-rollout 2>/dev/null || git push
    
    # Create PR
    echo "   Creating PR..."
    gh pr create \
        --title "feat: Add Mojo Solo development standards" \
        --body "## Summary
This PR adds automated code quality checks to prevent common issues:
- Console.logs in production
- TODOs without issue numbers
- Hardcoded secrets
- Linting errors

## What's New
- Pre-commit hooks that run automatically
- BOB CLI wrapper for consistent commands
- Organization-wide standards enforcement

## Testing
The hooks are already active. Try:
\`\`\`bash
./bob lint
./bob test
\`\`\`

## Team Setup
After merging, team members run:
\`\`\`bash
curl -sL https://raw.githubusercontent.com/Mojo-Solo/mojo-solo-template/main/scripts/team-quick-start.sh | bash
\`\`\`

Based on MojoDevProcess.md standards." \
        --base main || echo "   ℹ️  PR already exists"
    
    echo "   ✅ Done! PR created for $repo"
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$temp_dir"
}

# Menu
echo "Choose rollout option:"
echo ""
echo "1. Single repository"
echo "2. Top 5 most active repos"  
echo "3. All active repos (30 days)"
echo "4. Custom list"
echo ""
read -p "Enter choice (1-4): " choice

case $choice in
    1)
        read -p "Repository name: " repo
        install_in_repo "$repo"
        ;;
        
    2)
        echo ""
        echo "Finding top 5 active repos..."
        repos=$(gh repo list Mojo-Solo --limit 5 --json name,pushedAt --jq 'sort_by(.pushedAt) | reverse | .[0:5] | .[].name')
        
        echo "Will install in:"
        echo "$repos" | sed 's/^/  - /'
        echo ""
        read -p "Continue? (y/N): " confirm
        
        if [[ $confirm == "y" || $confirm == "Y" ]]; then
            for repo in $repos; do
                install_in_repo "$repo"
            done
        fi
        ;;
        
    3)
        echo ""
        echo "Finding repos active in last 30 days..."
        repos=$(gh repo list Mojo-Solo --limit 100 --json name,pushedAt \
            --jq '.[] | select(.pushedAt > (now - 30*24*60*60 | strftime("%Y-%m-%dT%H:%M:%SZ"))) | .name')
        
        count=$(echo "$repos" | wc -l)
        echo "Found $count active repos"
        echo ""
        read -p "Install in all $count repos? (y/N): " confirm
        
        if [[ $confirm == "y" || $confirm == "Y" ]]; then
            for repo in $repos; do
                install_in_repo "$repo"
            done
        fi
        ;;
        
    4)
        echo ""
        echo "Enter repository names (comma-separated):"
        read -p "> " custom_repos
        
        IFS=',' read -ra REPO_ARRAY <<< "$custom_repos"
        for repo in "${REPO_ARRAY[@]}"; do
            repo=$(echo "$repo" | xargs) # Trim whitespace
            install_in_repo "$repo"
        done
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
echo "1. Review and merge the PRs"
echo "2. Share TEAM_ANNOUNCEMENT.md in Slack"
echo "3. Pin TEAM_GUIDE_SIMPLE.md in #dev-help"
echo ""
echo "Track adoption at: https://github.com/Mojo-Solo?q=mojo-standards"