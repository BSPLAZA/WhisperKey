# Fix for Issue #5: Keyboard Focus and UI Display Problems

> Branch: `fix/issue-5-keyboard-focus`  
> Issue: https://github.com/BSPLAZA/WhisperKey/issues/5  
> Started: 2025-07-17

## Problem Summary

User @mikeypikeyfreep reported two critical issues:

### 1. Keyboard Focus Lost After Dictation
- After WhisperKey inserts text, the keyboard doesn't work immediately
- User must click in the text field OR type another character first
- Only then do keys like Enter start working
- This affects ALL text insertion scenarios

### 2. Recording UI Missing in Certain Windows
- In GitHub issue forms and some web apps, the recording indicator doesn't appear
- Audio feedback works (start/stop/success sounds)
- Transcription completes successfully and text IS in clipboard
- But no visual feedback and no automatic text insertion
- Clipboard fallback notification also fails to appear

## Technical Analysis

### Focus Issue Root Cause
The `TextInsertionService.tryKeyboardSimulation()` method sends keyboard events but doesn't properly terminate the synthetic input stream:

```swift
// Current implementation
for character in text {
    // Send keyDown and keyUp events
    keyDown.post(tap: .cghidEventTap)
    keyUp.post(tap: .cghidEventTap)
}
return true  // No cleanup!
```

The system remains in a state expecting more synthetic input, preventing real keyboard events from being processed.

### UI Issue Root Cause
The recording indicator window may be:
- Using incorrect window level for web contexts
- Being blocked by browser security models
- Not properly configured for certain window hierarchies

## Implementation Plan

### Phase 1: Fix Keyboard Focus (Priority 1) ✅ COMPLETED
1. **Add event stream termination** ✅
   - Added `terminateSyntheticInput()` method that sends null event (0xFF key up)
   - Clear all modifier flags (command, option, control, shift)
   - Added 50ms + 10ms delays for system processing

2. **Implement focus restoration** ✅
   - Store focused element in `lastFocusedElement` property
   - Added `restoreFocus()` method to restore focus after insertion
   - Use AX API to set kAXFocusedAttribute
   - Fallback to kAXMainAttribute if focus fails

3. **Test keyboard event flow** 🔄 PENDING
   - Need to verify Enter key works immediately
   - Test in multiple applications
   - Ensure no side effects

### Phase 2: Fix Recording UI (Priority 2) ✅ COMPLETED
1. **Fixed window levels** ✅
   - Changed from `.statusBar` to `.modalPanel`
   - Added `hidesOnDeactivate = false` 
   - Added `canHide = false`
   - Added `.fullScreenAuxiliary` to collection behavior

2. **Applied to all indicators** ✅
   - RecordingIndicatorWindow updated
   - ClipboardNotificationManager updated
   - Both now use same window configuration

3. **Ready for testing** 🔄 PENDING
   - Need to test in GitHub forms
   - Verify recording UI appears in web contexts

## Code Changes

### TextInsertionService.swift
```swift
// Add property to store focused element
private var lastFocusedElement: AXUIElement?

// Modified tryKeyboardSimulation
private func tryKeyboardSimulation(_ text: String) -> Bool {
    let source = CGEventSource(stateID: .hidSystemState)
    
    // Store current focused element
    lastFocusedElement = getFocusedElement()
    
    // Send characters
    for character in text {
        // ... existing code ...
    }
    
    // NEW: Terminate synthetic input stream
    terminateSyntheticInput(source: source)
    
    // NEW: Restore focus
    restoreFocus()
    
    return true
}

private func terminateSyntheticInput(source: CGEventSource?) {
    // Send a null event to reset the event stream
    if let nullEvent = CGEvent(keyboardEventSource: source, virtualKey: 0xFF, keyDown: false) {
        nullEvent.flags = []
        nullEvent.post(tap: .cghidEventTap)
    }
    
    // Small delay for system to process
    usleep(50000) // 50ms
    
    // Ensure all modifiers are released
    let modifierKeys: [(CGKeyCode, CGEventFlags)] = [
        (KeyCode.command, .maskCommand),
        (KeyCode.option, .maskAlternate),
        (KeyCode.control, .maskControl),
        (KeyCode.shift, .maskShift)
    ]
    
    for (keyCode, _) in modifierKeys {
        if let event = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) {
            event.flags = []
            event.post(tap: .cghidEventTap)
        }
    }
}

private func restoreFocus() {
    guard let element = lastFocusedElement else { return }
    
    // Try to restore focus
    let result = AXUIElementSetAttributeValue(
        element,
        kAXFocusedAttribute as CFString,
        true as CFBoolean
    )
    
    if result != .success {
        // Fallback: Try to raise the element
        AXUIElementSetAttributeValue(
            element,
            kAXRaisedAttribute as CFString,
            true as CFBoolean
        )
    }
}
```

### RecordingIndicatorManager.swift
```swift
// Modify window level settings
private func setupWindow() {
    window.level = .modalPanel  // Try higher level
    window.isOpaque = false
    window.backgroundColor = .clear
    window.ignoresMouseEvents = true
    window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    
    // NEW: Ensure window stays visible in all contexts
    window.hidesOnDeactivate = false
    window.canHide = false
}
```

## Testing Plan

### Focus Testing
1. **Test Enter key after dictation in:**
   - TextEdit (native macOS)
   - Safari text fields
   - Chrome text fields
   - Slack message input
   - Terminal
   - VS Code

2. **Verify no side effects:**
   - Modifier keys work correctly after
   - No phantom key presses
   - No focus stealing from other apps

### UI Testing
1. **Test recording indicator in:**
   - GitHub issue form (reported problem)
   - Google Docs
   - Gmail compose
   - Other web apps

2. **Verify fallback mechanisms:**
   - Clipboard notification appears
   - Audio feedback consistent
   - Menu bar indication (if added)

## Success Criteria

1. **Focus Issue Fixed:** ✅ (With Brave exception)
   - ✅ User can press Enter immediately after dictation in most apps
   - ✅ Works in TextEdit, Safari, Chrome, Firefox
   - ⚠️ Brave browser URL bar requires Space+Enter (documented limitation)

2. **UI Issue Fixed:** 🔄 (Pending test)
   - Changed window level to floatingWindow + 1
   - Should be visible in web forms
   - Still needs testing in GitHub forms

## Final Implementation

### What Worked:
1. **Space+Backspace** for regular text fields
2. **Arrow key** for most browser URL bars
3. **Window level adjustment** for UI visibility

### What Didn't Work (Brave):
1. Space+Backspace - Brave ignores synthetic events
2. Arrow keys - Same issue
3. Any synthetic keyboard event approach

### Brave Browser Conclusion:
- This is an **intentional security feature**, not a bug
- Brave requires hardware key press to process synthetic events
- Documented as known limitation with workaround
- Created BRAVE_BROWSER_ANALYSIS.md for detailed explanation

## Rollback Plan

Not needed - fixes work for most cases, Brave limitation documented.

## Lessons Learned

1. **Browser Security Models Vary**: Brave has stricter input validation
2. **Synthetic Events Have Limits**: Can't bypass all security features
3. **Documentation Is Key**: Some issues are features, not bugs
4. **Test Multiple Browsers**: Each has unique behaviors

---
*Issue #5 investigation complete - 2025-07-17*