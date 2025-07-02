//
//  WhisperStreamingTranscriber.swift
//  WhisperKey
//
//  Purpose: Streaming transcription using whisper.cpp with balanced latency/accuracy
//  
//  Created by Assistant on 2025-07-02.
//

import Foundation
import AVFoundation

class WhisperStreamingTranscriber {
    // Whisper needs substantial audio context for accurate transcription
    // These settings balance latency vs accuracy:
    private let minimumProcessingDuration: TimeInterval = 2.0  // Don't process until we have 2s of audio
    private let processingInterval: TimeInterval = 2.0         // Process every 2 seconds after minimum
    private let contextWindow: TimeInterval = 5.0              // Use up to 5s of context for accuracy
    
    private let transcriber = WhisperCppTranscriber()
    private var audioBuffer: [Float] = []
    private var isProcessing = false
    private let processingQueue = DispatchQueue(label: "whisper.streaming", qos: .userInitiated)
    
    // Timing
    private var lastProcessingTime: Date?
    private var bufferStartTime: Date = Date()
    
    // Callbacks
    var onPartialTranscription: ((String) -> Void)?
    var onError: ((Error) -> Void)?
    
    private var fullTranscript = ""
    private var lastTranscriptLength = 0
    private let sampleRate: Double = 16000  // Whisper expects 16kHz
    
    // Audio format converter
    private var converter: AVAudioConverter?
    private let targetFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                           sampleRate: 16000,
                                           channels: 1,
                                           interleaved: false)!
    
    init() {
        print("WhisperStreamingTranscriber: Initialized - will process every \(processingInterval)s with \(contextWindow)s context")
    }
    
    func startStreaming() {
        print("WhisperStreamingTranscriber: Starting streaming mode")
        audioBuffer.removeAll()
        fullTranscript = ""
        lastTranscriptLength = 0
        lastProcessingTime = nil
        bufferStartTime = Date()
    }
    
    func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        // Convert to 16kHz if needed
        let convertedBuffer = convertTo16kHz(buffer: buffer) ?? buffer
        
        // Extract audio samples
        guard let channelData = convertedBuffer.floatChannelData else { return }
        let channelDataValue = channelData.pointee
        let channelDataArray = Array(UnsafeBufferPointer(
            start: channelDataValue,
            count: Int(convertedBuffer.frameLength)
        ))
        
        // Add to buffer
        processingQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.audioBuffer.append(contentsOf: channelDataArray)
            
            // Calculate buffer duration
            let bufferDuration = Double(self.audioBuffer.count) / self.sampleRate
            let timeSinceLastProcessing = self.lastProcessingTime.map { Date().timeIntervalSince($0) } ?? bufferDuration
            
            // Process if we have enough audio and enough time has passed
            if bufferDuration >= self.minimumProcessingDuration &&
               timeSinceLastProcessing >= self.processingInterval &&
               !self.isProcessing {
                
                self.isProcessing = true
                self.lastProcessingTime = Date()
                
                // Use up to contextWindow seconds of audio
                let maxSamples = Int(self.contextWindow * self.sampleRate)
                let samplesToProcess = min(self.audioBuffer.count, maxSamples)
                let chunkSamples = Array(self.audioBuffer.suffix(samplesToProcess))
                
                print("WhisperStreamingTranscriber: Processing \(bufferDuration)s of audio")
                
                // Process chunk asynchronously
                Task {
                    await self.processChunk(samples: chunkSamples)
                    
                    // Keep only the last contextWindow of audio for next processing
                    await MainActor.run {
                        let samplesToKeep = Int(self.contextWindow * self.sampleRate)
                        if self.audioBuffer.count > samplesToKeep {
                            let removeCount = self.audioBuffer.count - samplesToKeep
                            self.audioBuffer.removeFirst(removeCount)
                        }
                        self.isProcessing = false
                    }
                }
            }
        }
    }
    
    private func convertTo16kHz(buffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
        let inputFormat = buffer.format
        
        // If already 16kHz, return as-is
        if inputFormat.sampleRate == targetFormat.sampleRate {
            return nil
        }
        
        // Create converter if needed
        if converter == nil {
            converter = AVAudioConverter(from: inputFormat, to: targetFormat)
        }
        
        guard let converter = converter else { return nil }
        
        // Calculate output buffer size
        let outputFrameCapacity = AVAudioFrameCount(
            Double(buffer.frameLength) * targetFormat.sampleRate / inputFormat.sampleRate
        )
        
        guard let outputBuffer = AVAudioPCMBuffer(
            pcmFormat: targetFormat,
            frameCapacity: outputFrameCapacity
        ) else { return nil }
        
        var error: NSError?
        converter.convert(to: outputBuffer, error: &error) { _, outStatus in
            outStatus.pointee = .haveData
            return buffer
        }
        
        if let error = error {
            print("WhisperStreamingTranscriber: Conversion error: \(error)")
            return nil
        }
        
        return outputBuffer
    }
    
    private func processChunk(samples: [Float]) async {
        // Create temporary WAV file
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("stream_chunk_\(Date().timeIntervalSince1970).wav")
        
        do {
            // Write samples to WAV file
            try writeBufferToWAV(samples, sampleRate: sampleRate, to: tempURL)
            
            // Transcribe chunk - this gets the FULL transcription of the chunk
            let chunkTranscript = try await transcriber.transcribe(audioFileURL: tempURL)
            
            // Clean up immediately
            try? FileManager.default.removeItem(at: tempURL)
            
            // Process transcription result
            if !chunkTranscript.isEmpty {
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    
                    // For streaming, we need to detect what's new
                    // Since we're processing overlapping audio, we need to find the new portion
                    self.fullTranscript = chunkTranscript
                    
                    // Find what's new compared to last time
                    if chunkTranscript.count > self.lastTranscriptLength {
                        // Extract only the new portion
                        let newText = String(chunkTranscript.dropFirst(self.lastTranscriptLength))
                        
                        if !newText.isEmpty {
                            print("WhisperStreamingTranscriber: New text: \"\(newText)\"")
                            self.onPartialTranscription?(newText)
                        }
                        
                        self.lastTranscriptLength = chunkTranscript.count
                    }
                }
            }
        } catch {
            print("WhisperStreamingTranscriber: Error processing chunk: \(error)")
            await MainActor.run { [weak self] in
                self?.onError?(error)
            }
        }
    }
    
    private func writeBufferToWAV(_ samples: [Float], sampleRate: Double, to url: URL) throws {
        let format = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: sampleRate,
            channels: 1,
            interleaved: false
        )!
        
        let audioFile = try AVAudioFile(forWriting: url, settings: format.settings)
        
        let frameCount = samples.count
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: AVAudioFrameCount(frameCount)
        ) else {
            throw NSError(domain: "StreamingTranscriber", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to create buffer"])
        }
        
        buffer.frameLength = AVAudioFrameCount(frameCount)
        
        // Copy samples to buffer
        if let channelData = buffer.floatChannelData {
            samples.withUnsafeBufferPointer { srcBuffer in
                channelData[0].update(from: srcBuffer.baseAddress!, count: frameCount)
            }
        }
        
        try audioFile.write(from: buffer)
    }
    
    func stopStreaming() {
        print("WhisperStreamingTranscriber: Stopping streaming")
        
        // Process any remaining audio
        processingQueue.async { [weak self] in
            guard let self = self,
                  !self.audioBuffer.isEmpty,
                  !self.isProcessing else { return }
            
            let remainingSamples = self.audioBuffer
            self.audioBuffer.removeAll()
            
            Task {
                await self.processChunk(samples: remainingSamples)
            }
        }
    }
    
    func finalize() -> String {
        // Process any remaining audio synchronously
        processingQueue.sync { [weak self] in
            guard let self = self,
                  !self.audioBuffer.isEmpty,
                  !self.isProcessing else { return }
            
            let remainingSamples = self.audioBuffer
            self.audioBuffer.removeAll()
            
            Task {
                await self.processChunk(samples: remainingSamples)
            }
        }
        
        // Return the full transcript
        let finalText = fullTranscript.trimmingCharacters(in: .whitespaces)
        
        // Reset for next session
        fullTranscript = ""
        lastTranscriptLength = 0
        audioBuffer.removeAll()
        
        return finalText
    }
}