//
//  DebugLogger.swift
//  WhisperKey
//
//  Purpose: Centralized debug logging that respects user preferences
//  
//  Created by Author on 2025-07-10.
//

import Foundation

/// Simple debug logger that only prints when debug mode is enabled
struct DebugLogger {
    /// Check if debug mode is enabled
    static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: "debugMode")
    }
    
    /// Log a debug message if debug mode is enabled
    static func log(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        guard isEnabled else { return }
        
        let filename = (file as NSString).lastPathComponent
        print("[\(filename):\(line)] \(function) - \(message)")
    }
    
    /// Log a simple message without file info
    static func simple(_ message: String) {
        guard isEnabled else { return }
        print(message)
    }
}