# WhisperKey Quick Reference

> Keep this open while developing - Updated 2025-07-02

## Current Status
- **Phase**: Testing & Polish  
- **Version**: 0.9.0 (Pre-release)
- **Status**: MVP Complete, polishing for release
- **Remaining**: 10 tasks (8 testing, 2 features)

## Key Commands

### Build & Run
```bash
# Open project in Xcode
open /Users/orion/Omni/WhisperKey/WhisperKey/WhisperKey.xcodeproj

# Build: ⌘B
# Run: ⌘R
# Clean: ⌘⇧K

# Build whisper.cpp
cd ~/Developer/whisper.cpp
WHISPER_METAL=1 make -j

# Test whisper
./build/bin/whisper-cli -m models/ggml-base.en.bin -f samples/jfk.wav
```

### Testing
```bash
# Reset permissions for testing
tccutil reset All com.whisperkey.WhisperKey

# Monitor secure input state
ioreg -l | grep SecureInput

# Check for temp files
ls -la /var/folders/*/T/whisperkey_*
```

### Documentation Updates
```bash
cd scripts
./update-timeline.sh "Testing" "in_progress" "2"
./new-decision.sh "Remove streaming mode due to quality issues"
./log-issue.sh "Streaming garbled" "Removed feature entirely"
```

## Key Constants

### Audio Settings (DictationService.swift)
```swift
let sampleRate: Double = 16000              // 16kHz for Whisper
let silenceThreshold: Float = 0.015         // Prevents premature cutoff
let silenceDuration: TimeInterval = 2.5     // Stop after silence
let maxRecordingDuration: TimeInterval = 60.0  // Max recording limit
```

### Visual Feedback
```swift
// Recording indicator normalization
let normalizedLevel = min(max(level * 30, 0), 1.0)  // 30x sensitivity

// Window size
width: 320, height: 60  // Recording indicator dimensions
```

### Hotkey Options
```swift
"right_option"     // keyCode 61
"caps_lock"        // Caps Lock key
"f13" - "f15"      // Function keys
"cmd_shift_space"  // Command+Shift+Space
```

## Key Classes (Architecture)

### Core Services
- `DictationService` - Manages recording lifecycle
- `WhisperCppTranscriber` - Whisper integration
- `TextInsertionService` - Text input at cursor
- `ErrorHandler` - Error management (30+ types)

### UI Components
- `WhisperKeyMenuBarApp` - SwiftUI app entry
- `MenuBarContentView` - Menu bar dropdown
- `RecordingIndicator` - Floating feedback window
- `PreferencesView` - 4-tab preferences window
- `ModelManager` - Model download UI

### Supporting
- `AudioLevelMonitor` - Real-time audio levels
- `RecordingIndicatorManager` - Window management
- `PreferencesWindowController` - Preferences window

## File Locations

### Models
```bash
~/Developer/whisper.cpp/models/
├── ggml-base.en.bin    # 141 MB
├── ggml-small.en.bin   # 465 MB
└── ggml-medium.en.bin  # 1.4 GB
```

### Temp Audio Files
```bash
/var/folders/*/T/whisperkey_*.wav
# Cleaned automatically on exit
```

### Preferences
```bash
~/Library/Preferences/com.whisperkey.WhisperKey.plist
```

## Permission Checks

```swift
// Accessibility
if !AXIsProcessTrusted() {
    requestAccessibilityPermission()
}

// Microphone
switch AVCaptureDevice.authorizationStatus(for: .audio) {
case .authorized: // Good to go
case .notDetermined: // Request permission
default: // Denied or restricted
}

// Secure Field Detection
if TextInsertionService.isInSecureField() {
    // Block recording in password fields
}
```

## Error Types

### Common Errors
- `noMicrophonePermission` - Grant in System Settings
- `noAccessibilityPermission` - Grant and restart app
- `secureFieldDetected` - Can't dictate passwords
- `modelNotFound` - Download from preferences
- `diskFull` - Free up space
- `memoryPressure` - Close other apps

## Testing Checklist

### Priority Apps
1. TextEdit - Plain/RTF text
2. Safari - Forms, textareas
3. Terminal - Secure input detection
4. VS Code - Code editing
5. Slack - Messaging
6. 1Password - Secure fields

### Edge Cases
- Long recordings (>60s timeout)
- Rapid start/stop
- No microphone
- Bluetooth audio switching
- Multiple displays
- Low disk space

## Git Workflow

```bash
# Feature branch
git checkout -b feature/description

# Commit format
git commit -m "Component: Brief description

TESTED ✅: What was tested
- Specific changes made
- Test results

STATUS: Ready for review"

# Never commit untested code!
```

## Debugging

```bash
# Console logs
log stream --predicate 'subsystem == "com.whisperkey"' --level debug

# Check bundle ID
defaults read /Applications/WhisperKey.app/Contents/Info.plist CFBundleIdentifier

# Force quit
killall WhisperKey
```

---
*Last Updated: 2025-07-02 16:30 PST*