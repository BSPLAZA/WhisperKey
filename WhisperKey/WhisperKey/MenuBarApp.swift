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
    
    init() {
        // Create shared dictation service and connect it immediately
        let service = DictationService.shared
        appDelegate.dictationService = service
    }
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView(dictationService: DictationService.shared)
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
    
    func showPreferences() {
        if let window = preferencesWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
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
    }
    
    func showOnboarding() {
        if let window = onboardingWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        
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
        window.styleMask = [.titled, .closable]
        window.setContentSize(NSSize(width: 500, height: 500))
        window.center()
        window.isReleasedWhenClosed = false
        
        onboardingWindow = window
        window.level = .floating
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
                Label("Grant Accessibility Permission", systemImage: "exclamationmark.triangle")
                    .foregroundColor(.orange)
                    .onTapGesture {
                        dictationService.requestAccessibilityPermission()
                    }
            }
            
            Divider()
            
            Button("Preferences...") {
                windowManager.showPreferences()
            }
            .keyboardShortcut(",", modifiers: .command)
            
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
            hotKey?.keyDownHandler = { [weak self] in
                self?.handleHotkeyPress()
            }
        }
    }
    
    private func setupRightOptionMonitoring() {
        // Check if we have accessibility permission
        if !AXIsProcessTrusted() {
            // Request permission
            let alert = NSAlert()
            alert.messageText = "Accessibility Permission Required"
            alert.informativeText = "WhisperKey needs accessibility permission to detect the Right Option key. Please grant permission in System Settings."
            alert.addButton(withTitle: "Open System Settings")
            alert.addButton(withTitle: "Cancel")
            
            if alert.runModal() == .alertFirstButtonReturn {
                dictationService?.requestAccessibilityPermission()
            }
            return
        }
        
        // Monitor for flags changed events globally
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleFlagsChanged(event)
        }
    }
    
    private func handleFlagsChanged(_ event: NSEvent) {
        // Check if option key is pressed and it's the right one (keyCode 61)
        if event.keyCode == 61 { // Right Option key code
            if event.modifierFlags.contains(.option) && !self.isRightOptionPressed {
                // Right Option pressed down
                self.isRightOptionPressed = true
                self.handleHotkeyPress()
            } else if !event.modifierFlags.contains(.option) && self.isRightOptionPressed {
                // Right Option released
                self.isRightOptionPressed = false
            }
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

