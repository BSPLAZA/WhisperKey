//
//  DictationService.swift
//  WhisperKey
//
//  Purpose: Handles audio recording and transcription
//  
//  Created by Orion on 2025-07-01.
//

import AVFoundation
import Cocoa

@MainActor
class DictationService: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var hasAccessibilityPermission = false
    @Published var hasMicrophonePermission = false
    @Published var transcriptionStatus = ""
    
    private let textInsertion = TextInsertionService()
    private let transcriber = WhisperCppTranscriber()
    private var audioEngine: AVAudioEngine?
    private var audioFile: AVAudioFile?
    private var audioFileURL: URL?
    private var audioConverter: AVAudioConverter?
    
    // Audio settings
    private let sampleRate: Double = 16000 // 16kHz for Whisper
    private let silenceThreshold: Float = 0.015  // Increased threshold to prevent premature cutoff
    private let silenceDuration: TimeInterval = 2.5  // Stop after 2.5 seconds of silence
    private let minimumRecordingDuration: TimeInterval = 1.0  // Record at least 1 second
    private var lastSoundTime: Date = Date()
    private var recordingStartTime: Date = Date()
    
    override init() {
        super.init()
        checkPermissions()
        setupAudioEngine()
        
        // Initialize model selection
        if UserDefaults.standard.string(forKey: "whisperModel") == nil {
            UserDefaults.standard.set("small.en", forKey: "whisperModel")
        }
        
        // Check permissions periodically but less frequently
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                let oldValue = self.hasAccessibilityPermission
                self.checkAccessibilityPermission()
                // Only log if status changed
                if oldValue != self.hasAccessibilityPermission {
                    print("DictationService: Accessibility permission changed to: \(self.hasAccessibilityPermission)")
                }
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
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.hasMicrophonePermission = granted
                }
            }
        default:
            hasMicrophonePermission = false
        }
    }
    
    func checkAccessibilityPermission() {
        hasAccessibilityPermission = AXIsProcessTrusted()
    }
    
    func requestAccessibilityPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(options)
        
        if !trusted {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let alert = NSAlert()
                alert.messageText = "Restart Required"
                alert.informativeText = "After granting accessibility permission, please quit and restart WhisperKey for the changes to take effect."
                alert.alertStyle = .informational
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
        }
    }
    
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        // On macOS, audio session configuration is not needed
        print("DictationService: Audio engine created")
    }
    
    func startRecording() {
        print("DictationService: startRecording() called")
        
        guard hasAccessibilityPermission else {
            print("DictationService: No accessibility permission")
            requestAccessibilityPermission()
            return
        }
        
        guard hasMicrophonePermission else {
            print("DictationService: No microphone permission")
            transcriptionStatus = "Microphone permission required"
            return
        }
        
        print("DictationService: Starting audio recording...")
        
        do {
            try startAudioRecording()
            isRecording = true
            transcriptionStatus = "Listening..."
            print("DictationService: Recording started successfully")
        } catch {
            print("DictationService: Failed to start recording: \(error)")
            transcriptionStatus = "Failed to start recording: \(error.localizedDescription)"
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        print("DictationService: Stopping recording...")
        isRecording = false
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        
        
        // Close the audio file to ensure all data is written
        audioFile = nil
        
        transcriptionStatus = "Processing..."
        
        // Process the audio file (for both streaming and non-streaming)
        if let fileURL = audioFileURL {
            print("DictationService: Processing audio file at: \(fileURL.path)")
            processAudioFile(at: fileURL)
        } else {
            print("DictationService: No audio file to process!")
        }
    }
    
    private func startAudioRecording() throws {
        // Create temp file for audio
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "whisperkey_\(Date().timeIntervalSince1970).wav"
        audioFileURL = tempDir.appendingPathComponent(fileName)
        
        guard let audioEngine = audioEngine,
              let fileURL = audioFileURL else {
            throw NSError(domain: "WhisperKey", code: 1, userInfo: [NSLocalizedDescriptionKey: "Audio engine not initialized"])
        }
        
        // Get input node and its native format
        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.inputFormat(forBus: 0)
        
        print("DictationService: Input hardware format: \(inputFormat)")
        
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
        
        print("DictationService: Created audio file at: \(fileURL.path)")
        
        // Track samples recorded
        var samplesRecorded = 0
        
        // Install tap on input with explicit format
        var tapCount = 0
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: recordingFormat) { [weak self] buffer, _ in
            guard let self = self, let audioFile = self.audioFile else { return }
            
            // Debug: Log first few taps
            tapCount += 1
            if tapCount <= 3 {
                print("DictationService: Tap #\(tapCount) - Buffer format: \(buffer.format), frameLength: \(buffer.frameLength)")
            }
            
            // Write to file
            do {
                try audioFile.write(from: buffer)
                samplesRecorded += Int(buffer.frameLength)
                
                
                if tapCount % 50 == 0 {
                    print("DictationService: Recorded \(samplesRecorded) samples (\(Double(samplesRecorded) / recordingFormat.sampleRate) seconds)")
                }
            } catch {
                print("DictationService: Error writing audio: \(error)")
            }
            
            // Check for silence
            let level = self.getAudioLevel(from: buffer)
            if level > self.silenceThreshold {
                self.lastSoundTime = Date()
                if tapCount <= 10 || tapCount % 10 == 0 {
                    print("DictationService: Sound detected, level: \(level)")
                }
            } else if Date().timeIntervalSince(self.lastSoundTime) > self.silenceDuration && tapCount > 50 {
                // Auto-stop after silence (wait for more taps to ensure we have some audio)
                print("DictationService: Silence detected for 2 seconds, stopping... (samples recorded: \(samplesRecorded))")
                DispatchQueue.main.async {
                    self.stopRecording()
                }
            }
        }
        
        // Start engine
        try audioEngine.start()
        
        // Initialize timestamps to prevent immediate stop
        self.lastSoundTime = Date()
        self.recordingStartTime = Date()
        
        print("DictationService: Audio engine started, recording... (speak now!)")
    }
    
    private func getAudioLevel(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData else { return 0 }
        
        let channelDataValue = channelData.pointee
        let channelDataArray = Array(UnsafeBufferPointer(start: channelDataValue, count: Int(buffer.frameLength)))
        
        let rms = sqrt(channelDataArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        return rms
    }
    
    private func processAudioFile(at url: URL) {
        print("DictationService: Processing audio file...")
        
        // Check file size
        if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
           let fileSize = attributes[.size] as? Int64 {
            print("DictationService: Audio file size: \(fileSize) bytes")
        }
        
        // Convert to 16kHz WAV for Whisper if needed
        Task {
            do {
                // Process entire file at once
                let convertedURL = try await convertAudioToWhisperFormat(url: url)
                print("DictationService: Starting whisper transcription...")
                let transcribedText = try await self.transcriber.transcribe(audioFileURL: convertedURL)
                
                DispatchQueue.main.async { [weak self] in
                    self?.transcriptionStatus = "Ready"
                    
                    if transcribedText.isEmpty {
                        print("DictationService: No speech detected")
                        self?.transcriptionStatus = "No speech detected"
                    } else {
                        print("DictationService: Final transcription: \(transcribedText)")
                        
                        // Insert at cursor
                        Task {
                            do {
                                try await self?.textInsertion.insertText(transcribedText)
                                self?.transcriptionStatus = "Text inserted"
                                print("DictationService: Text inserted successfully")
                            } catch {
                                self?.transcriptionStatus = "Failed to insert: \(error.localizedDescription)"
                                print("DictationService: Failed to insert text: \(error)")
                            }
                        }
                    }
                }
                    
                // Clean up audio files
                // DEBUG: Keep the file for inspection
                print("DictationService: DEBUG - Audio file saved at: \(url.path)")
                // try? FileManager.default.removeItem(at: url)
                // if convertedURL != url {
                //     try? FileManager.default.removeItem(at: convertedURL)
                // }
                // print("DictationService: Cleaned up audio files")
            } catch {
                print("DictationService: Error processing audio: \(error)")
                self.transcriptionStatus = "Processing failed"
            }
        }
    }
    
    private func convertAudioToWhisperFormat(url: URL) async throws -> URL {
        // Whisper.cpp can handle resampling internally, so we'll use the original file
        print("DictationService: Using original audio file at \(url.path)")
        
        // Verify the file has content
        if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
           let fileSize = attributes[.size] as? Int64 {
            print("DictationService: Audio file size for transcription: \(fileSize) bytes")
            
            if fileSize < 1000 {
                print("DictationService: Warning - Audio file seems too small")
            }
        }
        
        return url
    }
    
    func updateModel() {
        // Model will be read from UserDefaults by transcriber
        let modelName = UserDefaults.standard.string(forKey: "whisperModel") ?? "small.en"
        print("DictationService: Updated to model: \(modelName)")
    }
}

// MARK: - Audio Notifications
extension DictationService {
    private func setupAudioNotifications() {
        // On macOS, we can monitor for audio device changes differently
        // For now, we'll skip this as AVAudioEngine handles device changes
    }
}