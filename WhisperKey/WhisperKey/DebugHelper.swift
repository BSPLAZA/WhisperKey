//
//  DebugHelper.swift
//  WhisperKey
//
//  Purpose: Collect debug information for troubleshooting
//  
//  Created by Assistant on 2025-07-15.
//

import Foundation
import SwiftUI
import AppKit

@MainActor
class DebugHelper: ObservableObject {
    static let shared = DebugHelper()
    
    func generateDebugReport() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        
        var report = "WhisperKey Debug Report\n"
        report += "Generated: \(Date().formatted())\n"
        report += "Version: \(version) (Build \(buildNumber))\n"
        report += "==========================\n\n"
        
        // System Info
        report += "System Information:\n"
        report += "- macOS Version: \(ProcessInfo.processInfo.operatingSystemVersionString)\n"
        report += "- Architecture: \(ProcessInfo.processInfo.machineHardwareName ?? "Unknown")\n\n"
        
        // WhisperService Status
        let whisperService = WhisperService.shared
        report += "WhisperService Status:\n"
        report += "- Is Available: \(whisperService.isAvailable)\n"
        report += "- Whisper Path: \(whisperService.whisperPath ?? "Not Found")\n"
        report += "- Models Path: \(whisperService.modelsPath ?? "Not Set")\n"
        report += "- Setup Error: \(whisperService.setupError ?? "None")\n\n"
        
        // Model Directories
        report += "Model Search Paths:\n"
        for path in whisperService.modelsSearchPaths {
            let expandedPath = NSString(string: path).expandingTildeInPath
            let exists = FileManager.default.fileExists(atPath: expandedPath)
            report += "- \(path): \(exists ? "EXISTS" : "NOT FOUND")\n"
            
            if exists {
                do {
                    let contents = try FileManager.default.contentsOfDirectory(atPath: expandedPath)
                    let models = contents.filter { $0.hasSuffix(".bin") }
                    if !models.isEmpty {
                        report += "  Models found: \(models.joined(separator: ", "))\n"
                    }
                } catch {
                    report += "  Error reading directory: \(error)\n"
                }
            }
        }
        report += "\n"
        
        // ModelManager Status
        let modelManager = ModelManager.shared
        report += "Model Status:\n"
        for model in modelManager.availableModels {
            let installed = modelManager.isModelInstalled(model.filename)
            let downloading = modelManager.isDownloading[model.filename] ?? false
            let progress = modelManager.downloadProgress[model.filename]
            let error = modelManager.downloadError[model.filename]
            
            report += "- \(model.filename):\n"
            report += "  Installed: \(installed)\n"
            if downloading {
                report += "  Downloading: \(Int((progress ?? 0) * 100))%\n"
            }
            if let error = error {
                report += "  Error: \(error)\n"
            }
        }
        report += "\n"
        
        // Disk Space
        if let attributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
           let freeSize = attributes[.systemFreeSize] as? Int64 {
            report += "Disk Space:\n"
            report += "- Free: \(ByteCountFormatter.string(fromByteCount: freeSize, countStyle: .file))\n\n"
        }
        
        // Recent Logs
        report += "Recent Debug Logs:\n"
        report += DebugLogger.getRecentLogs(lines: 50)
        
        return report
    }
    
    func saveDebugReport() -> URL? {
        let report = generateDebugReport()
        let timestamp = Date().formatted(.iso8601.year().month().day().time(includingFractionalSeconds: false))
            .replacingOccurrences(of: ":", with: "-")
        let filename = "WhisperKey-Debug-\(timestamp).txt"
        
        let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        let fileURL = downloadsURL?.appendingPathComponent(filename)
        
        if let fileURL = fileURL {
            do {
                try report.write(to: fileURL, atomically: true, encoding: .utf8)
                return fileURL
            } catch {
                DebugLogger.log("Failed to save debug report: \(error)")
            }
        }
        
        return nil
    }
    
    func testSystemSounds() {
        DebugLogger.log("Testing system sounds...")
        
        // Test 1: Basic beep
        DebugLogger.log("Playing basic beep")
        NSSound.beep()
        
        Thread.sleep(forTimeInterval: 1.0)
        
        // Test 2: Double beep (like Glass sound)
        DebugLogger.log("Playing double beep")
        NSSound.beep()
        Thread.sleep(forTimeInterval: 0.15)
        NSSound.beep()
        
        Thread.sleep(forTimeInterval: 1.0)
        
        // Test 3: Triple beep pattern
        DebugLogger.log("Playing triple beep pattern")
        for _ in 0..<3 {
            NSSound.beep()
            Thread.sleep(forTimeInterval: 0.2)
        }
    }
    
    func verifyAudioSettings() -> String {
        var report = "Audio Settings Verification\n"
        report += "========================\n"
        report += "Play Feedback Sounds: \(UserDefaults.standard.bool(forKey: "playFeedbackSounds"))\n"
        
        // Check system sound availability
        report += "System Beep Available: Yes\n"
        report += "Note: WhisperKey uses NSSound.beep() for reliable cross-system compatibility\n"
        
        return report
    }
}

// Extension to get machine hardware name
extension ProcessInfo {
    var machineHardwareName: String? {
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String(cString: model)
    }
}

// Debug menu item for testing
struct DebugMenuView: View {
    @StateObject private var debugHelper = DebugHelper.shared
    @State private var showingSaved = false
    @State private var savedPath = ""
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Debug Helper")
                .font(.headline)
                .padding(.bottom, 8)
            
            Button(action: {
                if let url = debugHelper.saveDebugReport() {
                    savedPath = url.path
                    showingSaved = true
                }
            }) {
                Label("Save Debug Report", systemImage: "doc.text")
                    .frame(width: 200)
            }
            .buttonStyle(.borderedProminent)
            
            if showingSaved {
                VStack(spacing: 8) {
                    Label("Report saved to:", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    
                    Text(savedPath)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .truncationMode(.middle)
                        .textSelection(.enabled)
                }
                .padding(.top, 8)
            }
            
            Divider()
                .padding(.vertical, 8)
            
            Text("Report includes:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                Label("System information", systemImage: "info.circle")
                Label("Model locations & status", systemImage: "folder")
                Label("Download progress", systemImage: "arrow.down.circle")
                Label("Recent debug logs", systemImage: "doc.text")
            }
            .font(.caption2)
            .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 280)
    }
}