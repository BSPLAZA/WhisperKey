# WhisperKey Issues and Solutions Archive

> Comprehensive record of problems encountered and their solutions

## Issue Template

```markdown
## Issue #XXX: [Brief Description]
**Discovered**: [Date - Phase]  
**Severity**: [Critical | High | Medium | Low]  
**Symptoms**: [What went wrong]  
**Root Cause**: [Why it happened]  
**Solution**: [How it was fixed]  
**Prevention**: [How to avoid in future]  
**Time Lost**: [Hours spent debugging]
```

---

## Issue #001: F5 Dictation Key Intercepts Not Working

**Discovered**: 2025-07-01 - Phase 1  
**Severity**: Critical  
**Symptoms**: 
- F5 key triggers native macOS dictation popup
- CGEventTap doesn't consume the dictation event
- Both regular F5 (0x60) and system F5 (0x00cf) pass through

**Root Cause**: 
macOS handles dictation key at a privileged system level before CGEventTap

**Solution**: (In Progress)
1. Try disabling system dictation:
   ```bash
   defaults write com.apple.HIToolbox AppleDictationAutoEnable -int 0
   ```
2. Use Karabiner-Elements complex modification
3. Investigate IOKit HID for lower-level interception

**Prevention**: 
- Research macOS security model before implementation
- Test with system features disabled first

**Time Lost**: 2 hours

---

## Issue #002: Accessibility Permission False Negative

**Discovered**: 2025-07-01 - Phase 1  
**Severity**: High  
**Symptoms**: 
- AXIsProcessTrusted() returns false even after granting permission
- Permission dialog keeps appearing
- App shows "Not Granted" in UI

**Root Cause**: 
Unknown - possibly related to:
- Bundle identifier mismatch
- Missing code signing
- Generated Info.plist not including permission keys

**Solution**: (In Progress)
1. Reset permissions: `tccutil reset Accessibility com.whisperkey.WhisperKey`
2. Ensure Info.plist is properly configured in Xcode
3. May need Developer ID signing

**Prevention**: 
- Test with signed builds
- Verify bundle identifier consistency

**Time Lost**: 1 hour

---

## Common Issues Categories

### 🔑 Permissions & Security
_Issues related to macOS security model_

### 🎤 Audio Processing
_Audio capture, format conversion, buffering issues_

### 🤖 Whisper/ML Integration
_Model loading, inference, memory issues_

### ⌨️ Text Insertion
_Problems with inserting text in various applications_

### 🎯 Key Interception
_CGEventTap, media keys, event handling_

### 💾 Memory Management
_Leaks, high usage, Swift/C++ bridge issues_

### 🚀 Performance
_Latency, CPU usage, responsiveness_

---

## Quick Solutions Reference

| Problem | Quick Fix | Full Solution |
|---------|-----------|---------------|
| CGEventTap stops | Restart app | See Issue #001 |
| ... | ... | ... |

---

## Environment-Specific Issues

### macOS Sonoma (14.x)
- _Issues specific to Sonoma_

### macOS Sequoia (15.x)
- _Issues specific to Sequoia_

### Apple Silicon (M1/M2/M3/M4)
- _ARM-specific issues_

### Intel Macs
- _x86-specific issues_

---

## Issue #003: F5 Key Impossible to Intercept at User Level

**Discovered**: 2025-07-01 - Phase 1  
**Severity**: Critical  
**Symptoms**: 
- F5 always triggers system dictation
- CGEventTap cannot block system-reserved keys
- Even Karabiner-Elements struggles with F5

**Root Cause**: 
macOS reserves F5 at kernel level for system dictation - impossible to override from user space

**Solution**: 
Pivoted to menu bar app with configurable hotkeys (Right Option as default)

**Prevention**: 
- Research system-reserved keys before planning features
- Don't fight the OS, work with it

**Time Lost**: 4 hours

---

## Issue #004: Streaming Mode Produces Garbled Text

**Discovered**: 2025-07-01 20:00 PST - Phase 2  
**Severity**: High  
**Symptoms**: 
- Words split across chunks: "streaming" → "stream" + "streaming"
- Incorrect words substituted: "mode" → "mood"
- Complete nonsense output with 0.5s chunks

**Root Cause**: 
Whisper requires 2-5 seconds of audio context for accurate transcription. Small chunks lack sufficient phonetic context.

**Solution**: 
- Increased chunk size to 2s minimum
- Use 5s context window for processing
- Default to non-streaming mode for accuracy

**Prevention**: 
- Understand model requirements before implementation
- Test with various chunk sizes early

**Time Lost**: 3 hours

---

## Issue #005: Model Path Missing Forward Slash

**Discovered**: 2025-07-01 19:30 PST - Phase 2  
**Severity**: Medium  
**Symptoms**: 
- "Model not found" error
- Path showed as "/Users/.../modelsggml-small.en.bin"

**Root Cause**: 
String concatenation without separator: `basePath + "ggml-small.en.bin"`

**Solution**: 
Added forward slash: `basePath + "/ggml-small.en.bin"`

**Prevention**: 
- Use proper path joining methods
- Log full paths during debugging

**Time Lost**: 0.5 hours

---

## Issue #006: Right Option Key Not Supported by HotKey Library

**Discovered**: 2025-07-01 - Phase 1  
**Severity**: Medium  
**Symptoms**: 
- HotKey library only supports key+modifier combinations
- Cannot use modifier keys alone as hotkeys

**Root Cause**: 
Carbon Events API limitation - designed for traditional hotkeys

**Solution**: 
Used NSEvent.addGlobalMonitorForEvents for Right Option (keyCode 61)

**Prevention**: 
- Check library capabilities before choosing
- Have fallback approaches ready

**Time Lost**: 1 hour

---

## Issue #007: Audio Format Mismatch (48kHz vs 16kHz)

**Discovered**: 2025-07-01 - Phase 1  
**Severity**: Medium  
**Symptoms**: 
- Whisper expects 16kHz audio
- macOS captures at 48kHz
- Initial format conversion attempts failed

**Root Cause**: 
Hardware sample rate differs from Whisper requirements

**Solution**: 
Let whisper.cpp handle resampling internally - it's more reliable

**Prevention**: 
- Check tool capabilities before implementing conversions
- Use existing functionality when available

**Time Lost**: 2 hours

---

## Issue #008: Streaming Mode Quality Issues

**Discovered**: 2025-07-01 - Phase 2  
**Severity**: High  
**Symptoms**: 
- Streaming transcription produced garbled text
- Quality peaked at 6/10 even with improvements
- User feedback: "streaming text is really bad"

**Root Cause**: 
Whisper requires 2-5 seconds of audio context for accurate transcription. Small chunks (0.5-2s) lack sufficient context.

**Solution**: 
Removed streaming mode entirely. Single-mode operation with 2-3 second wait provides consistent 10/10 quality.

**Prevention**: 
- Research model requirements before implementing features
- Test quality early in development
- Listen to user feedback

**Time Lost**: 4 hours

---

## Issue #009: Recording Indicator UI Issues

**Discovered**: 2025-07-02 - Day 2  
**Severity**: Medium  
**Symptoms**:
- Recording indicator too narrow (text truncated)
- Double ellipses appeared
- Audio level bars not responding
- Menu bar icon too small

**Root Cause**:
- Window width only 200px
- AudioLevelMonitor not connected
- Used `mic.circle` icon which reduced visibility

**Solution**:
- Increased window to 320px width
- Connected audio levels with 30x sensitivity
- Changed to plain `mic` icon

**Prevention**:
- Test UI on actual device early
- Consider icon visibility in menu bar
- Connect all UI elements to data sources

**Time Lost**: 30 minutes

---

## Issue #010: Duplicate Permission Dialogs

**Discovered**: 2025-07-02 - Day 2  
**Severity**: High  
**Symptoms**:
- Users saw system permission dialog
- Then immediately saw our custom alert
- Confusing and annoying experience

**Root Cause**:
Code showed custom alerts after system dialogs

**Solution**:
Removed custom dialogs when system handles permissions

**Prevention**:
- Trust system UI for system features
- Don't duplicate OS functionality
- Test permission flows thoroughly

**Time Lost**: 15 minutes

---

## Issue #011: Right Option Key Not Working (False Debugging Rabbit Hole)

**Discovered**: 2025-07-09  
**Severity**: User Error / Debugging Confusion  
**Symptoms**:
- Right Option key not triggering recording
- No keyboard events in logs
- Thought it was accessibility permission issue

**Root Cause**:
**The user had F13 selected in preferences, not Right Option!**

The logs clearly showed:
```
=== WHISPERKEY: Current hotkey preference: f13 ===
```

**Solution**:
Select "Right Option ⌥" in Settings → General tab

**What Went Wrong**:
1. **Tunnel Vision**: Focused on complex permission issues
2. **Ignored Logs**: Logs clearly stated "selectedHotkey: f13"
3. **Over-engineering**: Added complex debugging for a simple preference issue
4. **Assumption Error**: Assumed Right Option was broken when it wasn't enabled

**Lessons Learned**:
- ALWAYS check user preferences first
- Read logs carefully before debugging
- Start with simple explanations
- Configuration > Code issues

**Time Lost**: 2 hours

---

## Issue #012: Swift 6 Build Errors

**Discovered**: 2025-07-02 - Day 2  
**Severity**: High  
**Symptoms**:
- Sendable conformance errors
- Deprecated API warnings
- Missing imports

**Root Cause**:
Swift 6 stricter concurrency and deprecated APIs

**Solution**:
- Added `@unchecked Sendable`
- Migrated to UserNotifications framework
- Updated to modern APIs

**Prevention**:
- Keep up with Swift evolution
- Address warnings promptly
- Use modern APIs from start

**Time Lost**: 20 minutes

---

## Issue #013: PermissionGuideView EXC_BAD_ACCESS Crash

**Discovered**: 2025-07-11 03:30 PST - Beta Testing  
**Severity**: Critical  
**Symptoms**: 
- App crashed with EXC_BAD_ACCESS when clicking Continue/Skip buttons
- Navigation buttons cut off at bottom of window
- Thread 1: EXC_BAD_ACCESS (code=1, address=0x20)
- App completely frozen after crash

**Root Cause**: 
Window lifecycle mismanagement. Created NSWindow without proper retention, causing it to be deallocated while SwiftUI was still trying to use it through @Environment(\.dismiss).

**Solution**: 
1. Created centralized WindowManager to properly retain windows
2. Changed from @Environment(\.dismiss) to explicit dismiss closure
3. Increased window height from 550 to 600 to fix button cutoff
4. Proper window lifecycle: store reference, handle close, clean up

**Code Fix**:
```swift
// WRONG: Window gets deallocated
func showPermissionGuide() {
    let window = NSWindow(...) // No retention!
    let view = PermissionGuideView() // Uses @Environment(\.dismiss)
    window.contentView = NSHostingView(rootView: view)
    window.makeKeyAndOrderFront(nil)
}

// CORRECT: Proper lifecycle management
class WindowManager {
    private var permissionWindow: NSWindow?
    
    func showPermissionGuide() {
        let view = PermissionGuideView(dismiss: {
            self.permissionWindow?.close()
            self.permissionWindow = nil
        })
        // Window retained by permissionWindow property
    }
}
```

**Prevention**: 
- Always retain NSWindow references in properties
- Don't use @Environment(\.dismiss) in standalone windows
- Use explicit dismiss closures for manual window management
- Test all UI dismiss/close actions
- Increase window sizes when content might be cut off

**Time Lost**: 30 minutes

---

## Issue #014: Settings Changes Not Auto-Saving

**Discovered**: 2025-07-11 08:25 AM PST - Beta Testing  
**Severity**: High  
**Symptoms**: 
- Settings changes (like silence duration) not automatically saved when closing dialog
- User has to manually trigger save somehow
- Changes may be lost if app quits

**Root Cause**: 
DictationService was using hardcoded constants instead of reading from UserDefaults. The settings were saving correctly but weren't being used.

**Solution**: 
Changed DictationService audio settings from constants to computed properties that read from UserDefaults:
```swift
// Before: private let silenceDuration: TimeInterval = 2.5
// After:
private var silenceDuration: TimeInterval {
    let stored = UserDefaults.standard.double(forKey: "silenceDuration")
    return stored != 0 ? stored : 2.5
}
```

**Prevention**: 
- Test all settings persistence
- Ensure @AppStorage changes are immediate

**Time Lost**: TBD

---

## Issue #015: No Clipboard Fallback for Non-Text Fields

**Discovered**: 2025-07-11 08:25 AM PST - Beta Testing  
**Severity**: Medium  
**Symptoms**: 
- When cursor not in text field, transcription is lost
- User clicks button or other control, transcription fails silently
- No way to recover transcribed text

**Root Cause**: 
Text insertion only works in editable text fields

**Solution**: 
Detect if current focus is text field, if not:
- Copy transcription to clipboard
- Show message "Saved to clipboard - press ⌘V to paste"
- Play different sound to indicate clipboard mode

**Prevention**: 
- Always provide fallback for user actions
- Never lose user data silently

**Time Lost**: TBD

---
*Last Updated: 2025-07-11 08:25 AM PST*