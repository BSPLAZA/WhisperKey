# WhisperKey Daily Development Log

> Quick daily notes on progress, discoveries, and next steps

---

## 2025-07-01 (Day 1)

**Goal**: Set up project documentation and begin environment setup

**Completed**:
- ✅ Created comprehensive documentation structure
- ✅ Set up project directories
- ✅ Migrated planning document to archive
- ✅ Established documentation workflow
- ✅ Enhanced git commit guidelines in CLAUDE.md
- ✅ Created .gitignore file
- ✅ Initialized git repository
- ✅ Made initial commit with proper format
- ✅ Setting up GitHub repository
- ✅ Cloned and built whisper.cpp with Metal support
- ✅ Downloaded all three Whisper models (base.en, small.en, medium.en)
- ✅ Verified whisper.cpp works with Metal acceleration on M4 Pro

**Discovered**:
- Need to decide between whisper.cpp vs Core ML Whisper implementation
- Consider creating custom MCP tool for documentation updates
- whisper.cpp Metal support works perfectly on M4 Pro
- Models downloaded: base.en (141MB), small.en (465MB), medium.en (1.4GB)

**Blockers**:
- Xcode not installed (only command line tools available) - RESOLVED
- F5 dictation key still triggers system dialog
- Accessibility permission shows as not granted even when approved

**Time Spent**: 4 hours

**Status Before Logout**:
- Applied two fixes that need testing:
  1. Disabled system dictation: `defaults write com.apple.HIToolbox AppleDictationAutoEnable -int 0`
  2. Configured Xcode to use custom Info.plist (GENERATE_INFOPLIST_FILE = NO)
- Need to log out/in for dictation change to take effect
- Have NOT committed these changes yet (waiting for test results)

**Next Steps After Login**:
1. Build and run the app
2. Test if F5 is intercepted without system dictation popup
3. Verify accessibility permission shows correctly
4. Commit only if fixes work

**Code Snippets/Commands**:
```bash
# Project structure created
mkdir -p WhisperKey/{docs,docs-archive/planning,scripts,src,tests,resources}

# GitHub repository created
gh repo create WhisperKey --private --source=. --remote=origin \
  --description="Privacy-focused local dictation app for macOS using Whisper AI" --push

# Built whisper.cpp with Metal
cd ~/Developer/whisper.cpp && WHISPER_METAL=1 make -j

# Downloaded models
cd ~/Developer/whisper.cpp/models
bash download-ggml-model.sh base.en
bash download-ggml-model.sh small.en
bash download-ggml-model.sh medium.en

# Test whisper.cpp
./build/bin/whisper-cli -m models/ggml-base.en.bin -f jfk.wav
```

**Links/References**:
- [GitHub Repository](https://github.com/BSPLAZA/WhisperKey)
- [whisper.cpp](https://github.com/ggerganov/whisper.cpp)

---

## 2025-07-01 (Day 1 - Session 2)

**Goal**: Fix F5 interception and accessibility permission issues

**Completed**:
- ✅ Tested fixes - both issues persisted
- ✅ Deep research into macOS dictation and key interception
- ✅ Discovered F5 is system-reserved at kernel level
- ✅ Pivoted to menu bar app architecture
- ✅ Selected HotKey library for reliable global shortcuts
- ✅ Created new MenuBarApp.swift implementation
- ✅ Documented architectural decisions (ADR-005, ADR-006)
- ✅ Created comprehensive fix scripts
- ✅ Created transition guide for new architecture

**Discovered**:
- **F5 is untouchable**: macOS intercepts it before any user-space app
- **CGEventTap limitations**: Can't block system-reserved keys
- **TCC database issues**: Known macOS bug causes false negatives
- **Carbon Events still work**: Though deprecated, most reliable for hotkeys
- **Menu bar apps are ideal**: Standard pattern for this type of utility
- **F13-F19 are perfect**: Designed for custom functions, no conflicts

**Key Insight**:
We were solving the wrong problem. Instead of "How to intercept F5?", we should ask "How to give users the best dictation experience?" The answer isn't F5.

**Blockers**:
- None - clear path forward with new architecture

**Time Spent**: 3 hours

**Tomorrow's Focus**:
1. Update Xcode project to use menu bar architecture
2. Add HotKey Swift package dependency
3. Test F13 hotkey functionality
4. Begin Whisper integration with new architecture

**Code Snippets/Commands**:
```swift
// New simple architecture
let hotKey = HotKey(key: .f13, modifiers: [])
hotKey.keyDownHandler = { startDictation() }
```

```bash
# For users who insist on F5
./scripts/comprehensive-fix.sh
# Then enable standard function keys in System Settings
```

**Links/References**:
- [HotKey Library](https://github.com/soffes/HotKey)
- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) - Alternative

---

## 2025-07-01 Session 3 (Day 1 - 4:00 PM)

**Goal**: Debug hotkey and accessibility permission issues

**Completed**:
- ✅ Identified why AXIsProcessTrusted() returns false
- ✅ Implemented custom Right Option key detection
- ✅ Fixed double hotkey initialization bug
- ✅ Added user notification for app restart requirement

**Discovered**:
- HotKey library cannot handle modifier-only keys (like Right Option alone)
- NSEvent.addGlobalMonitorForEvents works for Right Option (keyCode 61)
- Accessibility permission requires app restart to take effect
- Xcode development builds may have inconsistent bundle IDs affecting permissions

**Blockers**:
- Need to verify Right Option works after proper app restart

**Time Spent**: 1 hour

**Tomorrow's Focus**:
- Verify Right Option key functionality after restart
- Complete audio recording pipeline
- Integrate whisper.cpp for actual transcription

**Code Snippets/Commands**:
```swift
// Right Option detection via NSEvent
eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { event in
    if event.keyCode == 61 { // Right Option
        // Handle key press
    }
}
```

**Links/References**:
- [NSEvent Monitoring](https://developer.apple.com/documentation/appkit/nsevent)

---

## 2025-07-01 (Day 1 - Session 4 - 17:00 PST)

**Goal**: Implement streaming transcription and test audio quality

**Completed**:
- ✅ Implemented WhisperStreamingTranscriber with configurable chunks
- ✅ Added model selection in menu bar (Base, Small, Medium)
- ✅ Created streaming mode toggle
- ✅ Fixed model path issues (missing / in path)
- ✅ Built whisper-stream binary with SDL2 support
- ✅ Conducted comprehensive quality testing
- ✅ Researched alternative streaming approaches

**Discovered**:
- **Critical**: Whisper requires 2-5 seconds of audio context for accurate transcription
- **Streaming quality is terrible**: Small chunks (0.5s) produce garbled output
- **Non-streaming is near perfect**: Full context gives excellent results
- **Market analysis**: 10+ competitors already exist (MacWhisper, SuperWhisper, etc.)
- **whisper-stream exists**: But requires SDL2 and direct audio capture

**Quality Test Results (21:00 PST)**:
Test phrase: "If streaming mode is off, you'll only see the complete transcription at the end. Make sure to enable it in the settings!"

**Streaming ON (Poor Quality)**:
- Base: "It's true.Dreamingmode isoff.you'llonlysee thePleaseWeinscription..."
- Small: "It'sstreamstreamingmode is off.your ownonly seethe comcomplete transition..."
- Medium: "youIfStreetstreaming mode.mode is on.off.you'll almost"

**Streaming OFF (Excellent Quality)**:
- Base: "If streaming mode is off, you'll only see the complete transcription at the end. Make sure to enable it in the settings."
- Small: "If streaming. modeis off, you'll only see the complete transcription at the end. Make sure to enable it in the settings."
- Medium: "If streaming mode. isoff, you'll only see the complete transcription at the end. Make sure to enable it in the settings."

**Blockers**:
- Whisper architecture fundamentally incompatible with real-time streaming
- Need 2+ seconds of context for reasonable accuracy
- True sub-second streaming not feasible with current approach

**Time Spent**: 4.5 hours

**Key Decisions**:
- Updated streaming to use 2s chunks with 5s context window
- Acknowledged this is a learning project with potential for future innovation
- Decided to continue despite market saturation

**Tomorrow's Focus**:
- Test improved streaming implementation (2s chunks)
- Document all technical limitations clearly
- Consider hybrid approaches (Apple Speech Recognition for streaming)
- Explore unique differentiators for future development

**Code Snippets/Commands**:
```bash
# Build whisper-stream
brew install sdl2
cmake -B build -S /Users/orion/Developer/whisper.cpp -DWHISPER_SDL2=ON -DWHISPER_METAL=1
cmake --build build --config Release -j8
```

```swift
// Streaming configuration for better accuracy
private let minimumProcessingDuration: TimeInterval = 2.0
private let processingInterval: TimeInterval = 2.0
private let contextWindow: TimeInterval = 5.0
```

**Links/References**:
- [whisper.cpp streaming](https://github.com/ggerganov/whisper.cpp/tree/master/examples/stream)
- [OpenSuperWhisper](https://github.com/search?q=OpenSuperWhisper) - Open source competitor

---

## Template for Future Entries

## YYYY-MM-DD (Day X)

**Goal**: [Primary objective for the day]

**Completed**:
- ✅ [Completed task]
- ✅ [Completed task]
- ⏸️ [Partially completed]
- ❌ [Not completed]

**Discovered**:
- [Important discovery or insight]
- [Technical finding]

**Blockers**:
- [Any blocking issues]

**Time Spent**: X hours

**Tomorrow's Focus**:
- [Next priority]
- [Next priority]

**Code Snippets/Commands**:
```language
# Important code or commands from today
```

**Links/References**:
- [Relevant links discovered]

---
*Note: Keep entries brief - max 10 minutes to write*