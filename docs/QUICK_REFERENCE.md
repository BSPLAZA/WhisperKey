# WhisperKey Quick Reference

> Keep this open while developing - Updated 2025-07-15 13:50 PST

## Current Status
- **Phase**: v1.0.1 Hotfix In Progress
- **Version**: 1.0.1-test-v8
- **Status**: Testing audio fixes and UI cleanup
- **Key Fixes**: 
  - Bundled whisper.cpp binary
  - Added audio test button
  - Cleaned up Advanced settings
- **Documentation**: Fully updated
- **Next**: Address v8 DMG issue, then release

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

## Default Settings

### User Preferences (v1.0.1)
- **Hotkey**: Right Option ⌥
- **Model**: base.en (changed from small.en)
- **Silence Duration**: 2.5 seconds
- **Silence Threshold**: 0.015
- **Show Recording Indicator**: Yes
- **Play Feedback Sounds**: Yes
- **Always Save to Clipboard**: No (changed from Yes)
- **Launch at Login**: Yes (changed from No)

### Settings Synchronization
All settings use @AppStorage which automatically syncs with UserDefaults:
- Changes in onboarding immediately reflect in preferences
- Changes in preferences immediately reflect throughout the app
- Settings persist between app launches
- The same key (e.g., "alwaysSaveToClipboard") is used everywhere

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
"right_option"     // keyCode 61 (Default)
"f13"             // F13 key (Alternative)
// Other options removed for simplicity
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

## v1.0.1 Critical Fixes Reference

### Bundle Path Fix
```swift
// WRONG: nil at init time
private let paths = [Bundle.main.resourcePath + "/whisper-cli"]

// CORRECT: computed property
private var paths: [String] {
    if let resourcePath = Bundle.main.resourcePath {
        return ["\(resourcePath)/whisper-cli"]
    }
    return []
}
```

### Model Path Checking
```swift
// Check ALL locations before downloading
for searchPath in whisperService.modelsSearchPaths {
    if FileManager.default.fileExists(atPath: modelFile) {
        return true  // Don't download again!
    }
}
```

### Disk Space Validation
```swift
let requiredSpace = model.size + 100_000_000  // Add buffer
if !ErrorHandler.checkDiskSpace(requiredBytes: requiredSpace) {
    // Show error, don't start download
}
```

## File Locations

### Models (v1.0.1+)
- Primary: `~/.whisperkey/models/`
- Legacy: `~/Developer/whisper.cpp/models/`
- System: `/usr/local/share/whisper/models/`

### whisper-cli (v1.0.1+)
- Bundled: `WhisperKey.app/Contents/Resources/whisper-cli`
- Fallback: `~/Developer/whisper.cpp/main`
- System: `/usr/local/bin/whisper-cli`

### Old Models Location (v1.0.0)
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
- `noFocusedElement` - Click in a text field first
- `insertionFailed` - Text saved to clipboard instead

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

## New Features Added

### Clipboard Fallback
- Automatically saves to clipboard when not in text field
- Shows notification with word count
- Different sound feedback (Pop vs Glass)
- Optional "Always save to clipboard" setting

### Sound Feedback
- Start recording: Tink
- Stop recording: Pop
- Success (text inserted): Glass
- Clipboard save: Pop (only if not "always save")

### UI Improvements
- Models tab uses SettingsSection styling
- Enhanced recording indicator with live audio
- Better error messages and recovery
- Polished settings organization

---
*Last Updated: 2025-07-13 14:15 PST*