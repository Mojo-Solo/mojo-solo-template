#!/usr/bin/env bash
set -e

COMMIT_MSG_FILE=$1
COMMIT_SOURCE=$2
SHA1=$3

# Skip if it's a merge or amend
if [ "$COMMIT_SOURCE" = "merge" ] || [ "$COMMIT_SOURCE" = "commit" ]; then
    exit 0
fi

# Read the current commit message
CURRENT_MSG=$(cat "$COMMIT_MSG_FILE")

# Function to extract ticket number from branch name
get_ticket_from_branch() {
    git rev-parse --abbrev-ref HEAD | grep -oE '[A-Z]+-[0-9]+' || echo ""
}

# Function to determine change type from staged files
determine_change_type() {
    local staged_files=$(git diff --cached --name-only)
    
    # Check for test files
    if echo "$staged_files" | grep -qE '\.(test|spec)\.(js|ts|py)$'; then
        echo "test"
        return
    fi
    
    # Check for documentation
    if echo "$staged_files" | grep -qE '\.(md|rst|txt)$|^docs/'; then
        echo "docs"
        return
    fi
    
    # Check for new files (likely features)
    if git diff --cached --name-status | grep -q '^A'; then
        echo "feat"
        return
    fi
    
    # Default to fix for modifications
    echo "fix"
}

# Generate conventional commit format
TICKET=$(get_ticket_from_branch)
TYPE=$(determine_change_type)

# If message doesn't follow conventional format, prepend it
if ! echo "$CURRENT_MSG" | grep -qE '^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?:'; then
    if [ -n "$TICKET" ]; then
        FORMATTED_MSG="$TYPE($TICKET): $CURRENT_MSG"
    else
        FORMATTED_MSG="$TYPE: $CURRENT_MSG"
    fi
    
    # Add change summary
    echo "$FORMATTED_MSG" > "$COMMIT_MSG_FILE"
    echo "" >> "$COMMIT_MSG_FILE"
    echo "# Changes made:" >> "$COMMIT_MSG_FILE"
    git diff --cached --stat | sed 's/^/# /' >> "$COMMIT_MSG_FILE"
fi

# Auto-update CHANGELOG.md if it exists
if [ -f "CHANGELOG.md" ]; then
    # Create temporary changelog entry
    TEMP_ENTRY=$(mktemp)
    echo "### [$(date +%Y-%m-%d)]" > "$TEMP_ENTRY"
    echo "- $FORMATTED_MSG" >> "$TEMP_ENTRY"
    echo "" >> "$TEMP_ENTRY"
    
    # Insert after the first ## heading
    awk '/^## / && !found {print; found=1; while(getline line < "'"$TEMP_ENTRY"'") print line; next} 1' CHANGELOG.md > CHANGELOG.md.tmp
    mv CHANGELOG.md.tmp CHANGELOG.md
    rm "$TEMP_ENTRY"
    
    # Stage the changelog update
    git add CHANGELOG.md
fi