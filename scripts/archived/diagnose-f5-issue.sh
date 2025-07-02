#!/bin/bash

# F5 Dictation Issue Diagnostic Script
echo "=== F5 Dictation Issue Diagnosis ==="
echo ""

# Check current dictation settings
echo "1. Checking dictation settings..."
echo -n "   AppleDictationAutoEnable: "
defaults read com.apple.HIToolbox AppleDictationAutoEnable 2>/dev/null || echo "not set"

echo -n "   DictationEnabled: "
defaults read com.apple.speech.recognition.AppleSpeechRecognition.prefs DictationEnabled 2>/dev/null || echo "not set"

echo -n "   Standard function keys: "
defaults read -g com.apple.keyboard.fnState 2>/dev/null || echo "not set"

# Check symbolic hotkeys
echo ""
echo "2. Checking symbolic hotkeys..."
echo "   Dictation hotkeys (should all be disabled):"
for id in 160 161 162 163 164; do
    echo -n "   Hotkey $id: "
    /usr/libexec/PlistBuddy -c "Print :AppleSymbolicHotKeys:$id:enabled" ~/Library/Preferences/com.apple.symbolichotkeys.plist 2>/dev/null || echo "not found"
done

# Check if Karabiner is running
echo ""
echo "3. Checking Karabiner-Elements..."
if pgrep -x "karabiner_grabber" > /dev/null; then
    echo "   ✅ Karabiner grabber is running"
else
    echo "   ❌ Karabiner grabber is NOT running"
fi

if [ -f "$HOME/.config/karabiner/karabiner.json" ]; then
    echo "   ✅ Karabiner config exists"
    # Check if our rule is present
    if grep -q "whisperkey" "$HOME/.config/karabiner/assets/complex_modifications/"*.json 2>/dev/null; then
        echo "   ✅ WhisperKey rules found"
    else
        echo "   ❌ WhisperKey rules NOT found"
    fi
else
    echo "   ❌ Karabiner config NOT found"
fi

# Test F5 interception
echo ""
echo "4. Testing F5 key interception..."
echo "   Creating temporary key logger..."

# Create a simple key logger
cat > /tmp/test_f5_intercept.swift << 'EOF'
import Cocoa
import Carbon

print("Monitoring F5 key for 10 seconds...")
print("Press F5 to test...")

var count = 0
let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << 14)

guard let eventTap = CGEvent.tapCreate(
    tap: .cgSessionEventTap,
    place: .headInsertEventTap,
    options: .listenOnly,
    eventsOfInterest: CGEventMask(eventMask),
    callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
        if type == .keyDown {
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            if keyCode == 0x60 {
                print("✅ F5 key detected! (keycode: 0x60)")
                count += 1
            }
        } else if type.rawValue == 14 {
            if let nsEvent = NSEvent(cgEvent: event) {
                if nsEvent.subtype.rawValue == 8 {
                    let keyCode = Int((nsEvent.data1 & 0xFFFF0000) >> 16)
                    if keyCode == 0xCF {
                        print("⚠️ Dictation key detected (system event)")
                        count += 1
                    }
                }
            }
        }
        return Unmanaged.passRetained(event)
    },
    userInfo: nil
) else {
    print("Failed to create event tap")
    exit(1)
}

let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
CGEvent.tapEnable(tap: eventTap, enable: true)

// Run for 10 seconds
DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
    print("\nTest complete. F5 pressed \(count) times")
    exit(0)
}

CFRunLoopRun()
EOF

echo "   Running key monitor (press F5 in the next 10 seconds)..."
swift /tmp/test_f5_intercept.swift 2>&1

# Summary
echo ""
echo "=== Diagnosis Summary ==="
echo ""
echo "If F5 still triggers system dictation:"
echo "1. Run: /Users/orion/Omni/WhisperKey/scripts/comprehensive-fix.sh"
echo "2. Restart your Mac"
echo "3. Enable 'Use F1, F2, etc. keys as standard function keys' in System Settings"
echo "4. Make sure Karabiner-Elements is running with Input Monitoring permission"
echo ""
echo "If you see 'Dictation key detected (system event)' above,"
echo "the system is still intercepting F5 before our app can block it."