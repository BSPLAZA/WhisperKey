//
//  MenuBarApp.swift
//  WhisperKey
//
//  Purpose: Menu bar app with configurable global hotkeys using HotKey library
//  
//  Created by Author on 2025-07-01.
//

import SwiftUI
import HotKey
import Carbon
import UserNotifications

@main
struct WhisperKeyMenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Connection will be established in applicationDidFinishLaunching
    }
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView(dictationService: DictationService.shared)
        } label: {
            if DictationService.shared.isRecording {
                Image(systemName: "mic.fill")
                    .foregroundStyle(.red)
            } else if DictationService.shared.transcriptionStatus.contains("Processing") {
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
    private var permissionWindow: NSWindow?
    
    func showPreferences(tab: Int = 0) {
        // Store the requested tab
        UserDefaults.standard.set(tab, forKey: "preferencesRequestedTab")
        
        if let window = preferencesWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let preferencesView = PreferencesView()
        let hostingController = NSHostingController(rootView: preferencesView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "WhisperKey Settings"
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.setContentSize(NSSize(width: 600, height: 500))
        window.center()
        window.isReleasedWhenClosed = false
        
        preferencesWindow = window
        window.makeKeyAndOrderFront(nil)
        window.level = .floating
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func showOnboarding() {
        if let window = onboardingWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        // Don't reset the completion flag - this was causing onboarding to show repeatedly!
        
        let onboardingView = OnboardingView(showOnboarding: .init(
            get: { self.onboardingWindow != nil },
            set: { show in
                if !show {
                    self.onboardingWindow?.close()
                    self.onboardingWindow = nil
                }
            }
        ))
        let hostingController = NSHostingController(rootView: onboardingView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Welcome to WhisperKey"
        window.styleMask = [.titled, .closable, .resizable]
        window.setContentSize(NSSize(width: 700, height: 700))
        window.center()
        window.isReleasedWhenClosed = false
        
        onboardingWindow = window
        window.level = .floating
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func showPermissionGuide() {
        if let window = permissionWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let permissionView = PermissionGuideView(dismiss: {
            self.permissionWindow?.close()
            self.permissionWindow = nil
        })
        let hostingController = NSHostingController(rootView: permissionView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Fix WhisperKey Permissions"
        window.styleMask = [.titled, .closable]
        window.setContentSize(NSSize(width: 500, height: 600)) // Increased height
        window.center()
        window.isReleasedWhenClosed = false
        
        permissionWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
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
            
            HStack {
                Text("Hotkey:")
                    .foregroundColor(.secondary)
                Text(hotkeyDisplayName)
                    .fontWeight(.medium)
            }
            .font(.caption)
            
            Divider()
            
            if !dictationService.hasAccessibilityPermission {
                Button(action: {
                    let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
                    _ = AXIsProcessTrustedWithOptions(options)
                }) {
                    Label("Grant Accessibility Permission", systemImage: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                }
                .help("Click to open System Settings")
            }
            
            Divider()
            
            Button("Settings...") {
                windowManager.showPreferences()
            }
            .keyboardShortcut(",", modifiers: .command)
            
            Button("Show Onboarding") {
                windowManager.showOnboarding()
            }
            
            Divider()
            
            Menu("Help") {
                Button("Fix Permissions...") {
                    showPermissionGuide()
                }
                
                Divider()
                
                Button("About WhisperKey") {
                    showAboutWindow()
                }
            }
            
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
        case "f13": return "F13"
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
    
    func showPermissionGuide() {
        WindowManager.shared.showPermissionGuide()
    }
    
    func showAboutWindow() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        
        let alert = NSAlert()
        alert.messageText = "WhisperKey"
        alert.informativeText = """
        Version \(version) (Build \(buildNumber))
        
        Privacy-focused local dictation for macOS
        
        • All processing happens locally
        • No data leaves your device
        • Powered by OpenAI's Whisper
        
        Open Source • MIT License
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var hotKey: HotKey?
    var dictationService: DictationService?
    private var lastCommandPressTime: TimeInterval = 0
    private var commandPressTimer: Timer?
    var eventMonitor: Any?
    private var isRightOptionPressed = false
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Remove from dock
        NSApp.setActivationPolicy(.accessory)
        
        // Connect dictation service
        dictationService = DictationService.shared
        
        // Register default values for all settings
        let defaults: [String: Any] = [
            "selectedHotkey": "right_option",
            "alwaysSaveToClipboard": false,
            "playFeedbackSounds": true,
            "showRecordingIndicator": true,
            "launchAtLogin": true,
            "whisperModel": "base.en",
            "silenceDuration": 2.5,
            "silenceThreshold": 0.015
        ]
        UserDefaults.standard.register(defaults: defaults)
        
        // Log current settings
        NSLog("=== WHISPERKEY: Current settings ===")
        NSLog("Hotkey: \(UserDefaults.standard.string(forKey: "selectedHotkey") ?? "nil")")
        NSLog("Play Feedback Sounds: \(UserDefaults.standard.bool(forKey: "playFeedbackSounds"))")
        NSLog("Always Save to Clipboard: \(UserDefaults.standard.bool(forKey: "alwaysSaveToClipboard"))")
        
        let currentHotkey = UserDefaults.standard.string(forKey: "selectedHotkey") ?? "right_option"
        NSLog("=== WHISPERKEY: Current hotkey preference: \(currentHotkey) ===")
        DictationService.shared.debugLog("Current hotkey preference: \(currentHotkey)")
        
        // Set up hotkey IMMEDIATELY, not after delay
        NSLog("=== WHISPERKEY: Setting up hotkey immediately ===")
        updateHotkey()
        
        // Check if onboarding is needed AFTER hotkey setup
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if !hasCompletedOnboarding {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.showOnboarding()
            }
        }
        
        // Clean up any leftover temp files from previous sessions
        DictationService.cleanupAllTempFiles()
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            // Permission handled
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
        NSLog("=== WHISPERKEY: updateHotkey() called, selectedHotkey: \(selectedHotkey) ===")
        
        switch selectedHotkey {
        case "right_option":
            // Use NSEvent monitoring for Right Option since HotKey doesn't support it
            NSLog("=== WHISPERKEY: Setting up Right Option monitoring ===")
            setupRightOptionMonitoring()
            
        case "f13":
            hotKey = HotKey(key: .f13, modifiers: [])
            
        default:
            // Default to right option
            NSLog("=== WHISPERKEY: Unknown hotkey, defaulting to Right Option ===")
            setupRightOptionMonitoring()
        }
        
        if hotKey != nil {
            hotKey?.keyDownHandler = { [weak self] in
                self?.handleHotkeyPress()
            }
        }
    }
    
    private func setupRightOptionMonitoring() {
        NSLog("AppDelegate: Setting up Right Option monitoring via NSEvent")
        
        // Monitor for flags changed events - EXACTLY like the working version
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            guard let self = self else { return }
            
            // Log the event for debugging
            if event.keyCode == KeyCode.rightOption {
                NSLog("AppDelegate: Right Option event - keyCode: \(KeyCode.rightOption), modifiers: \(event.modifierFlags.rawValue)")
            }
            
            // Check if option key is pressed and it's the right one
            if event.keyCode == KeyCode.rightOption {
                if event.modifierFlags.contains(.option) && !self.isRightOptionPressed {
                    // Right Option pressed down - TOGGLE recording
                    self.isRightOptionPressed = true
                    NSLog("AppDelegate: Right Option pressed - toggling recording")
                    self.handleHotkeyPress()
                } else if !event.modifierFlags.contains(.option) && self.isRightOptionPressed {
                    // Right Option released - just reset state
                    self.isRightOptionPressed = false
                    NSLog("AppDelegate: Right Option released")
                }
            }
        }
        
        if eventMonitor != nil {
            NSLog("AppDelegate: Right Option monitoring active")
        } else {
            NSLog("AppDelegate: Failed to set up Right Option monitoring - check Accessibility permission")
        }
    }
    
    
    
    func handleHotkeyPress() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let dictationService = self.dictationService else { return }
            
            if dictationService.isRecording {
                dictationService.stopRecording()
            } else {
                dictationService.startRecording()
            }
        }
    }
    
    func showPreferences() {
        WindowManager.shared.showPreferences()
    }
    
    
    func showOnboarding() {
        WindowManager.shared.showOnboarding()
    }
}

