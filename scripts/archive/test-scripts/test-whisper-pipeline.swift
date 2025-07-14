#!/usr/bin/env swift

import Foundation

// Test the whisper binary directly with a test audio file
let whisperPath = "/Users/orion/Developer/whisper.cpp/build/bin/whisper-cli"
let modelPath = "/Users/orion/Developer/whisper.cpp/models/ggml-base.en.bin"

print("Testing Whisper Pipeline")
print("========================")

// Check if whisper exists
if !FileManager.default.fileExists(atPath: whisperPath) {
    print("❌ Whisper binary not found at: \(whisperPath)")
    exit(1)
}
print("✓ Whisper binary found")

// Check if model exists
if !FileManager.default.fileExists(atPath: modelPath) {
    print("❌ Model not found at: \(modelPath)")
    exit(1)
}
print("✓ Model found")

// Find a recent audio file to test with
let tempDir = "/var/folders/g0/gsspjwhd5kv09gf4wcjyhd8w0000gn/T/"
let enumerator = FileManager.default.enumerator(atPath: tempDir)

var testFile: String?
while let file = enumerator?.nextObject() as? String {
    if file.hasPrefix("test_recording_") && file.hasSuffix(".wav") {
        let fullPath = tempDir + file
        let attributes = try? FileManager.default.attributesOfItem(atPath: fullPath)
        if let size = attributes?[.size] as? Int64, size > 100000 {
            testFile = fullPath
            break
        }
    }
}

guard let audioFile = testFile else {
    print("❌ No test audio file found. Run test-audio-recording.swift first!")
    exit(1)
}

print("✓ Using test file: \(audioFile)")

// Get file info
let attributes = try! FileManager.default.attributesOfItem(atPath: audioFile)
let fileSize = attributes[.size] as! Int64
print("  File size: \(fileSize) bytes")

// Run whisper
print("\nRunning whisper transcription...")
print("Command: \(whisperPath) -m \(modelPath) -f \(audioFile) --no-timestamps --language en")

let process = Process()
process.executableURL = URL(fileURLWithPath: whisperPath)
process.arguments = [
    "-m", modelPath,
    "-f", audioFile,
    "--no-timestamps",
    "--language", "en",
    "--threads", "8"
]

let outputPipe = Pipe()
process.standardOutput = outputPipe

do {
    try process.run()
    process.waitUntilExit()
    
    let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""
    
    print("\nWhisper output:")
    print("================")
    print(output)
    
    if process.terminationStatus == 0 {
        print("\n✓ Transcription completed successfully!")
        
        // Extract just the transcribed text
        let lines = output.components(separatedBy: .newlines)
        let transcribedLines = lines.filter { line in
            !line.isEmpty && 
            !line.contains("[") && 
            !line.hasPrefix("whisper_") &&
            !line.hasPrefix("main:") &&
            !line.hasPrefix("system_")
        }
        
        if !transcribedLines.isEmpty {
            print("\nTranscribed text:")
            print("\"" + transcribedLines.joined(separator: " ") + "\"")
        } else {
            print("\n⚠️  No speech detected in the audio file")
        }
    } else {
        print("\n❌ Transcription failed with exit code: \(process.terminationStatus)")
    }
    
} catch {
    print("❌ Error running whisper: \(error)")
}