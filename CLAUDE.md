# WhisperKey Project Guidelines

## Important: Time Zone
**Always use PST (Pacific Standard Time) for all timestamps and documentation**

## Project Overview
WhisperKey is a privacy-focused local dictation app for macOS that intercepts the F5 dictation key and uses Whisper AI for transcription. All processing happens locally with zero network connections.

## Current Status
- **Phase**: 0 - Environment Setup
- **Focus**: Setting up development environment
- **Target**: 24-day development cycle
- **Started**: 2025-07-01

## Key Technical Details

### Hardware Target
- **Primary**: Apple M4 Pro with 48GB RAM
- **Optimization**: Neural Engine and Metal acceleration
- **Models**: base.en (39MB), small.en (141MB), medium.en (466MB)

### Critical Values
- **Dictation Key HID**: 0x000c00cf
- **Audio Sample Rate**: 16kHz
- **Silence Threshold**: 2.0 seconds
- **Target Latency**: <500ms end-to-end

### Architecture Decisions
- **Concurrency**: Swift 5.9 Actors
- **Key Interception**: CGEventTap (primary), Karabiner (fallback)
- **Audio**: AVAudioEngine
- **Text Insertion**: CGEventPost → AXUIElement → Clipboard

## Documentation Requirements

### ALWAYS Update These Files:
1. **DAILY_LOG.md** - End of each session (max 10 min)
2. **TIMELINE.md** - When completing tasks or hitting blockers
3. **DECISIONS.md** - For any architectural choices
4. **ISSUES_AND_SOLUTIONS.md** - When solving problems
5. **TESTING_GUIDE.md** - After testing in new apps

### Use Helper Scripts:
```bash
cd scripts
./update-timeline.sh "Phase 0" "completed" "8 hours"
./new-decision.sh "Switched to Core ML for M4 optimization"
./log-issue.sh "CGEventTap timeout" "Process events async"
```

## Development Workflow

### Session Start Checklist:
- [ ] Read DAILY_LOG.md for context
- [ ] Check TIMELINE.md for current phase
- [ ] Review blockers in ISSUES_AND_SOLUTIONS.md
- [ ] Open QUICK_REFERENCE.md in split pane

### During Development:
- Test key interception with actual F5 key frequently
- Document macOS permission prompts exactly
- Track memory usage with Activity Monitor
- Note any security warnings or entitlement issues

### Session End Checklist:
- [ ] Update DAILY_LOG.md
- [ ] Update task status in TIMELINE.md
- [ ] Document any decisions made
- [ ] Commit with proper format
- [ ] Note tomorrow's priorities

## Code Standards

### Swift Conventions:
```swift
// File header for all source files
//
//  ComponentName.swift
//  WhisperKey
//
//  Purpose: What this component does
//  
//  Created by [Your name] on 2025-07-XX.
//

// Use actors for concurrent components
actor AudioCapture {
    // Implementation
}

// Explicit error handling
enum WhisperKeyError: LocalizedError {
    case permissionDenied(String)
    // Full context in errors
}
```

### Testing Requirements:
- Test dictation in: TextEdit, Safari, Terminal, Slack, VS Code
- Document app-specific behaviors
- Test with Fn+F5 to ensure F5 functionality preserved
- Verify secure field detection

## Performance Targets
- Cold start: <2 seconds
- Key response: <50ms
- First word: <300ms
- Memory with model: <200MB
- Idle memory: <50MB

## Security Checklist
- [ ] No network connections (verify with Little Snitch)
- [ ] Proper entitlements only
- [ ] Secure input field detection
- [ ] No logging of transcribed text
- [ ] Memory cleared after use

## Common Commands

### Build & Test:
```bash
# Build whisper.cpp with Metal
cd ~/Developer/whisper.cpp
WHISPER_METAL=1 make -j

# Test dictation key
tail -f /tmp/whisperkey-test.log

# Reset permissions
tccutil reset All com.whisperkey.app
```

### Debugging:
```bash
# Monitor Console
log stream --predicate 'subsystem == "com.whisperkey"'

# Check memory
leaks WhisperKey

# Profile performance
instruments -t "Time Profiler" WhisperKey
```

## Known Challenges
1. **CGEventTap Timeout**: Must process events async within 1 second
2. **Secure Input Fields**: Terminal and password fields block input
3. **Permission Loops**: May need to reset TCC database during dev
4. **Model Loading Time**: Consider pre-loading base.en model

## Testing Scenarios Priority
1. Basic dictation in TextEdit
2. Web forms (Safari, Chrome)
3. Code editors (Xcode, VS Code)
4. Chat apps (Slack, Discord)
5. Terminal (special handling needed)
6. Password fields (should show warning)

## Git Workflow
```bash
# Feature branches
git checkout -b feature/audio-capture

# Commit format
git commit -m "Audio: Implement ring buffer for streaming

TESTED ✅: 16kHz capture working
- Ring buffer with 30-second capacity
- Silence detection with 2-second threshold
- Pre-roll buffer captures speech onset

STATUS: Ready for Whisper integration"
```

## Resource Links
- [Original Plan](docs-archive/planning/WhisperKey-Planning.md)
- [whisper.cpp](https://github.com/ggerganov/whisper.cpp)
- [Karabiner Docs](https://karabiner-elements.pqrs.org/docs/)

---
*This file loaded with every Claude Code session for WhisperKey context*