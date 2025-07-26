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
    @AppStorage("whisperModel") private var whisperModel = "base.en"
    @AppStorage("silenceDuration") private var silenceDuration = 2.5
    @AppStorage("silenceThreshold") private var silenceThreshold = 0.015
    @AppStorage("launchAtLogin") private var launchAtLogin = true
    @AppStorage("showRecordingIndicator") private var showRecordingIndicator = true
    @AppStorage("playFeedbackSounds") private var playFeedbackSounds = true
    @AppStorage("alwaysSaveToClipboard") private var alwaysSaveToClipboard = false
    
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
            
            #if DEBUG
            DebugMenuView()
                .tabItem {
                    Label("Debug", systemImage: "ladybug")
                }
                .tag(4)
            #endif
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
    @AppStorage("launchAtLogin") private var launchAtLogin = true
    @AppStorage("showRecordingIndicator") private var showRecordingIndicator = true
    @AppStorage("playFeedbackSounds") private var playFeedbackSounds = true
    @AppStorage("alwaysSaveToClipboard") private var alwaysSaveToClipboard = false
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
                        .onChange(of: launchAtLogin) { _, newValue in
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
    @AppStorage("whisperModel") private var whisperModel = "base.en"
    @AppStorage("autoSelectModel") private var autoSelectModel = false
    @StateObject private var modelManager = ModelManager.shared
    
    private var modelDisplayName: String {
        switch whisperModel {
        case "tiny.en": return "Tiny (39 MB)"
        case "base.en": return "Base (141 MB)"
        case "small.en": return "Small (465 MB)"
        case "medium.en": return "Medium (1.4 GB)"
        case "large-v3": return "Large V3 (3.1 GB)"
        default: return whisperModel
        }
    }
    
    private var performanceLabel: String {
        switch whisperModel {
        case "tiny.en": return "Speed Mode"
        case "base.en": return "Balanced"
        case "small.en": return "Quality"
        case "medium.en": return "Accuracy"
        default: return "Custom"
        }
    }
    
    private var performanceColor: Color {
        switch whisperModel {
        case "tiny.en": return .green
        case "base.en": return .blue
        case "small.en": return .orange
        case "medium.en": return .red
        default: return .gray
        }
    }
    
    private var performanceDescription: String {
        switch whisperModel {
        case "tiny.en": return "~200ms response"
        case "base.en": return "~500ms response"
        case "small.en": return "~1s response"
        case "medium.en": return "~2s response"
        default: return "Variable response"
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Model Selection Section
                SettingsSection(title: "AI Models", icon: "cpu") {
                    VStack(alignment: .leading, spacing: 16) {
                        // Current model display with performance indicator
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Active Model")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(modelDisplayName)
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(.accentColor)
                                    .fontWeight(.medium)
                            }
                            Spacer()
                            
                            // Performance indicator
                            VStack(alignment: .trailing, spacing: 4) {
                                HStack(spacing: 4) {
                                    Image(systemName: "speedometer")
                                        .font(.caption)
                                        .foregroundColor(performanceColor)
                                    Text(performanceLabel)
                                        .font(.caption)
                                        .foregroundColor(performanceColor)
                                }
                                Text(performanceDescription)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(12)
                        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                        .cornerRadius(8)
                        
                        // Model selection list
                        VStack(spacing: 8) {
                            ForEach(modelManager.availableModels, id: \.filename) { model in
                                ModelDownloadRow(model: model)
                            }
                        }
                    }
                }
                
                // Model Features Section
                SettingsSection(title: "Model Information", icon: "info.circle") {
                    VStack(alignment: .leading, spacing: 12) {
                        // Model descriptions
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Tiny: Ultra-fast, good for quick notes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("• Base: Fast with decent accuracy")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("• Small: Balanced speed and quality")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("• Medium: Best accuracy, slower")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        // Model location
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Model Storage Location", systemImage: "folder")
                                .font(.caption)
                                .fontWeight(.medium)
                            Text(WhisperService.shared.modelsPath ?? "~/.whisperkey/models")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .textSelection(.enabled)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                                .cornerRadius(4)
                        }
                    }
                }
                
                // Advanced Options Section
                SettingsSection(title: "Advanced Options", icon: "gearshape.2") {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $autoSelectModel) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Auto-select optimal model")
                                Text("Let WhisperKey choose based on your hardware")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .disabled(true)
                        .opacity(0.6)
                        
                        HStack {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text("Coming in a future update")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer(minLength: 20)
            }
            .padding(20)
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
    @State private var testingAudio = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Audio Test Section
                SettingsSection(title: "Audio Testing", icon: "speaker.wave.3") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Test if system sounds are working properly")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Button(action: {
                                testingAudio = true
                                Task {
                                    await testAudioSounds()
                                    testingAudio = false
                                }
                            }) {
                                Label(testingAudio ? "Testing..." : "Test Audio Feedback", systemImage: "play.circle")
                            }
                            .disabled(testingAudio)
                            
                            if testingAudio {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .padding(.leading, 8)
                            }
                        }
                        
                        Text("You should hear several beeps if audio is working")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Clean temporary files
                SettingsSection(title: "Maintenance", icon: "trash") {
                    VStack(alignment: .leading, spacing: 12) {
                        Button("Clean Temporary Files") {
                            DictationService.cleanupAllTempFiles()
                            showCleanupSuccess()
                        }
                        Text("Remove all temporary audio recordings")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Debug & Troubleshooting - available to all users
                SettingsSection(title: "Debug & Troubleshooting", icon: "ladybug") {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Enable debug logging", isOn: $debugMode)
                            .help("Shows detailed logs for troubleshooting")
                        
                        Text("Debug logs help diagnose issues when something goes wrong")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Divider()
                        
                        Button("Export Debug Info") {
                            exportDebugInfo()
                        }
                        .help("Export system and app configuration for troubleshooting")
                        
                        Text("Creates a text file with diagnostic information")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                #if DEBUG
                // Developer Tools - only in debug builds
                SettingsSection(title: "Developer Tools", icon: "hammer") {
                    VStack(alignment: .leading, spacing: 12) {
                        // Path Information
                        VStack(alignment: .leading, spacing: 4) {
                            if let whisperPath = WhisperService.shared.whisperPath {
                                HStack {
                                    Text("Whisper binary:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(whisperPath)
                                        .font(.caption.monospaced())
                                        .textSelection(.enabled)
                                }
                            }
                            
                            if let modelsPath = WhisperService.shared.modelsPath {
                                HStack {
                                    Text("Models path:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(modelsPath)
                                        .font(.caption.monospaced())
                                        .textSelection(.enabled)
                                }
                            }
                        }
                        
                        Button("Test Transcription") {
                            testTranscription()
                        }
                        .help("Record a 3-second test and show detailed debug output")
                        .controlSize(.small)
                    }
                }
                #endif
                
                // Reset settings - available in production
                SettingsSection(title: "Reset", icon: "arrow.counterclockwise") {
                    VStack(alignment: .leading, spacing: 12) {
                        Button("Reset All Settings") {
                            showingResetAlert = true
                        }
                        .foregroundColor(.red)
                        Text("Restore all settings to defaults")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Version info
                VStack(spacing: 4) {
                    Text("WhisperKey \(appVersion)")
                        .font(.caption)
                    Text("Privacy-focused local dictation")
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
                WhisperService.shared.checkAvailability()
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
                WhisperService.shared.checkAvailability()
            }
        }
    }
    
    private func testTranscription() {
        let alert = NSAlert()
        alert.messageText = "Test Transcription"
        alert.informativeText = "This will record 3 seconds of audio and transcribe it with detailed debug output.\n\nClick 'Start Test' and speak clearly."
        alert.addButton(withTitle: "Start Test")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            // Record 3 seconds of test audio
            Task { @MainActor in
                DictationService.shared.startRecording()
                
                // Stop after 3 seconds
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                DictationService.shared.stopRecording()
                
                // Show debug log after a delay
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                showDebugOutput()
            }
        }
    }
    
    private func openDebugLog() {
        let logPath = "/tmp/whisperkey_debug.log"
        if FileManager.default.fileExists(atPath: logPath) {
            NSWorkspace.shared.open(URL(fileURLWithPath: logPath))
        } else {
            let alert = NSAlert()
            alert.messageText = "Debug Log Not Found"
            alert.informativeText = "The debug log file doesn't exist yet. Try recording something first."
            alert.alertStyle = .informational
            alert.runModal()
        }
    }
    
    private func exportDebugInfo() {
        var debugInfo = "WhisperKey Debug Information\n"
        debugInfo += "Generated: \(Date())\n"
        debugInfo += "========================\n\n"
        
        debugInfo += "App Version: \(appVersion)\n"
        debugInfo += "macOS Version: \(ProcessInfo.processInfo.operatingSystemVersionString)\n"
        debugInfo += "Architecture: \(getArchitecture())\n\n"
        
        debugInfo += "Whisper Configuration:\n"
        debugInfo += "Whisper Path: \(WhisperService.shared.whisperPath ?? "Not found")\n"
        debugInfo += "Models Path: \(WhisperService.shared.modelsPath ?? "Not found")\n"
        debugInfo += "Selected Model: \(UserDefaults.standard.string(forKey: "whisperModel") ?? "small.en")\n\n"
        
        debugInfo += "Settings:\n"
        debugInfo += "Hotkey: \(UserDefaults.standard.string(forKey: "selectedHotkey") ?? "right_option")\n"
        debugInfo += "Play Feedback Sounds: \(UserDefaults.standard.bool(forKey: "playFeedbackSounds"))\n"
        debugInfo += "Always Save to Clipboard: \(UserDefaults.standard.bool(forKey: "alwaysSaveToClipboard"))\n"
        debugInfo += "Silence Duration: \(UserDefaults.standard.double(forKey: "silenceDuration"))\n"
        debugInfo += "Silence Threshold: \(UserDefaults.standard.double(forKey: "silenceThreshold"))\n\n"
        
        // Add recent debug log
        if let logData = try? String(contentsOfFile: "/tmp/whisperkey_debug.log", encoding: .utf8) {
            debugInfo += "Recent Debug Log (last 1000 chars):\n"
            debugInfo += "========================\n"
            debugInfo += String(logData.suffix(1000))
        }
        
        // Save to file
        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = "WhisperKey-Debug-\(Date().ISO8601Format()).txt"
        
        // Make save panel a child of the preferences window to ensure proper ordering
        if let window = NSApp.keyWindow {
            savePanel.beginSheetModal(for: window) { response in
                if response == .OK, let url = savePanel.url {
                    try? debugInfo.write(to: url, atomically: true, encoding: .utf8)
                }
            }
        } else {
            // Fallback to standard modal
            savePanel.begin { response in
                if response == .OK, let url = savePanel.url {
                    try? debugInfo.write(to: url, atomically: true, encoding: .utf8)
                }
            }
        }
    }
    
    private func showDebugOutput() {
        if let logData = try? String(contentsOfFile: "/tmp/whisperkey_debug.log", encoding: .utf8) {
            let alert = NSAlert()
            alert.messageText = "Test Transcription Debug Output"
            alert.informativeText = String(logData.suffix(1000))
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Copy to Clipboard")
            
            if alert.runModal() == .alertSecondButtonReturn {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(logData, forType: .string)
            }
        }
    }
    
    private func getArchitecture() -> String {
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }
    
    private func testAudioSounds() async {
        await MainActor.run {
            DebugHelper.shared.testSystemSounds()
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