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
    
    @State private var selectedTab = UserDefaults.standard.integer(forKey: "preferencesRequestedTab")
    
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
        .padding(.top, 8) // Add space between title bar and tabs
        .frame(minWidth: 600, minHeight: 500)
    }
}

// MARK: - General Tab

// MARK: - Visual Components

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.accentColor)
                Text(title)
                    .font(.headline)
            }
            
            content
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
}

struct GeneralTab: View {
    @AppStorage("selectedHotkey") private var selectedHotkey = "right_option"
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("showRecordingIndicator") private var showRecordingIndicator = true
    @AppStorage("playFeedbackSounds") private var playFeedbackSounds = true
    @State private var isTestingHotkey = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Hotkey selection
                SettingsSection(title: "Activation Method", icon: "keyboard") {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach([
                            ("right_option", "Right Option ⌥", "Tap to start/stop recording"),
                            ("f13", "F13", "Tap F13 to start/stop (if available)")
                        ], id: \.0) { value, label, description in
                            HStack(alignment: .top, spacing: 8) {
                                RadioButton(isSelected: selectedHotkey == value) {
                                    selectedHotkey = value
                                    // Update hotkey immediately
                                    if let appDelegate = NSApp.delegate as? AppDelegate {
                                        appDelegate.updateHotkey()
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(label)
                                        .font(.system(size: 13))
                                    Text(description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedHotkey = value
                                if let appDelegate = NSApp.delegate as? AppDelegate {
                                    appDelegate.updateHotkey()
                                }
                            }
                        }
                    }
                    
                    Text("Tap once to start recording, tap again to stop")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Test hotkey area
                    HStack {
                        Image(systemName: isTestingHotkey ? "mic.fill" : "mic")
                            .foregroundColor(isTestingHotkey ? .red : .secondary)
                        Text(isTestingHotkey ? "Recording..." : "Press \(hotkeyDisplayName) to test")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(6)
                }
                
                // Startup and Feedback in two columns
                HStack(alignment: .top, spacing: 16) {
                    SettingsSection(title: "Startup", icon: "power") {
                        Toggle("Launch WhisperKey at login", isOn: $launchAtLogin)
                            .onChange(of: launchAtLogin) { newValue in
                                updateLaunchAtLogin(newValue)
                            }
                    }
                    .frame(maxWidth: .infinity)
                    
                    SettingsSection(title: "Visual & Audio Feedback", icon: "eye") {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Show recording indicator", isOn: $showRecordingIndicator)
                                .help("Shows a floating indicator when recording")
                            
                            Toggle("Play feedback sounds", isOn: $playFeedbackSounds)
                                .help("Play sounds when starting/stopping recording")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var hotkeyDisplayName: String {
        switch selectedHotkey {
        case "right_option": return "Right ⌥"
        case "f13": return "F13"
        default: return "Right ⌥"
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
            DebugLogger.log("Failed to update launch at login: \(error)")
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
    @StateObject private var modelManager = ModelManager.shared
    
    private var modelDisplayName: String {
        switch whisperModel {
        case "base.en": return "Base (141 MB)"
        case "small.en": return "Small (465 MB)"
        case "medium.en": return "Medium (1.4 GB)"
        case "large-v3": return "Large V3 (3.1 GB)"
        default: return whisperModel
        }
    }
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Whisper Models")
                        .font(.headline)
                    
                    Text("Download and select AI models for transcription")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("Current Model:")
                            .font(.caption)
                            .fontWeight(.medium)
                        Text(modelDisplayName)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .padding(.bottom, 8)
                    
                    // Model selection with download support
                    ForEach(modelManager.availableModels, id: \.filename) { model in
                        ModelDownloadRow(model: model)
                    }
                    
                    Divider()
                    
                    // Auto-selection
                    Toggle("Automatically select model based on performance", isOn: $autoSelectModel)
                        .disabled(true) // Not implemented yet
                        .help("Coming soon: Let WhisperKey choose the best model")
                    
                    // Model location info
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Model Location")
                            .font(.caption)
                            .fontWeight(.medium)
                        Text("~/Developer/whisper.cpp/models/")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
        }
    }
}

// MARK: - Advanced Tab

struct AdvancedTab: View {
    @AppStorage("debugMode") private var debugMode = false
    @AppStorage("customWhisperPath") private var customWhisperPath = ""
    @AppStorage("customModelsPath") private var customModelsPath = ""
    @State private var showingResetAlert = false
    @State private var showingWhisperPicker = false
    @State private var showingModelsPicker = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Debug mode
                Toggle("Enable debug logging", isOn: $debugMode)
                    .help("Shows detailed logs in Console.app")
                
                Divider()
                
                // Custom paths
                VStack(alignment: .leading, spacing: 12) {
                    Text("Custom Paths")
                        .font(.headline)
                    
                    // Whisper path
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Whisper.cpp location:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            TextField("Leave empty for auto-detection", text: $customWhisperPath)
                                .textFieldStyle(.roundedBorder)
                                .disabled(true)
                            Button("Browse...") {
                                selectWhisperPath()
                            }
                            .controlSize(.small)
                            if !customWhisperPath.isEmpty {
                                Button("Clear") {
                                    customWhisperPath = ""
                                    WhisperService.shared.checkAvailability()
                                }
                                .controlSize(.small)
                            }
                        }
                    }
                    
                    // Models path
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Models directory:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            TextField("Leave empty for auto-detection", text: $customModelsPath)
                                .textFieldStyle(.roundedBorder)
                                .disabled(true)
                            Button("Browse...") {
                                selectModelsPath()
                            }
                            .controlSize(.small)
                            if !customModelsPath.isEmpty {
                                Button("Clear") {
                                    customModelsPath = ""
                                    WhisperService.shared.checkAvailability()
                                }
                                .controlSize(.small)
                            }
                        }
                    }
                    
                    // Status
                    if WhisperService.shared.isAvailable {
                        Label("Whisper.cpp found", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Label("Whisper.cpp not found", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .padding(.vertical, 4)
                
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
                    Text("Open Source • MIT License")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
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
    
    private func selectWhisperPath() {
        let openPanel = NSOpenPanel()
        openPanel.prompt = "Select"
        openPanel.message = "Select the whisper-cli executable"
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = false
        openPanel.directoryURL = URL(fileURLWithPath: NSString(string: "~/Developer/whisper.cpp").expandingTildeInPath)
        
        openPanel.begin { response in
            if response == .OK, let url = openPanel.url {
                customWhisperPath = url.path
                WhisperService.shared.setCustomPaths(whisper: customWhisperPath, models: nil)
            }
        }
    }
    
    private func selectModelsPath() {
        let openPanel = NSOpenPanel()
        openPanel.prompt = "Select"
        openPanel.message = "Select the directory containing Whisper models"
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
        openPanel.directoryURL = URL(fileURLWithPath: NSString(string: "~/Developer/whisper.cpp/models").expandingTildeInPath)
        
        openPanel.begin { response in
            if response == .OK, let url = openPanel.url {
                customModelsPath = url.path
                WhisperService.shared.setCustomPaths(whisper: nil, models: customModelsPath)
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


// MARK: - Preferences Window Controller

class PreferencesWindowController: NSWindowController, NSWindowDelegate {
    convenience init() {
        let preferencesView = PreferencesView()
        let hostingController = NSHostingController(rootView: preferencesView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "WhisperKey Preferences"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.center()
        window.setFrameAutosaveName("PreferencesWindow")
        
        self.init(window: window)
        window.delegate = self
    }
    
    override func showWindow(_ sender: Any?) {
        DebugLogger.log("PreferencesWindowController: showWindow called")
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        DebugLogger.log("PreferencesWindowController: window shown")
    }
    
    func windowWillClose(_ notification: Notification) {
        DebugLogger.log("PreferencesWindowController: window will close")
    }
}