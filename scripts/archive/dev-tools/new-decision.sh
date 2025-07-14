#!/bin/bash
# Create a new ADR entry

DECISION=$1

if [ -z "$DECISION" ]; then
    echo "Usage: $0 '<decision description>'"
    echo "Example: $0 'Use Core ML instead of whisper.cpp for better performance'"
    exit 1
fi

DATE=$(date +%Y-%m-%d)
DECISIONS_FILE="../docs/DECISIONS.md"

# Find next ADR number
NEXT_NUM=$(grep -o 'ADR-[0-9]\+' "$DECISIONS_FILE" | tail -1 | sed 's/ADR-//')
NEXT_NUM=$((NEXT_NUM + 1))
NEXT_NUM_PADDED=$(printf "%03d" $NEXT_NUM)

# Create ADR template
cat << EOF

## ADR-$NEXT_NUM_PADDED: $DECISION

**Date**: $DATE  
**Status**: Proposed  
**Context**: [Why this decision needed to be made]  
**Decision**: [What we decided]  
**Consequences**: [What happens as a result]  
**Alternatives Considered**: [Other options evaluated]

EOF

echo "📝 Add this to $DECISIONS_FILE and fill in the details"
echo "💡 Don't forget to change status to 'Accepted' once decided"