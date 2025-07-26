//
//  DictationService.swift
//  WhisperKey
//
//  Purpose: Handles audio recording and transcription
//  
//  Created by Author on 2025-07-01.
//

import AVFoundation
import Cocoa
import SwiftUI

@MainActor
class DictationService: NSObject, ObservableObject {
    static let shared = DictationService()
    @Published var isRecording = false
    @Published var hasAccessibilityPermission = false
    @Published var hasMicrophonePermission = false
    @Published var transcriptionStatus = ""
    
    private let debugLogPath = "/tmp/whisperkey_debug.log"
    
    func debugLog(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logMessage = "[\(timestamp)] \(message)\n"
        
        if let data = logMessage.data(using: .utf8),
           let fileHandle = FileHandle(forWritingAtPath: debugLogPath) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
            fileHandle.closeFile()
        } else {
            // Create file if it doesn't exist
            try? logMessage.write(toFile: debugLogPath, atomically: true, encoding: .utf8)
        }
    }
    
    private let textInsertion = TextInsertionService()
    private let transcriber = WhisperCppTranscriber()
    private var audioEngine: AVAudioEngine?
    private var audioFile: AVAudioFile?
    private var audioFileURL: URL?
    private var audioConverter: AVAudioConverter?
    
    // Audio settings
    private let sampleRate: Double = 16000 // 16kHz for Whisper
    private var silenceThreshold: Float {
        Float(UserDefaults.standard.double(forKey: "silenceThreshold") != 0 ? 
              UserDefaults.standard.double(forKey: "silenceThreshold") : 0.015)
    }
    private var silenceDuration: TimeInterval {
        let stored = UserDefaults.standard.double(forKey: "silenceDuration")
        return stored != 0 ? stored : 2.5
    }
    private var maxRecordingDuration: TimeInterval {
        let stored = UserDefaults.standard.double(forKey: "maxRecordingDuration") 
        return stored != 0 ? stored : 60.0
    }
    private let minimumRecordingDuration: TimeInterval = 1.0  // Record at least 1 second
    private var lastSoundTime: Date = Date()
    private var recordingStartTime: Date = Date()
    
    private override init() {
        super.init()
        
        // Create debug log file
        let debugPath = "/tmp/whisperkey_debug.log"
        if !FileManager.default.fileExists(atPath: debugPath) {
            FileManager.default.createFile(atPath: debugPath, contents: nil, attributes: nil)
        }
        
        // Write debug info to file
        let debugInfo = "=== WhisperKey Started at \(Date()) ===\n"
        if let fileHandle = FileHandle(forWritingAtPath: debugPath) {
            fileHandle.seekToEndOfFile()
            if let data = debugInfo.data(using: .utf8) {
                fileHandle.write(data)
            }
            fileHandle.closeFile()
        }
        
        checkPermissions()
        setupAudioEngine()
        setupAudioNotifications()
        
        // Initialize model selection
        if UserDefaults.standard.string(forKey: "whisperModel") == nil {
            UserDefaults.standard.set("base.en", forKey: "whisperModel")
        }
        
        // Check permissions periodically
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkAccessibilityPermission()
            }
        }
    }
    
    func checkPermissions() {
        // Check accessibility
        checkAccessibilityPermission()
        
        // Check microphone
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            hasMicrophonePermission = true
            NSLog("=== WHISPERKEY: Microphone permission authorized ===")
        case .notDetermined:
            NSLog("=== WHISPERKEY: Microphone permission not determined, requesting... ===")
            AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.hasMicrophonePermission = granted
                    NSLog("=== WHISPERKEY: Microphone permission granted: %@", granted ? "YES" : "NO")
                }
            }
        case .denied:
            hasMicrophonePermission = false
            NSLog("=== WHISPERKEY: Microphone permission denied ===")
        case .restricted:
            hasMicrophonePermission = false
            NSLog("=== WHISPERKEY: Microphone permission restricted ===")
        @unknown default:
            hasMicrophonePermission = false
            NSLog("=== WHISPERKEY: Microphone permission unknown status ===")
        }
    }
    
    func checkAccessibilityPermission() {
        hasAccessibilityPermission = AXIsProcessTrusted()
    }
    
    func requestAccessibilityPermission() {
        // First check if we already have permission
        if AXIsProcessTrusted() {
            hasAccessibilityPermission = true
            debugLog("Accessibility permission already granted")
            return
        }
        
        debugLog("Requesting accessibility permission...")
        
        // This will show the system dialog the first time only
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(options)
        
        hasAccessibilityPermission = trusted
        
        if trusted {
            debugLog("Accessibility permission granted immediately")
        } else {
            debugLog("Accessibility permission not granted - user needs to manually enable in System Settings")
        }
    }
    
    private func showPermissionGuide() {
        WindowManager.shared.showPermissionGuide()
    }
    
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
    }
    
    func startRecording() {
        DebugLogger.log("=== WHISPERKEY: startRecording() called ===")
        NSLog("=== WHISPERKEY: startRecording() called ===")
        debugLog("startRecording() called")
        
        // Check if whisper.cpp is available
        guard WhisperService.shared.isAvailable else {
            DebugLogger.log("=== WHISPERKEY: Whisper.cpp not available ===")
            transcriptionStatus = "⚠️ Whisper.cpp not found - please reinstall WhisperKey"
            return
        }
        
        guard hasAccessibilityPermission else {
            DebugLogger.log("=== WHISPERKEY: No accessibility permission ===")
            NSLog("=== WHISPERKEY: No accessibility permission ===")
            debugLog("No accessibility permission")
            showPermissionGuide()
            return
        }
        
        debugLog("Accessibility permission OK")
        
        guard hasMicrophonePermission else {
            DebugLogger.log("=== WHISPERKEY: No microphone permission ===")
            NSLog("=== WHISPERKEY: No microphone permission ===")
            debugLog("No microphone permission")
            showPermissionGuide()
            return
        }
        
        debugLog("Microphone permission OK")
        
        // Check for secure field
        if TextInsertionService.isInSecureField() {
            // Check which app has secure input
            if let appName = TextInsertionService.getSecureInputApp() {
                debugLog("Secure input detected in: \(appName)")
                
                // For Terminal, just log a warning but continue
                if appName == "Terminal" || appName == "iTerm2" {
                    transcriptionStatus = "⚠️ Terminal detected - transcription may not work"
                    debugLog("Terminal app detected - continuing anyway")
                    // Don't return, continue with recording
                } else {
                    transcriptionStatus = "⚠️ \(appName) has secure input enabled"
                    Task { @MainActor in
                        ErrorHandler.shared.handle(.secureFieldDetected)
                    }
                    return
                }
            } else {
                transcriptionStatus = "⚠️ Cannot dictate into secure fields"
                Task { @MainActor in
                    ErrorHandler.shared.handle(.secureFieldDetected)
                }
                return
            }
        }
        
        // Check memory pressure
        if !MemoryMonitor.shared.checkBeforeRecording() {
            transcriptionStatus = "⚠️ Low memory - close some apps"
            return
        }
        
        DebugLogger.log("=== WHISPERKEY: All checks passed, starting audio recording ===")
        NSLog("=== WHISPERKEY: All checks passed, starting audio recording ===")
        debugLog("All checks passed, starting audio recording")
        
        // Play start sound BEFORE recording begins
        if UserDefaults.standard.bool(forKey: "playFeedbackSounds") {
            playSound(named: "Tink")
            // Small delay to let the sound finish playing
            Thread.sleep(forTimeInterval: 0.2)
        }
        
        do {
            try startAudioRecording()
            isRecording = true
            let modelName = UserDefaults.standard.string(forKey: "whisperModel") ?? "base.en"
            let modelDisplay = modelName.replacingOccurrences(of: ".en", with: "").capitalized
            transcriptionStatus = "🔴 Recording... (\(modelDisplay) model)"
            DebugLogger.log("=== WHISPERKEY: Recording started successfully ===")
            NSLog("=== WHISPERKEY: Recording started successfully ===")
            debugLog("Recording started successfully")
            
            // Show visual feedback
            Task { @MainActor in
                RecordingIndicatorManager.shared.showRecordingIndicator()
            }
            
            // Notify preferences window for test indicator
            NotificationCenter.default.post(
                name: NSNotification.Name("RecordingStateChanged"),
                object: nil,
                userInfo: ["isRecording": true]
            )
        } catch {
            DebugLogger.log("=== WHISPERKEY: Failed to start recording: \(error) ===")
            NSLog("=== WHISPERKEY: Failed to start recording: %@", error.localizedDescription)
            debugLog("Failed to start recording: \(error)")
            transcriptionStatus = "❌ Recording failed: \(error.localizedDescription)"
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        DebugLogger.log("DictationService: Stopping recording...")
        debugLog("stopRecording() called")
        isRecording = false
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        
        // Hide visual feedback
        Task { @MainActor in
            RecordingIndicatorManager.shared.hideRecordingIndicator()
        }
        
        // Notify preferences window for test indicator
        NotificationCenter.default.post(
            name: NSNotification.Name("RecordingStateChanged"),
            object: nil,
            userInfo: ["isRecording": false]
        )
        
        // Play stop sound if enabled
        if UserDefaults.standard.bool(forKey: "playFeedbackSounds") {
            playSound(named: "Pop")
        }
        
        // Close the audio file to ensure all data is written
        audioFile = nil
        
        // Show more detailed processing status
        let modelName = UserDefaults.standard.string(forKey: "whisperModel") ?? "base.en"
        transcriptionStatus = "⏳ Processing with \(modelName.replacingOccurrences(of: ".en", with: "").capitalized) model..."
        
        // Process the audio file
        if let fileURL = audioFileURL {
            DebugLogger.log("DictationService: Processing audio file at: \(fileURL.path)")
            debugLog("Processing audio file at: \(fileURL.path)")
            DebugLogger.log("DictationService: File exists after closing: \(FileManager.default.fileExists(atPath: fileURL.path))")
            
            // Log current whisper and model paths
            debugLog("Current whisper path: \(WhisperService.shared.whisperPath ?? "nil")")
            debugLog("Current model: \(UserDefaults.standard.string(forKey: "whisperModel") ?? "base.en")")
            
            // Check file size
            if let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
               let fileSize = attributes[.size] as? Int64 {
                DebugLogger.log("DictationService: Audio file size: \(fileSize) bytes")
                debugLog("Audio file size: \(fileSize) bytes")
                
                // Read first few bytes to verify it's a valid WAV file
                if let data = try? Data(contentsOf: fileURL, options: .mappedIfSafe) {
                    let header = data.prefix(4).map { String(format: "%c", $0) }.joined()
                    DebugLogger.log("DictationService: File header: '\(header)' (should be 'RIFF' for WAV)")
                    debugLog("File header: '\(header)'")
                }
            } else {
                DebugLogger.log("DictationService: ERROR - Could not get file attributes!")
                debugLog("ERROR - Could not get file attributes!")
            }
            processAudioFile(at: fileURL)
        } else {
            DebugLogger.log("DictationService: No audio file to process!")
            transcriptionStatus = "❌ No audio recorded"
        }
    }
    
    private func startAudioRecording() throws {
        // Create temp file for audio
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "whisperkey_\(Date().timeIntervalSince1970).wav"
        audioFileURL = tempDir.appendingPathComponent(fileName)
        
        DebugLogger.log("DictationService: Temp directory: \(tempDir.path)")
        DebugLogger.log("DictationService: Will create audio file: \(fileName)")
        
        guard let audioEngine = audioEngine,
              let fileURL = audioFileURL else {
            throw NSError(domain: "WhisperKey", code: 1, userInfo: [NSLocalizedDescriptionKey: "Audio engine not initialized"])
        }
        
        // Check if we have microphone access
        let micStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        DebugLogger.log("DictationService: Microphone authorization status: \(micStatus.rawValue)")
        
        // Get input node and its native format
        let inputNode = audioEngine.inputNode
        
        // Check if input is available
        guard inputNode.numberOfInputs > 0 else {
            DebugLogger.log("DictationService: ERROR - No audio inputs available!")
            throw NSError(domain: "WhisperKey", code: 3, userInfo: [NSLocalizedDescriptionKey: "No audio input available"])
        }
        
        let inputFormat = inputNode.inputFormat(forBus: 0)
        
        DebugLogger.log("DictationService: Input hardware format: \(inputFormat)")
        DebugLogger.log("DictationService: Sample rate: \(inputFormat.sampleRate), channels: \(inputFormat.channelCount)")
        DebugLogger.log("DictationService: Number of inputs: \(inputNode.numberOfInputs)")
        
        // Create recording format explicitly
        guard let recordingFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: inputFormat.sampleRate,
            channels: inputFormat.channelCount,
            interleaved: false
        ) else {
            throw NSError(domain: "WhisperKey", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create recording format"])
        }
        
        // Create audio file with explicit settings
        audioFile = try AVAudioFile(forWriting: fileURL, settings: recordingFormat.settings)
        
        DebugLogger.log("DictationService: Created audio file at: \(fileURL.path)")
        DebugLogger.log("DictationService: File exists: \(FileManager.default.fileExists(atPath: fileURL.path))")
        
        // Track samples recorded
        var samplesRecorded = 0
        
        // Install tap on input with native format
        var tapCount = 0
        DebugLogger.log("=== WHISPERKEY: Installing audio tap ===")
        NSLog("=== WHISPERKEY: Installing audio tap with format: %@", recordingFormat.description)
        
        // Try using nil format to let AVAudioEngine use the native format
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: nil) { [weak self] buffer, _ in
            guard let self = self, let audioFile = self.audioFile else { 
                DebugLogger.log("=== WHISPERKEY: Tap called but self or audioFile is nil ===")
                return 
            }
            
            // Debug: Log first few taps
            tapCount += 1
            if tapCount <= 3 {
                DebugLogger.log("=== WHISPERKEY: Tap #\(tapCount) - Buffer format: \(buffer.format), frameLength: \(buffer.frameLength) ===")
                self.debugLog("Audio tap #\(tapCount) - frameLength: \(buffer.frameLength)")
            }
            
            // Write to file
            do {
                try audioFile.write(from: buffer)
                samplesRecorded += Int(buffer.frameLength)
                
                
                if tapCount % 50 == 0 {
                    DebugLogger.log("DictationService: Recorded \(samplesRecorded) samples (\(Double(samplesRecorded) / recordingFormat.sampleRate) seconds)")
                }
            } catch {
                DebugLogger.log("DictationService: Error writing audio: \(error)")
            }
            
            // Check for silence
            let level = self.getAudioLevel(from: buffer)
            
            // Update recording indicator with audio level
            if tapCount % 5 == 0 { // Update every 5th buffer to avoid too frequent updates
                Task { @MainActor in
                    RecordingIndicatorManager.shared.updateAudioLevel(level)
                }
            }
            
            // Handle silence detection and duration checks on main actor for thread safety
            Task { @MainActor in
                if level > self.silenceThreshold {
                    self.lastSoundTime = Date()
                    if tapCount <= 10 || tapCount % 10 == 0 {
                        DebugLogger.log("DictationService: Sound detected, level: \(level)")
                    }
                } else if Date().timeIntervalSince(self.lastSoundTime) > self.silenceDuration && tapCount > 50 {
                    // Auto-stop after silence (wait for more taps to ensure we have some audio)
                    DebugLogger.log("DictationService: Silence detected for \(self.silenceDuration) seconds, stopping... (samples recorded: \(samplesRecorded))")
                    self.stopRecording()
                }
                
                // Check for maximum recording duration
                let recordingDuration = Date().timeIntervalSince(self.recordingStartTime)
                if recordingDuration > self.maxRecordingDuration {
                    DebugLogger.log("DictationService: Maximum recording duration reached (\(Int(self.maxRecordingDuration)) seconds), stopping...")
                    self.transcriptionStatus = "⏱️ Recording stopped (\(Int(self.maxRecordingDuration))s limit)"
                    self.stopRecording()
                }
            }
        }
        
        // Start engine
        NSLog("=== WHISPERKEY: Starting audio engine ===")
        try audioEngine.start()
        NSLog("=== WHISPERKEY: Audio engine started successfully ===")
        
        // Initialize timestamps to prevent immediate stop
        self.lastSoundTime = Date()
        self.recordingStartTime = Date()
        
        DebugLogger.log("DictationService: Audio engine started, recording... (speak now!)")
        NSLog("=== WHISPERKEY: Audio engine started, recording... (speak now!) ===")
    }
    
    private func getAudioLevel(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData else { return 0 }
        
        let channelDataValue = channelData.pointee
        let channelDataArray = Array(UnsafeBufferPointer(start: channelDataValue, count: Int(buffer.frameLength)))
        
        let rms = sqrt(channelDataArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        return rms
    }
    
    private func processAudioFile(at url: URL) {
        DebugLogger.log("DictationService: Processing audio file...")
        debugLog("Processing audio file at: \(url.path)")
        
        // Check file size
        if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
           let fileSize = attributes[.size] as? Int64 {
            DebugLogger.log("DictationService: Audio file size: \(fileSize) bytes")
            debugLog("Audio file size: \(fileSize) bytes")
        }
        
        // Convert to 16kHz WAV for Whisper if needed
        Task {
            do {
                // Process entire file at once
                let convertedURL = try await convertAudioToWhisperFormat(url: url)
                DebugLogger.log("DictationService: Starting whisper transcription...")
                let transcribedText = try await self.transcriber.transcribe(audioFileURL: convertedURL)
                
                DispatchQueue.main.async { [weak self] in
                    self?.transcriptionStatus = "✅ Ready to dictate"
                    
                    if transcribedText.isEmpty {
                        DebugLogger.log("DictationService: No speech detected")
                        self?.debugLog("No speech detected in audio")
                        self?.transcriptionStatus = "🔇 No speech detected - try again"
                    } else {
                        DebugLogger.log("DictationService: Final transcription: \(transcribedText)")
                        self?.debugLog("Transcription result: \"\(transcribedText)\"")
                        
                        // Insert at cursor - try normal insertion first
                        Task {
                            // Save to clipboard if user prefers
                            if UserDefaults.standard.bool(forKey: "alwaysSaveToClipboard") {
                                TextInsertionService.saveToClipboard(transcribedText)
                                self?.debugLog("Text saved to clipboard as backup")
                            }
                            
                            do {
                                self?.debugLog("Attempting to insert text at cursor...")
                                
                                // Try to insert at cursor position
                                guard let insertionResult = try await self?.textInsertion.insertText(transcribedText) else {
                                    DebugLogger.log("DictationService: Self was nil, cannot insert text")
                                    return
                                }
                                
                                // Check insertion result
                                if insertionResult == .insertedAtCursor {
                                    // Successfully inserted at cursor (either AX or keyboard simulation in text field)
                                    let wordCount = transcribedText.split(separator: " ").count
                                    self?.transcriptionStatus = "✅ Inserted \(wordCount) word\(wordCount == 1 ? "" : "s")"
                                    DebugLogger.log("DictationService: Text inserted at cursor successfully")
                                    self?.debugLog("Text inserted at cursor!")
                                    
                                    // Play success sound
                                    if UserDefaults.standard.bool(forKey: "playFeedbackSounds") {
                                        self?.playSound(named: "Glass")
                                    }
                                } else if insertionResult == .keyboardSimulated {
                                    // No focused element found - not in a text field
                                    if !UserDefaults.standard.bool(forKey: "alwaysSaveToClipboard") {
                                        TextInsertionService.saveToClipboard(transcribedText)
                                        self?.debugLog("Text saved to clipboard (not in text field)")
                                    }
                                    
                                    let wordCount = transcribedText.split(separator: " ").count
                                    self?.transcriptionStatus = "📋 Saved to clipboard (\(wordCount) word\(wordCount == 1 ? "" : "s")) - press ⌘V to paste"
                                    DebugLogger.log("DictationService: No text field detected, clipboard backup used")
                                    
                                    // Show visual notification when not in text field
                                    Task { @MainActor in
                                        ClipboardNotificationManager.shared.showClipboardNotification(wordCount: wordCount)
                                    }
                                    
                                    // Play clipboard sound only if we actually saved to clipboard (not when user has "always save" on)
                                    if UserDefaults.standard.bool(forKey: "playFeedbackSounds") && 
                                       !UserDefaults.standard.bool(forKey: "alwaysSaveToClipboard") {
                                        self?.playSound(named: "Pop")
                                    }
                                }
                                
                                // Clear status after delay
                                Task {
                                    try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                                    await MainActor.run {
                                        if self?.transcriptionStatus.starts(with: "✅") == true || self?.transcriptionStatus.starts(with: "📋") == true {
                                            self?.transcriptionStatus = "Ready"
                                        }
                                    }
                                }
                            } catch let error as TextInsertionService.InsertionError {
                                // Always save to clipboard on error
                                if !UserDefaults.standard.bool(forKey: "alwaysSaveToClipboard") {
                                    TextInsertionService.saveToClipboard(transcribedText)
                                    self?.debugLog("Text saved to clipboard due to error")
                                }
                                
                                // Handle specific insertion errors
                                let wordCount = transcribedText.split(separator: " ").count
                                
                                switch error {
                                case .secureField:
                                    self?.transcriptionStatus = "🔒 Cannot insert into password field - saved to clipboard"
                                    ErrorHandler.shared.handle(.secureFieldDetected)
                                case .readOnlyField:
                                    self?.transcriptionStatus = "📝 Cannot insert into read-only field - saved to clipboard"
                                    ErrorHandler.shared.handle(.readOnlyField)
                                case .disabledField:
                                    self?.transcriptionStatus = "🚫 Cannot insert into disabled field - saved to clipboard"
                                    ErrorHandler.shared.handle(.disabledField)
                                case .noFocusedElement, .insertionFailed, .savedToClipboard:
                                    self?.transcriptionStatus = "📋 Saved to clipboard (\(wordCount) word\(wordCount == 1 ? "" : "s")) - press ⌘V to paste"
                                    DebugLogger.log("DictationService: Using clipboard fallback")
                                }
                                
                                // Show visual notification for clipboard saves
                                switch error {
                                case .noFocusedElement, .insertionFailed, .savedToClipboard:
                                    Task { @MainActor in
                                        ClipboardNotificationManager.shared.showClipboardNotification(wordCount: wordCount)
                                    }
                                default:
                                    break
                                }
                                
                                // Play sound for clipboard fallback only on actual errors (not intentional saves)
                                if UserDefaults.standard.bool(forKey: "playFeedbackSounds") && 
                                   !UserDefaults.standard.bool(forKey: "alwaysSaveToClipboard") {
                                    self?.playSound(named: "Pop")
                                }
                                
                                self?.debugLog("Using clipboard due to: \(error)")
                            } catch {
                                // Always save to clipboard on generic error
                                if !UserDefaults.standard.bool(forKey: "alwaysSaveToClipboard") {
                                    TextInsertionService.saveToClipboard(transcribedText)
                                }
                                
                                // Generic error
                                let wordCount = transcribedText.split(separator: " ").count
                                self?.transcriptionStatus = "📋 Saved to clipboard (\(wordCount) word\(wordCount == 1 ? "" : "s")) - press ⌘V to paste"
                                DebugLogger.log("DictationService: Failed to insert text: \(error)")
                                
                                // Show visual notification
                                Task { @MainActor in
                                    ClipboardNotificationManager.shared.showClipboardNotification(wordCount: wordCount)
                                }
                                
                                // Play sound for clipboard fallback only on actual errors (not intentional saves)
                                if UserDefaults.standard.bool(forKey: "playFeedbackSounds") && 
                                   !UserDefaults.standard.bool(forKey: "alwaysSaveToClipboard") {
                                    self?.playSound(named: "Pop")
                                }
                            }
                        }
                    }
                }
                    
                // Clean up audio files
                self.cleanupTempFiles(primaryFile: url, convertedFile: convertedURL != url ? convertedURL : nil)
            } catch {
                DebugLogger.log("DictationService: Error processing audio: \(error)")
                self.debugLog("Error processing audio: \(error)")
                self.transcriptionStatus = "❌ Processing failed - please try again"
                
                // Show detailed error to user
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "Processing Failed"
                    alert.informativeText = "WhisperKey encountered an error:\n\n\(error.localizedDescription)\n\nPlease check:\n• Whisper.cpp is properly installed\n• Selected model is downloaded\n• You have enough disk space"
                    alert.alertStyle = .warning
                    
                    // Add debug info button
                    alert.addButton(withTitle: "OK")
                    alert.addButton(withTitle: "Show Debug Log")
                    
                    let response = alert.runModal()
                    if response == .alertSecondButtonReturn {
                        // Show debug log
                        if let logData = try? String(contentsOfFile: "/tmp/whisperkey_debug.log", encoding: .utf8) {
                            let logAlert = NSAlert()
                            logAlert.messageText = "Debug Log"
                            logAlert.informativeText = String(logData.suffix(2000)) // Last 2000 chars
                            logAlert.alertStyle = .informational
                            logAlert.runModal()
                        }
                    }
                }
            }
        }
    }
    
    private func convertAudioToWhisperFormat(url: URL) async throws -> URL {
        // Whisper.cpp can handle resampling internally, so we'll use the original file
        DebugLogger.log("DictationService: Using original audio file at \(url.path)")
        
        // Verify the file has content
        if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
           let fileSize = attributes[.size] as? Int64 {
            DebugLogger.log("DictationService: Audio file size for transcription: \(fileSize) bytes")
            
            if fileSize < 1000 {
                DebugLogger.log("DictationService: Warning - Audio file seems too small")
            }
        }
        
        return url
    }
    
    func updateModel() {
        // Model will be read from UserDefaults by transcriber
        let modelName = UserDefaults.standard.string(forKey: "whisperModel") ?? "base.en"
        DebugLogger.log("DictationService: Updated to model: \(modelName)")
    }
    
    // MARK: - Cleanup
    
    private func cleanupTempFiles(primaryFile: URL?, convertedFile: URL?) {
        // Clean up primary file
        if let primaryFile = primaryFile {
            do {
                try FileManager.default.removeItem(at: primaryFile)
                DebugLogger.log("DictationService: Cleaned up primary audio file")
            } catch {
                DebugLogger.log("DictationService: Failed to clean up primary file: \(error)")
            }
        }
        
        // Clean up converted file if different
        if let convertedFile = convertedFile {
            do {
                try FileManager.default.removeItem(at: convertedFile)
                DebugLogger.log("DictationService: Cleaned up converted audio file")
            } catch {
                DebugLogger.log("DictationService: Failed to clean up converted file: \(error)")
            }
        }
        
        // Clear stored reference
        audioFileURL = nil
    }
    
    /// Clean up all WhisperKey temp files (called on app termination)
    static func cleanupAllTempFiles() {
        let tempDir = FileManager.default.temporaryDirectory
        do {
            let files = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
            let whisperKeyFiles = files.filter { $0.lastPathComponent.hasPrefix("whisperkey_") }
            
            for file in whisperKeyFiles {
                try? FileManager.default.removeItem(at: file)
            }
            
            if !whisperKeyFiles.isEmpty {
                DebugLogger.log("DictationService: Cleaned up \(whisperKeyFiles.count) temp files on termination")
            }
        } catch {
            DebugLogger.log("DictationService: Failed to enumerate temp files: \(error)")
        }
    }
    
    deinit {
        // Clean up any remaining temp file
        if let fileURL = audioFileURL {
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        // Remove audio notifications
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Audio Notifications
extension DictationService {
    private func setupAudioNotifications() {
        // Monitor for audio device changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioDeviceChange),
            name: .AVAudioEngineConfigurationChange,
            object: audioEngine
        )
        
        // Note: AVAudioSession is iOS-only, on macOS we rely on AVAudioEngine notifications
    }
    
    @objc private func handleAudioDeviceChange(_ notification: Notification) {
        DebugLogger.log("DictationService: Audio device configuration changed")
        
        if isRecording {
            // Stop recording gracefully
            DebugLogger.log("DictationService: Stopping recording due to audio device change")
            transcriptionStatus = "⚠️ Audio device changed - recording stopped"
            stopRecording()
            
            // Notify user
            Task { @MainActor in
                ErrorHandler.shared.handle(.audioEngineFailure("Audio device changed during recording"))
            }
        }
        
        // Recreate audio engine with new configuration
        setupAudioEngine()
    }
    
    // MARK: - Audio Feedback
    
    private func playSound(named soundName: String) {
        // Use actual system sounds for better feedback
        var actualSoundName: String
        
        switch soundName {
        case "Tink":
            // Start recording sound
            actualSoundName = "Tink"
            debugLog("Playing start recording sound: \(actualSoundName)")
        case "Pop":
            // Stop recording or clipboard sound
            actualSoundName = "Pop"
            debugLog("Playing stop/clipboard sound: \(actualSoundName)")
        case "Glass":
            // Success sound
            actualSoundName = "Glass"
            debugLog("Playing success sound: \(actualSoundName)")
        default:
            // Fallback
            actualSoundName = soundName
            debugLog("Playing sound: \(actualSoundName)")
        }
        
        // Try to play the actual system sound
        if let sound = NSSound(named: NSSound.Name(actualSoundName)) {
            sound.play()
        } else {
            // Fallback to beep if sound not found
            NSSound.beep()
            debugLog("Sound '\(actualSoundName)' not found, using beep")
        }
    }
}