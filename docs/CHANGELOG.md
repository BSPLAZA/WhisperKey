# Changelog

All notable changes to WhisperKey will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of WhisperKey
- Menu bar app with dropdown controls
- Right Option key hotkey for hands-free recording
- Audio recording with automatic silence detection (2.5s)
- Whisper transcription using whisper.cpp with Metal acceleration
- Visual recording indicator with live audio level display
- Comprehensive preferences window with 4 tabs
- Model download manager for Whisper models
- 30+ specific error types with recovery suggestions
- Secure field detection to prevent recording in password fields
- 60-second recording timeout
- Automatic temp file cleanup
- Launch at login option
- Support for base.en, small.en, and medium.en models

### Changed
- Pivoted from F5 key to Right Option due to system restrictions
- Removed streaming transcription mode for better accuracy
- Simplified architecture to single transcription mode
- Increased recording indicator width from 200px to 320px
- Changed menu bar icon from mic.circle to mic for visibility
- Adjusted audio level sensitivity from 50x to 30x

### Fixed
- Double ellipses in recording indicator
- Audio level bars not responding to input
- Duplicate permission dialogs
- Swift 6 compatibility issues
- Deprecated API usage (NSUserNotification → UserNotifications)
- Model path concatenation missing forward slash

### Security
- All processing happens locally
- No network connections except model downloads
- Blocks recording in secure text fields
- Respects Terminal secure input mode

## [0.9.0] - 2025-07-02 (Pre-release)

### Development Milestones
- Day 1: Core functionality implementation
- Day 1: Discovered F5 key limitations
- Day 1: Pivoted to menu bar architecture
- Day 1: Implemented and removed streaming mode
- Day 2: Added visual feedback and preferences
- Day 2: Fixed UI issues based on user feedback
- Day 2: Achieved feature completeness

### Known Issues
- Right Option key only (no other modifier-only keys)
- English models only
- No custom vocabulary support
- Doesn't handle audio device switching mid-recording
- Basic text insertion without formatting

---

## Version History Summary

### Pre-1.0 Development Timeline

**2025-07-01**: Project initiated
- Set up documentation structure
- Built whisper.cpp with Metal support
- Downloaded Whisper models
- Attempted F5 key interception (failed)
- Pivoted to menu bar app with Right Option
- Implemented basic recording and transcription
- Added streaming mode
- Removed streaming mode due to quality issues

**2025-07-02**: Polish and completion
- Added visual recording indicator
- Implemented preferences window
- Fixed UI issues from user feedback
- Added model download functionality
- Fixed build errors
- Updated all documentation
- Prepared for testing phase

### Versioning Strategy
- 0.x.x: Pre-release development
- 1.0.0: First public release
- 1.x.x: Feature additions and improvements
- 2.0.0: Major architectural changes or breaking features

---

*For detailed release information, see [RELEASE_NOTES.md](RELEASE_NOTES.md)*