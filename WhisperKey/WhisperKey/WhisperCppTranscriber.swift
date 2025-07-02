//
//  WhisperCppTranscriber.swift
//  WhisperKey
//
//  Purpose: Direct integration with whisper.cpp binary
//  
//  Created by Assistant on 2025-07-01.
//

import Foundation

class WhisperCppTranscriber {
    private let whisperPath = "/Users/orion/Developer/whisper.cpp/build/bin/whisper-cli"
    private var modelPath: String {
        let modelName = UserDefaults.standard.string(forKey: "whisperModel") ?? "small.en"
        let basePath = NSString(string: "~/Developer/whisper.cpp/models/").expandingTildeInPath
        
        switch modelName {
        case "base.en":
            return basePath + "/ggml-base.en.bin"
        case "small.en":
            return basePath + "/ggml-small.en.bin"
        case "medium.en":
            return basePath + "/ggml-medium.en.bin"
        case "large-v3-turbo":
            return basePath + "/ggml-large-v3-turbo.bin"
        default:
            return basePath + "/ggml-small.en.bin"
        }
    }
    
    init() {
        // Verify paths exist
        if !FileManager.default.fileExists(atPath: whisperPath) {
            print("WhisperCppTranscriber: Warning - whisper binary not found at: \(whisperPath)")
        }
        if !FileManager.default.fileExists(atPath: modelPath) {
            print("WhisperCppTranscriber: Warning - model not found at: \(modelPath)")
        }
    }
    
    func transcribe(audioFileURL: URL) async throws -> String {
        print("WhisperCppTranscriber: Starting transcription of: \(audioFileURL.path)")
        
        // Verify audio file exists and has content
        let attributes = try FileManager.default.attributesOfItem(atPath: audioFileURL.path)
        let fileSize = attributes[.size] as? Int64 ?? 0
        print("WhisperCppTranscriber: Audio file size: \(fileSize) bytes")
        
        if fileSize < 1000 {
            print("WhisperCppTranscriber: File too small, likely no audio")
            return ""
        }
        
        // Run whisper.cpp
        let process = Process()
        process.executableURL = URL(fileURLWithPath: whisperPath)
        
        // Use simple arguments for transcription
        process.arguments = [
            "-m", modelPath,
            "-f", audioFileURL.path,
            "-nt",  // no timestamps
            "-np",  // no prints (only output transcription)
            "-l", "en",  // language: English
            "-t", "8"    // threads
        ]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        print("WhisperCppTranscriber: Running whisper with arguments: \(process.arguments!)")
        
        try process.run()
        
        // Read output asynchronously
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            print("WhisperCppTranscriber: Error running whisper: \(errorString)")
            throw NSError(domain: "WhisperKey", code: 10, userInfo: [
                NSLocalizedDescriptionKey: "Whisper transcription failed: \(errorString)"
            ])
        }
        
        // Parse output
        let output = String(data: outputData, encoding: .utf8) ?? ""
        print("WhisperCppTranscriber: Raw output:\n\(output)")
        
        // Extract transcribed text
        // Whisper outputs the transcription after any system messages
        // The transcription might have leading/trailing whitespace
        let lines = output.components(separatedBy: .newlines)
        let transcribedLines = lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            // Skip empty lines and system output
            return !trimmed.isEmpty && 
                   !trimmed.contains("[") && 
                   !trimmed.hasPrefix("whisper_") &&
                   !trimmed.hasPrefix("main:") &&
                   !trimmed.hasPrefix("system_info")
        }
        
        let transcribedText = transcribedLines
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .joined(separator: " ")
        
        print("WhisperCppTranscriber: Transcribed text: \"\(transcribedText)\"")
        
        return transcribedText
    }
}