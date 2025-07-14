#!/usr/bin/env swift

import AVFoundation
import Foundation

print("Testing basic audio recording...")

// Request microphone permission
switch AVCaptureDevice.authorizationStatus(for: .audio) {
case .authorized:
    print("✓ Microphone permission granted")
case .notDetermined:
    print("Requesting microphone permission...")
    AVCaptureDevice.requestAccess(for: .audio) { granted in
        if granted {
            print("✓ Microphone permission granted")
        } else {
            print("✗ Microphone permission denied")
            exit(1)
        }
    }
    sleep(2) // Wait for permission
default:
    print("✗ Microphone permission not granted")
    exit(1)
}

// Create audio engine
let audioEngine = AVAudioEngine()
let inputNode = audioEngine.inputNode

// Get the input format
let inputFormat = inputNode.inputFormat(forBus: 0)
print("\nInput format: \(inputFormat)")
print("Sample rate: \(inputFormat.sampleRate) Hz")
print("Channels: \(inputFormat.channelCount)")

// Create output file
let outputURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("test_recording_\(Date().timeIntervalSince1970).wav")

do {
    // Create recording format (use input format)
    let recordingFormat = AVAudioFormat(
        commonFormat: .pcmFormatFloat32,
        sampleRate: inputFormat.sampleRate,
        channels: inputFormat.channelCount,
        interleaved: false
    )!
    
    // Create audio file
    let audioFile = try AVAudioFile(forWriting: outputURL, settings: recordingFormat.settings)
    print("\nCreated audio file at: \(outputURL.path)")
    
    var samplesRecorded = 0
    
    // Install tap
    inputNode.installTap(onBus: 0, bufferSize: 4096, format: recordingFormat) { buffer, time in
        do {
            try audioFile.write(from: buffer)
            samplesRecorded += Int(buffer.frameLength)
            
            // Calculate audio level
            if let channelData = buffer.floatChannelData {
                let data = channelData[0]
                let frames = Array(UnsafeBufferPointer(start: data, count: Int(buffer.frameLength)))
                let rms = sqrt(frames.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
                
                if rms > 0.001 {
                    print("Sound detected! Level: \(rms)")
                }
            }
        } catch {
            print("Error writing buffer: \(error)")
        }
    }
    
    // Start recording
    try audioEngine.start()
    print("\n🎤 Recording for 5 seconds... Make some noise!")
    
    // Record for 5 seconds
    Thread.sleep(forTimeInterval: 5.0)
    
    // Stop recording
    audioEngine.stop()
    inputNode.removeTap(onBus: 0)
    
    print("\n✓ Recording stopped")
    print("Samples recorded: \(samplesRecorded)")
    print("Duration: \(Double(samplesRecorded) / inputFormat.sampleRate) seconds")
    
    // Check file size
    let fileAttributes = try FileManager.default.attributesOfItem(atPath: outputURL.path)
    let fileSize = fileAttributes[.size] as? Int64 ?? 0
    print("File size: \(fileSize) bytes")
    
    // Verify with afinfo
    print("\nVerifying with afinfo:")
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/afinfo")
    process.arguments = [outputURL.path]
    try process.run()
    process.waitUntilExit()
    
    print("\n✓ Test complete! Audio file saved at: \(outputURL.path)")
    
} catch {
    print("Error: \(error)")
    exit(1)
}