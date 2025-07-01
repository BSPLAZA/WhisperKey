#!/bin/bash
# Log a new issue and solution

ISSUE=$1
SOLUTION=$2

if [ -z "$ISSUE" ]; then
    echo "Usage: $0 '<issue>' '<solution>'"
    echo "Example: $0 'CGEventTap timeout' 'Process events asynchronously'"
    exit 1
fi

DATE=$(date +%Y-%m-%d)
ISSUES_FILE="../docs/ISSUES_AND_SOLUTIONS.md"

# Find next issue number
NEXT_NUM=$(grep -o 'Issue #[0-9]\+' "$ISSUES_FILE" | tail -1 | sed 's/Issue #//')
NEXT_NUM=$((NEXT_NUM + 1))
NEXT_NUM_PADDED=$(printf "%03d" $NEXT_NUM)

# Create issue template
cat << EOF

## Issue #$NEXT_NUM_PADDED: $ISSUE

**Discovered**: $DATE  
**Severity**: [Critical | High | Medium | Low]  
**Symptoms**: [What went wrong]  
**Root Cause**: [Why it happened]  
**Solution**: $SOLUTION  
**Prevention**: [How to avoid in future]  
**Time Lost**: [Hours spent debugging]

EOF

echo "📝 Add this to $ISSUES_FILE and fill in the details"
echo "💡 Add code examples if applicable"