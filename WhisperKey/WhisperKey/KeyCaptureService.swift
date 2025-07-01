//
//  KeyCaptureService.swift
//  WhisperKey
//
//  Purpose: Monitor F5 key presses using CGEventTap
//  
//  Created by Orion on 2025-07-01.
//

import Cocoa
import Carbon

class KeyCaptureService: ObservableObject {
    @Published var isListening = false
    @Published var keyPressCount = 0
    
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    
    init() {
        requestAccessibilityPermission()
    }
    
    func requestAccessibilityPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        if accessEnabled {
            print("Accessibility permission granted")
        } else {
            print("Waiting for accessibility permission...")
            // Show current app bundle identifier for debugging
            print("App Bundle ID: \(Bundle.main.bundleIdentifier ?? "unknown")")
        }
    }
    
    func checkAccessibilityPermission() -> Bool {
        return AXIsProcessTrusted()
    }
    
    func startListening() {
        guard AXIsProcessTrusted() else {
            print("No accessibility permission")
            requestAccessibilityPermission()
            return
        }
        
        // Include NSSystemDefined events to catch F5 dictation key
        let eventMask = (1 << CGEventType.keyDown.rawValue) | 
                       (1 << CGEventType.keyUp.rawValue) |
                       (1 << 14) | // NSSystemDefined = 14
                       (1 << CGEventType.flagsChanged.rawValue)
        
        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else { return Unmanaged.passRetained(event) }
                
                let service = Unmanaged<KeyCaptureService>.fromOpaque(refcon).takeUnretainedValue()
                
                // Handle regular F5 key press
                if type == .keyDown {
                    let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
                    
                    // F5 key code
                    if keyCode == 0x60 {
                        print("F5 key down detected")
                        DispatchQueue.main.async {
                            service.keyPressCount += 1
                            service.handleF5Press()
                        }
                        // Consume the event to prevent system dictation
                        return nil
                    }
                }
                
                // Handle system-defined events (special keys like dictation)
                if type.rawValue == 14 { // NSSystemDefined
                    // For NSSystemDefined events, we need to check the subtype
                    let nsEvent = NSEvent(cgEvent: event)
                    
                    if let nsEvent = nsEvent {
                        // Check if this is a special system key event
                        if nsEvent.subtype.rawValue == 8 { // Special system keys
                            let keyCode = Int((nsEvent.data1 & 0xFFFF0000) >> 16)
                            let keyFlags = nsEvent.data1 & 0x0000FFFF
                            let keyState = (keyFlags & 0xFF00) >> 8
                            
                            // F5 dictation key code
                            if keyCode == 0x00cf {
                                print("F5 dictation key detected - state: \(keyState)")
                                if keyState == 0x0A { // Key down
                                    DispatchQueue.main.async {
                                        service.keyPressCount += 1
                                        service.handleF5Press()
                                    }
                                }
                                // Consume the event to prevent system dictation
                                return nil
                            }
                        }
                    }
                }
                
                return Unmanaged.passRetained(event)
            },
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        ) else {
            print("Failed to create event tap")
            return
        }
        
        self.eventTap = eventTap
        
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        
        self.runLoopSource = runLoopSource
        isListening = true
        
        print("Started listening for F5 key")
    }
    
    func stopListening() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }
        
        eventTap = nil
        runLoopSource = nil
        isListening = false
        
        print("Stopped listening")
    }
    
    private func handleF5Press() {
        // TODO: Start audio recording and transcription
        print("Handling F5 press - would start dictation here")
    }
    
    deinit {
        stopListening()
    }
}