# F5 Dictation Key Interception Solutions

## The Problem
macOS handles the F5 dictation key at a system level, making it difficult to intercept with standard CGEventTap. The system processes this key before most applications can intercept it.

## Solution 1: Karabiner-Elements (Recommended)

This is the most reliable solution for intercepting F5 before the system handles it.

### Installation
```bash
brew install --cask karabiner-elements
```

### Configuration
1. Open Karabiner-Elements
2. Go to "Simple Modifications" tab
3. Add modification:
   - From key: `f5`
   - To key: `f13` (or any unused key)

### Integration with WhisperKey
Create a Karabiner complex modification JSON:

```json
{
  "title": "WhisperKey F5 Integration",
  "rules": [
    {
      "description": "Remap F5 dictation to trigger WhisperKey",
      "manipulators": [
        {
          "type": "basic",
          "from": {
            "key_code": "f5"
          },
          "to": [
            {
              "shell_command": "open -g whisperkey://start-dictation"
            }
          ]
        }
      ]
    }
  ]
}
```

Save this to: `~/.config/karabiner/assets/complex_modifications/whisperkey.json`

## Solution 2: Enhanced CGEventTap Implementation

Update KeyCaptureService.swift with better NSSystemDefined event handling:

```swift
// Enhanced event mask including NSSystemDefined
let eventMask = (1 << CGEventType.keyDown.rawValue) | 
               (1 << CGEventType.keyUp.rawValue) |
               (1 << CGEventType.flagsChanged.rawValue) |
               (1 << 14) // NSSystemDefined

// In the callback, handle NSSystemDefined events
if type.rawValue == 14 { // NSSystemDefined
    let nsEvent = NSEvent(cgEvent: event)
    
    if let nsEvent = nsEvent, nsEvent.subtype.rawValue == 8 {
        let keyCode = Int((nsEvent.data1 & 0xFFFF0000) >> 16)
        let keyState = Int((nsEvent.data1 & 0xFF00) >> 8)
        
        // F5 dictation key
        if keyCode == 0x00cf && keyState == 0x0A {
            // Process immediately to avoid timeout
            DispatchQueue.global(qos: .userInteractive).async {
                // Your dictation handling
            }
            return nil // Consume event
        }
    }
}
```

## Solution 3: System Settings + Alternative Shortcuts

### Disable System Dictation
```bash
# Disable dictation completely
defaults write com.apple.HIToolbox AppleDictationAutoEnable -int 0

# Remove F5 as dictation shortcut
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 162 "{enabled = 0;}"

# Restart cfprefsd to apply changes
killall cfprefsd
```

### Use Alternative Shortcuts
Add support for multiple shortcuts in WhisperKey:
- ⌘⇧D (Command+Shift+D)
- F13-F19 (less commonly used)
- Double-tap modifier keys

## Solution 4: IOKit HID Manager (Lower Level)

For more direct hardware access:

```swift
import IOKit.hid

class LowLevelF5Monitor {
    private var hidManager: IOHIDManager?
    
    func start() {
        hidManager = IOHIDManagerCreate(kCFAllocatorDefault, 0)
        
        // Match all keyboards
        let matchingDict = [
            kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop,
            kIOHIDDeviceUsageKey: kHIDUsage_GD_Keyboard
        ] as CFDictionary
        
        IOHIDManagerSetDeviceMatching(hidManager!, matchingDict)
        
        // Set input value callback
        IOHIDManagerRegisterInputValueCallback(hidManager!, { context, result, sender, value in
            let element = IOHIDValueGetElement(value)
            let usage = IOHIDElementGetUsage(element)
            let usagePage = IOHIDElementGetUsagePage(element)
            
            // Consumer Control Page (0x0C), Dictation (0xCF)
            if usagePage == 0x0C && usage == 0xCF {
                // Handle dictation key
                print("Dictation key intercepted at HID level")
            }
        }, nil)
        
        IOHIDManagerScheduleWithRunLoop(hidManager!, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
        IOHIDManagerOpen(hidManager!, 0)
    }
}
```

## Solution 5: Hybrid Approach (Most Robust)

1. Use Karabiner-Elements to remap F5 to a custom key (e.g., F13)
2. Use CGEventTap to monitor for F13
3. Provide fallback support for ⌘⇧D
4. Show clear setup instructions to users

## Recommended Implementation

For WhisperKey, I recommend:

1. **Primary**: Karabiner-Elements integration
   - Most reliable F5 interception
   - Works at kernel extension level
   - User-friendly configuration

2. **Fallback**: Enhanced CGEventTap with ⌘⇧D support
   - Works without additional software
   - Good for users who can't install Karabiner

3. **Setup Assistant**: First-run wizard that:
   - Checks if system dictation is enabled
   - Offers to install Karabiner configuration
   - Tests key interception
   - Provides alternative shortcut options

## Testing

Test your implementation with:
```bash
# Monitor all keyboard events
sudo fs_usage -w -f filesys | grep -i "keyboard"

# Check if Karabiner is intercepting
log stream --predicate 'process == "karabiner_grabber"'

# Test CGEventTap
log stream --predicate 'subsystem == "com.whisperkey"'
```

## References
- [Karabiner-Elements Documentation](https://karabiner-elements.pqrs.org/docs/)
- [CGEventTap Documentation](https://developer.apple.com/documentation/coregraphics/1454426-cgeventtapcreate)
- [IOKit HID Documentation](https://developer.apple.com/documentation/iokit)