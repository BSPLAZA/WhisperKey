# WhisperKey v1.0.0 - Initial Release

🎉 **Welcome to WhisperKey** - The privacy-focused local dictation app for macOS that puts you in control of your voice and your data.

## 🌟 What is WhisperKey?

WhisperKey brings the power of OpenAI's Whisper AI to your Mac's menu bar, enabling fast, accurate voice-to-text transcription that runs entirely on your device. No internet connection required. No data leaves your Mac. Ever.

Simply tap the Right Option key, speak naturally, and watch your words appear at the cursor - in any app, any text field, anywhere on macOS.

## ✨ Key Features

### 🎙️ Effortless Voice Input
- **One-tap recording**: Just tap Right Option (or F13) to start/stop
- **Smart silence detection**: Automatically stops when you pause (customizable 0.5-5 seconds)
- **Visual feedback**: Real-time recording indicator shows duration and audio levels
- **Audio cues**: Optional sound effects for start, stop, and successful transcription

### 🧠 Powered by Whisper AI
- **Multiple model options**: 
  - `base.en` (74MB) - Fast, good for quick notes
  - `small.en` (234MB) - Balanced speed and accuracy
  - `medium.en` (1.42GB) - High accuracy for longer dictation
  - `large-v3` (2.87GB) - Best accuracy, supports 99 languages
- **Metal acceleration**: Optimized for Apple Silicon (M1/M2/M3/M4)
- **Built-in downloader**: Download models directly from the app

### 🔒 Privacy First
- **100% local processing**: No internet required for transcription
- **No analytics**: We don't track anything you say or do
- **No accounts**: No sign-ups, no logins, no cloud services
- **Secure by design**: Automatically blocks recording in password fields

### 🎯 Smart Integration
- **Works everywhere**: Any app, any text field (except secure fields)
- **Intelligent fallback**: If text can't be inserted, saves to clipboard with notification
- **Context aware**: Shows different feedback for successful insertion vs clipboard save
- **Native macOS**: Feels right at home on your Mac

### ⚙️ Thoughtful Design
- **Menu bar app**: Always accessible, never in your way
- **5-step onboarding**: Guides you through permissions and setup
- **Comprehensive preferences**:
  - General: Choose hotkey, enable launch at login
  - Recording: Adjust silence duration, sensitivity, max recording time
  - Models: Download and switch between Whisper models
  - Advanced: Debug mode, cleanup options, reset settings
- **Word count feedback**: Know exactly how much you dictated

## 📋 System Requirements

- **macOS**: 12.0 (Monterey) or later
- **Hardware**: Apple Silicon recommended, Intel Macs supported
- **Storage**: ~500MB for base model, up to 3GB for large model
- **Dependencies**: whisper.cpp (instructions included)
- **Permissions**: Microphone and Accessibility access required

## 🚀 Getting Started

### Installation
1. Download `WhisperKey-1.0.0.dmg` from the releases page
2. Open the DMG and drag WhisperKey to your Applications folder
3. **Important**: Right-click WhisperKey and select "Open" (required for unsigned apps)
4. Follow the 5-step onboarding wizard

### First-Time Setup
The onboarding wizard will guide you through:
- Step 1: Welcome and feature overview
- Step 2: Granting necessary permissions (Microphone & Accessibility)
- Step 3: Installing whisper.cpp (if needed)
- Step 4: Downloading your first AI model
- Step 5: Configuration and you're ready!

### Quick Start Guide
1. Look for the microphone icon in your menu bar
2. Click it to see status and access preferences
3. Place your cursor where you want text
4. Tap Right Option to start recording
5. Speak naturally
6. Tap Right Option again or pause to stop
7. Your transcribed text appears instantly!

## 🛠️ Technical Details

### Architecture
- Built with Swift 5.9 and SwiftUI
- Menu bar architecture for minimal resource usage
- Efficient memory management with ring buffers
- Async/await for responsive UI

### Performance
- Cold start: <2 seconds
- Recording latency: <50ms
- Transcription: 1-3 seconds for 10 seconds of audio
- Memory usage: ~50MB idle, ~200MB during transcription

### Security Features
- Sandboxed with minimal entitlements
- No network entitlements (cannot connect to internet)
- Secure input field detection prevents password recording
- Automatic cleanup of temporary audio files

## ⚠️ Known Limitations

### Current Release
- Models must be installed in `~/Developer/whisper.cpp/models/`
- UI currently shows only English models (multilingual models work via CLI)
- Custom model paths not yet configurable through preferences
- macOS will show security warning on first launch (app is not signed)

### Planned Improvements
- Code signing and notarization for smoother installation
- Custom model path selection
- Multilingual model UI support
- App Store release

## 🤝 Open Source

WhisperKey is open source and available on GitHub. We welcome:
- Bug reports and feature requests
- Code contributions
- Documentation improvements
- Community support

## 📝 Tips & Tricks

### For Best Results
- Speak clearly at a normal pace
- Position your Mac's microphone 1-2 feet away
- Use in a quiet environment for best accuracy
- Start with the small.en model for balanced performance

### Power User Features
- Hold Shift while clicking "Quit" to force quit if needed
- Check Advanced preferences for debug logging
- Use "Reset All Settings" if you encounter issues
- Recording automatically stops at 60 seconds (configurable)

## 🙏 Acknowledgments

- Built on [whisper.cpp](https://github.com/ggerganov/whisper.cpp) by Georgi Gerganov
- Uses OpenAI's [Whisper](https://github.com/openai/whisper) models
- [HotKey](https://github.com/soffes/HotKey) library for reliable hotkey handling

## 📞 Support

- **Issues**: Report bugs on [GitHub Issues](https://github.com/BSPLAZA/WhisperKey/issues)
- **Discussions**: Join our [GitHub Discussions](https://github.com/BSPLAZA/WhisperKey/discussions)
- **Documentation**: See the [docs folder](https://github.com/BSPLAZA/WhisperKey/tree/main/docs)

## 🎯 Why WhisperKey?

In a world where voice assistants send everything to the cloud, WhisperKey takes a different approach. Your voice is personal. Your thoughts are private. Your Mac is powerful enough to handle transcription locally. WhisperKey brings these principles together in a simple, reliable tool that respects your privacy while delivering exceptional accuracy.

---

**Note on Security Warning**: This release is not code-signed. macOS will display a security warning on first launch. This is normal for open-source releases. To open the app, right-click on WhisperKey and select "Open" from the context menu. You'll only need to do this once.

**Coming Soon**: Developer account and code signing are planned for future releases to eliminate this friction.

---

Thank you for trying WhisperKey! We hope it becomes an indispensable part of your Mac workflow. 🚀