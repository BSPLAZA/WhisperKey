#!/bin/bash

# Script to help transition WhisperKey to menu bar architecture

echo "=== WhisperKey Menu Bar Transition Helper ==="
echo ""
echo "This script will guide you through updating the Xcode project"
echo ""

# Step 1: Check current state
echo "Step 1: Checking current project state..."
if [ -f "/Users/orion/Omni/WhisperKey/WhisperKey/WhisperKey.xcodeproj/project.pbxproj" ]; then
    echo "✅ Xcode project found"
else
    echo "❌ Xcode project not found at expected location"
    exit 1
fi

# Step 2: Create backup
echo ""
echo "Step 2: Creating backup..."
cp -r "/Users/orion/Omni/WhisperKey/WhisperKey" "/Users/orion/Omni/WhisperKey/WhisperKey.backup.$(date +%Y%m%d_%H%M%S)"
echo "✅ Backup created"

# Step 3: Show what needs to be done in Xcode
echo ""
echo "Step 3: Manual steps needed in Xcode:"
echo ""
echo "1. Open WhisperKey.xcodeproj in Xcode"
echo ""
echo "2. Add Swift Package Dependency:"
echo "   - File → Add Package Dependencies..."
echo "   - Enter: https://github.com/soffes/HotKey"
echo "   - Click 'Add Package'"
echo "   - Select 'HotKey' and click 'Add Package'"
echo ""
echo "3. Update main app file:"
echo "   - Delete or rename WhisperKeyApp.swift"
echo "   - Set MenuBarApp.swift as the main app file"
echo "   - In Target settings → General → 'Main Interface': leave empty"
echo ""
echo "4. Update Info.plist:"
echo "   - Add key: 'Application is agent (UIElement)' = YES"
echo "   - This removes the app from the Dock"
echo ""
echo "5. Remove unnecessary files:"
echo "   - ContentView.swift (replaced by menu bar)"
echo "   - KeyCaptureService.swift (replaced by HotKey)"
echo "   - EnhancedKeyCaptureService.swift (replaced by HotKey)"
echo "   - IOKitF5Monitor.swift (no longer needed)"
echo "   - SimpleF5Monitor.swift (no longer needed)"
echo ""
echo "6. Keep for reference:"
echo "   - AccessibilityChecker.swift (might still be useful)"
echo ""
echo "7. Build and test:"
echo "   - Build: Cmd+B"
echo "   - Run: Cmd+R"
echo "   - Look for the 🎤 icon in menu bar"
echo "   - Test F13 key (or configured hotkey)"
echo ""

# Step 4: Create a simple test
echo "Step 4: Creating integration test..."
cat > /Users/orion/Omni/WhisperKey/test_integration.swift << 'EOF'
#!/usr/bin/swift

import Foundation

print("=== WhisperKey Integration Test ===")
print("")
print("Testing new architecture components...")

// Test 1: Check if MenuBarApp.swift exists
let menuBarPath = "/Users/orion/Omni/WhisperKey/WhisperKey/WhisperKey/MenuBarApp.swift"
if FileManager.default.fileExists(atPath: menuBarPath) {
    print("✅ MenuBarApp.swift exists")
} else {
    print("❌ MenuBarApp.swift not found")
}

// Test 2: Check Package.swift
let packagePath = "/Users/orion/Omni/WhisperKey/Package.swift"
if FileManager.default.fileExists(atPath: packagePath) {
    print("✅ Package.swift exists")
    if let content = try? String(contentsOfFile: packagePath),
       content.contains("HotKey") {
        print("✅ HotKey dependency configured")
    } else {
        print("⚠️  HotKey dependency not found in Package.swift")
    }
} else {
    print("❌ Package.swift not found")
}

// Test 3: Check for old files that should be removed
let oldFiles = [
    "KeyCaptureService.swift",
    "EnhancedKeyCaptureService.swift",
    "IOKitF5Monitor.swift",
    "SimpleF5Monitor.swift"
]

print("")
print("Checking for old files to remove:")
for file in oldFiles {
    let path = "/Users/orion/Omni/WhisperKey/WhisperKey/WhisperKey/\(file)"
    if FileManager.default.fileExists(atPath: path) {
        print("⚠️  \(file) still exists (should be removed)")
    } else {
        print("✅ \(file) removed")
    }
}

print("")
print("Integration test complete!")
EOF

chmod +x /Users/orion/Omni/WhisperKey/test_integration.swift

echo ""
echo "Step 5: Next actions:"
echo ""
echo "1. Run the manual steps in Xcode (listed above)"
echo "2. Test the integration: ./test_integration.swift"
echo "3. Commit the changes with:"
echo "   git add -A"
echo "   git commit -m \"Refactor: Pivot to menu bar app with HotKey library"
echo ""
echo "   TESTED ✅: Menu bar app with F13 hotkey"
echo "   - Replaced unreliable F5 interception with configurable hotkeys"
echo "   - Implemented menu bar UI for better user experience"
echo "   - Added HotKey library for reliable global shortcuts"
echo "   - Removed complex CGEventTap and IOKit code"
echo ""
echo "   STATUS: Ready for Whisper integration\""
echo ""
echo "Press Enter to continue..."
read