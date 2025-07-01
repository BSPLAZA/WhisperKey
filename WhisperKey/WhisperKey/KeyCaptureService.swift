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
        }
    }
    
    func startListening() {
        guard AXIsProcessTrusted() else {
            print("No accessibility permission")
            requestAccessibilityPermission()
            return
        }
        
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)
        
        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else { return Unmanaged.passRetained(event) }
                
                let service = Unmanaged<KeyCaptureService>.fromOpaque(refcon).takeUnretainedValue()
                
                if type == .keyDown {
                    let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
                    
                    // F5 key code
                    if keyCode == 0x60 {
                        print("F5 pressed!")
                        DispatchQueue.main.async {
                            service.keyPressCount += 1
                            service.handleF5Press()
                        }
                        // Consume the event
                        return nil
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