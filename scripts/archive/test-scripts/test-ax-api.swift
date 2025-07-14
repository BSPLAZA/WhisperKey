#!/usr/bin/env swift

import Cocoa
import ApplicationServices

print("=== Testing AX API for WhisperKey ===\n")

// Check accessibility permission
let trusted = AXIsProcessTrusted()
print("Accessibility permission: \(trusted ? "✅ Granted" : "❌ Not granted")")

if !trusted {
    print("\nPlease grant accessibility permission and run again.")
    exit(1)
}

print("\nWaiting 3 seconds... Click in a text field!")
Thread.sleep(forTimeInterval: 3)

// Test getting focused element
let systemWide = AXUIElementCreateSystemWide()
var focusedElement: CFTypeRef?

let result = AXUIElementCopyAttributeValue(
    systemWide,
    kAXFocusedUIElementAttribute as CFString,
    &focusedElement
)

print("\nAX API Result: \(result.rawValue)")
print("Result == .success: \(result == .success)")

if result == .success {
    print("focusedElement is nil: \(focusedElement == nil)")
    
    if focusedElement != nil {
        print("Type ID of focusedElement: \(CFGetTypeID(focusedElement))")
        print("AXUIElement Type ID: \(AXUIElementGetTypeID())")
        print("Types match: \(CFGetTypeID(focusedElement) == AXUIElementGetTypeID())")
        
        if CFGetTypeID(focusedElement) == AXUIElementGetTypeID() {
            let element = focusedElement as! AXUIElement
            
            // Get role
            var role: CFTypeRef?
            AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &role)
            print("\nElement role: \(role as? String ?? "unknown")")
            
            // Try to get value
            var value: CFTypeRef?
            AXUIElementCopyAttributeValue(element, kAXValueAttribute as CFString, &value)
            print("Element has value: \(value != nil)")
            
            // Try to insert text
            print("\nTrying to insert text...")
            let testText = "[TEST FROM AX API]"
            let insertResult = AXUIElementSetAttributeValue(
                element,
                kAXSelectedTextAttribute as CFString,
                testText as CFString
            )
            print("Insert result: \(insertResult.rawValue) (0 = success)")
        }
    }
} else {
    print("\nFailed to get focused element!")
    print("Common error codes:")
    print("  -25204 = API Disabled") 
    print("  -25202 = Invalid UI Element")
    print("  -25205 = Not Implemented")
}