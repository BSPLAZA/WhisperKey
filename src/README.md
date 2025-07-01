# WhisperKey Source Code Structure

## Directory Layout

```
src/
├── Models/          # Data models and structures
├── Views/           # UI components (SwiftUI views)
├── Controllers/     # Business logic and coordinators
├── Services/        # External integrations (Whisper, Audio, KeyCapture)
├── Utilities/       # Helper functions and extensions
└── Resources/       # Assets, sounds, icons
```

## Key Components (Planned)

### Services
- **KeyCaptureService**: CGEventTap for F5 interception
- **AudioCaptureService**: AVAudioEngine management
- **WhisperService**: whisper.cpp integration
- **TextInsertionService**: Text input handling

### Models
- **DictationSession**: Active dictation state
- **AudioBuffer**: Ring buffer implementation
- **TranscriptionResult**: Whisper output

### Controllers
- **DictationController**: Main coordinator
- **PermissionController**: macOS permission handling

### Views
- **FloatingIndicator**: Visual feedback during dictation
- **SettingsView**: User preferences
- **OnboardingView**: First-run experience