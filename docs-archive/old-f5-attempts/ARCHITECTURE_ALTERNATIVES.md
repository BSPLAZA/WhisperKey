# WhisperKey Architecture Alternatives

## The Core Problem
We've been fighting macOS's system-level F5 dictation handling. F5 is intercepted by the OS before any user-space app can block it. This is by design for security and consistency.

## Alternative Architectures

### Option 1: Don't Fight F5 - Use Better Hotkeys
**Approach**: Use hotkeys that aren't system-reserved
- **F13-F19**: Less commonly used, no system conflicts
- **Double-tap modifiers**: e.g., double-tap Right Command
- **Unique combinations**: Cmd+Shift+Space, Cmd+Option+D
- **Hyper key**: Cmd+Option+Control+Shift + key

**Implementation**:
```swift
// Use HotKey library (Carbon-based, proven to work)
import HotKey

let hotKey = HotKey(key: .f13, modifiers: [])
hotKey.keyDownHandler = { startDictation() }
```

**Pros**: 
- Simple, reliable, no system conflicts
- Works immediately without hacks
- No permission issues

**Cons**: 
- Not F5 (but is this really a con?)

### Option 2: Detect and Hijack System Dictation
**Approach**: Let F5 trigger system dictation, then take over
1. Monitor for dictation window appearance using Accessibility API
2. Immediately close it and start our recording
3. Use AXUIElement to detect dictation UI

**Implementation sketch**:
```swift
// Monitor for dictation window
let observer = AXObserver(...)
AXObserverAddNotification(observer, element, kAXWindowCreatedNotification, ...)
```

**Pros**: Works with user muscle memory
**Cons**: Flicker, complex, fragile

### Option 3: Menu Bar App with Proven Hotkey Library
**Approach**: Create menu bar app using battle-tested hotkey solutions

**Libraries to consider**:
1. **HotKey** (https://github.com/soffes/HotKey) - Uses Carbon Events
2. **MASShortcut** - Mature, widely used
3. **KeyboardShortcuts** by Sindre Sorhus - Modern Swift

**Pros**: 
- Proven to work with any key combination
- Menu bar apps are lightweight
- Can show recording status in menu bar

**Cons**: 
- Some use deprecated APIs (but they work!)

### Option 4: Custom Input Method
**Approach**: Create a custom keyboard input method
- Register as an input source
- Can intercept keys at lowest level
- Similar to how Japanese IMEs work

**Pros**: Ultimate control
**Cons**: Complex, overkill for our needs

### Option 5: Voice Activation Instead of Keyboard
**Approach**: Use wake word detection
- "Hey Whisper" to start recording
- No keyboard conflicts at all

**Implementation**: Use Porcupine wake word detection

**Pros**: No conflicts, hands-free
**Cons**: Different UX than requested

## Recommended Solution

**Primary**: Option 1 with F13 key + Option 3 (Menu Bar with HotKey library)
- Use F13 as default (touch bar Macs have it)
- Allow user to configure any hotkey
- Provide preset options including Cmd+Shift+Space

**Fallback**: If user insists on F5:
1. Document that they must disable system dictation
2. Provide our comprehensive-fix.sh script
3. Use Karabiner-Elements as advanced option

## Implementation Plan

1. **Pivot to menu bar architecture**:
   - Cleaner, no main window needed
   - Shows recording status
   - Quick preferences access

2. **Use HotKey library**:
   - Proven to work with system keys
   - Simple API
   - Handles all edge cases

3. **Make hotkey configurable**:
   - Default to F13
   - Let users choose
   - Save preference

4. **Stop fighting the system**:
   - Work with macOS, not against it
   - Use proven solutions
   - Focus on core functionality

## Key Insight

We've been solving the wrong problem. Instead of "How do we intercept F5?", we should ask "How do we give users the best dictation experience?". The answer isn't necessarily F5 - it's whatever hotkey works reliably and doesn't conflict with the system.