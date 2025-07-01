# WhisperKey Internal API Reference

> Documentation for key components and their interfaces

## Core Components

### KeyMonitor

Responsible for intercepting and handling the dictation key.

```swift
actor KeyMonitor {
    /// Start monitoring for dictation key presses
    func startMonitoring() async throws
    
    /// Stop monitoring
    func stopMonitoring() async
    
    /// Current monitoring state
    var isMonitoring: Bool { get }
    
    /// Delegate for key events
    weak var delegate: KeyMonitorDelegate?
}

protocol KeyMonitorDelegate: AnyObject {
    func keyMonitorDidDetectDictationKey()
    func keyMonitorDidDetectStop()
}
```

### AudioCapture

Handles microphone recording and silence detection.

```swift
actor AudioCapture {
    /// Start recording audio
    func startRecording() async throws
    
    /// Stop recording and return audio data
    func stopRecording() async -> Data
    
    /// Audio level for UI visualization (0.0-1.0)
    var currentAudioLevel: AsyncStream<Float> { get }
    
    /// Silence detection events
    var silenceDetected: AsyncStream<Void> { get }
}
```

### WhisperBridge

Swift interface to Whisper C++ implementation.

```swift
class WhisperBridge {
    /// Load model into memory
    func loadModel(_ modelPath: URL) throws
    
    /// Transcribe audio data
    func transcribe(_ audioData: Data) async throws -> String
    
    /// Unload model from memory
    func unloadModel()
    
    /// Current model info
    var loadedModel: WhisperModel? { get }
}

struct WhisperModel {
    let name: String
    let size: Int64
    let language: String
}
```

### TextInsertion

Manages inserting transcribed text at cursor position.

```swift
actor TextInsertion {
    /// Insert text at current cursor position
    func insertText(_ text: String) async throws
    
    /// Check if we can insert text in current context
    func canInsertText() async -> Bool
    
    /// Get info about current text field
    func getCurrentContext() async -> TextContext?
}

struct TextContext {
    let applicationName: String
    let isSecureField: Bool
    let supportsRichText: Bool
}
```

### TranscriptionManager

Orchestrates the full transcription pipeline.

```swift
actor TranscriptionManager {
    /// Start a new transcription session
    func startTranscription() async throws
    
    /// Cancel current transcription
    func cancelTranscription() async
    
    /// Current state
    var state: TranscriptionState { get }
    
    /// State changes
    var stateUpdates: AsyncStream<TranscriptionState> { get }
}

enum TranscriptionState {
    case idle
    case recording(startTime: Date)
    case processing
    case inserting
    case error(Error)
}
```

## State Diagrams

### Transcription State Machine

```
┌─────────┐
│  Idle   │◀─────────────────────┐
└────┬────┘                      │
     │ Key Pressed               │
     ▼                           │
┌──────────┐                     │
│Recording │                     │
└────┬─────┘                     │
     │ Silence/Key               │
     ▼                           │
┌────────────┐                   │
│Processing  │                   │
└────┬───────┘                   │
     │                           │
     ▼                           │
┌───────────┐                    │
│ Inserting │────────────────────┘
└───────────┘
```

## Error Handling

### Error Types

```swift
enum WhisperKeyError: LocalizedError {
    case permissionDenied(Permission)
    case audioDeviceUnavailable
    case modelLoadFailed(URL)
    case transcriptionFailed(String)
    case textInsertionFailed(reason: String)
    case secureInputActive
    
    var errorDescription: String? {
        // Localized descriptions
    }
}

enum Permission {
    case microphone
    case accessibility
    case inputMonitoring
}
```

## Configuration

### UserDefaults Keys

```swift
extension UserDefaults {
    // Model selection
    var selectedModel: WhisperModel
    
    // Silence detection threshold
    var silenceThreshold: TimeInterval
    
    // Auto-punctuation enabled
    var autoPunctuationEnabled: Bool
    
    // Launch at login
    var launchAtLogin: Bool
}
```

## Testing Utilities

### Mock Components

```swift
#if DEBUG
class MockAudioCapture: AudioCapture {
    // Test implementation
}

class MockWhisperBridge: WhisperBridge {
    // Test implementation
}
#endif
```

---
*Last Updated: 2025-07-01*