#!/usr/bin/env swift

import AVFoundation
import Foundation

// Simple test to verify audio recording works
class AudioTest {
    var audioEngine: AVAudioEngine?
    var audioFile: AVAudioFile?
    
    func test() {
        print("Testing audio recording...")
        
        audioEngine = AVAudioEngine()
        let inputNode = audioEngine!.inputNode
        let inputFormat = inputNode.inputFormat(forBus: 0)
        
        print("Input format: \(inputFormat)")
        
        // Create test file
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("test_audio.wav")
        
        guard let recordingFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: inputFormat.sampleRate,
            channels: inputFormat.channelCount,
            interleaved: false
        ) else {
            print("Failed to create format")
            return
        }
        
        do {
            audioFile = try AVAudioFile(forWriting: url, settings: recordingFormat.settings)
            
            var samplesRecorded = 0
            inputNode.installTap(onBus: 0, bufferSize: 4096, format: recordingFormat) { [weak self] buffer, _ in
                guard let audioFile = self?.audioFile else { return }
                
                do {
                    try audioFile.write(from: buffer)
                    samplesRecorded += Int(buffer.frameLength)
                    
                    // Check audio level
                    if let channelData = buffer.floatChannelData {
                        let data = channelData[0]
                        let frames = Array(UnsafeBufferPointer(start: data, count: Int(buffer.frameLength)))
                        let rms = sqrt(frames.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
                        
                        if rms > 0.001 {
                            print("Sound detected! Level: \(rms)")
                        }
                    }
                } catch {
                    print("Error writing: \(error)")
                }
            }
            
            try audioEngine!.start()
            print("Recording started. Speak into microphone...")
            
            // Record for 5 seconds
            Thread.sleep(forTimeInterval: 5.0)
            
            audioEngine!.stop()
            audioEngine!.inputNode.removeTap(onBus: 0)
            audioFile = nil
            
            print("Recording stopped.")
            print("Samples recorded: \(samplesRecorded)")
            print("Duration: \(Double(samplesRecorded) / recordingFormat.sampleRate) seconds")
            print("File saved at: \(url.path)")
            
            // Check file size
            let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
            print("File size: \(attrs[.size] ?? 0) bytes")
            
        } catch {
            print("Error: \(error)")
        }
    }
}

let test = AudioTest()
test.test()