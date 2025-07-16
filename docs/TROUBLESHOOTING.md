# WhisperKey Troubleshooting Guide

*Solutions to common problems and frequently asked questions*

## Quick Fixes

Before diving into detailed troubleshooting, try these quick fixes:

1. **Restart WhisperKey** - Quit and relaunch from Applications
2. **Check Permissions** - Both Microphone and Accessibility must be enabled
3. **Test Hotkey** - Use the test area in Preferences → General
4. **Update macOS** - WhisperKey requires macOS 12.0 or later

## Common Problems

### Installation Issues

#### "WhisperKey is damaged and can't be opened"
**Cause**: macOS Gatekeeper blocking unsigned app  
**Solution**:
1. Right-click WhisperKey.app
2. Select "Open" from the menu
3. Click "Open" in the dialog
4. Only need to do this once

#### "whisper.cpp not found" (v1.0.0)
**Note**: This issue is fixed in v1.0.1+ which includes bundled whisper.cpp

**For v1.0.0 users**:
1. Follow the setup wizard when it appears
2. Or manually install:
   ```bash
   git clone https://github.com/ggerganov/whisper.cpp
   cd whisper.cpp
   WHISPER_METAL=1 make -j
   ```

**For v1.0.1+ users**:
- This error should not occur
- If it does, check Resources folder in app bundle
- Report issue on GitHub

### Permission Problems

#### "Microphone access is required"
**Solution**:
1. Open System Settings → Privacy & Security → Microphone
2. Find WhisperKey in the list
3. Toggle the switch ON
4. Restart WhisperKey

**If WhisperKey isn't listed**:
1. Quit WhisperKey completely
2. Open Terminal and run:
   ```bash
   tccutil reset Microphone com.whisperkey.WhisperKey
   ```
3. Launch WhisperKey again
4. Grant permission when prompted

#### "Accessibility access is required"
**Solution**:
1. Open System Settings → Privacy & Security → Accessibility
2. Click the lock to make changes
3. Find WhisperKey and check the box
4. Restart WhisperKey

**Still not working?**
1. Remove WhisperKey from the list (- button)
2. Re-add it (+ button → navigate to Applications → WhisperKey)
3. Make sure it's checked
4. Restart your Mac

### Recording Issues

#### Recording doesn't start
**Check these**:
- Is the menu bar icon visible?
- Are you pressing the correct hotkey? (Right Option by default)
- Check Preferences → General → which hotkey is selected
- Try the menu option: Click icon → "Start Recording"

#### Recording stops immediately
**Possible causes**:
1. **Microphone not detected**
   - Check System Settings → Sound → Input
   - Select correct microphone
   
2. **Sensitivity too high**
   - Preferences → Recording → Reduce sensitivity
   - Try level 3 (Normal) first

3. **Permission dialog appeared**
   - Grant any requested permissions
   - Restart WhisperKey

#### No audio levels showing
**Solutions**:
- Check if microphone is muted (System Settings → Sound)
- Try different microphone
- Increase input volume
- Test with Voice Memos app first

### Transcription Problems

#### No text appears after recording
**Check these in order**:

1. **Cursor position**
   - Is cursor in an editable text field?
   - Click in the text field first
   - Try in TextEdit to test

2. **Clipboard mode**
   - Listen for sounds: Glass = inserted, Pop = clipboard
   - Check if text is in clipboard (⌘V to paste)
   - Check notification at bottom of screen

3. **Model not downloaded**
   - Preferences → Models
   - Download at least one model
   - Select it as active

4. **App compatibility**
   - Some apps block text insertion
   - Try enabling "Always save to clipboard"
   - Use clipboard as fallback

#### Poor transcription accuracy
**Improve accuracy**:
1. **Switch models**
   - Small model is more accurate than Base
   - Medium model is best (but slower)

2. **Reduce noise**
   - Find quieter environment
   - Use external microphone
   - Adjust sensitivity setting

3. **Speak clearly**
   - Normal pace, don't rush
   - Enunciate clearly
   - Pause between sentences

4. **Check audio input**
   - System Settings → Sound → Input level
   - Should peak around 75% when speaking

#### Transcription includes random words
**Common causes**:
- Background conversations
- TV/radio in background
- System sounds (mute notifications)
- Microphone picking up typing

**Solutions**:
- Use headset with boom mic
- Increase sensitivity setting (4 or 5)
- Mute system sounds while dictating

### Text Insertion Issues

#### Text always goes to clipboard
**This is normal when**:
- Not in a text field (e.g., Finder)
- In a secure field (passwords)
- App doesn't support text insertion

**To fix**:
- Click in text field first
- Make sure it's not a password field
- Try different app

#### Wrong characters appear
**Possible causes**:
- Keyboard layout mismatch
- Input source not English
- App intercepting keystrokes

**Solutions**:
- Check keyboard layout (menu bar)
- Switch to US English input
- Disable other keyboard utilities

#### Text appears in wrong place
**Solutions**:
- Don't move cursor while transcribing
- Wait for completion sound
- Disable any text expansion tools

### Performance Issues

#### Slow transcription
**Speed improvements**:
1. Use smaller model (Base is fastest)
2. Close other heavy apps
3. Check Activity Monitor for CPU usage
4. On Intel Macs, expect slower performance

#### High memory usage
**Normal usage**:
- Idle: ~50MB
- With model loaded: ~200MB
- During transcription: ~300MB

**If higher**:
- Restart WhisperKey
- Check for memory leaks (Activity Monitor)
- Report issue with details

#### Battery drain
**Reduce battery usage**:
- Use Base model
- Reduce recording frequency
- Disable audio feedback sounds
- Close when not needed

### App-Specific Issues

#### Terminal / iTerm
- **Password prompts**: Recording blocked (security feature)
- **vim/nano**: Exit to normal mode first
- **SSH sessions**: Should work normally

#### Web Browsers
- **No insertion**: Click in text field first
- **Google Docs**: May need to refresh page
- **Forms**: Some may block programmatic input

#### Slack / Discord
- **Formatting lost**: WhisperKey inserts plain text only
- **Sending accidentally**: Disable Enter to send
- **Emoji**: Say "colon smile colon" for :smile:

#### Code Editors
- **VS Code**: Works well, check accessibility permissions
- **Xcode**: Should work in editor views
- **Sublime**: May need accessibility permissions

### Advanced Troubleshooting

#### Reset all settings
```bash
defaults delete com.whisperkey.WhisperKey
```

#### Clear permissions
```bash
tccutil reset All com.whisperkey.WhisperKey
```

#### Debug mode
1. Preferences → Advanced → Enable debug logging
2. Reproduce issue
3. Check logs in Console.app

#### Manual model installation
If downloads fail:
1. Download from: https://huggingface.co/ggerganov/whisper.cpp
2. Place in: `~/Developer/whisper.cpp/models/`
3. Restart WhisperKey

## Frequently Asked Questions

### General

**Q: Is my voice data private?**  
A: Yes, 100%. WhisperKey works entirely offline. No internet connection required, no data sent anywhere.

**Q: Can I use WhisperKey in multiple languages?**  
A: The beta includes English models only. Multilingual support coming in v2.0.

**Q: Why is Right Option the default hotkey?**  
A: It's rarely used by other apps and easy to reach. You can change it to F13 in settings.

**Q: Can I use WhisperKey with external microphones?**  
A: Yes! External mics often provide better quality. Just select it in System Settings → Sound.

### Features

**Q: Can I dictate punctuation?**  
A: Yes! Say "period", "comma", "question mark", etc.

**Q: How do I make a new paragraph?**  
A: Say "new paragraph" or "new line"

**Q: Can I dictate special characters?**  
A: Basic ones yes: "at sign", "dollar sign", "percent sign"

**Q: Is there a way to correct mistakes?**  
A: Not within WhisperKey. Use your app's normal editing features.

### Technical

**Q: Why do I need to install whisper.cpp separately?**  
A: Beta limitation. Version 1.0 will bundle everything.

**Q: Which Whisper model should I use?**  
A: Small model is recommended for most users. Good balance of speed and accuracy.

**Q: Can I use custom vocabulary?**  
A: Not yet. This feature is planned for a future release.

**Q: Does WhisperKey work with dictation software?**  
A: Yes, but disable other dictation software to avoid conflicts.

## Still Need Help?

### Before Reporting an Issue

1. Check the [Known Issues](KNOWN_ISSUES.md) list
2. Update to the latest version
3. Try the solutions above
4. Restart your Mac

### Reporting a Bug

Include this information:
- macOS version
- WhisperKey version
- Steps to reproduce
- What you expected vs what happened
- Screenshots if applicable

Report at: https://github.com/BSPLAZA/WhisperKey/issues

### Contact

- **GitHub Issues**: Best for bug reports
- **Documentation**: You're reading it!
- **Source Code**: https://github.com/BSPLAZA/WhisperKey

---

*Last Updated: 2025-07-13 | WhisperKey v1.0.0-beta*