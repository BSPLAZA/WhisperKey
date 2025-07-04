//
//  MenuBarApp.swift
//  WhisperKey
//
//  Purpose: Menu bar app with configurable global hotkeys using HotKey library
//  
//  Created by Orion on 2025-07-01.
//

import SwiftUI
import HotKey
import Carbon
import UserNotifications

@main
struct WhisperKeyMenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var dictationService = DictationService()
    
    init() {
        // Connection will be set up in onAppear
    }
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView(dictationService: dictationService)
                .onAppear {
                    // Ensure the dictation service is connected to AppDelegate (backup)
                    print("WhisperKeyMenuBarApp: onAppear called")
                    if let delegate = NSApplication.shared.delegate as? AppDelegate {
                        delegate.dictationService = dictationService
                        print("WhisperKeyMenuBarApp: Connected dictationService to AppDelegate in onAppear")
                        print("WhisperKeyMenuBarApp: DictationService reference: \(dictationService)")
                        // Trigger hotkey update again to ensure it's working
                        delegate.updateHotkey()
                    } else {
                        print("WhisperKeyMenuBarApp: Failed to get AppDelegate!")
                    }
                }
        } label: {
            if dictationService.isRecording {
                Image(systemName: "mic.fill")
                    .foregroundStyle(.red)
            } else if dictationService.transcriptionStatus.contains("Processing") {
                Image(systemName: "waveform")
                    .foregroundStyle(.blue)
            } else {
                Image(systemName: "mic")
                    .foregroundStyle(.primary)
            }
        }
        .menuBarExtraStyle(.menu)
    }
}

class WindowManager: ObservableObject {
    static let shared = WindowManager()
    
    private var preferencesWindow: NSWindow?
    private var onboardingWindow: NSWindow?
    
    private init() {
        print("WindowManager: Initialized")
    }
    
    func showPreferences() {
        print("WindowManager: showPreferences called")
        
        if let window = preferencesWindow, window.isVisible {
            print("WindowManager: Preferences window already visible, bringing to front")
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        print("WindowManager: Creating new preferences window")
        let preferencesView = PreferencesView()
        let hostingController = NSHostingController(rootView: preferencesView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "WhisperKey Preferences"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.setContentSize(NSSize(width: 500, height: 400))
        window.center()
        window.isReleasedWhenClosed = false
        
        preferencesWindow = window
        window.makeKeyAndOrderFront(nil)
        window.level = .floating
        NSApp.activate(ignoringOtherApps: true)
        
        print("WindowManager: Preferences window should be visible now")
    }
    
    func showOnboarding() {
        print("WindowManager: showOnboarding called")
        
        if let window = onboardingWindow, window.isVisible {
            print("WindowManager: Onboarding window already visible, bringing to front")
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        print("WindowManager: Creating new onboarding window")
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        
        let onboardingView = OnboardingView(showOnboarding: .init(
            get: { self.onboardingWindow != nil },
            set: { show in
                if !show {
                    print("WindowManager: Closing onboarding window")
                    self.onboardingWindow?.close()
                    self.onboardingWindow = nil
                }
            }
        ))
        let hostingController = NSHostingController(rootView: onboardingView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Welcome to WhisperKey"
        window.styleMask = [.titled, .closable]
        window.setContentSize(NSSize(width: 500, height: 500))
        window.center()
        window.isReleasedWhenClosed = false
        
        onboardingWindow = window
        window.level = .floating
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        print("WindowManager: Onboarding window should be visible now")
    }
}

struct MenuBarContentView: View {
    @ObservedObject var dictationService: DictationService
    @AppStorage("selectedHotkey") private var selectedHotkey = "right_option"
    @StateObject private var windowManager = WindowManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if dictationService.isRecording {
                Label("Recording... Speak now!", systemImage: "mic.fill")
                    .foregroundColor(.red)
                
                Text(dictationService.transcriptionStatus)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button("Stop Recording") {
                    dictationService.stopRecording()
                }
                .keyboardShortcut(.escape, modifiers: [])
            } else {
                Label("WhisperKey", systemImage: "mic")
                    .font(.headline)
                
                Button("Start Recording") {
                    dictationService.startRecording()
                }
                .keyboardShortcut(.return, modifiers: [])
            }
            
            Divider()
            
            Menu("Hotkey: \(hotkeyDisplayName)") {
                Button(selectedHotkey == "right_option" ? "✓ Right Option ⌥ (Default)" : "Right Option ⌥ (Default)") {
                    selectedHotkey = "right_option"
                    if let delegate = NSApplication.shared.delegate as? AppDelegate {
                        delegate.updateHotkey()
                    }
                }
                
                Button(selectedHotkey == "caps_lock" ? "✓ Caps Lock" : "Caps Lock") {
                    selectedHotkey = "caps_lock"
                    if let delegate = NSApplication.shared.delegate as? AppDelegate {
                        delegate.updateHotkey()
                    }
                }
                
                Divider()
                
                Button(selectedHotkey == "cmd_shift_space" ? "✓ ⌘⇧Space" : "⌘⇧Space") {
                    selectedHotkey = "cmd_shift_space"
                    if let delegate = NSApplication.shared.delegate as? AppDelegate {
                        delegate.updateHotkey()
                    }
                }
                
                Button(selectedHotkey == "f13" ? "✓ F13" : "F13") {
                    selectedHotkey = "f13"
                    if let delegate = NSApplication.shared.delegate as? AppDelegate {
                        delegate.updateHotkey()
                    }
                }
                
                Button(selectedHotkey == "f14" ? "✓ F14" : "F14") {
                    selectedHotkey = "f14"
                    if let delegate = NSApplication.shared.delegate as? AppDelegate {
                        delegate.updateHotkey()
                    }
                }
                
                Button(selectedHotkey == "f15" ? "✓ F15" : "F15") {
                    selectedHotkey = "f15"
                    if let delegate = NSApplication.shared.delegate as? AppDelegate {
                        delegate.updateHotkey()
                    }
                }
            }
            
            Divider()
            
            if !dictationService.hasAccessibilityPermission {
                Label("Need Accessibility Permission", systemImage: "exclamationmark.triangle")
                    .foregroundColor(.orange)
                
                Button("Grant Permission...") {
                    dictationService.requestAccessibilityPermission()
                }
            }
            
            Menu("Settings") {
                Menu("Whisper Model: \(currentModelName)") {
                    Button("✓ Base (Fast)".replacingOccurrences(of: "✓ ", with: currentModel == "base.en" ? "✓ " : "")) {
                        UserDefaults.standard.set("base.en", forKey: "whisperModel")
                        dictationService.updateModel()
                    }
                    
                    Button("✓ Small (Balanced)".replacingOccurrences(of: "✓ ", with: currentModel == "small.en" ? "✓ " : "")) {
                        UserDefaults.standard.set("small.en", forKey: "whisperModel")
                        dictationService.updateModel()
                    }
                    
                    Button("✓ Medium (Quality)".replacingOccurrences(of: "✓ ", with: currentModel == "medium.en" ? "✓ " : "")) {
                        UserDefaults.standard.set("medium.en", forKey: "whisperModel")
                        dictationService.updateModel()
                    }
                    
                    if FileManager.default.fileExists(atPath: NSString(string: "~/Developer/whisper.cpp/models/ggml-large-v3-turbo.bin").expandingTildeInPath) {
                        Button("✓ Large Turbo (Best)".replacingOccurrences(of: "✓ ", with: currentModel == "large-v3-turbo" ? "✓ " : "")) {
                            UserDefaults.standard.set("large-v3-turbo", forKey: "whisperModel")
                            dictationService.updateModel()
                        }
                    }
                }
                
            }
            
            Divider()
            
            Button("Preferences...") {
                print("MenuBarContentView: Preferences clicked")
                windowManager.showPreferences()
            }
            .keyboardShortcut(",", modifiers: .command)
            
            #if DEBUG
            Divider()
            
            Button("Show Onboarding") {
                print("MenuBarContentView: Show Onboarding clicked")
                windowManager.showOnboarding()
            }
            
            Button("Test Recording") {
                print("Test Recording button clicked")
                dictationService.startRecording()
            }
            
            Button("Check Permissions") {
                let accessibilityPermission = AXIsProcessTrusted()
                print("Accessibility: \(accessibilityPermission)")
                dictationService.checkPermissions()
            }
            
            Button("Test Hotkey") {
                print("MenuBarContentView: Testing hotkey setup")
                if let delegate = NSApplication.shared.delegate as? AppDelegate {
                    print("Found AppDelegate, calling updateHotkey")
                    delegate.updateHotkey()
                } else {
                    print("Could not find AppDelegate!")
                }
            }
            #endif
            
            Divider()
            
            Button("Quit WhisperKey") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
        .padding(.vertical, 5)
    }
    
    var hotkeyDisplayName: String {
        switch selectedHotkey {
        case "right_option": return "Right ⌥"
        case "caps_lock": return "Caps Lock"
        case "cmd_shift_space": return "⌘⇧Space"
        case "f13": return "F13"
        case "f14": return "F14"
        case "f15": return "F15"
        default: return "Right ⌥"
        }
    }
    
    var appDelegate: AppDelegate? {
        NSApplication.shared.delegate as? AppDelegate
    }
    
    var currentModel: String {
        UserDefaults.standard.string(forKey: "whisperModel") ?? "small.en"
    }
    
    var currentModelName: String {
        switch currentModel {
        case "base.en": return "Base"
        case "small.en": return "Small"
        case "medium.en": return "Medium"
        case "large-v3-turbo": return "Large Turbo"
        default: return "Small"
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var hotKey: HotKey?
    var dictationService: DictationService?
    private var lastCommandPressTime: TimeInterval = 0
    private var commandPressTimer: Timer?
    private var eventMonitor: Any?
    private var isRightOptionPressed = false
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Remove from dock
        NSApp.setActivationPolicy(.accessory)
        
        // Check if onboarding is needed
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if !hasCompletedOnboarding {
            showOnboarding()
        }
        
        // Set default to right_option if no preference exists
        if UserDefaults.standard.string(forKey: "selectedHotkey") == nil {
            UserDefaults.standard.set("right_option", forKey: "selectedHotkey")
        }
        
        // Set up hotkey with a small delay to ensure everything is initialized
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.updateHotkey()
        }
        
        // Clean up any leftover temp files from previous sessions
        DictationService.cleanupAllTempFiles()
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            }
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Clean up temp files on exit
        DictationService.cleanupAllTempFiles()
    }
    
    func updateHotkey() {
        // Clear existing hotkey and event monitor
        hotKey = nil
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        
        let selectedHotkey = UserDefaults.standard.string(forKey: "selectedHotkey") ?? "right_option"
        print("AppDelegate: Setting up hotkey: \(selectedHotkey)")
        
        switch selectedHotkey {
        case "right_option":
            // Use NSEvent monitoring for Right Option since HotKey doesn't support it
            setupRightOptionMonitoring()
            
        case "caps_lock":
            hotKey = HotKey(key: .capsLock, modifiers: [])
            
        case "cmd_shift_space":
            hotKey = HotKey(key: .space, modifiers: [.command, .shift])
            
        case "f13":
            hotKey = HotKey(key: .f13, modifiers: [])
            
        case "f14":
            hotKey = HotKey(key: .f14, modifiers: [])
            
        case "f15":
            hotKey = HotKey(key: .f15, modifiers: [])
            
        default:
            hotKey = HotKey(key: .space, modifiers: [.command, .shift])
        }
        
        if hotKey != nil {
            print("AppDelegate: HotKey created successfully")
            hotKey?.keyDownHandler = { [weak self] in
                self?.handleHotkeyPress()
            }
        }
    }
    
    private func setupRightOptionMonitoring() {
        print("AppDelegate: Setting up Right Option monitoring via NSEvent")
        
        // First check if we have accessibility permission
        if !AXIsProcessTrusted() {
            print("AppDelegate: No accessibility permission for global monitoring")
            // Try local monitoring as fallback
            eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
                self?.handleFlagsChanged(event)
                return event
            }
            print("AppDelegate: Using local event monitoring (limited to app windows)")
        } else {
            // Monitor for flags changed events globally
            eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
                self?.handleFlagsChanged(event)
            }
            print("AppDelegate: Global event monitoring active")
        }
        
        if eventMonitor != nil {
            print("AppDelegate: Right Option monitoring active")
        } else {
            print("AppDelegate: Failed to set up Right Option monitoring")
        }
    }
    
    private func handleFlagsChanged(_ event: NSEvent) {
        // Check if option key is pressed and it's the right one (keyCode 61)
        if event.keyCode == 61 { // Right Option key code
            if event.modifierFlags.contains(.option) && !self.isRightOptionPressed {
                // Right Option pressed down
                self.isRightOptionPressed = true
                print("AppDelegate: Right Option pressed")
                self.handleHotkeyPress()
            } else if !event.modifierFlags.contains(.option) && self.isRightOptionPressed {
                // Right Option released
                self.isRightOptionPressed = false
                print("AppDelegate: Right Option released")
                // If you want to stop recording on release, uncomment:
                // self.handleHotkeyPress()
            }
        }
    }
    
    
    func handleHotkeyPress() {
        print("AppDelegate: Hotkey pressed!")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { 
                print("AppDelegate: Self is nil in hotkey handler")
                return 
            }
            
            if self.dictationService == nil {
                print("AppDelegate: No dictation service! Trying to find it...")
                // Try to get the dictation service from the app
                if let app = NSApp.delegate as? AppDelegate {
                    self.dictationService = app.dictationService
                    print("AppDelegate: Found dictation service from app delegate: \(self.dictationService != nil)")
                }
            }
            
            guard let dictationService = self.dictationService else {
                print("AppDelegate: Still no dictation service!")
                
                // Show alert to user
                let alert = NSAlert()
                alert.messageText = "WhisperKey Error"
                alert.informativeText = "Unable to start recording. Please restart WhisperKey."
                alert.alertStyle = .warning
                alert.runModal()
                return
            }
            
            if dictationService.isRecording {
                print("AppDelegate: Stopping recording...")
                dictationService.stopRecording()
            } else {
                print("AppDelegate: Starting recording...")
                dictationService.startRecording()
            }
        }
    }
    
    func showPreferences() {
        print("AppDelegate: showPreferences called")
        WindowManager.shared.showPreferences()
    }
    
    func showOnboarding() {
        print("AppDelegate: showOnboarding called")
        WindowManager.shared.showOnboarding()
    }
}

