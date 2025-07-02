#!/bin/bash

# WhisperKey Build and Run Script

echo "=== WhisperKey Build Script ==="
echo ""
echo "This script will help you build and run WhisperKey"
echo ""

PROJECT_DIR="/Users/orion/Omni/WhisperKey/WhisperKey"
PROJECT_FILE="$PROJECT_DIR/WhisperKey.xcodeproj"

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode command line tools not found"
    echo "   Please install Xcode from the App Store"
    exit 1
fi

echo "📦 Step 1: Opening project in Xcode..."
echo ""
echo "When Xcode opens:"
echo ""
echo "1. ADD HOTKEY PACKAGE:"
echo "   - File → Add Package Dependencies"
echo "   - Enter: https://github.com/soffes/HotKey"
echo "   - Click 'Add Package'"
echo "   - Select 'HotKey' and add to WhisperKey target"
echo ""
echo "2. CLEAN BUILD FOLDER:"
echo "   - Product → Clean Build Folder (Cmd+Shift+K)"
echo ""
echo "3. BUILD AND RUN:"
echo "   - Press Cmd+R or click the Play button"
echo ""
echo "4. GRANT PERMISSIONS:"
echo "   - When prompted, grant Accessibility permission"
echo "   - When prompted, grant Microphone permission"
echo ""
echo "5. TEST:"
echo "   - Look for 🎤 in your menu bar"
echo "   - Open TextEdit or Notes"
echo "   - Click in text field"
echo "   - Press Right Option (⌥)"
echo "   - Speak something"
echo "   - Press Right Option again"
echo ""

# Open the project
open "$PROJECT_FILE"

echo "📝 Quick Reference:"
echo "- Right Option (⌥): Start/stop recording"
echo "- Menu bar 🎤: Click for settings"
echo "- Red 🎤: Currently recording"
echo ""
echo "If Right Option doesn't work, you can:"
echo "1. Click 🎤 → Hotkey → Choose different key"
echo "2. Try Caps Lock or F13 instead"
echo ""
echo "Press Enter when ready to see build output..."
read

# Try to build from command line (may fail without package resolution)
echo ""
echo "Attempting command line build..."
cd "$PROJECT_DIR"
xcodebuild -scheme WhisperKey -configuration Debug build 2>&1 | grep -E "(error:|warning:|Build succeeded|Build failed)"

echo ""
echo "=== Next Steps ==="
echo ""
echo "If the build succeeded:"
echo "1. The app is running (check menu bar for 🎤)"
echo "2. Test Right Option key"
echo "3. Check ~/Library/Developer/Xcode/DerivedData/WhisperKey*/Build/Products/Debug/WhisperKey.app"
echo ""
echo "If the build failed:"
echo "1. Make sure you added the HotKey package in Xcode"
echo "2. Clean and rebuild in Xcode (Cmd+Shift+K, then Cmd+R)"
echo "3. Check that MenuBarApp.swift is the @main entry point"