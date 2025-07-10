# WhisperKey Daily Development Log

> Quick daily notes on progress, discoveries, and next steps

---

## 2025-07-04 (Friday) - Continued Session

**Goal**: Fix window management and hotkey issues from previous session

**Completed**:
- ✅ Implemented WindowManager singleton for proper window lifecycle
- ✅ Fixed window references being garbage collected
- ✅ Added comprehensive debug logging throughout app
- ✅ Enhanced hotkey connection debugging
- ✅ Improved error handling with user alerts
- ✅ Fixed duplicate onboarding window references

**Discovered**:
- Window references must be retained strongly or they get GC'd
- Menu bar apps need careful window lifecycle management
- xcodebuild requires full Xcode.app, swift build works with CLI tools
- NSHostingController windows need isReleasedWhenClosed = false

**Blockers**:
- User needs to rebuild and test if windows now open correctly
- Hotkey activation still needs verification

**Time Spent**: 2 hours

**Tomorrow's Focus**:
- Verify window fixes work for user
- Debug hotkey if still not working
- Complete testing across applications
- Prepare for release

**Code Snippets/Commands**:
```swift
// Proper window management pattern
class WindowManager: ObservableObject {
    static let shared = WindowManager()
    private var window: NSWindow?
    
    func showWindow() {
        let window = NSWindow(...)
        window.isReleasedWhenClosed = false
        self.window = window // Keep strong reference
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
```

---

## 2025-07-09 (Wednesday) - Part 2: Major UX Improvements

**Goal**: Improve overall user experience based on user feedback

**Completed**:
- ✅ Added recording duration timer (0:XX format) in indicator
- ✅ Added warning when approaching max recording time ("Stopping in Xs")
- ✅ Implemented audio feedback sounds (Tink on start, Pop on stop, Glass on success)
- ✅ Researched common dictation app user requests
- ✅ Added "ESC to cancel" hint in recording indicator
- ✅ Improved success feedback - shows word count inserted
- ✅ Added 3-second auto-clear for success messages
- ✅ Increased indicator window size for better visibility

**Key UX Improvements**:
1. **Recording Timer** - Users now see exactly how long they've been recording
2. **Time Limit Warning** - Yellow warning appears 10 seconds before max time
3. **Audio Feedback** - System sounds for start/stop/success (if enabled)
4. **Better Success Feedback** - "✅ Inserted X words" instead of generic message
5. **Visual Hints** - ESC key hint for canceling recording

**Research Findings**:
- Users want cross-app functionality (✓ we have this)
- Offline support is critical (✓ we have this)
- Custom vocabulary support (future feature)
- Voice commands for punctuation (future feature)

**Time Spent**: 1.5 hours

**Next Steps**:
- Test audio feedback with different system sound settings
- Consider adding voice commands for punctuation
- Monitor user feedback for additional improvements

---

## 2025-07-09 (Wednesday) - UI Cleanup & The Great Right Option Debugging Saga

**Goal**: Clean up UI and fix Right Option key detection

**Completed**:
- ✅ Removed "Test Right Option Key" diagnostic button
- ✅ Added "About WhisperKey" menu item
- ✅ Renamed "Preferences" to "Settings"
- ✅ Fixed window sizing (600x500 for Settings, 600x600 for Onboarding)
- ✅ Improved spacing in Settings dialog
- ✅ Reduced hotkey options to just Right Option and F13
- ✅ Implemented tap-to-toggle for hotkeys
- ✅ Added model selection indicator in Models tab
- ✅ SOLVED Right Option "bug" (it was set to F13 in preferences!)

**The Right Option Debugging Saga**:
- Spent 2+ hours debugging why Right Option wasn't working
- Added extensive logging, removed permission checks, restored old code
- Turns out the user had F13 selected in preferences, not Right Option!
- The logs clearly showed "selectedHotkey: f13" but we missed it

**Lesson Learned**:
```
ALWAYS CHECK USER CONFIGURATION FIRST!
The simplest explanation is usually correct.
```

**Key Changes**:
- Simplified menu bar UI
- Better window sizing and spacing
- Tap-to-toggle hotkey behavior (not press-and-hold)
- Force set to right_option for testing (needs removal)

**Time Spent**: 3 hours (mostly chasing a non-bug)

**Next Steps**:
- Remove the force setting of right_option
- Test across 8 applications
- Handle readonly fields gracefully
- Remember to check settings before debugging!

---

## 2025-07-02 (Tuesday) - Part 2

**Goal**: Fix UI issues and implement remaining features

**Completed**:
- ✅ Implemented readonly/disabled field detection in TextInsertionService
- ✅ Created comprehensive onboarding experience (4-step flow)
- ✅ Built memory pressure monitoring system with model recommendations
- ✅ Added audio device change detection and graceful handling
- ✅ Fixed window management with WindowManager singleton
- ✅ Added extensive debug logging throughout the app
- ✅ Enhanced error handling with user notifications

**Discovered**:
- Window references were being garbage collected without strong refs
- AVAudioSession is iOS-only, must use AVAudioEngine notifications on macOS
- PageTabViewStyle unavailable on macOS, use .automatic instead
- onChange signature changed in newer macOS versions
- Menu bar apps need careful window lifecycle management

**Blockers**:
- User reports preferences/onboarding windows still not opening
- Hotkey (Right Option) not triggering recording

**Time Spent**: 6 hours

**Tomorrow's Focus**:
- Debug why windows aren't showing despite code changes
- Fix hotkey activation issue
- Test all functionality thoroughly
- Complete testing across different applications

**Code Snippets/Commands**:
```swift
// Window management pattern that should work
class WindowManager: ObservableObject {
    static let shared = WindowManager()
    private var window: NSWindow?
    
    func showWindow() {
        window = NSWindow(...)
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
```

---

## 2025-07-02 (Tuesday)

**Goal**: Build and test WhisperKey, implement remaining critical features

**Completed**:
- ✅ Built and launched WhisperKey successfully from Xcode  
- ✅ Verified menu bar icon appears and changes state properly
- ✅ Tested basic recording functionality - works but needs refinement
- ✅ Fixed secure field detection for password inputs
- ✅ Removed streaming mode for better accuracy
- ✅ Implemented comprehensive error handling system
- ✅ Created visual recording indicator
- ✅ Improved menu bar UI with better status messages

**Discovered**:
- Menu bar apps need @NSApplicationDelegateAdaptor for proper initialization
- HotKey library doesn't support modifier-only keys like Right Option
- Streaming transcription causes accuracy issues with whisper.cpp
- Need explicit NSEvent monitoring for Right Option key
- Password field detection works via IORegistry SecureInputMode

**Blockers**:
- None currently

**Time Spent**: 8 hours

**Tomorrow's Focus**:
- Test thoroughly across different applications
- Implement any remaining high-priority features
- Create demo video or screenshots
- Prepare for initial release

**Code Snippets/Commands**:
```bash
# Build and run from Xcode
# Cmd+R in Xcode

# Monitor for secure input fields
ioreg -c IOHIDSystem | grep SecureInput
```

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

**Blockers**:
- F5 cannot be intercepted (system limitation) - RESOLVED by architecture change
- False TCC status requires app restart - documented in UI

**Time Spent**: 5 hours

**Tomorrow's Focus**:
- Build and test new menu bar architecture
- Implement recording with customizable hotkeys
- Test accessibility features work properly
- Document any new issues discovered

**Code Snippets/Commands**:
```bash
# Fix attempts (for documentation)
defaults write com.apple.HIToolbox AppleDictationAutoEnable -int 0
sudo killall tccd
tccutil reset Accessibility com.example.WhisperKey

# New architecture testing
swift package init --type executable
swift package update
```

**Links/References**:
- [HotKey Library](https://github.com/soffes/HotKey)
- [Apple TCC Documentation](https://developer.apple.com/documentation/security/1399291-axtrustedcheckoptionprompt)

---

## 2025-07-10 (Wednesday) - Language Support Research

**Goal**: Research multi-language dictation capabilities and plan future support

**Completed**:
- ✅ Researched Apple's dictation (auto-detection broken since iOS 13!)
- ✅ Investigated Whisper's capabilities (99 languages, auto-detection)
- ✅ Studied code-switching challenges (mixed languages in same utterance)
- ✅ Created ADR-019 for multi-language strategy
- ✅ Created ADR-020 for model flexibility
- ✅ Updated PROJECT_STATUS.md with prioritized language roadmap

**Discovered**:
- Apple claims auto language detection but users report it's completely broken
- Whisper has robust language detection with `--language auto` flag
- Code-switching (mixing languages) remains challenging for all systems
- Dragon Dictation charges $699 but has best accuracy
- Whisper supports 99 languages from 680,000 hours of training data

**Key Insights**:
- **Start simple**: Manual language selection first, auto-detection later
- **User control essential**: Always provide override for auto-detection
- **Model abstraction needed**: Don't tie too tightly to Whisper
- **Rebranding consideration**: "WhisperKey" name may be limiting

**Time Spent**: 0.5 hours

**Next Focus**:
- Continue with English-only for v1.0
- Test across 8 applications
- Consider implementing language dropdown in v1.1

---

## Date (Template)

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