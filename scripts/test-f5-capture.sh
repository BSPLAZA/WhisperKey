#!/bin/bash
#
# Test F5 key capture with Karabiner
#

echo "WhisperKey F5 Test Monitor"
echo "========================="
echo ""
echo "This script monitors F5 key presses captured by Karabiner."
echo "Press F5 in different applications to test."
echo "Press Ctrl+C to stop monitoring."
echo ""

# Create log file if it doesn't exist
touch /tmp/whisperkey-f5-test.log

# Clear previous test data
echo "[$(date)] Test started" > /tmp/whisperkey-f5-test.log

echo "Monitoring F5 presses..."
echo ""

# Monitor the log file
tail -f /tmp/whisperkey-f5-test.log