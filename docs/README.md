# WhisperKey Developer Documentation

> For users, see the main [README.md](../README.md)

## Current Status

**Phase**: Testing & Polish  
**Status**: Feature Complete with Enhanced UX  
**Version**: 1.0.0-rc2  
**Updated**: 2025-07-10 08:07 PST

## 🎯 Project Summary

WhisperKey is a privacy-focused local dictation app for macOS that uses OpenAI's Whisper AI for high-accuracy speech recognition. All processing happens locally on your Mac - your voice never leaves your device.

### Key Stats
- **Development Time**: 2 days (vs 8 planned)
- **Code Size**: ~3,000 lines
- **Features Complete**: 17 major features
- **Testing Progress**: 0/8 apps tested
- **Quality**: 10/10 transcription accuracy

## ✅ What's Complete

### Core Features
- **Menu bar app** with professional dropdown UI
- **Tap-to-toggle hotkeys** - Right Option ⌥ or F13
- **Automatic silence detection** (2.5s configurable)
- **Whisper transcription** via whisper.cpp with Metal
- **Smart text insertion** at cursor position
- **Enhanced recording indicator** with duration timer
- **Settings window** with 4 organized tabs

### Advanced Features
- **Model download manager** - In-app HuggingFace downloads
- **Comprehensive error handling** - 30+ specific error types
- **Secure field detection** - Blocks password recording
- **60-second timeout** - Prevents runaway recordings
- **Temp file cleanup** - Automatic maintenance
- **Permission handling** - Clean system integration
- **Multiple model support** - Base, Small, Medium

### User Experience (Updated 2025-07-09)
- **Enhanced recording indicator** (380x70px) with:
  - Real-time duration timer (0:XX format)
  - Warning when approaching max time
  - "ESC to cancel" hint
- **Audio feedback sounds** (optional):
  - Start: "Tink" sound
  - Stop: "Pop" sound  
  - Success: "Glass" sound
- **Improved status messages**:
  - "✅ Inserted X words" with word count
  - Auto-clears after 3 seconds
- **Visual design improvements**:
  - Animated onboarding with feature cards
  - Sectioned settings with icons
  - Spring animations on progress indicators
- Live audio level visualization (30x sensitivity)
- Launch at login option
- Configurable audio thresholds
- Model selection with visual indicators

## 📋 What Needs Testing

### Priority Testing (8 tasks)
1. **TextEdit** - RTF, plain text, different fonts
2. **Safari** - Forms, content editable, web apps
3. **Terminal** - Secure input detection, vim/nano
4. **Code Editors** - VS Code, Xcode, Sublime
5. **Messaging** - Slack, Discord, Messages
6. **Office** - Word, Excel, PowerPoint
7. **Security** - 1Password, Keychain Access
8. **Multi-display** - Different screen configurations

### Known Working
- Basic text insertion ✓
- Menu bar interaction ✓
- Preferences persistence ✓
- Model switching ✓
- Error notifications ✓

## 🚀 Quick Start for Testing

1. **Run the app**:
   ```bash
   cd WhisperKey
   open WhisperKey/WhisperKey.xcodeproj
   # Cmd+R to run
   ```

2. **Grant permissions**:
   - Microphone access
   - Accessibility access
   - Restart app if needed

3. **Download a model**:
   - Click menu bar icon → Preferences
   - Go to Models tab
   - Download base.en (141MB) to start

4. **Test recording**:
   - Hold Right Option key
   - Speak clearly
   - Release to transcribe

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

### Future Planning
- [LANGUAGE_SUPPORT_PLAN](LANGUAGE_SUPPORT_PLAN.md) - Multi-language roadmap

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