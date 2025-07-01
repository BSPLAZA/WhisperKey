# WhisperKey - Local Dictation App Planning Document

## Project Overview
A privacy-focused macOS dictation app that intercepts the F5 dictation key and uses local Whisper AI for transcription, replacing Apple's cloud-based dictation service.

### Key Differentiators
- **Complete Privacy**: Zero network connections, all processing local
- **Superior Performance**: Leverages M4 Pro Neural Engine and 48GB RAM
- **Native Integration**: Seamless replacement for Apple's dictation
- **No Subscription**: One-time setup, runs forever

### Critical Constraints & Assumptions
- **macOS Security Model**: Increasing restrictions with each OS version
- **App Notarization**: Required for distribution outside Mac App Store
- **Gatekeeper**: Must handle quarantine attributes properly
- **TCC (Transparency, Consent, Control)**: Cannot programmatically grant permissions
- **Secure Event Input**: Cannot inject keystrokes when active (Terminal, password fields)

## Core Requirements

### Behavior Specifications
- **Activation**: Single press dictation key to start recording
- **Deactivation**: Auto-stop after ~2 seconds of silence OR manual stop with second key press
- **Always On**: Launch at login, runs continuously in background
- **Text Insertion**: Transcribed text appears directly at cursor position in any app
- **Context Awareness**: Works in any text field across all applications
- **Undo Support**: Inserted text supports standard Cmd+Z undo
- **Multi-display**: Floating indicator appears on active display

### Visual Design
- **Minimal UI**: Small floating microphone indicator with audio level visualization
- **No Preview**: Text appears directly at cursor (no preview window needed)
- **Error Handling**: System notifications for microphone conflicts or errors
- **Invisible When Idle**: No menu bar icon or dock presence

### Performance Requirements
- **Hardware**: Optimized for Apple M4 Pro with 48GB RAM
- **Real-time**: Transcription must keep up with natural speech
- **Resource Conscious**: Unload models when idle, minimize memory footprint
- **Local Only**: All processing on-device, no network connections

## Technical Architecture

### Component Structure
```
WhisperKey.app/
├── App/
│   ├── WhisperKeyApp.swift       # Main app entry point
│   ├── AppDelegate.swift         # Launch at login, permissions
│   └── Configuration.swift       # User preferences storage
├── Core/
│   ├── KeyMonitor.swift          # Dictation key interception
│   ├── AudioCapture.swift        # CoreAudio recording & silence detection
│   ├── WhisperBridge.swift       # Swift/C++ interface
│   ├── TextInsertion.swift       # Accessibility API for text input
│   └── ProcessMonitor.swift      # Track active app for context
├── Models/
│   ├── TranscriptionManager.swift # Manages Whisper inference
│   ├── PunctuationProcessor.swift # Auto-punctuation logic
│   ├── ModelLoader.swift         # Dynamic model loading/unloading
│   └── StreamingBuffer.swift     # Audio chunk management
├── UI/
│   ├── FloatingIndicator.swift   # Minimal recording UI
│   ├── ErrorNotifications.swift  # System alerts
│   └── PermissionPrompts.swift   # First-run permission flow
├── Utilities/
│   ├── SilenceDetector.swift     # VAD implementation
│   ├── AudioLevelMeter.swift     # Real-time audio visualization
│   └── KeyboardSimulator.swift   # Text insertion utilities
├── whisper.cpp/                  # Submodule for Whisper C++ implementation
├── Resources/
│   ├── Models/                   # Whisper model files
│   ├── Info.plist               # App metadata & permissions
│   └── Entitlements.plist       # Security entitlements
└── Tests/
    ├── PunctuationTests.swift
    ├── SilenceDetectionTests.swift
    └── TranscriptionTests.swift
```

### Key Technical Decisions

#### Architecture Pattern
- **MVVM with Coordinators**: Clean separation of concerns
- **Actor-based Concurrency**: Leverage Swift 5.9 actors for thread safety
- **Dependency Injection**: Protocol-based DI for testability
- **Event-Driven**: Combine framework for reactive updates

#### Whisper Configuration
- **Primary Model**: `base.en` for optimal real-time performance (~39MB)
- **Fallback Model**: `small.en` for better accuracy when needed (~141MB)
- **Large Model Option**: `medium.en` available but not default (~466MB)
- **Streaming**: Process audio in 480ms chunks (optimal for base model)
- **Memory Management**: Unload models after 5 minutes of inactivity
- **Model Format**: Use Core ML models for M4 optimization over GGML
- **Quantization**: INT8 quantization for 4x speed improvement

#### Text Processing Pipeline
1. **Audio Capture** → 16kHz mono audio stream
   - Ring buffer for continuous recording
   - Pre-roll buffer to capture speech onset
2. **Whisper Inference** → Raw transcription text
   - Streaming inference with 30-frame chunks
   - Context preservation between chunks
3. **Punctuation Processing**:
   - Auto-detect sentence boundaries using NLP
   - Add periods, commas, question marks
   - Capitalize sentence starts and proper nouns
   - Handle contractions and abbreviations
4. **Command Processing**:
   - "new line" → `\n`
   - "new paragraph" → `\n\n`
   - "comma" → `,`
   - "period" → `.`
   - "question mark" → `?`
   - "exclamation point" → `!`
   - "open quote" → `"`
   - "close quote" → `"`
5. **Text Insertion** → Simulate keyboard events
   - Buffer complete sentences before insertion
   - Support for rich text fields
   - Preserve existing formatting

#### System Integration Strategy
- **Primary Method**: IOKit HID APIs for direct key interception
- **Fallback Method**: Karabiner Elements configuration
- **Required Permissions**:
  - Accessibility (for text insertion)
  - Input Monitoring (for key interception)
  - Microphone Access

### Implementation Phases

#### Phase 0: Environment Setup (Day 1)
- [ ] Install Xcode 15.4+ and command line tools
- [ ] Clone and build whisper.cpp with Metal support
- [ ] Download whisper models (base.en, small.en, medium.en)
- [ ] Convert models to Core ML format using coremltools
- [ ] Set up code signing certificate (Developer ID)
- [ ] Create test Karabiner configuration
- [ ] Install testing tools: Instruments, Console.app filters
- [ ] Set up CI/CD pipeline (GitHub Actions + fastlane)
- [ ] Create notarization automation script

#### Phase 1: Core Prototype (Days 2-5)
- [ ] Create Xcode project "WhisperKey" with SwiftUI
- [ ] Configure entitlements and Info.plist
- [ ] Implement basic HID event monitoring
- [ ] Test dictation key interception
- [ ] Basic CoreAudio recording setup
- [ ] Simple whisper.cpp integration (file-based)
- [ ] Proof-of-concept text insertion
- [ ] Verify permissions flow

#### Phase 2: Audio Pipeline (Days 6-8)
- [ ] Implement ring buffer for audio
- [ ] Add real-time audio level monitoring
- [ ] Create silence detection algorithm
- [ ] Test various silence thresholds
- [ ] Implement pre-roll buffer
- [ ] Add audio format conversion

#### Phase 3: Whisper Integration (Days 9-12)
- [ ] Create Swift/C++ bridge with proper memory management
- [ ] Implement streaming inference
- [ ] Add model loading/unloading logic
- [ ] Optimize for M4 Neural Engine
- [ ] Test with different chunk sizes
- [ ] Implement context preservation

#### Phase 4: Text Processing (Days 13-15)
- [ ] Build punctuation processor
- [ ] Implement command recognition
- [ ] Add capitalization logic
- [ ] Create text buffering system
- [ ] Test with various text fields
- [ ] Handle special characters

#### Phase 5: UI and Polish (Days 16-18)
- [ ] Design floating indicator
- [ ] Implement audio visualization
- [ ] Add error notifications
- [ ] Create first-run experience
- [ ] Launch at login setup
- [ ] Multi-display support

#### Phase 6: Optimization (Days 19-20)
- [ ] Profile memory usage
- [ ] Optimize model switching
- [ ] Reduce latency
- [ ] Battery usage optimization
- [ ] Cold start performance

#### Phase 7: Testing & Release (Days 21-24)
- [ ] Unit test suite
- [ ] Integration testing
- [ ] Test across multiple apps
- [ ] Edge case documentation
- [ ] Create installer
- [ ] Write user documentation

## Development Guidelines

### Code Standards
- Swift 5.9+ with strict concurrency checking
- Comprehensive error handling
- Minimal external dependencies
- Clear separation of concerns

### Testing Strategy
- Unit tests for punctuation processing
- Integration tests for key interception
- Performance benchmarks for transcription speed
- Manual testing across various macOS apps

### Security Considerations
- No network connections whatsoever
- Minimal permissions requested
- Clear privacy policy
- Option to disable logging

## Open Questions & Decisions

### Resolved
- ✅ Activation model: Click once to start, auto-stop on silence
- ✅ Visual feedback: Minimal floating indicator
- ✅ Model selection: base.en default, upgradeable
- ✅ Punctuation: Full auto-punctuation system
- ✅ Launch behavior: Always on at login

### Pending
- [ ] App distribution method (direct download vs. notarization)
- [ ] Update mechanism for Whisper models
- [ ] Customization options to expose to users
- [ ] Handling of multiple languages (start with English only?)

## Critical Implementation Gotchas (Senior Engineer Notes)

### Memory Management
- **Model Loading**: Use memory-mapped files for models (mmap)
- **Audio Buffers**: Pre-allocate all buffers to avoid allocation during recording
- **Swift/C++ Bridge**: Use `@convention(c)` callbacks to avoid retain cycles
- **Autoreleasepool**: Wrap audio callbacks in explicit autorelease pools

### Threading Architecture
```swift
// Critical: Audio processing must never block
actor AudioPipeline {
    private let processingQueue = DispatchQueue(label: "audio.processing", 
                                               qos: .userInteractive,
                                               attributes: .concurrent)
    private let inferenceQueue = DispatchQueue(label: "whisper.inference",
                                              qos: .userInitiated)
}
```

### State Machine Design
```swift
enum DictationState {
    case idle
    case waitingForAudio(timeout: Task<Void, Never>)
    case recording(startTime: Date, silenceStart: Date?)
    case processing(audio: Data)
    case inserting(text: String)
    
    // Explicit state transitions prevent race conditions
}
```

### Production-Ready Considerations
1. **Crash Reporting**: Use PLCrashReporter (not dependent on network)
2. **Analytics**: Local SQLite for usage patterns (privacy-preserving)
3. **Update Mechanism**: Sparkle framework with EdDSA signatures
4. **Logging**: OSLog with privacy levels, no PII in logs
5. **Debug Mode**: Hidden keyboard shortcut for diagnostic mode

## Risk Mitigation & Contingency Plans

### Technical Risks
1. **Key Interception Blocked by macOS**
   - Primary: CGEventTap (more reliable than IOKit for media keys)
   - Backup: Karabiner Elements integration via IPC
   - Last Resort: Menu bar trigger + global hotkey
   - Nuclear Option: System Extension (requires notarization)

2. **Whisper Performance Issues**
   - Primary: Core ML models with Neural Engine
   - Backup: whisper.cpp with Metal acceleration
   - Last Resort: Smaller models with dynamic quality
   - Consider: Apple's Speech framework as fallback (with user consent)

3. **Text Insertion Failures**
   - Primary: CGEventPost with proper event source
   - Backup: Accessibility API with focused element detection
   - Last Resort: Clipboard with state preservation
   - Special: AppleScript for specific apps (Microsoft Office)

### System Compatibility
- **macOS Versions**: Test on 14.0 (Sonoma) and 15.0 (Sequoia)
- **Architecture**: Universal binary for Intel/ARM
- **Permissions**: Graceful degradation if denied

### Known Challenges
1. **Secure Input Fields**: Some password fields block programmatic input
   - Solution: Detect and show warning
   
2. **Full Screen Apps**: Some games capture all input
   - Solution: Windowed mode notification
   
3. **Multiple Audio Devices**: Device switching during recording
   - Solution: Automatic device following

### Testing Scenarios
- Terminal.app (unique input handling)
- Microsoft Office (custom text fields)
- Web browsers (contenteditable)
- Electron apps (Slack, Discord)
- Password managers (secure input)
- Full-screen games
- Screen sharing sessions
- Multiple displays
- External keyboards

## Success Criteria
1. Dictation key triggers local transcription immediately (<100ms response)
2. Transcription appears at cursor with <500ms end-to-end latency
3. Accuracy comparable to Apple's dictation (>95% for clear speech)
4. Zero network traffic (verified with network monitor)
5. <200MB memory usage when active, <50MB when idle
6. Proper cleanup when idle (model unloaded after 5 min)
7. Works in 100% of text input fields across all apps
8. No system performance impact when idle
9. Survives system sleep/wake cycles
10. Handles audio device changes gracefully

## Technical Implementation Details

### Audio Processing Specifications
- **Sample Rate**: 16kHz (Whisper native)
- **Bit Depth**: Float32 (for processing) → Int16 (for model)
- **Channels**: Mono (downmix if stereo input)
- **Buffer Size**: 512 samples (~32ms latency)
- **Ring Buffer**: 30 seconds capacity (circular buffer)
- **Pre-roll**: 500ms to capture speech onset
- **Audio Session**: Use AVAudioEngine (not deprecated Audio Queue Services)
- **Voice Isolation**: Enable built-in noise reduction

### Silence Detection Algorithm
```swift
// Enhanced VAD with adaptive threshold
actor SilenceDetector {
    private let energyThreshold: Float = 0.01  // RMS threshold
    private let zeroCrossingThreshold: Int = 50
    private let silenceDuration: TimeInterval = 2.0
    private let speechMinDuration: TimeInterval = 0.3
    private var noiseFloor: Float = 0.0
    private let adaptiveRate: Float = 0.995  // Noise floor adaptation
    
    func detectSpeech(buffer: AVAudioPCMBuffer) -> SpeechState {
        // 1. Calculate RMS energy
        // 2. Count zero crossings (differentiates speech from noise)
        // 3. Update adaptive noise floor
        // 4. Apply hangover time to prevent cutting off speech
    }
}
```

### Key Interception Details
- **Dictation Key Code**: 0x000c00cf (HID usage)
- **Monitoring Level**: System-wide via IOHIDManager
- **Event Handling**: Non-blocking async processing
- **Conflict Resolution**: Yield to system if permission denied
- **Alternative Approach**: CGEventTap as primary (more reliable than IOKit)
- **Event Mask**: kCGEventMaskForAllEvents filtered to NX_SYSDEFINED
- **Run Loop**: Dedicated high-priority thread for event processing
- **Latency Target**: < 16ms (one frame at 60Hz)

### Model Loading Strategy
1. **On Launch**: Load base.en into memory
2. **On First Use**: Keep loaded for 5 minutes
3. **Model Switching**: Based on audio length
   - < 10 seconds: base.en
   - 10-30 seconds: small.en  
   - > 30 seconds: medium.en (with user notification)

### Text Insertion Methods
1. **Primary**: CGEventPost with kCGSessionEventTap
   ```swift
   // Proper Unicode handling
   let eventSource = CGEventSource(stateID: .combinedSessionState)
   eventSource?.localEventsSuppressionInterval = 0.0  // Prevent interference
   ```
2. **Fallback**: AXUIElementSetAttributeValue
   - Detect focused element with AXUIElementCopyAttributeValue
   - Handle AXTextArea vs AXTextField differently
3. **Last Resort**: Clipboard paste (with restoration)
   - Save clipboard state
   - Use NSPasteboard.general.setString()
   - Simulate Cmd+V
   - Restore clipboard after 100ms delay
4. **Special Cases**:
   - WebKit: Use JavaScript injection for contenteditable
   - Terminal: Direct write to TTY if possible
   - Electron: Send via IPC if app supports it

### Performance Targets
- **Cold Start**: < 2 seconds to ready state
- **Key Response**: < 50ms to begin recording
- **First Word**: < 300ms from speech start
- **Memory**: 150MB with model loaded
- **CPU**: < 5% when idle, < 30% when transcribing

### Error Handling Matrix
| Error | User Feedback | Recovery Action |
|-------|--------------|-----------------|
| Mic in use | Notification | Queue or wait |
| No permissions | Alert + Settings | Guide to fix |
| Model load fail | Alert | Fallback model |
| Key conflict | Status bar | Use menu trigger |
| Out of memory | Alert | Unload + retry |

### Build Configuration
```
SWIFT_VERSION = 5.9
MACOSX_DEPLOYMENT_TARGET = 14.0
PRODUCT_BUNDLE_IDENTIFIER = com.whisperkey.app
CODE_SIGN_IDENTITY = "Developer ID Application"
ENABLE_HARDENED_RUNTIME = YES
OTHER_SWIFT_FLAGS = -D METAL_SUPPORT -warn-concurrency
SWIFT_STRICT_CONCURRENCY = complete
DEAD_CODE_STRIPPING = YES
DEPLOYMENT_POSTPROCESSING = YES
STRIP_INSTALLED_PRODUCT = YES
```

### Entitlements Required
```xml
<!-- Hardened Runtime Entitlements -->
<key>com.apple.security.device.audio-input</key><true/>
<key>com.apple.security.automation.apple-events</key><true/>

<!-- TCC Protected Resources (user must grant) -->
<key>com.apple.security.accessibility</key><true/>
<key>com.apple.security.input-monitoring</key><true/>

<!-- Disable unnecessary entitlements for security -->
<key>com.apple.security.network.client</key><false/>
<key>com.apple.security.network.server</key><false/>
```

### Info.plist Keys
```xml
<key>NSMicrophoneUsageDescription</key>
<string>WhisperKey needs microphone access to transcribe your speech locally.</string>
<key>NSAppleEventsUsageDescription</key>
<string>WhisperKey needs automation access to insert transcribed text.</string>
<key>LSUIElement</key><true/> <!-- Hidden from Dock -->
<key>LSBackgroundOnly</key><false/> <!-- Can show UI -->
```

## Resources & References
- whisper.cpp: https://github.com/ggerganov/whisper.cpp
- Apple Accessibility APIs: https://developer.apple.com/accessibility/
- IOKit Documentation: https://developer.apple.com/documentation/iokit
- Karabiner Elements: https://karabiner-elements.pqrs.org/
- CoreAudio Guide: https://developer.apple.com/audio/
- HID Usage Tables: https://www.usb.org/hid

## Debugging & Troubleshooting Guide

### Common Development Issues

1. **"Input Monitoring" Permission Loop**
   ```bash
   # Reset TCC database (development only)
   tccutil reset InputMonitoring com.whisperkey.app
   ```

2. **CGEventTap Stops Receiving Events**
   - Events taps timeout after 1 second of blocking
   - Solution: Process events asynchronously immediately

3. **Whisper Model Loading Crashes**
   - Check model checksum before loading
   - Validate Core ML model compatibility
   - Fall back to smaller model on failure

4. **Text Insertion in Secure Fields**
   ```swift
   // Detect secure input mode
   if (CGEventSourceSecureInputState() == true) {
       showSecureInputWarning()
   }
   ```

### Performance Profiling Points
- Audio callback duration (must be < 10ms)
- Whisper inference time per chunk
- Key event to recording start latency
- Text insertion delay
- Memory growth over time

### Debug Utilities
```swift
#if DEBUG
extension WhisperKeyApp {
    func installDebugHandlers() {
        // Cmd+Opt+Shift+D: Dump state
        // Cmd+Opt+Shift+P: Performance stats
        // Cmd+Opt+Shift+M: Memory report
    }
}
#endif
```

---
*Last Updated: December 2024*
*Status: Planning Phase - Ready for Implementation*