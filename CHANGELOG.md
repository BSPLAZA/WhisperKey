# Changelog

All notable changes to WhisperKey will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Model download improvements - better error handling for directory creation

## [1.0.0] - 2025-07-10

### Added
- Initial release of WhisperKey
- Menu bar interface for quick access
- Support for Right Option and F13 hotkeys (tap to toggle)
- Real-time recording indicator with duration timer
- Audio level visualization during recording
- Automatic silence detection (configurable, default 2.5s)
- Maximum recording duration limit (configurable, default 60s)
- Support for Whisper models: base.en, small.en, medium.en, large-v3
- Built-in model downloader with progress tracking
- Comprehensive preferences window with 4 tabs:
  - General: Hotkey selection, launch at login
  - Recording: Silence duration, sensitivity, max duration
  - Models: Download and manage Whisper models
  - Advanced: Debug mode, cleanup, reset
- Onboarding experience for first-time users
- Success feedback showing word count inserted
- Audio feedback sounds (optional): start, stop, success
- Secure input field detection (prevents recording in password fields)
- Memory pressure monitoring
- Automatic temp file cleanup
- Launch at login option

### Technical Features
- 100% local processing - no internet required for transcription
- Metal acceleration support for Apple Silicon
- No data collection or analytics
- Cross-application text insertion
- Smart cursor position detection
- Robust error handling with user-friendly messages
- Memory-efficient audio processing with ring buffer

### Security
- Microphone permission handling
- Accessibility permission for text insertion
- Blocks recording in secure/password fields
- All processing happens locally on device

### Known Limitations
- Models must be in `~/Developer/whisper.cpp/models/` directory
- Multilingual models not yet supported in UI
- Custom model paths not yet configurable

---

## Development Timeline

### 2025-07-10
- Fixed UI issues: timer reset, text truncation, dialog sizing
- Improved onboarding: removed non-working models, fixed permissions
- Prepared for open source release

### 2025-07-09  
- Enhanced UX with recording timer and audio feedback
- Fixed Right Option key detection
- Improved menu bar UI

### 2025-07-02
- Implemented core features
- Built menu bar architecture
- Added preferences window

### 2025-07-01
- Project started
- Initial architecture decisions
- whisper.cpp integration

[Unreleased]: https://github.com/BSPLAZA/WhisperKey/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/BSPLAZA/WhisperKey/releases/tag/v1.0.0