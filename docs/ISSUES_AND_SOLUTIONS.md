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

## Issue #001: Example - CGEventTap Timeout

**Discovered**: TBD  
**Severity**: High  
**Symptoms**: 
- Key events stop being received after ~1 second
- No error messages
- Requires app restart to fix  

**Root Cause**: 
CGEventTap has a built-in timeout - if event processing takes >1 second, macOS disables the tap

**Solution**:
```swift
// Process events asynchronously immediately
func eventTapCallback(proxy: CGEventTapProxy, 
                     type: CGEventType, 
                     event: CGEvent, 
                     refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    
    // CRITICAL: Dispatch immediately, don't process in callback
    DispatchQueue.global(qos: .userInteractive).async {
        self.processEvent(event)
    }
    
    return Unmanaged.passRetained(event)
}
```

**Prevention**: 
- Always process events asynchronously
- Monitor callback execution time
- Add timeout warnings in debug builds

**Time Lost**: N/A (example)

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
*Last Updated: 2025-07-01*