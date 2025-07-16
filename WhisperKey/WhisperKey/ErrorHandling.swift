//
//  ErrorHandling.swift
//  WhisperKey
//
//  Purpose: Comprehensive error handling and user feedback
//  
//  Created by Assistant on 2025-07-01.
//

import Foundation
import Cocoa
import SwiftUI
import UserNotifications

// MARK: - Error Types

enum WhisperKeyError: LocalizedError {
    // Permission Errors
    case noMicrophonePermission
    case noAccessibilityPermission
    case permissionRevoked(String)
    
    // Audio Errors
    case noMicrophoneAvailable
    case audioEngineFailure(String)
    case recordingFailure(String)
    case audioFormatError(String)
    
    // Transcription Errors
    case modelNotFound(String)
    case modelCorrupted(String)
    case transcriptionTimeout
    case transcriptionFailure(String)
    case whisperBinaryNotFound
    case dependencyMissing(String)
    
    // System Errors
    case diskFull
    case memoryPressure
    case fileSystemError(String)
    
    // Security Errors
    case secureFieldDetected
    case unauthorizedAccess(String)
    
    // User Errors
    case noActiveTextField
    case unsupportedApplication(String)
    case clipboardFailure
    case readOnlyField
    case disabledField
    
    var errorDescription: String? {
        switch self {
        // Permissions
        case .noMicrophonePermission:
            return "WhisperKey needs microphone access to transcribe speech"
        case .noAccessibilityPermission:
            return "WhisperKey needs accessibility permission to insert text"
        case .permissionRevoked(let permission):
            return "\(permission) permission was revoked. Please re-enable in System Settings"
            
        // Audio
        case .noMicrophoneAvailable:
            return "No microphone detected. Please connect a microphone"
        case .audioEngineFailure(let details):
            return "Audio system error: \(details)"
        case .recordingFailure(let reason):
            return "Failed to record audio: \(reason)"
        case .audioFormatError(let format):
            return "Unsupported audio format: \(format)"
            
        // Transcription
        case .modelNotFound(let model):
            return "Model '\(model)' not found. Please download it first"
        case .modelCorrupted(let model):
            return "Model '\(model)' is corrupted. Please re-download"
        case .transcriptionTimeout:
            return "Transcription took too long. Try a shorter recording"
        case .transcriptionFailure(let reason):
            return "Transcription failed: \(reason)"
        case .whisperBinaryNotFound:
            return "Whisper not found. Please reinstall WhisperKey"
        case .dependencyMissing(let message):
            return message
            
        // System
        case .diskFull:
            return "Not enough disk space for audio recording"
        case .memoryPressure:
            return "System memory is low. Please close some apps"
        case .fileSystemError(let error):
            return "File system error: \(error)"
            
        // Security
        case .secureFieldDetected:
            return "Cannot dictate into password fields for security"
        case .unauthorizedAccess(let resource):
            return "Unauthorized access to \(resource)"
            
        // User
        case .noActiveTextField:
            return "Please click in a text field first"
        case .unsupportedApplication(let app):
            return "WhisperKey doesn't work with \(app) yet"
        case .clipboardFailure:
            return "Failed to access clipboard"
        case .readOnlyField:
            return "This field is read-only and cannot be edited"
        case .disabledField:
            return "This field is disabled and cannot be edited"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .noMicrophonePermission, .noAccessibilityPermission:
            return "Open System Settings > Privacy & Security to grant permission"
        case .permissionRevoked:
            return "Open System Settings > Privacy & Security to re-enable"
        case .noMicrophoneAvailable:
            return "Connect a microphone or check System Settings > Sound"
        case .modelNotFound, .modelCorrupted:
            return "Download models from the WhisperKey menu"
        case .diskFull:
            return "Free up disk space and try again"
        case .memoryPressure:
            return "Close unused applications"
        case .secureFieldDetected:
            return "Type your password manually"
        case .noActiveTextField:
            return "Click where you want to insert text"
        case .readOnlyField:
            return "Click in an editable text field"
        case .disabledField:
            return "This field needs to be enabled first"
        default:
            return nil
        }
    }
    
    var isRecoverable: Bool {
        switch self {
        case .secureFieldDetected, .noActiveTextField, .diskFull, .memoryPressure, .readOnlyField, .disabledField:
            return true
        default:
            return false
        }
    }
}

// MARK: - Error Handler

@MainActor
class ErrorHandler: ObservableObject {
    static let shared = ErrorHandler()
    
    @Published var currentError: WhisperKeyError?
    @Published var isShowingError = false
    
    private var errorLog: [(Date, WhisperKeyError)] = []
    
    func handle(_ error: WhisperKeyError) {
        // Log error
        errorLog.append((Date(), error))
        DebugLogger.log("WhisperKey Error: \(error.localizedDescription)")
        
        // Update UI
        currentError = error
        isShowingError = true
        
        // Show appropriate feedback
        switch error {
        case .secureFieldDetected:
            showSecurityWarning()
        case .noMicrophonePermission, .noAccessibilityPermission:
            showPermissionAlert(error)
        case .diskFull, .memoryPressure:
            showSystemAlert(error)
        default:
            showNotification(error)
        }
        
        // Auto-dismiss recoverable errors
        if error.isRecoverable {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.isShowingError = false
            }
        }
    }
    
    private func showSecurityWarning() {
        // Visual + audio warning for security
        NSSound.beep()
        
        let alert = NSAlert()
        alert.messageText = "Security Warning"
        alert.informativeText = "Cannot dictate into password fields"
        alert.alertStyle = .warning
        alert.icon = NSImage(systemSymbolName: "lock.shield", accessibilityDescription: nil)
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func showPermissionAlert(_ error: WhisperKeyError) {
        let alert = NSAlert()
        alert.messageText = "Permission Required"
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            // Open System Settings to the right pane
            if case .noMicrophonePermission = error {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
                    NSWorkspace.shared.open(url)
                }
            } else if case .noAccessibilityPermission = error {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
    }
    
    private func showSystemAlert(_ error: WhisperKeyError) {
        let alert = NSAlert()
        alert.messageText = "System Issue"
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func showNotification(_ error: WhisperKeyError) {
        // Use modern UserNotifications framework
        let content = UNMutableNotificationContent()
        content.title = "WhisperKey"
        content.body = error.localizedDescription
        content.sound = .default
        
        if let suggestion = error.recoverySuggestion {
            content.subtitle = suggestion
        }
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                DebugLogger.log("Failed to show notification: \(error)")
            }
        }
    }
    
    // MARK: - Error Recovery
    
    func attemptRecovery(from error: WhisperKeyError) async -> Bool {
        switch error {
        case .modelNotFound(let model):
            // Attempt to download model
            return await downloadModel(model)
            
        case .diskFull:
            // Clean up temp files
            cleanupTempFiles()
            return Self.checkDiskSpace()
            
        case .audioEngineFailure:
            // Reset audio engine
            return await resetAudioEngine()
            
        default:
            return false
        }
    }
    
    private func downloadModel(_ model: String) async -> Bool {
        // Model download is handled by ModelManager
        ModelManager.shared.downloadModel(model)
        return true
    }
    
    private func cleanupTempFiles() {
        let tempDir = FileManager.default.temporaryDirectory
        do {
            let files = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
            for file in files where file.lastPathComponent.hasPrefix("whisperkey_") {
                try? FileManager.default.removeItem(at: file)
            }
        } catch {
            DebugLogger.log("Failed to cleanup temp files: \(error)")
        }
    }
    
    static func checkDiskSpace(requiredBytes: Int64 = 100_000_000) -> Bool {
        if let attributes = try? FileManager.default.attributesOfFileSystem(forPath: "/"),
           let freeSpace = attributes[.systemFreeSize] as? Int64 {
            return freeSpace > requiredBytes
        }
        return false
    }
    
    private func resetAudioEngine() async -> Bool {
        // Reset audio engine by recreating the DictationService
        DictationService.shared.stopRecording()
        return true
    }
    
    // MARK: - Analytics
    
    func getErrorReport() -> String {
        let report = """
        WhisperKey Error Report
        Generated: \(Date())
        
        Recent Errors:
        \(errorLog.suffix(20).map { "\($0.0): \($0.1)" }.joined(separator: "\n"))
        
        System Info:
        - macOS: \(ProcessInfo.processInfo.operatingSystemVersionString)
        - Memory: \(ProcessInfo.processInfo.physicalMemory / 1_000_000_000)GB
        - WhisperKey: \(Bundle.main.infoDictionary?["CFBundleVersion"] ?? "Unknown")
        """
        
        return report
    }
}

// MARK: - Error UI

struct ErrorBanner: View {
    @ObservedObject var errorHandler = ErrorHandler.shared
    
    var body: some View {
        if errorHandler.isShowingError, let error = errorHandler.currentError {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: iconName(for: error))
                        .foregroundColor(color(for: error))
                    
                    Text(error.localizedDescription)
                        .font(.headline)
                    
                    Spacer()
                    
                    if error.isRecoverable {
                        Button("Retry") {
                            Task {
                                await errorHandler.attemptRecovery(from: error)
                            }
                        }
                    }
                    
                    Button(action: { errorHandler.isShowingError = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .shadow(radius: 4)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
    
    private func iconName(for error: WhisperKeyError) -> String {
        switch error {
        case .secureFieldDetected:
            return "lock.shield"
        case .noMicrophonePermission, .noAccessibilityPermission:
            return "exclamationmark.shield"
        case .diskFull, .memoryPressure:
            return "exclamationmark.triangle"
        default:
            return "exclamationmark.circle"
        }
    }
    
    private func color(for error: WhisperKeyError) -> Color {
        switch error {
        case .secureFieldDetected:
            return .red
        case .noMicrophonePermission, .noAccessibilityPermission:
            return .orange
        default:
            return .yellow
        }
    }
}

// MARK: - Error Monitoring

extension ErrorHandler {
    func startMonitoring() {
        // Monitor system conditions
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            Task { @MainActor in
                self.checkSystemHealth()
            }
        }
    }
    
    private func checkSystemHealth() {
        // Check disk space
        if !Self.checkDiskSpace() {
            handle(.diskFull)
        }
        
        // Check memory pressure
        let memoryPressure = ProcessInfo.processInfo.physicalMemory
        if memoryPressure < 500_000_000 { // Less than 500MB free
            handle(.memoryPressure)
        }
    }
}