# WhisperKey v1.0.2 Release Notes

**Release Date**: July 17, 2025  
**Type**: Bug Fix Release

## 🐛 Bug Fixes

### Keyboard Focus After Dictation
- **Fixed**: Enter key and other keyboard shortcuts now work immediately after dictation in most applications
- **Technical**: Implemented proper event stream termination using space+backspace technique
- **Impact**: Significant UX improvement - no more clicking or typing required before pressing Enter

### Recording Indicator Visibility
- **Fixed**: Recording indicator now appears properly in web browsers and all window contexts
- **Technical**: Changed window level from `statusBar` to `floatingWindow + 1`
- **Impact**: Users always have visual feedback that recording is active

## ⚠️ Known Limitations

### Brave Browser URL Bar
- **Issue**: After dictation in Brave's URL bar, users must press Space then Enter
- **Reason**: This is an intentional security feature in Brave, not a bug in WhisperKey
- **Workaround**: Simply press Space after dictation, then Enter to navigate
- **Note**: Regular text fields in Brave work perfectly - only the URL bar is affected
- **Documentation**: See [BRAVE_BROWSER_ANALYSIS.md](docs/BRAVE_BROWSER_ANALYSIS.md) for technical details

## 🔧 Other Improvements

### Documentation
- Added comprehensive analysis of Brave browser behavior
- Updated KNOWN_ISSUES.md with Brave limitation
- Improved technical documentation for future contributors

### DMG Installer
- Enhanced DMG creation script with better visual instructions
- Added arrow graphic pointing from app to Applications folder
- Improved first-time user experience

## 📦 Installation

### New Users
1. Download WhisperKey-1.0.2.dmg
2. Open the DMG and drag WhisperKey to Applications folder
3. Launch WhisperKey and follow the setup wizard

### Existing Users
1. Quit WhisperKey from the menu bar
2. Replace the existing app with the new version
3. Your settings will be preserved

### Security Note
When you see "unidentified developer" warning:
1. Go to System Settings → Privacy & Security
2. Click "Open Anyway" next to WhisperKey
3. Launch WhisperKey again

## 🙏 Acknowledgments

Special thanks to @mikeypikeyfreep for reporting the keyboard focus issue and helping us identify the Brave browser behavior.

## 📝 Technical Details

### Fixed Issues
- GitHub Issue #5: Keys don't work after dictation
- Recording UI not appearing in certain windows

### Compatibility
- macOS 12.0 or later
- Intel and Apple Silicon support
- Tested with Safari, Chrome, Firefox, and Brave browsers

### Dependencies
- whisper.cpp (bundled)
- Metal framework (for acceleration)

## 🔗 Links

- [Download WhisperKey-1.0.2.dmg](#)
- [GitHub Repository](https://github.com/BSPLAZA/WhisperKey)
- [Report Issues](https://github.com/BSPLAZA/WhisperKey/issues)

---

*WhisperKey is open source software released under the MIT License*