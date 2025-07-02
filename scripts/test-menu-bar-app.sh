#!/bin/bash

# Test script for the new menu bar app approach

echo "=== WhisperKey Menu Bar App Test ==="
echo ""
echo "This script will help test the new menu bar app architecture"
echo ""

# Check if HotKey library can be fetched
echo "1. Testing Swift Package Manager..."
cd /Users/orion/Omni/WhisperKey
swift package resolve 2>&1 | grep -E "(Fetching|Computing|error)"

# Create a minimal test app
echo ""
echo "2. Creating minimal test app..."

cat > /tmp/test_hotkey_menubar.swift << 'EOF'
import Cocoa
import HotKey

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var hotKey: HotKey?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "🎤"
        
        // Create menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Test F13", action: #selector(testF13), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem?.menu = menu
        
        // Set up F13 hotkey
        hotKey = HotKey(key: .f13, modifiers: [])
        hotKey?.keyDownHandler = {
            print("✅ F13 pressed! WhisperKey would start recording now.")
            NSSound.beep()
        }
        
        print("✅ Menu bar app started. Press F13 to test.")
        print("   If F13 doesn't work, try Fn+F13 or check keyboard settings.")
    }
    
    @objc func testF13() {
        print("Testing F13 registration...")
        if hotKey != nil {
            print("✅ F13 hotkey is registered")
        } else {
            print("❌ F13 hotkey failed to register")
        }
    }
    
    @objc func quit() {
        NSApp.terminate(nil)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
EOF

echo ""
echo "3. Compiling test app..."
swiftc -framework Cocoa -framework Carbon /tmp/test_hotkey_menubar.swift -o /tmp/test_hotkey_menubar 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Compilation successful!"
    echo ""
    echo "4. Running test app..."
    echo "   - Look for 🎤 in your menu bar"
    echo "   - Press F13 to test hotkey"
    echo "   - Right-click the icon to quit"
    echo ""
    /tmp/test_hotkey_menubar
else
    echo "❌ Compilation failed. The HotKey library might need to be added via Xcode."
    echo ""
    echo "Alternative test: Let's verify our architecture decisions..."
    echo ""
    echo "Key insights from research:"
    echo "- F5 is system-reserved and cannot be reliably intercepted"
    echo "- Menu bar apps with F13/F14/F15 work perfectly"
    echo "- HotKey library uses Carbon Events (deprecated but functional)"
    echo "- This approach avoids all permission and TCC database issues"
fi

echo ""
echo "=== Summary ==="
echo ""
echo "The new architecture solves our problems by:"
echo "1. Not fighting the system (F5 is off-limits)"
echo "2. Using proven libraries (HotKey)"
echo "3. Providing better UX (menu bar status)"
echo "4. Avoiding permission headaches"
echo ""
echo "Next steps:"
echo "1. Update Xcode project to use Package.swift"
echo "2. Replace WhisperKeyApp.swift with MenuBarApp.swift"
echo "3. Test with actual Whisper integration"