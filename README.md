# WhisperKey

Privacy-focused local dictation for macOS using OpenAI's Whisper AI. Your voice never leaves your Mac.

## ✨ Features

- 🎤 **One-key dictation** - Hold Right Option (⌥) to record
- 🔒 **100% private** - No internet required, fully local processing
- ⚡ **Apple Silicon optimized** - Metal acceleration for M1/M2/M3/M4
- 🎯 **Works everywhere** - Any text field in any app
- 📊 **Visual feedback** - See audio levels while recording
- ⚙️ **Customizable** - Adjust silence detection, choose models
- 🛡️ **Security aware** - Blocks recording in password fields

## 🚀 Quick Start

1. **Hold Right Option (⌥)** to start recording
2. **Speak naturally** - Recording stops after 2.5s of silence
3. **Release** to stop manually
4. **Text appears** at your cursor automatically

### First Time Setup
1. Grant microphone permission when prompted
2. Grant accessibility permission when prompted
3. Download a Whisper model (base.en recommended to start)
4. You're ready to dictate!

## 📦 Installation

### Requirements
- macOS 13.0 (Ventura) or later
- 4GB RAM (8GB recommended)
- 2GB free space for app and models
- Microphone and Accessibility permissions

### From Release (Coming Soon)
1. Download WhisperKey.dmg from [Releases](https://github.com/BSPLAZA/WhisperKey/releases)
2. Drag WhisperKey to Applications
3. Launch and follow setup wizard
4. Look for 🎤 in your menu bar

### From Source
```bash
# Prerequisites: Xcode 15+, whisper.cpp
git clone https://github.com/BSPLAZA/WhisperKey.git
cd WhisperKey
open WhisperKey/WhisperKey.xcodeproj

# Add Swift Package: https://github.com/soffes/HotKey
# Build and run with Cmd+R
```

## 🎯 Usage

### Recording
- **Start**: Hold Right Option (⌥)
- **Stop**: Release key or wait for silence
- **Cancel**: Press Escape while recording
- **Status**: Watch the floating indicator

### Menu Bar
Click the 🎤 icon to:
- See current status
- Open Preferences
- Quit app

### Preferences
- **General**: Hotkey, startup, visual feedback
- **Recording**: Silence duration, threshold, timeout
- **Models**: Download and select Whisper models
- **Advanced**: Debug mode, reset settings

## 🧠 Whisper Models

| Model | Size | Speed | Accuracy | Use Case |
|-------|------|-------|----------|----------|
| base.en | 141MB | Fast (~2s) | Good | Quick notes, casual use |
| small.en | 465MB | Balanced (~3s) | Better | Daily dictation |
| medium.en | 1.4GB | Slower (~5s) | Best | Professional writing |

Models download from HuggingFace on first use.

## 🏗️ Architecture

- **UI Framework**: SwiftUI + AppKit
- **Transcription**: [whisper.cpp](https://github.com/ggerganov/whisper.cpp) with Metal
- **Hotkeys**: [HotKey](https://github.com/soffes/HotKey) library
- **Audio**: AVAudioEngine with real-time processing
- **Text Insertion**: Accessibility API (AXUIElement)

## 🔒 Privacy & Security

WhisperKey is designed with privacy first:

- ✅ **No network access** - Except optional model downloads
- ✅ **No telemetry** - We don't track anything
- ✅ **No accounts** - No sign-up required
- ✅ **No cloud** - Everything stays on your Mac
- ✅ **Open source** - Verify the code yourself
- 🛡️ **Secure fields** - Automatically blocks password recording

All audio is processed locally using Whisper AI and deleted immediately after transcription.

## 🤝 Contributing

We welcome contributions! See [Development Guide](docs/README.md) for setup instructions.

### Key Documents
- [Architecture Decisions](docs/DECISIONS.md) - Why we built it this way
- [API Reference](docs/API_REFERENCE.md) - Internal documentation
- [Testing Guide](docs/TESTING_GUIDE.md) - How to test thoroughly
- [Issues & Solutions](docs/ISSUES_AND_SOLUTIONS.md) - Common problems

## 📝 License

MIT License - See [LICENSE](LICENSE) for details

## 🙏 Acknowledgments

- [OpenAI Whisper](https://github.com/openai/whisper) - Speech recognition model
- [whisper.cpp](https://github.com/ggerganov/whisper.cpp) - C++ implementation
- [HotKey](https://github.com/soffes/HotKey) - Global hotkey handling

---

**WhisperKey** - *Dictation that respects your privacy*

Version 1.0.0-rc1 | Made with ❤️ for the Mac community