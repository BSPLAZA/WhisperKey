//
//  TextInsertionService.swift
//  WhisperKey
//
//  Purpose: Insert transcribed text at current cursor position
//  
//  Created by Orion on 2025-07-01.
//

import Cocoa
import ApplicationServices

class TextInsertionService {
    
    enum InsertionError: LocalizedError {
        case noFocusedElement
        case insertionFailed
        case secureField
        
        var errorDescription: String? {
            switch self {
            case .noFocusedElement:
                return "No text field is currently focused"
            case .insertionFailed:
                return "Failed to insert text"
            case .secureField:
                return "Cannot dictate into password fields"
            }
        }
    }
    
    /// Insert text at the current cursor position
    func insertText(_ text: String) async throws {
        // Ensure we have accessibility permission
        guard AXIsProcessTrusted() else {
            throw InsertionError.insertionFailed
        }
        
        // Get the focused element (might not work for all apps)
        if let focusedElement = getFocusedElement() {
            // Check if it's a secure field
            if isSecureField(focusedElement) {
                throw InsertionError.secureField
            }
            
            // Try direct AX insertion first
            if tryAXInsertion(text, into: focusedElement) {
                return
            }
        }
        
        // For apps that don't expose proper accessibility elements (like Electron apps),
        // fall back to keyboard simulation or clipboard
        if !tryKeyboardSimulation(text) {
            tryClipboardInsertion(text)
        }
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
        
        return result == .success ? (focusedElement as! AXUIElement) : nil
    }
    
    /// Check if the element is a secure/password field
    private func isSecureField(_ element: AXUIElement) -> Bool {
        var role: CFTypeRef?
        AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &role)
        
        if let roleString = role as? String {
            return roleString == "AXSecureTextField"
        }
        
        // Also check for password attribute
        var isPassword: CFTypeRef?
        AXUIElementCopyAttributeValue(element, "AXSecureTextField" as CFString, &isPassword)
        
        return isPassword as? Bool ?? false
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
                    Thread.sleep(forTimeInterval: 0.005)
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
        let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: true)
        cmdDown?.flags = .maskCommand
        cmdDown?.post(tap: .cghidEventTap)
        
        // Key down V
        let vDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        vDown?.flags = .maskCommand
        vDown?.post(tap: .cghidEventTap)
        
        // Key up V
        let vUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        vUp?.flags = .maskCommand
        vUp?.post(tap: .cghidEventTap)
        
        // Key up Cmd
        let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: false)
        cmdUp?.post(tap: .cghidEventTap)
        
        // Restore clipboard after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let saved = savedContents {
                pasteboard.clearContents()
                pasteboard.setString(saved, forType: .string)
            }
        }
    }
    
    /// Get information about the current text field (for debugging)
    func getCurrentFieldInfo() -> String {
        guard let element = getFocusedElement() else {
            return "No focused element"
        }
        
        var info = "Focused Element Info:\n"
        
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