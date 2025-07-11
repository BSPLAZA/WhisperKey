//
//  WhisperCppTranscriber.swift
//  WhisperKey
//
//  Purpose: Direct integration with whisper.cpp binary
//  
//  Created by Assistant on 2025-07-01.
//

import Foundation

@MainActor
class WhisperCppTranscriber {
    private let whisperService = WhisperService.shared
    
    private var whisperPath: String? {
        whisperService.whisperPath
    }
    
    private var modelPath: String? {
        let modelName = UserDefaults.standard.string(forKey: "whisperModel") ?? "small.en"
        return whisperService.getModelPath(for: modelName)
    }
    
    init() {
        // Verify paths exist
        if let whisperPath = whisperPath {
            if !FileManager.default.fileExists(atPath: whisperPath) {
                DebugLogger.log("WhisperCppTranscriber: Warning - whisper binary not found at: \(whisperPath)")
            }
        } else {
            DebugLogger.log("WhisperCppTranscriber: Error - No whisper path available")
        }
        
        if let modelPath = modelPath {
            if !FileManager.default.fileExists(atPath: modelPath) {
                DebugLogger.log("WhisperCppTranscriber: Warning - model not found at: \(modelPath)")
            }
        } else {
            DebugLogger.log("WhisperCppTranscriber: Error - No model path available")
        }
    }
    
    func transcribe(audioFileURL: URL) async throws -> String {
        DebugLogger.log("WhisperCppTranscriber: Starting transcription of: \(audioFileURL.path)")
        
        // Verify audio file exists and has content
        let attributes = try FileManager.default.attributesOfItem(atPath: audioFileURL.path)
        let fileSize = attributes[.size] as? Int64 ?? 0
        DebugLogger.log("WhisperCppTranscriber: Audio file size: \(fileSize) bytes")
        
        if fileSize < 1000 {
            DebugLogger.log("WhisperCppTranscriber: File too small, likely no audio")
            return ""
        }
        
        // Check if whisper is available
        guard let whisperPath = whisperPath else {
            throw WhisperKeyError.dependencyMissing(
                "WhisperKey couldn't find whisper.cpp. Please install it or set a custom path in Settings."
            )
        }
        
        // Check if model is available
        guard let modelPath = modelPath else {
            let modelName = UserDefaults.standard.string(forKey: "whisperModel") ?? "small.en"
            
            // Show the model missing dialog on the main thread
            await MainActor.run {
                ModelManager.shared.showModelMissingDialog(for: modelName)
            }
            
            throw WhisperKeyError.modelNotFound(
                "The selected Whisper model '\(modelName)' is not installed."
            )
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
        
        DebugLogger.log("WhisperCppTranscriber: Running whisper with arguments: \(process.arguments ?? [])")
        
        try process.run()
        
        // Read output asynchronously
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            DebugLogger.log("WhisperCppTranscriber: Error running whisper: \(errorString)")
            throw NSError(domain: "WhisperKey", code: 10, userInfo: [
                NSLocalizedDescriptionKey: "Whisper transcription failed: \(errorString)"
            ])
        }
        
        // Parse output
        let output = String(data: outputData, encoding: .utf8) ?? ""
        DebugLogger.log("WhisperCppTranscriber: Raw output:\n\(output)")
        
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
        
        DebugLogger.log("WhisperCppTranscriber: Transcribed text: \"\(transcribedText)\"")
        
        return transcribedText
    }
}