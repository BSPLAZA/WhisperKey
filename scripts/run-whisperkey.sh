#!/bin/bash

# Run WhisperKey from built app

echo "=== Running WhisperKey ==="

# Find the built app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "WhisperKey.app" -type d 2>/dev/null | grep -E "Debug|Release" | head -1)

if [ -z "$APP_PATH" ]; then
    echo "❌ WhisperKey.app not found in DerivedData"
    echo "Please build the app in Xcode first (Cmd+B)"
    exit 1
fi

echo "✅ Found app at: $APP_PATH"

# Kill any existing WhisperKey process
pkill -x WhisperKey 2>/dev/null

# Run the app
echo "🚀 Launching WhisperKey..."
open "$APP_PATH"

echo ""
echo "✅ WhisperKey should now be running in your menu bar"
echo ""
echo "To test Right Option key:"
echo "1. Click menu bar icon → 'Test Right Option Key'"
echo "2. Open Console.app and filter by 'WHISPERKEY'"
echo "3. Press Right Option and watch for log messages"
echo ""
echo "If hotkey doesn't work:"
echo "- Grant Accessibility permission in System Settings"
echo "- Try restarting the app after granting permission"