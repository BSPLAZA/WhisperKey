# WhisperKey

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-12.0%2B-blue.svg)](https://www.apple.com/macos)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Release](https://img.shields.io/badge/Version-1.0.1-green.svg)](https://github.com/BSPLAZA/WhisperKey/releases/tag/v1.0.1)

**Privacy-focused local dictation for macOS**

> 🚀 **v1.0.1 Released!** (July 15, 2025): Critical fixes including bundled whisper.cpp - no manual installation needed! [See release notes](docs/RELEASE_NOTES_v1.0.1.md)

WhisperKey brings the power of OpenAI's Whisper AI to your Mac for fast, accurate speech-to-text that works in any app. Your voice never leaves your device.

## Features

- 🎙️ **Works Everywhere** - Dictate into any text field in any app
- 🔒 **100% Private** - All processing happens locally on your Mac
- ⚡ **Fast & Accurate** - Powered by Whisper AI with Metal acceleration
- 🎯 **Simple to Use** - Just tap your hotkey and speak
- 🎨 **Native Mac App** - Clean menu bar interface that feels right at home
- ⏱️ **Recording Timer** - See how long you've been recording with live audio levels
- 🔊 **Smart Audio Feedback** - Different sounds for success vs clipboard saves
- 📋 **Clipboard Fallback** - Automatically saves to clipboard when not in a text field
- ⚙️ **Customizable** - Adjust silence detection, microphone sensitivity, and more

## Quick Start

1. **Download & Launch** - Get the latest release and run WhisperKey
2. **Complete Setup** - Follow the onboarding wizard
3. **Grant Permissions** - Allow microphone and accessibility access
4. **Start Dictating** - Tap Right Option (⌥) to start/stop recording

*Note: As of v1.0.1, whisper.cpp is bundled with the app - no separate installation needed!*

## Default Hotkey

**Right Option (⌥)** - Tap once to start recording, tap again to stop

You can change this in Settings to F13 if preferred.

## Installation

### Option 1: Download Release (Recommended)
1. Download the latest WhisperKey.dmg from [Releases](https://github.com/BSPLAZA/WhisperKey/releases)
2. Open the DMG and drag WhisperKey to Applications
3. **Important - Security Steps**:
   - Right-click WhisperKey in Applications and select "Open"
   - You'll see a warning about an unidentified developer
   - Click "Open" to proceed
   - If the above doesn't work:
     - Open System Settings → Privacy & Security
     - Scroll to the bottom
     - Look for "WhisperKey was blocked..." and click "Open Anyway"
4. Follow the onboarding wizard which will:
   - Guide you through permission setup
   - Download AI models automatically
   - Configure your preferences

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
- **whisper.cpp** (v1.0.1+ includes bundled binary or guides installation)

## Tips

- Speak clearly and at a normal pace
- WhisperKey automatically stops after 2.5 seconds of silence
- The menu bar icon turns red while recording
- A floating window shows recording time and audio levels
- Press ESC to cancel recording
- Cannot dictate into password fields for security
- Success message shows word count inserted

## Current Limitations

**v1.0.1 Fixed:**
- ✅ Now includes bundled whisper.cpp binary
- ✅ Models download to `~/.whisperkey/models/` (no manual setup)
- ✅ Improved error handling and disk space checks
- ✅ Better model detection across multiple paths

**Still Present:**
- App is unsigned - right-click and "Open" on first launch
- English models only (multilingual coming soon)

**Coming in v1.1:**
- Code signing and notarization (no more security warnings)
- Multilingual support (UI and models)
- Custom vocabulary support

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

- System sounds may be transcribed (e.g., notifications appear as "bell dings")
- Recording indicator may appear behind full-screen apps
- No formatting preservation (plain text only)
- Single audio device support (doesn't handle switching mid-recording)
- Custom vocabulary not yet supported

## Support

Having issues? Check the [troubleshooting guide](docs/troubleshooting) or [open an issue](https://github.com/BSPLAZA/WhisperKey/issues).

## License

WhisperKey is open source software licensed under the [MIT License](LICENSE).

---

Made with 🎤 for the Mac community