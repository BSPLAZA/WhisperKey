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
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView(dictationService: dictationService)
                .onAppear {
                    appDelegate.dictationService = dictationService
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

struct MenuBarContentView: View {
    @ObservedObject var dictationService: DictationService
    @AppStorage("selectedHotkey") private var selectedHotkey = "right_option"
    
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
                Button("Right Option ⌥ (Default)") {
                    selectedHotkey = "right_option"
                    appDelegate?.updateHotkey()
                }
                
                Button("Caps Lock") {
                    selectedHotkey = "caps_lock"
                    appDelegate?.updateHotkey()
                }
                
                Divider()
                
                Button("⌘⇧Space") {
                    selectedHotkey = "cmd_shift_space"
                    appDelegate?.updateHotkey()
                }
                
                Button("F13") {
                    selectedHotkey = "f13"
                    appDelegate?.updateHotkey()
                }
                
                Button("F14") {
                    selectedHotkey = "f14"
                    appDelegate?.updateHotkey()
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
            
            Button("Preferences...") {
                appDelegate?.showPreferences()
            }
            .keyboardShortcut(",", modifiers: .command)
            
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
        default: return "Right ⌥"
        }
    }
    
    var appDelegate: AppDelegate? {
        NSApp.delegate as? AppDelegate
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
    private var preferencesWindow: PreferencesWindowController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Remove from dock
        NSApp.setActivationPolicy(.accessory)
        
        // Set default to right_option if no preference exists
        if UserDefaults.standard.string(forKey: "selectedHotkey") == nil {
            UserDefaults.standard.set("right_option", forKey: "selectedHotkey")
        }
        
        // Set up hotkey
        updateHotkey()
        
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
        
        // Monitor for flags changed events
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            guard let self = self else { return }
            
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
        
        if eventMonitor != nil {
            print("AppDelegate: Right Option monitoring active")
        } else {
            print("AppDelegate: Failed to set up Right Option monitoring - check Accessibility permission")
        }
    }
    
    
    func handleHotkeyPress() {
        print("AppDelegate: Hotkey pressed!")
        DispatchQueue.main.async { [weak self] in
            guard let dictationService = self?.dictationService else {
                print("AppDelegate: No dictation service!")
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
        if preferencesWindow == nil {
            preferencesWindow = PreferencesWindowController()
        }
        preferencesWindow?.showWindow(nil)
    }
}

