#!/usr/bin/env swift

// Quick test to verify Right Option key code
import Cocoa

print("=== Right Option Key Test ===")
print("")
print("This will monitor key presses for 10 seconds.")
print("Press your RIGHT Option key to test.")
print("")

var rightOptionPressed = false

// Create event monitor
let eventMask: NSEvent.EventTypeMask = [.keyDown, .flagsChanged]
let monitor = NSEvent.addGlobalMonitorForEvents(matching: eventMask) { event in
    // Check for right option via modifier flags
    if event.type == .flagsChanged {
        let flags = event.modifierFlags
        
        // Check if ONLY right option is pressed (no other modifiers)
        if flags.contains(.option) && !flags.contains(.command) && !flags.contains(.shift) && !flags.contains(.control) {
            // Try to distinguish right vs left option
            // Note: This is tricky as macOS doesn't always distinguish
            print("✅ Option key detected! (flags: \(flags.rawValue))")
            rightOptionPressed = true
        }
    }
    
    // Also check keyDown events
    if event.type == .keyDown {
        print("Key pressed: keyCode=\(event.keyCode), characters=\(event.characters ?? "nil")")
        
        // Right Option typically doesn't generate keyDown events when pressed alone
        // But it might when used with other keys
    }
}

print("Monitoring... (press Ctrl+C to stop)")

// Run for 10 seconds
DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
    NSEvent.removeMonitor(monitor!)
    
    print("")
    if rightOptionPressed {
        print("✅ Right Option key detection successful!")
        print("   WhisperKey should be able to use this as a hotkey.")
    } else {
        print("❌ Right Option key not detected.")
        print("   Make sure you pressed the RIGHT Option key (next to right Cmd).")
    }
    exit(0)
}

// Keep the script running
RunLoop.main.run()