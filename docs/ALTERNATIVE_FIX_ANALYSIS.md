# Alternative Fix Analysis for Issue #5

## Current Fix Problems

### 1. Focus Restoration Approach
- **Problem**: Using AX API to restore focus is unreliable
- **Why**: Many apps don't support external focus changes
- **Evidence**: The user still needs to click/type after our "fix"

### 2. Null Event Approach  
- **Problem**: Sending virtual key 0xFF is undocumented
- **Why**: No guarantee this terminates event stream
- **Evidence**: No Apple documentation supports this

### 3. Window Level Issues
- **Problem**: `.modalPanel` is too aggressive
- **Why**: Will cover system dialogs and alerts
- **Better**: Use `.floating + 1` or `.popUpMenu`

## Better Solutions

### Option 1: Post a Real Character + Delete
```swift
// After inserting text, post a space then immediately backspace
// This triggers the field's change handlers
private func triggerFieldUpdate(source: CGEventSource?) {
    // Type space
    if let spaceDown = CGEvent(keyboardEventSource: source, virtualKey: 0x31, keyDown: true) {
        spaceDown.post(tap: .cghidEventTap)
    }
    if let spaceUp = CGEvent(keyboardEventSource: source, virtualKey: 0x31, keyDown: false) {
        spaceUp.post(tap: .cghidEventTap)
    }
    
    usleep(10000) // 10ms
    
    // Delete it
    if let backDown = CGEvent(keyboardEventSource: source, virtualKey: 0x33, keyDown: true) {
        backDown.post(tap: .cghidEventTap)
    }
    if let backUp = CGEvent(keyboardEventSource: source, virtualKey: 0x33, keyDown: false) {
        backUp.post(tap: .cghidEventTap)
    }
}
```

### Option 2: Send Input Method Events
```swift
// Use NSTextInputContext to properly notify the field
private func notifyTextChanged() {
    if let inputContext = NSTextInputContext.current {
        inputContext.invalidateCharacterCoordinates()
        inputContext.discardMarkedText()
    }
}
```

### Option 3: Post Mouse Click at Insertion Point
```swift
// Click at the end of the text to ensure field knows it's active
private func clickAtInsertionPoint() {
    // Get cursor position
    if let element = lastFocusedElement {
        var cursorPos: CFTypeRef?
        AXUIElementCopyAttributeValue(element, kAXSelectedTextRangeAttribute as CFString, &cursorPos)
        // Post mouse click at that position
    }
}
```

### For Window Level Issue

Instead of `.modalPanel`:
```swift
// More appropriate window level
window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)) + 1)
// This puts it above normal windows but below system panels
```

## Recommended Approach

1. **For Focus Issue**: Use Option 1 (space + backspace) as it's most reliable
2. **For Window Level**: Use floating + 1 instead of modalPanel
3. **Add Feature Flag**: Allow users to disable the fix if it causes issues

## Testing Required

Before implementing, we should:
1. Test current "fix" to see if it actually works
2. Try the space+backspace approach manually
3. Check if window level change is sufficient

## Risk Assessment

- **Current Fix**: Medium risk - uses undocumented behavior
- **Space+Backspace**: Low risk - uses standard key events
- **Window Level Change**: Low risk - standard approach