# WhisperKey API Reference

> Internal API documentation for WhisperKey components  
> Updated: 2025-07-02

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
}
```

**Key Methods**:
- `startRecording()` - Starts audio capture, shows visual feedback
- `stopRecording()` - Stops capture, processes audio, inserts text
- `checkPermissions()` - Verifies mic and accessibility permissions

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
class TextInsertionService {
    static func isInSecureField() -> Bool
    
    func insertText(_ text: String) async throws
    func clearPreviousText(characterCount: Int) async throws
    func getCurrentFieldInfo() -> String
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

**Purpose**: Floating window showing recording status

```swift
struct RecordingIndicatorView: View {
    @ObservedObject var audioLevelMonitor: AudioLevelMonitor
    
    // Shows:
    // - Pulsing red recording dot
    // - "Recording" text
    // - Live audio level bars (green/yellow/red)
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
- Window: 320x60px, bottom center of screen
- Audio bars: 10 segments, 30x sensitivity
- Colors: Green (0-40%), Yellow (40-70%), Red (70-100%)

### PreferencesView

**Purpose**: 4-tab preferences window

```swift
struct PreferencesView: View {
    // Tab 1: General
    @AppStorage("selectedHotkey") // right_option, caps_lock, f13-f15
    @AppStorage("launchAtLogin") 
    @AppStorage("showRecordingIndicator")
    @AppStorage("playFeedbackSounds")
    
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
1. User holds Right Option key
2. `DictationService.startRecording()` called
3. `RecordingIndicator` appears with live audio levels
4. Audio captured to temp file (`/var/folders/*/T/whisperkey_*.wav`)
5. Silence detected after 2.5 seconds
6. Recording stops automatically
7. `WhisperCppTranscriber` processes audio file
8. `TextInsertionService` inserts transcribed text
9. Temp file cleaned up

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

---
*This reference reflects the actual implementation as of 2025-07-02*