# WhisperKey Cursor Integration

## How It Works (Just Like System Dictation)

### The Complete Flow

1. **User has cursor in any text field** (TextEdit, Safari, Slack, Terminal, etc.)
2. **User presses Right Option** → WhisperKey activates
3. **WhisperKey records audio** → Shows red 🎤 in menu bar
4. **User speaks** → Audio captured to buffer
5. **User stops** (Right Option again or 2s silence)
6. **Whisper transcribes** → Text generated
7. **Text inserted at cursor** → Exactly where user was typing

### The Key: We Don't Move Focus

Unlike some dictation apps that open a window, WhisperKey:
- **Never steals focus** from the current app
- **Never moves the cursor**
- **Works exactly like Apple's dictation**

## Technical Implementation

### 1. Getting Current Cursor Position

```swift
// We use AXUIElement to find where to insert text
func getCurrentTextInsertionPoint() -> AXUIElement? {
    let systemWide = AXUIElementCreateSystemWide()
    var focusedElement: CFTypeRef?
    
    // Get the focused element (where cursor is)
    AXUIElementCopyAttributeValue(
        systemWide, 
        kAXFocusedUIElementAttribute as CFString,
        &focusedElement
    )
    
    return focusedElement as? AXUIElement
}
```

### 2. Inserting Text at Cursor

We have three methods, in order of preference:

#### Method 1: Direct AX Insertion (Best)
```swift
// Directly insert via Accessibility API
AXUIElementSetAttributeValue(
    focusedElement,
    kAXSelectedTextAttribute as CFString,
    transcribedText as CFString
)
```

#### Method 2: Simulated Typing (Fallback)
```swift
// Simulate keyboard typing
for character in transcribedText {
    let keyEvent = CGEvent(keyboardEventSource: nil, 
                          virtualKey: 0, 
                          keyDown: true)
    keyEvent?.unicodeString = String(character)
    keyEvent?.post(tap: .cghidEventTap)
}
```

#### Method 3: Clipboard (Last Resort)
```swift
// Only if other methods fail
NSPasteboard.general.setString(transcribedText, forType: .string)
// Simulate Cmd+V
```

### 3. Special Cases Handled

- **Password fields**: Detect and show warning
- **Terminal**: Use special handling for secure input
- **Web forms**: Works via JavaScript injection if needed
- **Read-only fields**: Detect and notify user

## Why This Works Better Than F5

1. **No focus switching**: F5 approach required complex window management
2. **Direct insertion**: No need to hijack system dictation UI
3. **Clean implementation**: ~50 lines vs 500+ for F5 intercept

## Testing Text Insertion

```bash
# Test script to verify cursor detection
./scripts/test-cursor-position.swift
```

This will:
1. Show current focused element
2. Attempt to insert test text
3. Verify insertion worked

## Privacy & Security

- We only access the focused text field
- No access to other windows/content
- Requires Accessibility permission (one-time)
- No keylogging - only inserts transcribed text

## Comparison with Apple Dictation

| Feature | Apple Dictation | WhisperKey |
|---------|----------------|------------|
| Activation | F5 (configurable) | Right Option (configurable) |
| Processing | Cloud (or local) | Always local |
| Privacy | Sends to Apple | Stays on device |
| Models | Apple's | Whisper (better) |
| Insert at cursor | ✅ | ✅ |
| Works everywhere | ✅ | ✅ |
| Offline | Limited | ✅ Full quality |

## The Bottom Line

WhisperKey provides the **exact same user experience** as Apple's dictation:
- Press hotkey with cursor anywhere
- Speak naturally  
- Text appears at cursor
- No window management
- No focus changes

But with:
- Better privacy (100% local)
- Better accuracy (Whisper)
- Better configurability