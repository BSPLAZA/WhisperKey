# WhisperKey

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-12.0%2B-blue.svg)](https://www.apple.com/macos)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Status](https://img.shields.io/badge/Status-Beta-orange.svg)](https://github.com/BSPLAZA/WhisperKey/releases)

<p align="center">
  <img src="docs/assets/whisperkey-icon.png" width="128" height="128" alt="WhisperKey Icon">
</p>

<h3 align="center">Privacy-first dictation for macOS, powered by OpenAI's Whisper</h3>

<p align="center">
  <strong>Your voice never leaves your device.</strong>
</p>

---

## 🎯 What is WhisperKey?

WhisperKey is a macOS menu bar app that lets you dictate text in any application using OpenAI's Whisper AI model. Unlike other dictation services, everything runs 100% locally on your Mac - no internet connection required, no data sent to the cloud.

### Demo
![WhisperKey Demo](docs/assets/demo.gif)
*Dictating into TextEdit with WhisperKey*

## ✨ Features

### Core Functionality
- 🎙️ **Universal Dictation** - Works in any text field, any app
- 🔒 **100% Private** - All processing happens locally, offline
- ⚡ **Metal Acceleration** - Optimized for Apple Silicon
- 🎯 **One-Tap Activation** - Just tap Right Option (⌥) to start/stop
- 📊 **Real-time Feedback** - See audio levels and recording duration

### Smart Features
- 🔇 **Auto-Stop on Silence** - Stops after 2.5s of quiet (configurable)
- 🚫 **Secure Field Detection** - Won't record in password fields
- 💾 **Multi-Model Support** - Choose accuracy vs speed
- 🔊 **Audio Feedback** - Optional sounds for start/stop/success
- ⏰ **Recording Timer** - Never lose track of time
- 📝 **Word Count** - See how many words were inserted

### Developer Friendly
- 🛠️ **Open Source** - MIT licensed, modify as needed
- 🐛 **Debug Mode** - Built-in logging for troubleshooting
- 📦 **No Dependencies** - Just whisper.cpp (included in setup)
- 🔧 **Extensible** - Clean architecture for contributions

## 🚀 Installation

### Easy Install (Recommended)
*Coming in v1.1 - For now, use manual installation*

### Manual Installation

1. **Install whisper.cpp** (one-time setup):
   ```bash
   # Install Xcode Command Line Tools if needed
   xcode-select --install
   
   # Clone and build whisper.cpp
   mkdir -p ~/Developer && cd ~/Developer
   git clone https://github.com/ggerganov/whisper.cpp.git
   cd whisper.cpp
   WHISPER_METAL=1 make -j  # Use Metal acceleration
   
   # Download a model (start with base for testing)
   cd models
   bash ./download-ggml-model.sh base.en
   ```

2. **Install WhisperKey**:
   - Download latest release from [Releases](https://github.com/BSPLAZA/WhisperKey/releases)
   - Drag WhisperKey.app to Applications
   - Launch and grant permissions

See [detailed setup guide](docs/WHISPER_SETUP.md) for more options and troubleshooting.

## 🎮 How to Use

1. **Launch WhisperKey** - Look for 🎤 in your menu bar
2. **Click any text field** where you want to dictate
3. **Tap Right Option (⌥)** to start recording
4. **Speak clearly** - The icon turns red while recording
5. **Tap again to stop** or just pause speaking
6. **Watch your words appear!** ✨

### Tips for Best Results
- Speak at a normal pace
- Pause briefly between sentences
- Use a good microphone if possible
- Start with smaller models for speed
- Enable debug logging if you have issues

## ⚙️ Configuration

Access preferences from the menu bar icon:

### General Tab
- **Activation Key**: Right Option or F13
- **Launch at Login**: Start with macOS
- **Visual/Audio Feedback**: Customize notifications

### Recording Tab
- **Silence Duration**: How long to wait (1-5 seconds)
- **Sensitivity**: Adjust for your environment
- **Max Duration**: Prevent runaway recordings

### Models Tab
- **Download Models**: Get different AI models
- **Select Active Model**: Balance speed vs accuracy

## 🗺️ Roadmap

### v1.1 (Next Release)
- [ ] Automated installer (no command line needed!)
- [ ] Custom model paths
- [ ] Homebrew cask support
- [ ] Apple Silicon native models
- [ ] Bug fixes from v1.0 feedback

### v1.2 (Q3 2025)
- [ ] Multi-language support (99 languages)
- [ ] Custom vocabulary/dictionary
- [ ] Text replacement shortcuts
- [ ] Punctuation commands
- [ ] Export/import settings

### v2.0 (Future)
- [ ] Real-time transcription
- [ ] Voice commands ("new paragraph", "comma")
- [ ] Multiple audio inputs
- [ ] Team sharing features
- [ ] Windows/Linux support

### Under Consideration
- App Store version (simplified)
- iCloud sync for settings
- Transcription history
- Voice training
- API for developers

## ⚠️ Current Limitations

### Beta Status
This is beta software. While it works well, you may encounter:
- Occasional crashes (please report!)
- Setup complexity (improving in v1.1)
- Limited to English models in UI
- Models must be in specific directory

### Known Issues
- Large model downloads may fail (workaround: manual download)
- Some apps may not accept text insertion (use clipboard mode)
- Permissions might need app restart
- Debug logging can affect performance

### Technical Limitations
- Requires whisper.cpp installation
- Models take significant disk space (141MB - 3GB)
- First transcription is slower (model loading)
- Max 60 seconds per recording

## 🔒 Privacy & Security

### Our Commitment
- **No Network Access**: WhisperKey has no internet code
- **No Analytics**: We don't track anything
- **No Accounts**: No sign-up, no cloud
- **Open Source**: Audit the code yourself

### Permissions Explained
- **Microphone**: To record your voice
- **Accessibility**: To insert text at cursor
- Both permissions are macOS standard, revocable anytime

### Security Notes
- Audio files are temporary, deleted immediately
- Refuses to record in password fields
- All processing is sandboxed to the app
- No data persistence between sessions

## 🤝 Contributing

We love contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Development setup
- Code style guide
- Testing procedures
- Pull request process

### Good First Issues
- Add new languages to UI
- Improve error messages
- Create app icon variations
- Write documentation
- Add unit tests

## 📈 Performance

Typical performance on Apple Silicon:

| Model | Size | Load Time | Words/Second |
|-------|------|-----------|--------------|
| base.en | 141MB | 0.5s | ~150 |
| small.en | 465MB | 1s | ~100 |
| medium.en | 1.4GB | 2s | ~50 |
| large-v3 | 3.1GB | 4s | ~25 |

*Results vary by hardware and audio quality*

## 🐛 Troubleshooting

### WhisperKey won't start
1. Check macOS version (12.0+)
2. Verify app isn't damaged: `xattr -cr /Applications/WhisperKey.app`
3. Check Console.app for errors

### No text appears
1. Grant accessibility permission
2. Try different app
3. Enable debug logging
4. Check if secure field

### Poor accuracy
1. Use better microphone
2. Reduce background noise
3. Try larger model
4. Speak more clearly

See [full troubleshooting guide](docs/troubleshooting) for more.

## 📝 License

MIT License - see [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

- [OpenAI Whisper](https://github.com/openai/whisper) for the amazing AI model
- [whisper.cpp](https://github.com/ggerganov/whisper.cpp) for the fast C++ implementation
- [HotKey](https://github.com/soffes/HotKey) for reliable keyboard shortcuts
- The macOS developer community for inspiration

## 📬 Contact

- **Issues**: [GitHub Issues](https://github.com/BSPLAZA/WhisperKey/issues)
- **Discussions**: [GitHub Discussions](https://github.com/BSPLAZA/WhisperKey/discussions)
- **Security**: See [SECURITY.md](SECURITY.md)

---

<p align="center">
  Made with 🎤 and ❤️ for the Mac community
</p>

<p align="center">
  <a href="https://github.com/BSPLAZA/WhisperKey/stargazers">⭐ Star us on GitHub!</a>
</p>