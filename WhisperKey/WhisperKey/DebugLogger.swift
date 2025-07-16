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
    private static var recentLogs: [String] = []
    private static let maxLogs = 1000
    private static let logQueue = DispatchQueue(label: "com.whisperkey.debuglogger")
    
    /// Check if debug mode is enabled
    static var isEnabled: Bool {
        // Always enable for test builds
        #if DEBUG
        return true
        #else
        return UserDefaults.standard.bool(forKey: "debugMode")
        #endif
    }
    
    /// Log a debug message if debug mode is enabled
    static func log(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let timestamp = Date().formatted(.dateTime.hour().minute().second())
        let filename = (file as NSString).lastPathComponent
        let logEntry = "[\(timestamp)] [\(filename):\(line)] \(message)"
        
        // Store in memory for debug reports
        logQueue.async {
            recentLogs.append(logEntry)
            if recentLogs.count > maxLogs {
                recentLogs.removeFirst(recentLogs.count - maxLogs)
            }
        }
        
        // Print if enabled
        guard isEnabled else { return }
        print(logEntry)
    }
    
    /// Log a simple message without file info
    static func simple(_ message: String) {
        log(message)
    }
    
    /// Get recent logs for debug reports
    static func getRecentLogs(lines: Int = 100) -> String {
        return logQueue.sync {
            let startIndex = max(0, recentLogs.count - lines)
            return recentLogs[startIndex..<recentLogs.count].joined(separator: "\n")
        }
    }
}