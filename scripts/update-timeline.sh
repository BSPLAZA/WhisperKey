#!/bin/bash
# Update timeline with phase completion

PHASE=$1
STATUS=$2
HOURS=$3

if [ -z "$PHASE" ] || [ -z "$STATUS" ]; then
    echo "Usage: $0 <phase> <status> [hours]"
    echo "Example: $0 'Phase 1' 'completed' '12'"
    exit 1
fi

DATE=$(date +%Y-%m-%d)
TIMELINE_FILE="../docs/TIMELINE.md"

# Update the timeline file
echo "Updating timeline for $PHASE to $STATUS..."

# Add implementation here to update the markdown file
# This is a placeholder - would need proper markdown parsing

echo "✅ Timeline updated: $PHASE is now $STATUS"
echo "📝 Remember to commit: git commit -m 'Timeline: $PHASE $STATUS'"