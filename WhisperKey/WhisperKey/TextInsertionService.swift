//
//  TextInsertionService.swift
//  WhisperKey
//
//  Purpose: Insert transcribed text at current cursor position
//  
//  Created by Author on 2025-07-01.
//

import Cocoa
import ApplicationServices
import IOKit

class TextInsertionService {
    
    /// Static method to check if we're in a secure field
    static func isInSecureField() -> Bool {
        let service = TextInsertionService()
        
        // First check Terminal secure input
        if service.isTerminalSecureInputEnabled() {
            return true
        }
        
        // Then check focused element
        if let element = service.getFocusedElement() {
            return service.isSecureField(element)
        }
        
        return false
    }
    
    enum InsertionResult {
        case insertedAtCursor
        case keyboardSimulated  // We tried but can't confirm success
        case failed
    }
    
    enum InsertionError: LocalizedError {
        case noFocusedElement
        case insertionFailed
        case secureField
        case readOnlyField
        case disabledField
        case savedToClipboard
        
        var errorDescription: String? {
            switch self {
            case .noFocusedElement:
                return "No text field is currently focused"
            case .insertionFailed:
                return "Failed to insert text"
            case .secureField:
                return "Cannot dictate into password fields"
            case .readOnlyField:
                return "Cannot dictate into read-only fields"
            case .disabledField:
                return "Cannot dictate into disabled fields"
            case .savedToClipboard:
                return "Text saved to clipboard"
            }
        }
    }
    
    /// Save text to clipboard without simulating paste
    static func saveToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
    
    /// Insert text at the current cursor position
    func insertText(_ text: String) async throws -> InsertionResult {
        // Ensure we have accessibility permission
        guard AXIsProcessTrusted() else {
            throw InsertionError.insertionFailed
        }
        
        // Small delay to ensure recording indicator has dismissed
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        let focusedElement = getFocusedElement()
        
        // If we have a focused element, check if it's suitable and try AX insertion
        if let element = focusedElement {
            // First check if this is actually a text-editable element
            var role: CFTypeRef?
            AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &role)
            
            if let roleString = role as? String {
                // Only these roles can accept text input
                let textEditableRoles = ["AXTextField", "AXTextArea", "AXComboBox", "AXSearchField"]
                
                if !textEditableRoles.contains(roleString) {
                    DebugLogger.log("TextInsertionService: Element role '\(roleString)' is not text-editable")
                    // Not a text field - don't try keyboard simulation to avoid error sound
                    return .keyboardSimulated
                }
            }
            
            // Check if it's a secure field
            if isSecureField(element) {
                throw InsertionError.secureField
            }
            
            // Check if it's readonly
            if isReadOnlyField(element) {
                throw InsertionError.readOnlyField
            }
            
            // Check if it's disabled
            if isDisabledField(element) {
                throw InsertionError.disabledField
            }
            
            // Try direct AX insertion first
            if tryAXInsertion(text, into: element) {
                DebugLogger.log("TextInsertionService: AX insertion successful")
                return .insertedAtCursor
            }
            
            // AX insertion failed, but we have a focused element
            // Try keyboard simulation - this often works
            DebugLogger.log("TextInsertionService: AX insertion failed, trying keyboard simulation")
            _ = tryKeyboardSimulation(text)
            // We have a text-editable element, so it probably worked
            return .insertedAtCursor
        }
        
        // No focused element found - but we might still be in a text field
        // Many apps don't properly report focused elements via AX API
        DebugLogger.log("TextInsertionService: No focused element found, trying keyboard simulation anyway")
        
        // Try keyboard simulation - it often works even without AX element
        _ = tryKeyboardSimulation(text)
        
        // Return insertedAtCursor to indicate we tried typing
        // DictationService will handle clipboard fallback if user reports issue
        return .insertedAtCursor
    }
    
    /// Get the currently focused UI element
    private func getFocusedElement() -> AXUIElement? {
        let systemWide = AXUIElementCreateSystemWide()
        var focusedElement: CFTypeRef?
        
        let result = AXUIElementCopyAttributeValue(
            systemWide,
            kAXFocusedUIElementAttribute as CFString,
            &focusedElement
        )
        
        DebugLogger.log("TextInsertionService: getFocusedElement result: \(result.rawValue)")
        
        // Log error codes for debugging
        if result != .success {
            switch result {
            case AXError.apiDisabled:
                DebugLogger.log("TextInsertionService: AX API is disabled (-25204)")
            case AXError.invalidUIElement:
                DebugLogger.log("TextInsertionService: Invalid UI element (-25202)")
            case AXError.attributeUnsupported:
                DebugLogger.log("TextInsertionService: Attribute unsupported (-25205)")
            case AXError.noValue:
                DebugLogger.log("TextInsertionService: No value (-25212)")
            default:
                DebugLogger.log("TextInsertionService: Unknown error: \(result.rawValue)")
            }
        }
        
        // When successful, focusedElement contains an AXUIElement
        if result == .success {
            if CFGetTypeID(focusedElement) == AXUIElementGetTypeID() {
                // Safe cast because we've verified the type
                let element = focusedElement as! AXUIElement
                
                // Debug: Get element info
                var role: CFTypeRef?
                AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &role)
                DebugLogger.log("TextInsertionService: Found focused element with role: \(role as? String ?? "unknown")")
                
                return element
            } else {
                DebugLogger.log("TextInsertionService: focusedElement is not an AXUIElement")
            }
        } else {
            DebugLogger.log("TextInsertionService: Failed to get focused element, error: \(result.rawValue)")
        }
        return nil
    }
    
    /// Check if the focused element is a text field
    func isTextFieldFocused() -> Bool {
        guard let element = getFocusedElement() else { return false }
        
        var role: CFTypeRef?
        AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &role)
        
        if let roleString = role as? String {
            // Check for text input roles
            let textRoles = ["AXTextField", "AXTextArea", "AXComboBox", "AXStaticText"]
            return textRoles.contains(roleString)
        }
        
        return false
    }
    
    /// Check if the element is a secure/password field
    private func isSecureField(_ element: AXUIElement) -> Bool {
        var role: CFTypeRef?
        AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &role)
        
        if let roleString = role as? String {
            // Direct secure field check
            if roleString == "AXSecureTextField" {
                return true
            }
        }
        
        // Check subrole
        var subrole: CFTypeRef?
        AXUIElementCopyAttributeValue(element, kAXSubroleAttribute as CFString, &subrole)
        if let subroleString = subrole as? String,
           subroleString.lowercased().contains("secure") || subroleString.lowercased().contains("password") {
            return true
        }
        
        // Check description
        var description: CFTypeRef?
        AXUIElementCopyAttributeValue(element, kAXDescriptionAttribute as CFString, &description)
        if let descString = description as? String,
           descString.lowercased().contains("password") || descString.lowercased().contains("secure") {
            return true
        }
        
        // Check placeholder
        var placeholder: CFTypeRef?
        AXUIElementCopyAttributeValue(element, kAXPlaceholderValueAttribute as CFString, &placeholder)
        if let placeholderString = placeholder as? String,
           placeholderString.lowercased().contains("password") {
            return true
        }
        
        return false
    }
    
    /// Check if Terminal has secure input mode enabled
    private func isTerminalSecureInputEnabled() -> Bool {
        // Use IOKit to check secure input state
        return secureInputModeEnabled()
    }
    
    /// Check if the element is read-only
    private func isReadOnlyField(_ element: AXUIElement) -> Bool {
        // Check if settable
        var settable: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, "AXValueIsSettable" as CFString, &settable)
        if result == .success, let isSettable = settable as? Bool {
            return !isSettable
        }
        
        // Check if editable
        var editable: CFTypeRef?
        let editableResult = AXUIElementCopyAttributeValue(element, "AXEditable" as CFString, &editable)
        if editableResult == .success, let isEditable = editable as? Bool {
            return !isEditable
        }
        
        // Check role-specific attributes
        var role: CFTypeRef?
        AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &role)
        if let roleString = role as? String {
            // Static text and labels are always readonly
            if roleString == "AXStaticText" || roleString == "AXLabel" {
                return true
            }
        }
        
        return false
    }
    
    /// Check if the element is disabled
    private func isDisabledField(_ element: AXUIElement) -> Bool {
        // Check enabled state
        var enabled: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, kAXEnabledAttribute as CFString, &enabled)
        if result == .success, let isEnabled = enabled as? Bool {
            return !isEnabled
        }
        
        // If no enabled attribute, assume it's enabled
        return false
    }
    
    /// Method 1: Direct insertion via Accessibility API
    private func tryAXInsertion(_ text: String, into element: AXUIElement) -> Bool {
        // First try to insert as selected text (replaces selection)
        var result = AXUIElementSetAttributeValue(
            element,
            kAXSelectedTextAttribute as CFString,
            text as CFString
        )
        
        if result == .success {
            return true
        }
        
        // If that fails, try to append to value
        var currentValue: CFTypeRef?
        result = AXUIElementCopyAttributeValue(
            element,
            kAXValueAttribute as CFString,
            &currentValue
        )
        
        if result == .success, let value = currentValue as? String {
            let newValue = value + text
            result = AXUIElementSetAttributeValue(
                element,
                kAXValueAttribute as CFString,
                newValue as CFString
            )
            return result == .success
        }
        
        return false
    }
    
    /// Method 2: Simulate keyboard typing
    private func tryKeyboardSimulation(_ text: String) -> Bool {
        let source = CGEventSource(stateID: .hidSystemState)
        
        for character in text {
            autoreleasepool {
                // Create key down event
                if let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true) {
                    let str = String(character)
                    // Convert String to UniChar array
                    let chars = Array(str.utf16)
                    chars.withUnsafeBufferPointer { buffer in
                        keyDown.keyboardSetUnicodeString(stringLength: chars.count, unicodeString: buffer.baseAddress)
                    }
                    keyDown.post(tap: .cghidEventTap)
                    
                    // Create key up event
                    if let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false) {
                        chars.withUnsafeBufferPointer { buffer in
                            keyUp.keyboardSetUnicodeString(stringLength: chars.count, unicodeString: buffer.baseAddress)
                        }
                        keyUp.post(tap: .cghidEventTap)
                    }
                    
                    // Small delay to simulate natural typing
                    usleep(5000) // 5ms
                }
            }
        }
        
        return true
    }
    
    /// Method 3: Clipboard insertion (last resort)
    private func tryClipboardInsertion(_ text: String) {
        // Save current clipboard
        let pasteboard = NSPasteboard.general
        let savedContents = pasteboard.string(forType: .string)
        
        // Set our text
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        
        // Simulate Cmd+V
        let source = CGEventSource(stateID: .hidSystemState)
        
        // Key down Cmd
        let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: KeyCode.command, keyDown: true)
        cmdDown?.flags = .maskCommand
        cmdDown?.post(tap: .cghidEventTap)
        
        // Key down V
        let vDown = CGEvent(keyboardEventSource: source, virtualKey: KeyCode.v, keyDown: true)
        vDown?.flags = .maskCommand
        vDown?.post(tap: .cghidEventTap)
        
        // Key up V
        let vUp = CGEvent(keyboardEventSource: source, virtualKey: KeyCode.v, keyDown: false)
        vUp?.flags = .maskCommand
        vUp?.post(tap: .cghidEventTap)
        
        // Key up Cmd
        let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: KeyCode.command, keyDown: false)
        cmdUp?.post(tap: .cghidEventTap)
        
        // Restore clipboard after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let saved = savedContents {
                pasteboard.clearContents()
                pasteboard.setString(saved, forType: .string)
            }
        }
    }
    
    /// Clear previous text by simulating backspace key presses
    func clearPreviousText(characterCount: Int) async throws {
        guard characterCount > 0 else { return }
        
        let source = CGEventSource(stateID: .hidSystemState)
        
        // Simulate backspace key presses
        for _ in 0..<characterCount {
            // Create backspace key down event
            if let backspaceDown = CGEvent(keyboardEventSource: source, virtualKey: KeyCode.backspace, keyDown: true) {
                backspaceDown.post(tap: .cghidEventTap)
                
                // Create backspace key up event
                if let backspaceUp = CGEvent(keyboardEventSource: source, virtualKey: KeyCode.backspace, keyDown: false) {
                    backspaceUp.post(tap: .cghidEventTap)
                }
                
                // Small delay to ensure proper processing
                usleep(10000) // 10ms
            }
        }
    }
    
    /// Get information about the current text field (for debugging)
    func getCurrentFieldInfo() -> String {
        // First check if AX is working at all
        let trusted = AXIsProcessTrusted()
        var info = "AX API Status:\n"
        info += "  Trusted: \(trusted)\n"
        
        // Try to get system-wide element first
        let systemWide = AXUIElementCreateSystemWide()
        var focusedApp: CFTypeRef?
        let appResult = AXUIElementCopyAttributeValue(
            systemWide,
            kAXFocusedApplicationAttribute as CFString,
            &focusedApp
        )
        info += "  Can get focused app: \(appResult == .success)\n"
        
        guard let element = getFocusedElement() else {
            return info + "\nNo focused element"
        }
        
        info += "\nFocused Element Info:\n"
        
        // Get role
        var role: CFTypeRef?
        AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &role)
        info += "Role: \(role as? String ?? "unknown")\n"
        
        // Get title
        var title: CFTypeRef?
        AXUIElementCopyAttributeValue(element, kAXTitleAttribute as CFString, &title)
        if let titleStr = title as? String {
            info += "Title: \(titleStr)\n"
        }
        
        // Check if editable
        var editable: CFTypeRef?
        AXUIElementCopyAttributeValue(element, "AXEditable" as CFString, &editable)
        info += "Editable: \(editable as? Bool ?? false)\n"
        
        // Check if secure
        info += "Secure: \(isSecureField(element))\n"
        
        return info
    }
}

// MARK: - Static Helper Methods

// Function to check secure input mode
private func secureInputModeEnabled() -> Bool {
    // Use IOKit to check secure input state
    var secureInputEnabled: DarwinBoolean = false
    if let ioFramework = CFBundleGetBundleWithIdentifier("com.apple.iokit" as CFString),
       let funcPointer = CFBundleGetFunctionPointerForName(ioFramework, "IOHIDCheckSecureInputMode" as CFString) {
        typealias IOHIDCheckSecureInputModeFunc = @convention(c) () -> DarwinBoolean
        let checkFunc = unsafeBitCast(funcPointer, to: IOHIDCheckSecureInputModeFunc.self)
        secureInputEnabled = checkFunc()
    }
    return secureInputEnabled.boolValue
}

extension TextInsertionService {
    /// Check if Terminal or another app has secure input mode enabled
    static func getSecureInputApp() -> String? {
        // Check if secure input mode is enabled
        if secureInputModeEnabled() {
            // Get the frontmost app
            let workspace = NSWorkspace.shared
            if let activeApp = workspace.frontmostApplication {
                return activeApp.localizedName
            }
        }
        return nil
    }
}