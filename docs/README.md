# WhisperKey Developer Documentation

> For users, see the main [README.md](../README.md)

## Current Status

**Phase**: Core App Implementation  
**Focus**: Right Option hotkey with menu bar UI  
**Approach**: Clean architecture with proven libraries

## Development Plan

See [SIMPLE_PLAN.md](SIMPLE_PLAN.md) for the streamlined roadmap.

### Quick Progress Check
- ✅ Menu bar app structure created
- ✅ HotKey library integrated
- ⏳ Right Option key binding 
- ⏳ Audio recording pipeline
- ⏳ Whisper integration

## Key Documents

### Active Development
- [SIMPLE_PLAN](SIMPLE_PLAN.md) - Current development roadmap
- [DAILY_LOG](DAILY_LOG.md) - Development diary
- [DECISIONS](DECISIONS.md) - Architecture Decision Records

### Implementation Guides  
- [RIGHT_OPTION_SETUP](RIGHT_OPTION_SETUP.md) - Hotkey implementation
- [QUICK_REFERENCE](QUICK_REFERENCE.md) - Constants and snippets
- [API_REFERENCE](API_REFERENCE.md) - Internal APIs

### Process
- [TIMELINE](TIMELINE.md) - Detailed phase tracking
- [ISSUES_AND_SOLUTIONS](ISSUES_AND_SOLUTIONS.md) - Problem archive
- [TESTING_GUIDE](TESTING_GUIDE.md) - Test scenarios

## Quick Start for Developers

1. **Clone and open project**:
   ```bash
   git clone https://github.com/BSPLAZA/WhisperKey.git
   cd WhisperKey
   open WhisperKey/WhisperKey.xcodeproj
   ```

2. **Add HotKey package**: 
   - File → Add Package Dependencies
   - Enter: `https://github.com/soffes/HotKey`

3. **Build and run**: Cmd+R

## Architecture Overview

```
MenuBarApp (SwiftUI)
    ├── DictationService (Recording & Transcription)
    │   ├── AVAudioEngine (Audio capture)
    │   └── WhisperService (whisper.cpp wrapper)
    ├── HotkeyManager (Global shortcuts)
    │   └── HotKey library (Carbon Events)
    └── TextInsertion (Cursor interaction)
        └── AXUIElement (Accessibility API)
```

## Key Technical Decisions

1. **Right Option over F5**: System doesn't interfere
2. **Menu bar over window**: Always accessible
3. **HotKey library**: Battle-tested shortcuts
4. **whisper.cpp**: Fast local transcription

---

*Building dictation that respects privacy and just works.*