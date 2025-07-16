# User Feedback and Future Improvements

## Date: July 16, 2025

### Live Transcription Feedback
**Issue**: Users prefer Apple-style dictation with live text insertion as they speak
- **Current behavior**: WhisperKey waits until recording stops, then inserts all text at once
- **Desired behavior**: Text appears word-by-word as user speaks (like Apple dictation)
- **Technical challenge**: Would require streaming transcription instead of batch processing
- **Priority**: HIGH - Major UX improvement

### DMG Installation UX
**Issue**: DMG window doesn't clearly indicate drag-to-install action
- **Current**: Shows Applications folder shortcut and WhisperKey icon side-by-side
- **Better approach**: 
  - Arrow graphic pointing from app to Applications folder
  - Background image with instructions
  - Similar to how Spotify, Discord, etc. handle DMG installation
- **Priority**: MEDIUM - First impression matters

### Code Signing / Gatekeeper Warning
**Issue**: Users see scary "unidentified developer" warning
- **Current**: No mention in release notes about this
- **Needed**: Clear instructions in release notes:
  ```
  ## Important Installation Note
  
  WhisperKey is currently unsigned (we're a small independent project). 
  When you first open it, macOS will show a security warning.
  
  To install:
  1. Try to open WhisperKey
  2. When warned, click "Cancel" (not "Move to Trash")
  3. Go to System Settings > Privacy & Security
  4. Find WhisperKey and click "Open Anyway"
  5. Enter your password when prompted
  
  This is a one-time process. We're working on getting a developer certificate.
  ```
- **Priority**: HIGH - Users might abandon install otherwise

### Language Support
**Feature Request**: Multi-language support like Apple dictation
- **Current**: English only (hardcoded to `en` models)
- **Desired**:
  - Support multiple Whisper language models
  - Language picker in recording indicator popup
  - Remember last used language
  - Quick language switching without going to preferences
- **Technical notes**:
  - Whisper supports 100+ languages
  - Would need to download appropriate models
  - UI needs language picker component
- **Priority**: MEDIUM - Expands user base significantly

## Implementation Ideas

### For Live Transcription
1. Use Whisper.cpp's streaming mode (if available)
2. Or implement chunked processing:
   - Process audio in 1-2 second chunks
   - Insert partial results as they complete
   - Show "..." while processing next chunk
3. Consider VAD (Voice Activity Detection) for better chunking

### For DMG Installer
1. Create custom DMG background image
2. Use `create-dmg` tool with proper configuration
3. Example from other apps:
   ```bash
   create-dmg \
     --volname "WhisperKey" \
     --background "installer-background.png" \
     --window-pos 200 120 \
     --window-size 600 400 \
     --icon-size 100 \
     --icon "WhisperKey.app" 150 200 \
     --hide-extension "WhisperKey.app" \
     --app-drop-link 450 200 \
     --text-size 14 \
     --add-text "Drag WhisperKey to Applications" 300 50 \
     "WhisperKey-1.0.2.dmg" \
     "WhisperKey.app"
   ```

### For Code Signing
- Short term: Update all documentation with clear Gatekeeper instructions
- Long term: 
  - Get Apple Developer account ($99/year)
  - Implement proper code signing in build process
  - Consider notarization for even better UX

### For Multi-Language Support
1. UI Changes:
   - Add language picker to recording indicator
   - Add language management to preferences
   - Show current language in menu bar icon tooltip
   
2. Model Management:
   - Extend ModelManager to handle language-specific models
   - Auto-download models for selected languages
   - Cache multiple language models
   
3. Whisper Integration:
   - Remove hardcoded `-l en` parameter
   - Pass selected language to whisper.cpp
   - Handle language detection mode

## Next Steps
1. Update v1.0.2 release notes template with Gatekeeper instructions
2. Create GitHub issues for each improvement
3. Prioritize based on user impact and implementation effort
4. Consider creating a public roadmap

## User Quotes
> "I really don't like that it's like the Apple dictation where you can see the text go in the cursor in live time. That's really cool and I think that's something that we should strive for in the future."

> "The DMG opens and it's not really like other DMGs where it's really clear that a user has to move whisper key into the applications folder."

---
*This document captures real user feedback to guide future development priorities*