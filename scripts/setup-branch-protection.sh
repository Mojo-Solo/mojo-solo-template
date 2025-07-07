#!/usr/bin/env bash
# Setup branch protection rules for Mojo Solo repos

set -e

REPO=$1
if [ -z "$REPO" ]; then
  echo "Usage: ./setup-branch-protection.sh <repo-name>"
  echo "Example: ./setup-branch-protection.sh mojosolo-dashboard"
  exit 1
fi

echo "🔒 Setting up branch protection for Mojo-Solo/$REPO"
echo ""

# Check if gh is authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub CLI"
    echo "Run: gh auth login"
    exit 1
fi

# Function to create branch if it doesn't exist
ensure_branch_exists() {
    local branch=$1
    echo "Checking if $branch branch exists..."
    
    if ! gh api repos/Mojo-Solo/$REPO/branches/$branch &> /dev/null; then
        echo "Creating $branch branch..."
        # Get the default branch SHA
        DEFAULT_SHA=$(gh api repos/Mojo-Solo/$REPO/branches/main --jq '.commit.sha' 2>/dev/null || \
                      gh api repos/Mojo-Solo/$REPO/branches/master --jq '.commit.sha')
        
        # Create the branch
        gh api repos/Mojo-Solo/$REPO/git/refs -X POST \
            -f ref="refs/heads/$branch" \
            -f sha="$DEFAULT_SHA" || echo "Branch creation failed - may already exist"
    fi
}

# Ensure staging branch exists
ensure_branch_exists "staging"

echo ""
echo "🛡️ Protecting main branch..."

# Protect main branch with strict rules
gh api repos/Mojo-Solo/$REPO/branches/main/protection -X PUT \
  --field required_status_checks='{"strict":true,"contexts":["Lint + Type Check","Unit + Integration Tests","Security Scan"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"dismissal_restrictions":{},"dismiss_stale_reviews":true,"require_code_owner_reviews":true,"required_approving_review_count":1,"require_last_push_approval":true}' \
  --field restrictions=null \
  --field allow_force_pushes=false \
  --field allow_deletions=false \
  --field required_conversation_resolution=true \
  --field lock_branch=false \
  --field allow_fork_syncing=false 2>/dev/null && echo "✅ Main branch protected" || echo "⚠️  Main branch protection failed - check permissions"

echo ""
echo "🛡️ Protecting staging branch..."

# Protect staging branch with less strict rules
gh api repos/Mojo-Solo/$REPO/branches/staging/protection -X PUT \
  --field required_status_checks='{"strict":false,"contexts":["Lint + Type Check","Unit + Integration Tests"]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"required_approving_review_count":1}' \
  --field restrictions=null \
  --field allow_force_pushes=false \
  --field allow_deletions=false 2>/dev/null && echo "✅ Staging branch protected" || echo "⚠️  Staging branch protection failed"

echo ""
echo "📋 Branch Protection Summary:"
echo ""
echo "Main Branch:"
echo "  ✅ Requires PR with 1 approval"
echo "  ✅ Dismisses stale reviews"
echo "  ✅ Requires code owner review"
echo "  ✅ Requires status checks to pass"
echo "  ✅ Requires branches to be up to date"
echo "  ✅ Requires conversation resolution"
echo "  ✅ No force pushes allowed"
echo ""
echo "Staging Branch:"
echo "  ✅ Requires PR with 1 approval"
echo "  ✅ Requires basic status checks"
echo "  ✅ No force pushes allowed"
echo ""
echo "🎯 Next steps:"
echo "  1. Add team members to @Mojo-Solo/core-team"
echo "  2. Configure required status checks in CI/CD"
echo "  3. Set up CODEOWNERS file for automatic reviewers"
echo ""
echo "View settings: https://github.com/Mojo-Solo/$REPO/settings/branches"