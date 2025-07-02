# WhisperKey

Privacy-focused local dictation for macOS using OpenAI's Whisper - all processing on your device.

## Quick Start

1. **Press Right Option (⌥)** to start/stop dictation
2. Speak naturally
3. Text appears at your cursor
4. Everything stays on your Mac

## Features

- 🎤 **One-key dictation** - Right Option key toggles recording
- 🔒 **100% private** - No internet required, all processing local
- ⚡ **Apple Silicon optimized** - Uses Metal acceleration
- 📝 **Smart punctuation** - Automatic periods and commas
- 🎯 **Works everywhere** - Any text field in any app

## Installation

### From Release (Coming Soon)
1. Download WhisperKey.dmg
2. Drag to Applications
3. Launch and grant accessibility permission
4. Look for 🎤 in menu bar

### From Source
```bash
git clone https://github.com/BSPLAZA/WhisperKey.git
cd WhisperKey
open WhisperKey/WhisperKey.xcodeproj
# Build and run (Cmd+R)
```

## Usage

### Basic Commands
- **Start/Stop**: Right Option (⌥)
- **Cancel**: Escape while recording
- **Settings**: Click 🎤 in menu bar

### Customizing the Hotkey
Don't like Right Option? Click 🎤 → Settings → Hotkey to choose:
- Caps Lock
- Cmd+Shift+Space  
- F13-F19
- Custom combination

## Technical Details

- **Architecture**: Menu bar app with global hotkey
- **Transcription**: whisper.cpp with Metal acceleration
- **Hotkeys**: HotKey library (reliable Carbon Events)
- **Min macOS**: 13.0 (Ventura)

## Privacy Promise

- ✅ No network connections
- ✅ No analytics or telemetry  
- ✅ No data leaves your device
- ✅ Open source for transparency

## Documentation

- [Development Guide](docs/README.md) - For contributors
- [Architecture Decision Records](docs/DECISIONS.md) - Why we built it this way

---

*WhisperKey - Dictation that respects your privacy*