//
//  WhisperService.swift
//  WhisperKey
//
//  Purpose: Manage whisper.cpp installation detection and paths
//  
//  Created by Author on 2025-07-10.
//

import Foundation
import SwiftUI

@MainActor
class WhisperService: ObservableObject {
    static let shared = WhisperService()
    
    @Published var isAvailable = false
    @Published var whisperPath: String?
    @Published var modelsPath: String?
    @Published var setupError: String?
    
    // User-configurable paths
    @AppStorage("customWhisperPath") private var customWhisperPath = ""
    @AppStorage("customModelsPath") private var customModelsPath = ""
    
    // Common installation locations to search
    private let whisperSearchPaths = [
        "~/.whisperkey/bin/whisper-cli",
        "~/Developer/whisper.cpp/build/bin/whisper-cli",
        "~/Developer/whisper.cpp/main",
        "/usr/local/bin/whisper-cli",
        "/opt/homebrew/bin/whisper-cli",
        "/opt/local/bin/whisper-cli"
    ]
    
    private let modelsSearchPaths = [
        "~/.whisperkey/models",
        "~/Developer/whisper.cpp/models",
        "~/.local/share/whisper/models",
        "/usr/local/share/whisper/models"
    ]
    
    init() {
        checkAvailability()
    }
    
    func checkAvailability() {
        // First check custom paths if set
        if !customWhisperPath.isEmpty {
            let expandedPath = NSString(string: customWhisperPath).expandingTildeInPath
            if validateWhisperExecutable(at: expandedPath) {
                whisperPath = expandedPath
                isAvailable = true
                DebugLogger.log("Found whisper.cpp at custom path: \(expandedPath)")
            } else {
                setupError = "Custom whisper path is invalid: \(customWhisperPath)"
            }
        }
        
        // If no custom path or invalid, search common locations
        if whisperPath == nil {
            for path in whisperSearchPaths {
                let expandedPath = NSString(string: path).expandingTildeInPath
                if validateWhisperExecutable(at: expandedPath) {
                    whisperPath = expandedPath
                    isAvailable = true
                    DebugLogger.log("Found whisper.cpp at: \(expandedPath)")
                    break
                }
            }
        }
        
        // Check for models directory
        if !customModelsPath.isEmpty {
            let expandedPath = NSString(string: customModelsPath).expandingTildeInPath
            if FileManager.default.fileExists(atPath: expandedPath) {
                modelsPath = expandedPath
                DebugLogger.log("Using custom models path: \(expandedPath)")
            }
        }
        
        if modelsPath == nil {
            for path in modelsSearchPaths {
                let expandedPath = NSString(string: path).expandingTildeInPath
                if FileManager.default.fileExists(atPath: expandedPath) {
                    modelsPath = expandedPath
                    DebugLogger.log("Found models at: \(expandedPath)")
                    break
                }
            }
        }
        
        // Set error if whisper not found
        if whisperPath == nil {
            isAvailable = false
            setupError = "WhisperKey couldn't find whisper.cpp on your system. Please install it or set a custom path in Settings."
        }
        
        // Warn if models not found
        if modelsPath == nil && isAvailable {
            setupError = "Whisper models directory not found. You may need to download models."
        }
    }
    
    private func validateWhisperExecutable(at path: String) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        
        if exists && !isDirectory.boolValue {
            // Check if it's executable
            return FileManager.default.isExecutableFile(atPath: path)
        }
        
        // Also check for 'main' executable (common whisper.cpp binary name)
        if exists && isDirectory.boolValue {
            let mainPath = (path as NSString).appendingPathComponent("main")
            return FileManager.default.isExecutableFile(atPath: mainPath)
        }
        
        return false
    }
    
    func getModelPath(for modelName: String) -> String? {
        guard let modelsPath = modelsPath else { return nil }
        
        let modelFile = "ggml-\(modelName).bin"
        let fullPath = (modelsPath as NSString).appendingPathComponent(modelFile)
        
        if FileManager.default.fileExists(atPath: fullPath) {
            return fullPath
        }
        
        return nil
    }
    
    func showSetupError() {
        // Show the interactive setup assistant
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "WhisperKey Setup"
        window.center()
        window.isReleasedWhenClosed = false
        
        let setupView = WhisperSetupAssistant()
        window.contentView = NSHostingView(rootView: setupView)
        
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func setCustomPaths(whisper: String?, models: String?) {
        if let whisper = whisper {
            customWhisperPath = whisper
        }
        if let models = models {
            customModelsPath = models
        }
        checkAvailability()
    }
}