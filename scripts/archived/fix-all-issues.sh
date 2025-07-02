#!/bin/bash

echo "WhisperKey Complete Fix Script"
echo "=============================="
echo ""

# Step 1: Kill any stuck processes
echo "Step 1: Cleaning up stuck processes..."
pkill -f WhisperKey 2>/dev/null
echo "✅ Cleaned up processes"
echo ""

# Step 2: Reset permissions
echo "Step 2: Resetting accessibility permissions..."
tccutil reset Accessibility com.whisperkey.WhisperKey
echo "✅ Reset accessibility permissions"
echo ""

# Step 3: Check Karabiner status
echo "Step 3: Checking Karabiner-Elements..."
if pgrep -f "karabiner_grabber" > /dev/null; then
    echo "✅ Karabiner-Elements is running"
else
    echo "❌ Karabiner-Elements is not running"
    echo "   Please start Karabiner-Elements"
fi
echo ""

# Step 4: Open necessary system settings
echo "Step 4: Opening System Settings..."
echo ""
echo "IMPORTANT: You need to grant permissions in these sections:"
echo ""
echo "1. Privacy & Security → Input Monitoring"
echo "   ✓ Enable: karabiner_grabber"
echo "   ✓ Enable: karabiner_observer"
echo ""
echo "2. Privacy & Security → Accessibility" 
echo "   ✓ Enable: WhisperKey (when it appears after running)"
echo ""

# Open System Settings to the right page
open "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"

echo "Press Enter after granting Input Monitoring permissions to Karabiner..."
read

# Step 5: Restart Karabiner
echo "Step 5: Restarting Karabiner-Elements..."
launchctl kickstart -k gui/$(id -u)/org.pqrs.karabiner.karabiner_console_user_server
sleep 2
echo "✅ Karabiner-Elements restarted"
echo ""

# Step 6: Build location
echo "Step 6: Finding WhisperKey app..."
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "WhisperKey.app" -path "*/Debug/*" 2>/dev/null | head -1)

if [ -z "$APP_PATH" ]; then
    echo "❌ WhisperKey.app not found in DerivedData"
    echo "   Please build the app in Xcode first"
    exit 1
else
    echo "✅ Found app at: $APP_PATH"
fi
echo ""

# Step 7: Copy to Applications for stable location
echo "Step 7: Installing to Applications folder..."
echo "Copy to /Applications for stable location? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    cp -R "$APP_PATH" /Applications/
    APP_PATH="/Applications/WhisperKey.app"
    echo "✅ Installed to /Applications"
else
    echo "⚠️  Running from DerivedData (may cause permission issues)"
fi
echo ""

# Step 8: Test Karabiner
echo "Step 8: Testing Karabiner configuration..."
echo "Opening Karabiner Event Viewer..."
open -a "Karabiner-EventViewer"
echo ""
echo "1. Press F5 in the Event Viewer"
echo "2. You should see it register as 'f13' not 'f5'"
echo "3. If you see 'f5', the Input Monitoring permission is not working"
echo ""
echo "Press Enter after testing F5 → F13 mapping..."
read

# Step 9: Launch WhisperKey
echo "Step 9: Launching WhisperKey..."
open "$APP_PATH"
echo ""
echo "✅ WhisperKey launched"
echo ""
echo "When prompted, grant Accessibility permission to WhisperKey"
echo ""

# Step 10: Final test
echo "Step 10: Final Testing"
echo "====================="
echo "1. Click 'Start Listening' in WhisperKey"
echo "2. Open TextEdit"
echo "3. Press F5 - should NOT trigger system dictation"
echo "4. Should see WhisperKey notification instead"
echo "5. Alternative: Try ⌘⇧D"
echo ""
echo "If F5 still triggers system dictation:"
echo "- Check Karabiner Event Viewer again"
echo "- Ensure Input Monitoring is granted to karabiner_grabber"
echo "- Try logging out and back in"
echo ""
echo "Done! 🎉"