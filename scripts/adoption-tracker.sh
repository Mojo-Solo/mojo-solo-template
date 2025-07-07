#!/usr/bin/env bash
# Track Mojo Solo standards adoption across the organization

echo "📊 Mojo Solo Standards Adoption Tracker"
echo "======================================"
echo ""

# Check repos with standards installed
echo "🔍 Checking repositories..."
echo ""

# Get all repos
all_repos=$(gh repo list Mojo-Solo --limit 100 --json name --jq '.[].name' | sort)
total_repos=$(echo "$all_repos" | wc -l | xargs)

# Check each repo for BOB
installed_repos=""
not_installed_repos=""
install_count=0

for repo in $all_repos; do
    # Check if .claude/hooks exists in the repo
    if gh api "repos/Mojo-Solo/$repo/contents/.claude/hooks" &> /dev/null; then
        installed_repos+="✅ $repo\n"
        ((install_count++))
    else
        not_installed_repos+="❌ $repo\n"
    fi
done

# Calculate percentage
percentage=$((install_count * 100 / total_repos))

# Display results
echo "📈 Adoption Status"
echo "=================="
echo ""
echo "Total repositories: $total_repos"
echo "With standards: $install_count ($percentage%)"
echo "Without standards: $((total_repos - install_count))"
echo ""

# Progress bar
echo -n "Progress: ["
for ((i=0; i<50; i++)); do
    if ((i < percentage / 2)); then
        echo -n "█"
    else
        echo -n "░"
    fi
done
echo "] $percentage%"
echo ""

# Show details if requested
if [[ "$1" == "--details" ]] || [[ "$1" == "-d" ]]; then
    echo ""
    echo "✅ Repositories with standards:"
    echo "==============================="
    echo -e "$installed_repos"
    
    echo "❌ Repositories without standards:"
    echo "=================================="
    echo -e "$not_installed_repos"
fi

# Show recent commits blocked
echo ""
echo "🛡️  Recent Quality Saves (last 7 days):"
echo "======================================"
echo ""

# Search for commits mentioning fixes due to hooks
gh search commits "org:Mojo-Solo 'remove console.log' OR 'add issue number' OR 'remove hardcoded'" \
    --limit 5 \
    --json repository,commit,commit_message \
    --jq '.[] | "• [\(.repository.name)] \(.commit.message | split("\n")[0])"' || echo "No recent saves found"

echo ""
echo "💡 To see detailed status: $0 --details"
echo "🚀 To install in more repos: ./scripts/team-rollout.sh"