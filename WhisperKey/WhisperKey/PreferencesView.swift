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
    @AppStorage("alwaysSaveToClipboard") private var alwaysSaveToClipboard = true
    
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
    @AppStorage("alwaysSaveToClipboard") private var alwaysSaveToClipboard = true
    @State private var isTestingHotkey = false
    @State private var testingTimer: Timer?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Hotkey section with improved design
                SettingsSection(title: "Activation", icon: "keyboard") {
                    VStack(alignment: .leading, spacing: 16) {
                        // Radio buttons with better styling
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach([
                                ("right_option", "Right Option ⌥", "Tap once to start, tap again to stop", "keyboard.badge.ellipsis"),
                                ("f13", "F13 Key", "For keyboards with F13 support", "keyboard")
                            ], id: \.0) { value, label, description, icon in
                                HStack(spacing: 12) {
                                    RadioButton(isSelected: selectedHotkey == value) {
                                        selectedHotkey = value
                                        if let appDelegate = NSApp.delegate as? AppDelegate {
                                            appDelegate.updateHotkey()
                                        }
                                    }
                                    
                                    Image(systemName: icon)
                                        .font(.system(size: 16))
                                        .foregroundColor(selectedHotkey == value ? .accentColor : .secondary)
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(label)
                                            .font(.system(size: 13, weight: .medium))
                                        Text(description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(selectedHotkey == value ? Color.accentColor.opacity(0.1) : Color.clear)
                                .cornerRadius(6)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedHotkey = value
                                    if let appDelegate = NSApp.delegate as? AppDelegate {
                                        appDelegate.updateHotkey()
                                    }
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Enhanced test area
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                Text("Test your hotkey")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isTestingHotkey ? Color.red : Color.secondary.opacity(0.2))
                                    .frame(width: 4)
                                    .animation(.easeInOut(duration: 0.3), value: isTestingHotkey)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 8) {
                                        Image(systemName: isTestingHotkey ? "mic.fill" : "mic")
                                            .foregroundColor(isTestingHotkey ? .red : .secondary)
                                            .animation(.easeInOut(duration: 0.2), value: isTestingHotkey)
                                        
                                        Text(isTestingHotkey ? "Recording..." : "Press \(hotkeyDisplayName) to test")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(isTestingHotkey ? .red : .primary)
                                    }
                                    
                                    Text(isTestingHotkey ? "Press \(hotkeyDisplayName) again to stop" : "Your hotkey is working when you see the red indicator")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding(12)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isTestingHotkey ? Color.red.opacity(0.3) : Color.clear, lineWidth: 1)
                            )
                        }
                    }
                }
                
                // Behavior settings
                SettingsSection(title: "Behavior", icon: "gearshape.2") {
                    VStack(alignment: .leading, spacing: 16) {
                        Toggle(isOn: $launchAtLogin) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Launch at login")
                                    .font(.system(size: 13))
                                Text("Start WhisperKey automatically when you log in")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onChange(of: launchAtLogin) { newValue in
                            updateLaunchAtLogin(newValue)
                        }
                        
                        Divider()
                        
                        Toggle(isOn: $showRecordingIndicator) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Show recording indicator")
                                    .font(.system(size: 13))
                                Text("Display a floating window with timer during recording")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Toggle(isOn: $playFeedbackSounds) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Play feedback sounds")
                                    .font(.system(size: 13))
                                Text("Audio cues for start, stop, and completion")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Toggle(isOn: $alwaysSaveToClipboard) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Always save to clipboard")
                                    .font(.system(size: 13))
                                Text("Keep a backup copy in clipboard even when inserting at cursor")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // Quick tips
                SettingsSection(title: "Quick Tips", icon: "lightbulb") {
                    VStack(alignment: .leading, spacing: 12) {
                        Label {
                            Text("WhisperKey works in any text field across all apps")
                                .font(.caption)
                        } icon: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                        
                        Label {
                            Text("Press ESC anytime to cancel recording")
                                .font(.caption)
                        } icon: {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                        
                        Label {
                            Text("Your voice never leaves your Mac")
                                .font(.caption)
                        } icon: {
                            Image(systemName: "lock.circle.fill")
                                .foregroundColor(.purple)
                                .font(.caption)
                        }
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear {
            // Listen for recording state changes to update test indicator
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("RecordingStateChanged"),
                object: nil,
                queue: .main
            ) { notification in
                if let isRecording = notification.userInfo?["isRecording"] as? Bool {
                    isTestingHotkey = isRecording
                }
            }
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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SettingsSection(title: "Recording Behavior", icon: "mic") {
                    VStack(alignment: .leading, spacing: 16) {
                        // Auto-stop timing
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Auto-stop after silence")
                                Spacer()
                                Text("\(silenceDuration, specifier: "%.1f") seconds")
                                    .foregroundColor(.secondary)
                                    .monospacedDigit()
                            }
                            Slider(value: $silenceDuration, in: 1.0...5.0, step: 0.5)
                            Text("How long WhisperKey waits after you stop speaking before ending the recording")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        // Microphone sensitivity
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Microphone sensitivity")
                                Spacer()
                                Text(sensitivityDescription)
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: Binding(
                                get: { sensitivityToUserValue(silenceThreshold) },
                                set: { silenceThreshold = userValueToSensitivity($0) }
                            ), in: 1...5, step: 1)
                            HStack(spacing: 0) {
                                Image(systemName: "speaker.wave.1")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                                Image(systemName: "speaker.wave.3")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .padding(.top, 4)
                            Text(sensitivityHelp)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                SettingsSection(title: "Safety Limits", icon: "timer") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Maximum recording duration")
                            Spacer()
                            Text("\(Int(maxRecordingDuration)) seconds")
                                .foregroundColor(.secondary)
                                .monospacedDigit()
                        }
                        Slider(value: $maxRecordingDuration, in: 30...120, step: 10)
                        Text("Automatically stops recording after this time to prevent accidental recordings")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Tips section
                SettingsSection(title: "Recording Tips", icon: "lightbulb") {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Speak at a normal pace and volume", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        Label("WhisperKey adapts to your speaking patterns", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        Label("Adjust sensitivity if recording cuts off early", systemImage: "info.circle.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Label("Press ESC anytime to cancel recording", systemImage: "info.circle.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var sensitivityDescription: String {
        let value = sensitivityToUserValue(silenceThreshold)
        switch value {
        case 1: return "Very Sensitive"
        case 2: return "Sensitive"
        case 3: return "Normal"
        case 4: return "Less Sensitive"
        case 5: return "Least Sensitive"
        default: return "Normal"
        }
    }
    
    private var sensitivityHelp: String {
        let value = sensitivityToUserValue(silenceThreshold)
        switch value {
        case 1: return "Best for very quiet rooms with minimal background noise"
        case 2: return "Good for typical home offices with some ambient noise"
        case 3: return "Balanced for most environments (recommended)"
        case 4: return "Better for offices or spaces with background conversations"
        case 5: return "Use in cafes, open offices, or other noisy environments"
        default: return "Balanced for most environments"
        }
    }
    
    // Convert technical threshold (0.005-0.03) to user-friendly scale (1-5)
    private func sensitivityToUserValue(_ threshold: Double) -> Double {
        // Inverted: lower threshold = more sensitive = lower number on scale
        let normalized = (threshold - 0.005) / (0.03 - 0.005)
        return round(1 + normalized * 4)
    }
    
    // Convert user-friendly scale (1-5) to technical threshold
    private func userValueToSensitivity(_ userValue: Double) -> Double {
        let normalized = (userValue - 1) / 4
        return 0.005 + normalized * (0.03 - 0.005)
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