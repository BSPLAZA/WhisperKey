//
//  ModelManager.swift
//  WhisperKey
//
//  Purpose: Manage Whisper model downloads and installation
//  
//  Created by Assistant on 2025-07-02.
//

import Foundation
import SwiftUI

@MainActor
class ModelManager: ObservableObject {
    static let shared = ModelManager()
    
    @Published var downloadProgress: [String: Double] = [:]
    @Published var isDownloading: [String: Bool] = [:]
    @Published var downloadError: [String: String] = [:]
    
    private let modelPath = NSString(string: "~/Developer/whisper.cpp/models").expandingTildeInPath
    private let whisperCppPath = NSString(string: "~/Developer/whisper.cpp").expandingTildeInPath
    
    private var downloadTasks: [String: URLSessionDownloadTask] = [:]
    
    struct ModelInfo {
        let filename: String
        let downloadURL: String
        let size: Int64
        let displayName: String
        let description: String
    }
    
    let availableModels: [ModelInfo] = [
        ModelInfo(
            filename: "base.en",
            downloadURL: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin",
            size: 147_964_211, // ~141 MB
            displayName: "Base (English)",
            description: "Fastest, good for quick notes"
        ),
        ModelInfo(
            filename: "small.en",
            downloadURL: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.en.bin",
            size: 487_688_691, // ~465 MB
            displayName: "Small (English)",
            description: "Balanced speed and accuracy"
        ),
        ModelInfo(
            filename: "medium.en",
            downloadURL: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.en.bin",
            size: 1_528_884_219, // ~1.4 GB
            displayName: "Medium (English)",
            description: "Higher accuracy, slower"
        ),
        ModelInfo(
            filename: "large-v3",
            downloadURL: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3.bin",
            size: 3_094_623_691, // ~2.9 GB
            displayName: "Large v3",
            description: "Best accuracy, multilingual"
        )
    ]
    
    func isModelInstalled(_ filename: String) -> Bool {
        let fullPath = "\(modelPath)/ggml-\(filename).bin"
        return FileManager.default.fileExists(atPath: fullPath)
    }
    
    func downloadModel(_ filename: String) {
        guard let model = availableModels.first(where: { $0.filename == filename }) else {
            return
        }
        
        // Check if already downloading
        if isDownloading[filename] == true {
            return
        }
        
        // Create models directory if needed
        try? FileManager.default.createDirectory(atPath: modelPath, withIntermediateDirectories: true)
        
        guard let url = URL(string: model.downloadURL) else {
            downloadError[filename] = "Invalid download URL"
            return
        }
        
        isDownloading[filename] = true
        downloadProgress[filename] = 0.0
        downloadError[filename] = nil
        
        let session = URLSession(configuration: .default, delegate: DownloadDelegate(filename: filename, manager: self), delegateQueue: nil)
        let task = session.downloadTask(with: url)
        downloadTasks[filename] = task
        task.resume()
    }
    
    func cancelDownload(_ filename: String) {
        downloadTasks[filename]?.cancel()
        downloadTasks[filename] = nil
        isDownloading[filename] = false
        downloadProgress[filename] = nil
        downloadError[filename] = nil
    }
    
    private func moveDownloadedFile(from location: URL, for filename: String) {
        let destinationPath = "\(modelPath)/ggml-\(filename).bin"
        let destinationURL = URL(fileURLWithPath: destinationPath)
        
        do {
            // Remove existing file if present
            try? FileManager.default.removeItem(at: destinationURL)
            
            // Move downloaded file
            try FileManager.default.moveItem(at: location, to: destinationURL)
            
            DispatchQueue.main.async {
                self.isDownloading[filename] = false
                self.downloadProgress[filename] = nil
                self.downloadError[filename] = nil
                
                // Show success notification
                let alert = NSAlert()
                alert.messageText = "Model Downloaded"
                alert.informativeText = "\(self.availableModels.first(where: { $0.filename == filename })?.displayName ?? filename) is now ready to use"
                alert.alertStyle = .informational
                alert.runModal()
            }
        } catch {
            DispatchQueue.main.async {
                self.isDownloading[filename] = false
                self.downloadError[filename] = "Failed to install model: \(error.localizedDescription)"
            }
        }
    }
    
    class DownloadDelegate: NSObject, URLSessionDownloadDelegate, @unchecked Sendable {
        let filename: String
        let manager: ModelManager?
        
        init(filename: String, manager: ModelManager) {
            self.filename = filename
            self.manager = manager
        }
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
            Task { @MainActor in
                manager?.moveDownloadedFile(from: location, for: filename)
            }
        }
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
            let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            DispatchQueue.main.async {
                self.manager?.downloadProgress[self.filename] = progress
            }
        }
        
        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            if let error = error {
                DispatchQueue.main.async {
                    self.manager?.isDownloading[self.filename] = false
                    self.manager?.downloadError[self.filename] = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Model Download Row View

struct ModelDownloadRow: View {
    let model: ModelManager.ModelInfo
    @ObservedObject var manager = ModelManager.shared
    @AppStorage("whisperModel") private var selectedModel = "small.en"
    
    private var isInstalled: Bool {
        manager.isModelInstalled(model.filename)
    }
    
    private var isDownloading: Bool {
        manager.isDownloading[model.filename] == true
    }
    
    private var downloadProgress: Double {
        manager.downloadProgress[model.filename] ?? 0.0
    }
    
    private var hasError: Bool {
        manager.downloadError[model.filename] != nil
    }
    
    var body: some View {
        HStack {
            // Radio button
            RadioButton(
                isSelected: selectedModel == model.filename && isInstalled,
                action: { 
                    if isInstalled {
                        selectedModel = model.filename
                    }
                }
            )
            .disabled(!isInstalled)
            
            // Model info
            VStack(alignment: .leading, spacing: 2) {
                Text(model.displayName)
                    .font(.system(size: 13))
                    .foregroundColor(isInstalled ? .primary : .secondary)
                
                HStack(spacing: 8) {
                    Text(model.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if isInstalled {
                        Label("Installed", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                // Download progress
                if isDownloading {
                    ProgressView(value: downloadProgress)
                        .progressViewStyle(.linear)
                        .frame(width: 200)
                    
                    Text("\(Int(downloadProgress * 100))% of \(formatBytes(model.size))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Error message
                if let error = manager.downloadError[model.filename] {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            Spacer()
            
            // Download/Cancel button
            if !isInstalled {
                if isDownloading {
                    Button("Cancel") {
                        manager.cancelDownload(model.filename)
                    }
                    .font(.caption)
                } else {
                    Button("Download") {
                        manager.downloadModel(model.filename)
                    }
                    .font(.caption)
                }
            }
            
            // Size label
            Text(formatBytes(model.size))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}