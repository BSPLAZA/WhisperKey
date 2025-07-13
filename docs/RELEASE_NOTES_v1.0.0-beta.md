# WhisperKey v1.0.0-beta Release Notes

*Release Date: July 13, 2025*

## 🎉 Welcome to WhisperKey!

WhisperKey is a privacy-focused local dictation app for macOS that brings the power of OpenAI's Whisper to your Mac. All transcription happens locally on your device - your voice never leaves your computer.

## ✨ Key Features

### 🎤 Local Voice Transcription
- Powered by OpenAI's Whisper running locally
- Metal acceleration for Apple Silicon
- Support for multiple model sizes (base, small, medium)
- No internet connection required

### ⌨️ Seamless Text Input
- Works in any app that accepts text
- Smart clipboard fallback for non-text areas
- Automatic text insertion at cursor
- Optional "Always save to clipboard" mode

### 🎯 Simple Controls
- Single hotkey activation (Right Option key by default)
- Tap to start/stop recording
- Automatic silence detection (2.5 seconds)
- Visual recording indicator with timer

### 🔐 Privacy First
- All processing happens locally
- No network connections (except model downloads)
- No telemetry or usage tracking
- Your voice data never leaves your Mac

### 🎨 Polished User Experience
- Beautiful onboarding wizard
- Organized settings with visual sections
- Audio feedback for all actions
- Real-time audio level monitoring
- Clipboard notifications with word count

## 🚀 Getting Started

1. **Launch WhisperKey** - Menu bar icon appears
2. **Complete Onboarding** - Grant permissions and download a model
3. **Start Dictating** - Tap Right Option key and speak
4. **Stop Recording** - Tap again or wait for silence detection

## ⚙️ System Requirements

- macOS 14.0 (Sonoma) or later
- Apple Silicon (M1/M2/M3/M4) or Intel Mac
- ~500MB disk space for app and models
- Microphone access permission
- Accessibility permission for text insertion

## 📦 What's Included

### Models Available
- **base.en** (141MB) - Fast, good accuracy
- **small.en** (465MB) - Balanced speed and accuracy
- **medium.en** (1.4GB) - Best accuracy, slower

### Customization Options
- Adjustable silence detection (1-5 seconds)
- Microphone sensitivity settings
- Recording time limits (30-120 seconds)
- Alternative hotkey (F13)
- Launch at login option

## 🐛 Known Issues

### Minor Issues
- System sounds (notifications) may be transcribed as "bell dings"
- No support for audio device switching during recording
- English language models only in this release
- Plain text only (no rich text formatting)

### Workarounds
- **For password fields**: Text automatically saved to clipboard
- **For non-text areas**: Use clipboard mode (shows notification)
- **For secure fields**: Recording works but uses clipboard

## 🔄 Changes from Previous Versions

### New in v1.0.0-beta
- Complete UI overhaul with premium design
- Smart clipboard fallback system
- Context-aware sound feedback
- Auto-refreshing permission dialogs
- Enhanced onboarding with animations
- Improved error recovery
- Better visual organization in settings

### Fixed Issues
- Text insertion now works reliably
- No more error sounds in non-text areas
- Settings properly persist
- Window management crashes resolved
- Permission dialogs update automatically

## 📝 Feedback

This is a beta release. We'd love to hear your feedback:
- Report issues on GitHub
- Share feature requests
- Let us know what works well

## 🙏 Acknowledgments

WhisperKey is built on top of amazing open source projects:
- [OpenAI Whisper](https://github.com/openai/whisper)
- [whisper.cpp](https://github.com/ggerganov/whisper.cpp)
- SwiftUI and the macOS development community

---

**Note**: This is beta software. While it's feature complete and tested, you may encounter bugs. Please report any issues you find.

Enjoy dictating with WhisperKey! 🎉