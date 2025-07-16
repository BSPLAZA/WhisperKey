# WhisperKey Release Notes

> Track features, fixes, and known issues for each release

## v1.0.1 (July 15, 2025)

**Release Date**: July 15, 2025  
**Type**: Hotfix Release  
**Status**: Released

Critical fixes for first-run experience. See [v1.0.1 Release Notes](RELEASE_NOTES_v1.0.1.md) for details.

### Key Fixes
- Bundled whisper.cpp binary (no manual installation)
- Fixed model download issues
- Improved resource detection
- Better error handling

---

## v1.0.0 (July 14, 2025)

**Release Date**: July 14, 2025  
**Status**: Initial Release  
**Last Updated**: 2025-07-14

### 🎯 Overview

WhisperKey v1.0 delivers a privacy-focused local dictation app for macOS using Whisper AI. After extensive development and user feedback, we've created a polished experience that prioritizes accuracy and simplicity over real-time streaming.

### ✨ Key Features

#### Core Functionality
- **Local-only transcription** - Your voice never leaves your Mac
- **Whisper AI integration** - State-of-the-art speech recognition
- **Metal acceleration** - Optimized for Apple Silicon (M1/M2/M3/M4)
- **Right Option hotkey** - Natural trigger for dictation
- **Automatic silence detection** - Stops recording after 2.5s of silence
- **60-second timeout** - Prevents accidental long recordings

#### User Experience
- **Menu bar app** - Always accessible, never in the way
- **Visual recording indicator** - Floating window with live audio levels
- **Status feedback** - Clear emoji indicators for all states
- **Comprehensive preferences** - 4-tab window with all settings
- **Model download manager** - In-app downloads from HuggingFace
- **Launch at login** - Optional auto-start capability

#### Security & Privacy
- **Secure field detection** - Blocks recording in password fields
- **Terminal secure input aware** - Respects system security
- **No network requests** - Except for model downloads
- **No telemetry** - Your data stays yours
- **Automatic cleanup** - Temp files deleted after use

#### Technical Excellence
- **30+ error types** - Specific guidance for every issue
- **Permission handling** - Clean flow without duplicate dialogs
- **Memory efficient** - ~50MB idle, ~200MB active
- **Fast response** - <3s from speech to text
- **Multiple model support** - Base, Small, Medium (English)

### 🔄 Changes from Initial Design

#### Removed Features
- **Streaming transcription** - Removed for quality (was producing 1-6/10 accuracy)
- **F5 hotkey support** - System reserves this key
- **Carbon hotkey API** - Using NSEvent monitoring for Right Option

#### Architecture Changes
- **Menu bar app** instead of background service
- **Single transcription mode** instead of streaming/non-streaming options
- **Simplified audio pipeline** without real-time processing
- **Direct whisper.cpp integration** instead of Core ML

### 📊 Performance

- **Transcription Accuracy**: 10/10 (non-streaming mode)
- **Response Time**: 2-3 seconds end-to-end
- **Memory Usage**: 50MB idle, 200MB active
- **CPU Usage**: Minimal when idle, spike during transcription
- **Model Performance**:
  - Base (141MB): Fastest, good for quick notes
  - Small (465MB): Balanced speed and accuracy
  - Medium (1.4GB): Best accuracy for complex content

### 🛠️ Recent Fixes (July 2025)

1. **Fixed critical text insertion bug** - Text now properly inserts at cursor
2. **Improved sound feedback** - Context-appropriate sounds for success/errors
3. **Fixed permission dialog crashes** - Proper window lifecycle management
4. **Settings auto-save** - All preferences now persist correctly
5. **Smart clipboard fallback** - Graceful handling when not in text field
6. **No more error sounds** - Fixed keyboard simulation in non-text areas

### 🐛 Known Issues

1. **Right Option key only** - Other modifier-only keys not supported
2. **English models only** - Multilingual support planned for v2
3. **No custom vocabulary** - Cannot add specialized terms yet
4. **Single audio device** - Doesn't handle device switching mid-recording
5. **Basic text insertion** - No formatting preservation
6. **System sounds captured** - May transcribe notification sounds as "(bell dings)"

### 📋 System Requirements

- **macOS**: 13.0 (Ventura) or later
- **Hardware**: Apple Silicon recommended, Intel supported
- **Memory**: 4GB RAM minimum, 8GB recommended
- **Storage**: 2GB for app and models
- **Permissions**: Microphone and Accessibility

### 🚀 Installation

1. Download WhisperKey.app
2. Move to Applications folder
3. Launch and grant permissions
4. Download desired Whisper model
5. Test with Right Option key

### 🔮 Future Plans (v2.0)

- Multilingual model support
- Custom vocabulary/corrections
- Keyboard shortcuts customization
- Integration with text expanders
- Markdown formatting support
- Voice commands for editing

### 🙏 Acknowledgments

- [whisper.cpp](https://github.com/ggerganov/whisper.cpp) by Georgi Gerganov
- [OpenAI Whisper](https://github.com/openai/whisper) team
- Early testers and feedback providers

### 📝 Migration Notes

For users coming from other dictation apps:
- **From macOS Dictation**: Better accuracy, no internet required
- **From Dragon**: Simpler, more private, Mac-native
- **From Otter.ai**: Fully local, no subscription
- **From Google Voice Typing**: Privacy-focused, works offline

---

## Development History

### Pre-Release Milestones

#### 2025-07-01: Day 1
- Initial implementation with F5 key attempt
- Discovered F5 system reservation
- Pivoted to menu bar architecture
- Implemented audio pipeline
- Added streaming (later removed)
- Achieved basic functionality

#### 2025-07-02: Day 2
- Added visual recording indicator
- Implemented preferences window
- Fixed UI issues based on feedback
- Added model download manager
- Achieved feature completeness
- Entered testing phase

### Beta Feedback Incorporated
- Increased recording indicator width
- Removed confusing double ellipses
- Made audio levels responsive
- Simplified menu bar icon
- Eliminated duplicate permission dialogs

---

*Last Updated: 2025-07-02 16:50 PST*