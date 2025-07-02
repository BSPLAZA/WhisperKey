# WhisperKey Test Checklist

## After Building in Xcode

### 1. Initial Launch
- [ ] WhisperKey builds without errors
- [ ] 🎤 icon appears in menu bar
- [ ] Clicking 🎤 shows menu

### 2. Permissions
- [ ] First click on "Start Recording" prompts for Accessibility
- [ ] Grant permission in System Settings
- [ ] Microphone permission requested when starting recording
- [ ] Grant microphone permission

### 3. Hotkey Test
- [ ] Open TextEdit or Notes
- [ ] Click in text field to place cursor
- [ ] Press Right Option (⌥) - the one next to right Cmd
- [ ] Menu bar 🎤 turns red (recording)
- [ ] Say "Hello WhisperKey"
- [ ] Press Right Option again to stop
- [ ] Text appears at cursor (currently simulated)

### 4. Menu Features
- [ ] Click 🎤 → shows recording status
- [ ] Hotkey menu shows "Right ⌥"
- [ ] Can change hotkey to Caps Lock
- [ ] Settings menu visible
- [ ] Quit works

### 5. Alternative Hotkeys
If Right Option doesn't work:
- [ ] Click 🎤 → Hotkey → Caps Lock
- [ ] Test with Caps Lock key
- [ ] Or try F13 if available

## Current Status

✅ What's Working:
- Menu bar app structure
- Right Option hotkey detection
- Basic recording flow
- Text insertion framework

⏳ What's Coming Next:
- Real Whisper transcription (currently simulated)
- Audio level visualization
- Model selection
- Preferences window

## Troubleshooting

### "Nothing happens when I press Right Option"
1. Check 🎤 is in menu bar
2. Verify Accessibility permission granted
3. Make sure cursor is in a text field
4. Try clicking 🎤 → Start Recording instead

### "No text appears"
- Currently using simulated text
- Real transcription coming after whisper.cpp integration

### "Build errors about HotKey"
1. File → Add Package Dependencies
2. Enter: https://github.com/soffes/HotKey
3. Add to WhisperKey target
4. Clean build folder (Cmd+Shift+K)
5. Build again (Cmd+R)