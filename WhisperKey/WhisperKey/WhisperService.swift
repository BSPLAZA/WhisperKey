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
    private var whisperSearchPaths: [String] {
        var paths: [String] = []
        
        // FIRST: Check for bundled whisper-cli in MacOS directory (moved from Resources to avoid conflict)
        // This must be computed at runtime, not init time
        let bundlePath = Bundle.main.bundlePath
        let macOSPath = (bundlePath as NSString).appendingPathComponent("Contents/MacOS")
        let whisperPath = (macOSPath as NSString).appendingPathComponent("whisper-cli")
        paths.append(whisperPath)
        DebugLogger.log("WhisperService: Checking bundle path: \(whisperPath)")
        
        // Then check system paths as fallback
        paths.append(contentsOf: [
            "~/.whisperkey/bin/whisper-cli",
            "~/Developer/whisper.cpp/build/bin/whisper-cli",
            "~/Developer/whisper.cpp/main",
            "/usr/local/bin/whisper-cli",
            "/opt/homebrew/bin/whisper-cli",
            "/opt/local/bin/whisper-cli"
        ])
        
        return paths
    }
    
    let modelsSearchPaths = [
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
                DebugLogger.log("WhisperService: Checking for whisper at: \(expandedPath)")
                if validateWhisperExecutable(at: expandedPath) {
                    whisperPath = expandedPath
                    isAvailable = true
                    DebugLogger.log("WhisperService: Found whisper.cpp at: \(expandedPath)")
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
            // Create default models directory if it doesn't exist
            let defaultModelsPath = NSString(string: "~/.whisperkey/models").expandingTildeInPath
            do {
                try FileManager.default.createDirectory(atPath: defaultModelsPath, withIntermediateDirectories: true, attributes: nil)
                DebugLogger.log("Created default models directory at: \(defaultModelsPath)")
                modelsPath = defaultModelsPath
            } catch {
                DebugLogger.log("Failed to create default models directory: \(error)")
            }
            
            // Still search other paths in case models exist elsewhere
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
        let modelFile = "ggml-\(modelName).bin"
        
        // First check primary models path if set
        if let modelsPath = modelsPath {
            let fullPath = (modelsPath as NSString).appendingPathComponent(modelFile)
            if FileManager.default.fileExists(atPath: fullPath) {
                DebugLogger.log("WhisperService: Found model at primary path: \(fullPath)")
                return fullPath
            }
        }
        
        // Then check all search paths to find models in alternate locations
        for path in modelsSearchPaths {
            let expandedPath = NSString(string: path).expandingTildeInPath
            let fullPath = (expandedPath as NSString).appendingPathComponent(modelFile)
            if FileManager.default.fileExists(atPath: fullPath) {
                DebugLogger.log("WhisperService: Found model at alternate path: \(fullPath)")
                return fullPath
            }
        }
        
        DebugLogger.log("WhisperService: Model \(modelName) not found in any location")
        return nil
    }
    
    // Call this after model downloads to ensure paths are up to date
    func refreshModelsPath() {
        DebugLogger.log("WhisperService: Refreshing models path")
        
        let previousPath = modelsPath
        
        // First check if our current modelsPath exists and has models
        if let currentPath = modelsPath {
            if FileManager.default.fileExists(atPath: currentPath) {
                DebugLogger.log("WhisperService: Current models path still valid: \(currentPath)")
                // Don't send update if nothing changed
                return
            }
        }
        
        // Re-check all paths
        modelsPath = nil
        
        // Create default directory if needed
        let defaultModelsPath = NSString(string: "~/.whisperkey/models").expandingTildeInPath
        do {
            try FileManager.default.createDirectory(atPath: defaultModelsPath, withIntermediateDirectories: true, attributes: nil)
            modelsPath = defaultModelsPath
            DebugLogger.log("WhisperService: Set models path to default: \(defaultModelsPath)")
        } catch {
            DebugLogger.log("WhisperService: Failed to create default models directory: \(error)")
        }
        
        // Check other paths
        for path in modelsSearchPaths {
            let expandedPath = NSString(string: path).expandingTildeInPath
            if FileManager.default.fileExists(atPath: expandedPath) {
                modelsPath = expandedPath
                DebugLogger.log("WhisperService: Found models at: \(expandedPath)")
                break
            }
        }
        
        // Only send update if path actually changed
        if previousPath != modelsPath {
            objectWillChange.send()
        }
    }
    
    // Setup assistant removed - whisper-cli is now bundled with the app
    
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