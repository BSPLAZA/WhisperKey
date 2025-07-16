# WhisperKey v1.0.1 Release Notes

**Release Date**: July 16, 2025  
**Version**: 1.0.1  
**Type**: Hotfix Release

## Overview

WhisperKey v1.0.1 is a critical hotfix release that addresses several important issues discovered after the v1.0.0 launch. This update ensures the app works reliably on all systems, improves security, and enhances the overall user experience.

## What's Fixed

### 🔧 Critical Fixes

1. **Missing Library Dependencies**
   - Fixed app crash on launch due to missing GGML libraries
   - All required libraries now properly bundled
   - App is truly self-contained

2. **Audio Feedback Sounds**
   - Fixed sounds not playing despite being enabled
   - Properly initialized UserDefaults
   - Enhanced with actual system sounds (not just beeps)

3. **Settings Synchronization**
   - Settings changed in onboarding now properly sync to preferences
   - Fixed model selection persistence
   - All UI components now share consistent settings

4. **Version Display**
   - Fixed incorrect version string showing "1.01 test v4"
   - About dialog now dynamically reads version from bundle
   - Consistent version numbering throughout the app

### 🎯 Improvements

1. **Updated Default Settings**
   - Default model changed to base.en (faster, smaller)
   - "Always Save to Clipboard" now defaults to No
   - "Launch at Login" now defaults to Yes

2. **Code Quality & Security**
   - Removed all force unwraps for safer code
   - Fixed function naming conventions (SwiftLint compliance)
   - Enhanced error handling throughout
   - Improved input validation

3. **Development Infrastructure**
   - Fixed CI/CD pipeline for automated testing
   - Added security validations to GitHub workflows
   - Implemented dependency caching for faster builds
   - Enhanced code review automation

4. **Code Cleanup**
   - Removed obsolete WhisperSetupAssistant
   - Cleaned up project artifacts and test files
   - Removed outdated development documentation
   - Improved error messages and user feedback

## Technical Details

### Dependencies Fixed
- libggml.dylib
- libggml-base.dylib
- libggml-cpu.dylib
- libggml-blas.dylib
- libggml-metal.dylib

### Settings Migration
All settings now use @AppStorage for proper synchronization:
- Model selection
- Audio feedback preference
- Clipboard behavior
- Launch at login

## Known Issues

### Minor (Non-Critical)
- Models tab could use visual polish to match other tabs
- Long error sound when attempting to type in non-text fields

These will be addressed in a future update.

## Installation

1. Download WhisperKey-1.0.1.dmg
2. Open the DMG file
3. Drag WhisperKey to Applications
4. Launch and enjoy!

## Upgrade Notes

If upgrading from v1.0.0:
- Your settings will be preserved
- You may need to re-grant accessibility permissions
- The default model will remain as your previously selected choice

## System Requirements

- macOS 15.0 (Sequoia) or later
- Apple Silicon (M1/M2/M3/M4) or Intel Mac
- 500MB free disk space
- Accessibility permissions

## Thank You

Thanks to our early adopters who reported these issues. Your feedback helps make WhisperKey better for everyone!

---

For support or questions, please visit: https://github.com/BSPLAZA/WhisperKey