# WhisperKey

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-12.0%2B-blue.svg)](https://www.apple.com/macos)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Beta](https://img.shields.io/badge/Status-Beta-orange.svg)](https://github.com/BSPLAZA/WhisperKey/releases)

**Privacy-focused local dictation for macOS**

> ⚠️ **BETA SOFTWARE**: This is our first public release! While core functionality is solid, you may encounter some rough edges. Please report any issues you find.

WhisperKey brings the power of OpenAI's Whisper AI to your Mac for fast, accurate speech-to-text that works in any app. Your voice never leaves your device.

## Features

- 🎙️ **Works Everywhere** - Dictate into any text field in any app
- 🔒 **100% Private** - All processing happens locally on your Mac
- ⚡ **Fast & Accurate** - Powered by Whisper AI with Metal acceleration
- 🎯 **Simple to Use** - Just tap your hotkey and speak
- 🎨 **Native Mac App** - Clean menu bar interface that feels right at home
- ⏱️ **Recording Timer** - See how long you've been recording
- 🔊 **Audio Feedback** - Optional sounds for start/stop/success

## Quick Start

1. **Download & Launch** - Get the latest release and run WhisperKey
2. **Complete Setup** - Follow the onboarding wizard
3. **Grant Permissions** - Allow microphone and accessibility access
4. **Install whisper.cpp** - If not found, WhisperKey will guide you
5. **Start Dictating** - Tap Right Option (⌥) to start/stop recording

## Default Hotkey

**Right Option (⌥)** - Tap once to start recording, tap again to stop

You can change this in Settings to F13 if preferred.

## Installation

### Option 1: Download Beta Release (Recommended)
1. Download the latest beta from the [Releases page](https://github.com/BSPLAZA/WhisperKey/releases)
2. Open the DMG and drag WhisperKey to Applications
3. Launch WhisperKey - it will help you set up whisper.cpp
4. Follow the setup wizard for permissions and model selection

### Option 2: Build from Source
```bash
# First, install whisper.cpp
git clone https://github.com/ggerganov/whisper.cpp
cd whisper.cpp
WHISPER_METAL=1 make -j

# Then build WhisperKey
git clone https://github.com/BSPLAZA/WhisperKey.git
cd WhisperKey
swift build
```

## Requirements

- macOS 12.0 or later
- Apple Silicon or Intel Mac
- ~500MB disk space for AI models
- **whisper.cpp** installed separately (see Beta Limitations)

## Tips

- Speak clearly and at a normal pace
- WhisperKey automatically stops after 2.5 seconds of silence
- The menu bar icon turns red while recording
- A floating window shows recording time and audio levels
- Press ESC to cancel recording
- Cannot dictate into password fields for security
- Success message shows word count inserted

## Beta Limitations

**Current beta requires manual setup:**
- You need to install [whisper.cpp](https://github.com/ggerganov/whisper.cpp) separately
- WhisperKey will guide you if it's not found
- Models need to be downloaded on first use
- Some apps may require additional accessibility permissions

**Coming in v1.0:**
- Bundled whisper.cpp (no separate installation)
- Automatic model downloads
- One-click installer
- More language support in UI

## Models

WhisperKey includes three AI models:
- **Base** - Fastest, good for quick notes
- **Small** - Balanced speed and accuracy (default)
- **Medium** - Best accuracy, slower

## Privacy

WhisperKey is designed with privacy first:
- No internet connection required
- No data leaves your Mac
- No analytics or tracking
- Open source

## Building from Source

Prerequisites:
- Xcode 14.0 or later (or Xcode Command Line Tools)
- [whisper.cpp](https://github.com/ggerganov/whisper.cpp) built with Metal support

```bash
# Clone and build
git clone https://github.com/BSPLAZA/WhisperKey.git
cd WhisperKey
swift build

# Or open in Xcode
open WhisperKey/WhisperKey.xcodeproj
```

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## Known Issues

- Terminal apps may require special handling
- Some Electron apps need extra permissions
- Recording indicator may appear behind full-screen apps
- First launch after granting permissions may require restart

## Support

Having issues? Check the [troubleshooting guide](docs/troubleshooting) or [open an issue](https://github.com/BSPLAZA/WhisperKey/issues).

## License

WhisperKey is open source software licensed under the [MIT License](LICENSE).

---

Made with 🎤 for the Mac community