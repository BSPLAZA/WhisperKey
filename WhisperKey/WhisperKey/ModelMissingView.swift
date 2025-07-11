//
//  ModelMissingView.swift
//  WhisperKey
//
//  Purpose: Dialog shown when selected model is not installed
//  
//  Created by Author on 2025-07-11.
//

import SwiftUI
import AppKit

struct ModelMissingView: View {
    let missingModel: String
    @State private var isDownloading = false
    @State private var downloadProgress: Double = 0.0
    @ObservedObject private var modelManager = ModelManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var modelInfo: ModelManager.ModelInfo? {
        ModelManager.shared.availableModels.first { $0.filename == missingModel }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Model Not Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("The selected model '\(modelInfo?.displayName ?? missingModel)' is not installed.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Divider()
            
            // Model info
            if let model = modelInfo {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Model:")
                            .fontWeight(.medium)
                        Text(model.displayName)
                    }
                    
                    HStack {
                        Text("Size:")
                            .fontWeight(.medium)
                        Text(formatBytes(model.size))
                    }
                    
                    HStack {
                        Text("Description:")
                            .fontWeight(.medium)
                        Text(model.description)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }
            
            // Download section
            if isDownloading {
                VStack(spacing: 8) {
                    ProgressView(value: downloadProgress)
                        .progressViewStyle(.linear)
                    
                    Text("Downloading... \(Int(downloadProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                VStack(spacing: 16) {
                    Text("What would you like to do?")
                        .fontWeight(.medium)
                    
                    HStack(spacing: 12) {
                        Button("Download Now") {
                            downloadModel()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Choose Different Model") {
                            openPreferences()
                        }
                        
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
            
            // Alternative models
            if !isDownloading && !installedModels.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Installed models:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    ScrollView {
                        VStack(spacing: 4) {
                            ForEach(installedModels, id: \.filename) { model in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                    
                                    Text(model.displayName)
                                        .font(.caption)
                                    
                                    Spacer()
                                    
                                    Button("Use This") {
                                        selectModel(model.filename)
                                    }
                                    .font(.caption)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                            }
                        }
                    }
                    .frame(maxHeight: 120)
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }
        }
        .padding(30)
        .frame(width: 500, height: 550)
        .onReceive(modelManager.$downloadProgress) { progress in
            if let modelProgress = progress[missingModel] {
                downloadProgress = modelProgress
            }
        }
        .onReceive(modelManager.$downloadError) { errors in
            if let error = errors[missingModel] {
                showError(error)
            }
        }
    }
    
    var installedModels: [ModelManager.ModelInfo] {
        ModelManager.shared.availableModels.filter { model in
            ModelManager.shared.isModelInstalled(model.filename)
        }
    }
    
    func downloadModel() {
        isDownloading = true
        modelManager.downloadModel(missingModel)
    }
    
    func openPreferences() {
        dismiss()
        // Small delay to ensure dialog closes before opening preferences
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Open preferences on Models tab (tab index 2)
            WindowManager.shared.showPreferences(tab: 2)
        }
    }
    
    func selectModel(_ filename: String) {
        UserDefaults.standard.set(filename, forKey: "whisperModel")
        dismiss()
    }
    
    func showError(_ error: String) {
        isDownloading = false
        
        let alert = NSAlert()
        alert.messageText = "Download Failed"
        alert.informativeText = error
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// Helper function to show model missing dialog
extension ModelManager {
    @MainActor
    func showModelMissingDialog(for model: String) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 550),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Model Required"
        window.center()
        window.isReleasedWhenClosed = false
        
        let view = ModelMissingView(missingModel: model)
        window.contentView = NSHostingView(rootView: view)
        
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}