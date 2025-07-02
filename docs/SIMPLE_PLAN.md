# WhisperKey Simple Development Plan

## The Goal
Build a macOS menu bar app that transcribes speech to text when you press Right Option.

## The Solution
1. **Menu bar app** - Shows 🎤 icon, indicates recording status
2. **Right Option hotkey** - Reliable, no conflicts with system
3. **Local Whisper** - Privacy-focused transcription
4. **Type anywhere** - Works in any text field

## Development Phases

### Phase 1: Core App ✓ CURRENT
- [x] Menu bar app structure
- [x] HotKey library integration  
- [ ] Right Option key binding
- [ ] Basic UI (start/stop)

### Phase 2: Audio Pipeline
- [ ] Audio recording with AVAudioEngine
- [ ] Silence detection (2 second threshold)
- [ ] Audio buffer management
- [ ] Save temporary WAV files

### Phase 3: Whisper Integration
- [ ] Link whisper.cpp library
- [ ] Load base.en model
- [ ] Transcribe audio files
- [ ] Handle results asynchronously

### Phase 4: Text Insertion
- [ ] Get current text field with AXUIElement
- [ ] Insert transcribed text at cursor
- [ ] Handle special cases (secure fields)

### Phase 5: Polish
- [ ] Settings window (hotkey, model selection)
- [ ] Audio level indicator
- [ ] Error notifications
- [ ] Launch at login

## Technical Stack
- **Language**: Swift 5.9
- **UI**: SwiftUI + AppKit (menu bar)
- **Hotkeys**: HotKey library by soffes
- **Audio**: AVAudioEngine
- **Transcription**: whisper.cpp
- **Text Input**: AXUIElement + CGEvent

## Key Files
- `MenuBarApp.swift` - Main app entry
- `DictationService.swift` - Recording & transcription
- `HotkeyManager.swift` - Right Option handling
- `TextInsertion.swift` - Cursor interaction

## No Longer Worried About
- ❌ F5 key interception (impossible)
- ❌ Complex permission flows
- ❌ Kernel extensions
- ❌ Fighting macOS

## Current Status
Ready to implement Right Option hotkey and test basic functionality.

## Next Step
Update MenuBarApp.swift to properly handle Right Option key.