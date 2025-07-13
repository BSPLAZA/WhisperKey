# WhisperKey API Reference

> Internal API documentation for WhisperKey components  
> Updated: 2025-07-13

## Core Services

### DictationService

**Purpose**: Central coordinator for recording lifecycle

```swift
class DictationService: ObservableObject {
    @Published var isRecording = false
    @Published var transcriptionStatus = ""
    @Published var hasMicrophonePermission = false
    @Published var hasAccessibilityPermission = false
    
    // Audio settings
    private let sampleRate: Double = 16000
    private let silenceThreshold: Float = 0.015
    private let silenceDuration: TimeInterval = 2.5
    private let maxRecordingDuration: TimeInterval = 60.0
    
    func startRecording()
    func stopRecording()
    func checkPermissions()
    func updateModel()
    
    // Private methods
    private func playSound(named: String)  // Audio feedback
}
```

**Key Methods**:
- `startRecording()` - Starts audio capture, shows visual feedback, plays "Tink" sound
- `stopRecording()` - Stops capture, processes audio, inserts text, plays "Pop" sound
- `checkPermissions()` - Verifies mic and accessibility permissions
- `playSound(named:)` - Plays system sounds for audio feedback

### WhisperCppTranscriber

**Purpose**: Interface to whisper.cpp binary

```swift
class WhisperCppTranscriber {
    static let shared = WhisperCppTranscriber()
    
    func transcribe(audioFileURL: URL) async throws -> String
    func updateModel()
}
```

**Model Paths**:
```
~/Developer/whisper.cpp/models/ggml-{model}.bin
- base.en: 141MB, fastest
- small.en: 465MB, balanced
- medium.en: 1.4GB, best accuracy
```

### TextInsertionService

**Purpose**: Insert text at cursor position across all apps

```swift
enum InsertionResult {
    case insertedAtCursor
    case keyboardSimulated
    case savedToClipboard
}

class TextInsertionService {
    static func isInSecureField() -> Bool
    static func saveToClipboard(_ text: String)
    
    func insertText(_ text: String) async throws -> InsertionResult
    func clearPreviousText(characterCount: Int) async throws
    func getCurrentFieldInfo() -> String
    
    // Private helpers
    private func getFocusedElement() -> AXUIElement?
    private func tryKeyboardSimulation(_ text: String) -> Bool
}
```

**Security Features**:
- Detects password fields via `AXSecureTextField`
- Checks Terminal secure input state
- Blocks insertion in secure contexts

### ErrorHandler

**Purpose**: Centralized error management with UI feedback

```swift
@MainActor
class ErrorHandler: ObservableObject {
    static let shared = ErrorHandler()
    
    @Published var currentError: WhisperKeyError?
    @Published var isShowingError = false
    
    func handle(_ error: WhisperKeyError)
    func attemptRecovery(from error: WhisperKeyError) async -> Bool
}
```

**Error Types** (30+):
- Permission errors (mic, accessibility)
- Audio errors (no device, format issues)
- Transcription errors (model missing, timeout)
- System errors (disk full, memory pressure)
- Security errors (secure field detected)

## UI Components

### RecordingIndicator

**Purpose**: Floating window showing recording status with duration

```swift
struct RecordingIndicatorView: View {
    @ObservedObject var audioLevelMonitor: AudioLevelMonitor
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    
    // Shows:
    // - Pulsing red recording dot
    // - "Recording" text with duration (0:XX format)
    // - Time warning when <10s remaining
    // - "ESC to cancel" hint
    // - Live audio level bars (green/yellow/red)
    
    private var formattedTime: String  // Minutes:seconds
    private var warningText: String?   // "Stopping in Xs"
}

@MainActor
class RecordingIndicatorManager {
    static let shared = RecordingIndicatorManager()
    
    func showRecordingIndicator()
    func hideRecordingIndicator()
    func updateAudioLevel(_ level: Float)
}
```

**Visual Specs**:
- Window: 380x70px, bottom center of screen (increased for timer)
- Audio bars: 10 segments, 30x sensitivity
- Colors: Green (0-40%), Yellow (40-70%), Red (70-100%)
- Timer updates: Every 0.1 seconds
- Warning color: Yellow text when <10s remaining

### PreferencesView

**Purpose**: 4-tab preferences window

```swift
struct PreferencesView: View {
    // Tab 1: General
    @AppStorage("selectedHotkey") // right_option, f13 only (simplified)
    @AppStorage("launchAtLogin") 
    @AppStorage("showRecordingIndicator")
    @AppStorage("playFeedbackSounds")  // NEW: Audio feedback toggle
    
    // Tab 2: Recording
    @AppStorage("silenceDuration") // 1.0-5.0 seconds
    @AppStorage("silenceThreshold") // 0.005-0.03
    @AppStorage("maxRecordingDuration") // 30-120 seconds
    
    // Tab 3: Models
    @AppStorage("whisperModel") // base.en, small.en, medium.en
    @AppStorage("autoSelectModel") // Future feature
    
    // Tab 4: Advanced
    @AppStorage("debugMode")
}

// NEW: Settings Section Component
struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String  // SF Symbol name
    let content: Content
    
    // Creates visual section with:
    // - Icon + title header
    // - Gray background
    // - 10pt corner radius
    // - 16pt padding
}
```

### ModelManager

**Purpose**: Download and manage Whisper models

```swift
@MainActor
class ModelManager: ObservableObject {
    @Published var downloadProgress: [String: Double]
    @Published var isDownloading: [String: Bool]
    @Published var downloadError: [String: String]
    
    func downloadModel(_ filename: String)
    func cancelDownload(_ filename: String)
    func isModelInstalled(_ filename: String) -> Bool
}
```

**Download Sources**:
- HuggingFace: `https://huggingface.co/ggerganov/whisper.cpp/`
- Supports progress tracking and cancellation

## Data Flow

### Recording Flow
1. User taps Right Option key (tap-to-toggle, not hold)
2. `DictationService.startRecording()` called
3. "Tink" sound plays (if enabled)
4. `RecordingIndicator` appears with timer and audio levels
5. Audio captured to temp file (`/var/folders/*/T/whisperkey_*.wav`)
6. Duration timer updates every 0.1 seconds
7. Warning shown when <10s remaining before max time
8. Silence detected after 2.5 seconds OR user taps hotkey again
9. "Pop" sound plays (if enabled)
10. Recording stops automatically
11. `WhisperCppTranscriber` processes audio file
12. `TextInsertionService` attempts insertion:
    - If in text field: Insert at cursor → Glass sound
    - If not in text field: Save to clipboard → Pop sound
    - Show appropriate message with word count
13. Success message shows result:
    - "✅ Inserted X words" (for cursor insertion)
    - "📋 Saved to clipboard (X words)" (for clipboard)
14. Status auto-clears after 3 seconds
15. Temp file cleaned up

### Permission Flow
1. Check `AXIsProcessTrusted()` on startup
2. If false, show system dialog via `AXIsProcessTrustedWithOptions`
3. Check `AVCaptureDevice.authorizationStatus(.audio)`
4. If not determined, request permission
5. Store status in `@Published` properties for UI

### Error Flow
1. Error occurs in any component
2. Component calls `ErrorHandler.shared.handle(error)`
3. Error logged with timestamp
4. Appropriate UI shown (alert, notification, or banner)
5. Recovery attempted if possible
6. User notified of resolution

## Key Protocols

### Audio Processing
```swift
// Buffer format
AVAudioFormat(
    commonFormat: .pcmFormatFloat32,
    sampleRate: hardware.sampleRate, // Usually 48kHz
    channels: hardware.channelCount,
    interleaved: false
)

// Level calculation
let rms = sqrt(samples.map { $0 * $0 }.reduce(0, +) / Float(count))
```

### Secure Field Detection
```swift
// Check multiple indicators
- AXRole == "AXSecureTextField"
- AXSubrole contains "secure" or "password"
- AXDescription contains "password"
- Terminal secure input enabled
```

## Performance Considerations

### Memory Usage
- Idle: ~50MB
- Recording: ~100MB
- Processing: ~200MB (varies by model)
- Models loaded on-demand

### Response Times
- Hotkey → Recording: <100ms
- Stop → Text insertion: <3s
- Preference changes: Immediate

### Cleanup
- Temp files deleted after processing
- All temp files cleaned on app exit
- Audio buffer released after recording

## Audio Feedback

### System Sounds Used
- **Start Recording**: "Tink" - Light tap sound
- **Stop Recording**: "Pop" - Soft completion sound  
- **Success**: "Glass" - Pleasant success chime

### Sound Settings
- Controlled by `playFeedbackSounds` preference
- Plays via `NSSound(named:)?.play()`
- Non-blocking (asynchronous)

---
*This reference reflects the actual implementation as of 2025-07-10*