//
//  KeyCodes.swift
//  WhisperKey
//
//  Purpose: Centralized keyboard constants for better maintainability
//  
//  Created by Assistant on 2025-07-16.
//

import Carbon

/// Centralized keyboard key code constants
enum KeyCode {
    // Keys used for dictation trigger
    static let rightOption: UInt16 = 61
    
    // Keys used for text insertion (Cmd+V simulation)
    static let command: CGKeyCode = 0x37
    static let v: CGKeyCode = 0x09
    static let backspace: CGKeyCode = 0x33
    
    // Modifier keys
    static let option: CGKeyCode = 0x3A
    static let control: CGKeyCode = 0x3B
    static let shift: CGKeyCode = 0x38
    
    // Historical F5 constants (kept for reference/future use)
    static let f5Standard: UInt16 = 0x60
    static let f5DictationHID: UInt32 = 0x000c00cf
    static let f5SystemEvent: UInt16 = 0xCF
}