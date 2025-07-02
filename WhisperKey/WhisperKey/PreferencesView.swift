//
//  PreferencesView.swift
//  WhisperKey
//
//  Purpose: Preferences window for all WhisperKey settings
//  
//  Created by Assistant on 2025-07-02.
//

import SwiftUI
import ServiceManagement

struct PreferencesView: View {
    @AppStorage("selectedHotkey") private var selectedHotkey = "right_option"
    @AppStorage("whisperModel") private var whisperModel = "small.en"
    @AppStorage("silenceDuration") private var silenceDuration = 2.5
    @AppStorage("silenceThreshold") private var silenceThreshold = 0.015
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("showRecordingIndicator") private var showRecordingIndicator = true
    @AppStorage("playFeedbackSounds") private var playFeedbackSounds = true
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralTab()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(0)
            
            RecordingTab()
                .tabItem {
                    Label("Recording", systemImage: "mic")
                }
                .tag(1)
            
            ModelsTab()
                .tabItem {
                    Label("Models", systemImage: "cpu")
                }
                .tag(2)
            
            AdvancedTab()
                .tabItem {
                    Label("Advanced", systemImage: "slider.horizontal.3")
                }
                .tag(3)
        }
        .frame(width: 500, height: 400)
    }
}

// MARK: - General Tab

struct GeneralTab: View {
    @AppStorage("selectedHotkey") private var selectedHotkey = "right_option"
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("showRecordingIndicator") private var showRecordingIndicator = true
    @AppStorage("playFeedbackSounds") private var playFeedbackSounds = true
    
    var body: some View {
        Form {
            Section {
                // Hotkey selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Activation Hotkey")
                        .font(.headline)
                    
                    Picker("", selection: $selectedHotkey) {
                        Text("Right Option ⌥").tag("right_option")
                        Text("Caps Lock").tag("caps_lock")
                        Text("F13").tag("f13")
                        Text("F14").tag("f14")
                        Text("F15").tag("f15")
                        Text("⌘⇧Space").tag("cmd_shift_space")
                    }
                    .pickerStyle(RadioGroupPickerStyle())
                    .onChange(of: selectedHotkey) { _ in
                        // Update hotkey in AppDelegate
                        if let appDelegate = NSApp.delegate as? AppDelegate {
                            appDelegate.updateHotkey()
                        }
                    }
                    
                    Text("Press and hold to start recording, release to stop")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
                
                Divider()
                
                // Launch at login
                Toggle("Launch WhisperKey at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { enabled in
                        updateLaunchAtLogin(enabled)
                    }
                
                // Visual feedback
                Toggle("Show recording indicator", isOn: $showRecordingIndicator)
                    .help("Shows a floating indicator when recording")
                
                // Audio feedback
                Toggle("Play feedback sounds", isOn: $playFeedbackSounds)
                    .help("Play sounds when starting/stopping recording")
            }
            .padding()
        }
    }
    
    private func updateLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to update launch at login: \(error)")
        }
    }
}

// MARK: - Recording Tab

struct RecordingTab: View {
    @AppStorage("silenceDuration") private var silenceDuration = 2.5
    @AppStorage("silenceThreshold") private var silenceThreshold = 0.015
    @AppStorage("maxRecordingDuration") private var maxRecordingDuration = 60.0
    
    var body: some View {
        Form {
            Section {
                // Silence duration
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Stop after silence")
                        Spacer()
                        Text("\(silenceDuration, specifier: "%.1f") seconds")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $silenceDuration, in: 1.0...5.0, step: 0.5)
                    Text("How long to wait after you stop speaking")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
                
                Divider()
                
                // Silence threshold
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Silence sensitivity")
                        Spacer()
                        Text(sensitivityDescription)
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $silenceThreshold, in: 0.005...0.03, step: 0.005)
                    Text("Adjust if recording stops too early or late")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
                
                Divider()
                
                // Max recording duration
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Maximum recording time")
                        Spacer()
                        Text("\(Int(maxRecordingDuration)) seconds")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $maxRecordingDuration, in: 30...120, step: 10)
                    Text("Prevents accidental long recordings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            .padding()
        }
    }
    
    private var sensitivityDescription: String {
        if silenceThreshold < 0.01 {
            return "Very Sensitive"
        } else if silenceThreshold < 0.02 {
            return "Normal"
        } else {
            return "Less Sensitive"
        }
    }
}

// MARK: - Models Tab

struct ModelsTab: View {
    @AppStorage("whisperModel") private var whisperModel = "small.en"
    @AppStorage("autoSelectModel") private var autoSelectModel = false
    
    private let modelPath = NSString(string: "~/Developer/whisper.cpp/models").expandingTildeInPath
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Whisper Model")
                        .font(.headline)
                    
                    // Model selection
                    ForEach(availableModels, id: \.filename) { model in
                        HStack {
                            RadioButton(
                                isSelected: whisperModel == model.filename,
                                action: { whisperModel = model.filename }
                            )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(model.name)
                                    .font(.system(size: 13))
                                HStack(spacing: 8) {
                                    Text(model.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    if isModelInstalled(model.filename) {
                                        Label("Installed", systemImage: "checkmark.circle.fill")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            Text(model.size)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Divider()
                    
                    // Auto-selection
                    Toggle("Automatically select model based on performance", isOn: $autoSelectModel)
                        .disabled(true) // Not implemented yet
                        .help("Coming soon: Let WhisperKey choose the best model")
                    
                    // Download instructions
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Missing models?")
                            .font(.caption)
                            .fontWeight(.medium)
                        Text("Download from whisper.cpp/models directory")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
        }
    }
    
    private var availableModels: [WhisperModel] {
        [
            WhisperModel(
                filename: "base.en",
                name: "Base (English)",
                description: "Fastest, good for quick notes",
                size: "141 MB"
            ),
            WhisperModel(
                filename: "small.en",
                name: "Small (English)",
                description: "Balanced speed and accuracy",
                size: "465 MB"
            ),
            WhisperModel(
                filename: "medium.en",
                name: "Medium (English)",
                description: "Higher accuracy, slower",
                size: "1.4 GB"
            ),
            WhisperModel(
                filename: "large-v3-turbo",
                name: "Large Turbo",
                description: "Best accuracy, multilingual",
                size: "1.6 GB"
            )
        ]
    }
    
    private func isModelInstalled(_ filename: String) -> Bool {
        let fullPath = "\(modelPath)/ggml-\(filename).bin"
        return FileManager.default.fileExists(atPath: fullPath)
    }
}

// MARK: - Advanced Tab

struct AdvancedTab: View {
    @AppStorage("debugMode") private var debugMode = false
    @State private var showingResetAlert = false
    
    var body: some View {
        Form {
            Section {
                // Debug mode
                Toggle("Enable debug logging", isOn: $debugMode)
                    .help("Shows detailed logs in Console.app")
                
                Divider()
                
                // Temp file cleanup
                VStack(alignment: .leading, spacing: 8) {
                    Button("Clean Temporary Files") {
                        DictationService.cleanupAllTempFiles()
                        showCleanupSuccess()
                    }
                    Text("Remove all temporary audio recordings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
                
                Divider()
                
                // Reset settings
                VStack(alignment: .leading, spacing: 8) {
                    Button("Reset All Settings") {
                        showingResetAlert = true
                    }
                    .foregroundColor(.red)
                    Text("Restore all settings to defaults")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
                
                Spacer()
                
                // Version info
                VStack(spacing: 4) {
                    Text("WhisperKey \(appVersion)")
                        .font(.caption)
                    Text("© 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .alert("Reset All Settings?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAllSettings()
            }
        } message: {
            Text("This will restore all settings to their default values.")
        }
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private func showCleanupSuccess() {
        // Show a brief notification
        let alert = NSAlert()
        alert.messageText = "Cleanup Complete"
        alert.informativeText = "Temporary files have been removed"
        alert.alertStyle = .informational
        alert.runModal()
    }
    
    private func resetAllSettings() {
        // Reset all UserDefaults
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
            
            // Update hotkey
            if let appDelegate = NSApp.delegate as? AppDelegate {
                appDelegate.updateHotkey()
            }
        }
    }
}

// MARK: - Supporting Views

struct RadioButton: View {
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(Color.secondary, lineWidth: 1)
                    .frame(width: 16, height: 16)
                
                if isSelected {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 10, height: 10)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Models

struct WhisperModel {
    let filename: String
    let name: String
    let description: String
    let size: String
}

// MARK: - Preferences Window Controller

class PreferencesWindowController: NSWindowController {
    convenience init() {
        let preferencesView = PreferencesView()
        let hostingController = NSHostingController(rootView: preferencesView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "WhisperKey Preferences"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.center()
        window.setFrameAutosaveName("PreferencesWindow")
        
        self.init(window: window)
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}