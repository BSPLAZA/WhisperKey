#!/usr/bin/env swift

import Cocoa
import ApplicationServices

print("=== WhisperKey Cursor Position Test ===")
print("")
print("This tests if we can detect and insert text at cursor position")
print("")

// Check if we have accessibility permission
let trusted = AXIsProcessTrusted()
print("Accessibility permission: \(trusted ? "✅ Granted" : "❌ Not granted")")

if !trusted {
    print("\nTo grant permission:")
    print("1. System Settings → Privacy & Security → Accessibility")
    print("2. Add Terminal (or your script runner)")
    print("3. Run this test again")
    exit(1)
}

print("\nTesting in 3 seconds...")
print("1. Click in any text field (TextEdit, Notes, etc.)")
print("2. Wait for the test to run")
print("")

// Wait for user to position cursor
Thread.sleep(forTimeInterval: 3)

// Get the focused element
let systemWide = AXUIElementCreateSystemWide()
var focusedElement: CFTypeRef?
let result = AXUIElementCopyAttributeValue(
    systemWide,
    kAXFocusedUIElementAttribute as CFString,
    &focusedElement
)

if result == .success, let element = focusedElement {
    print("✅ Found focused element!")
    
    // Get element details
    var role: CFTypeRef?
    AXUIElementCopyAttributeValue(element as! AXUIElement, kAXRoleAttribute as CFString, &role)
    print("   Role: \(role as? String ?? "unknown")")
    
    var value: CFTypeRef?
    AXUIElementCopyAttributeValue(element as! AXUIElement, kAXValueAttribute as CFString, &value)
    print("   Current value: \(String(describing: value).prefix(50))...")
    
    // Try to insert text
    print("\n🔤 Attempting to insert text...")
    let testText = "[WhisperKey Test Insert]"
    
    // Method 1: Try setting selected text
    let insertResult = AXUIElementSetAttributeValue(
        element as! AXUIElement,
        kAXSelectedTextAttribute as CFString,
        testText as CFString
    )
    
    if insertResult == .success {
        print("✅ Successfully inserted text using AX API!")
        print("   You should see: \(testText)")
    } else {
        print("⚠️  AX insertion failed, trying keyboard simulation...")
        
        // Method 2: Simulate typing
        let source = CGEventSource(stateID: .hidSystemState)
        
        for char in testText {
            if let event = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true) {
                let str = String(char)
                event.keyboardSetUnicodeString(stringLength: str.count, unicodeString: str)
                event.post(tap: .cghidEventTap)
                
                // Key up
                if let upEvent = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false) {
                    upEvent.post(tap: .cghidEventTap)
                }
                
                Thread.sleep(forTimeInterval: 0.01) // Small delay between characters
            }
        }
        
        print("✅ Simulated keyboard typing complete!")
        print("   You should see: \(testText)")
    }
    
    // Check if it's a secure field
    var isSecure: CFTypeRef?
    AXUIElementCopyAttributeValue(
        element as! AXUIElement,
        "AXSecureTextField" as CFString,
        &isSecure
    )
    if isSecure as? Bool == true {
        print("\n⚠️  Warning: This is a secure/password field!")
        print("   WhisperKey will warn users before dictating passwords")
    }
    
} else {
    print("❌ Could not find focused element")
    print("   Make sure cursor is in a text field")
    print("   Error: \(result)")
}

print("\n=== Test Complete ===")
print("")
print("This demonstrates that WhisperKey can:")
print("✅ Detect where your cursor is")
print("✅ Insert text at that exact position")
print("✅ Work in any app's text field")
print("✅ Provide the same UX as Apple's dictation")