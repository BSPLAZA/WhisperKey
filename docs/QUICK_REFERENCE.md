# WhisperKey Quick Reference

> Keep this open while developing

## Current Status
- **Phase**: 0 (Environment Setup)
- **Focus**: Setting up development environment
- **Blocker**: Waiting for Xcode to expand
- **Next**: Create Xcode project and start Phase 1

## Key Commands

### Documentation Updates
```bash
cd scripts
./update-timeline.sh "Phase 0" "completed" "8"
./new-decision.sh "Switch to Core ML for better M4 performance"
./log-issue.sh "Build fails on M4" "Add -arch arm64 flag"
```

### Build & Run
```bash
# Build whisper.cpp
cd ~/Developer/whisper.cpp
WHISPER_METAL=1 make -j

# Test whisper
./build/bin/whisper-cli -m models/ggml-base.en.bin -f samples/jfk.wav

# Run Xcode (once installed)
open WhisperKey.xcodeproj

# Test F5 capture
./scripts/test-f5-capture.sh

# Accept Xcode license
sudo xcodebuild -license accept
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

### Git Workflow
```bash
# Commit with proper format
git add .
git commit -m "Component: Brief description

TIMELINE: Phase X update
DECISION: Any architectural decisions
ISSUE: Any issues discovered"
```

## Key File Locations

| What | Where |
|------|-------|
| Timeline | `docs/TIMELINE.md` |
| Today's work | `docs/DAILY_LOG.md` |
| Decisions | `docs/DECISIONS.md` |
| Problems | `docs/ISSUES_AND_SOLUTIONS.md` |
| Original plan | `docs-archive/planning/WhisperKey-Planning.md` |

## Technical Quick Ref

### F5 Dictation Key
- HID Usage: `0x000c00cf`
- CGEventType: `NX_SYSDEFINED`

### Audio Settings
- Sample Rate: 16kHz
- Format: Float32 → Int16
- Buffer: 512 samples

### Model Sizes & Paths
- base.en: 141MB - `~/Developer/whisper.cpp/models/ggml-base.en.bin`
- small.en: 465MB - `~/Developer/whisper.cpp/models/ggml-small.en.bin`
- medium.en: 1.4GB - `~/Developer/whisper.cpp/models/ggml-medium.en.bin`

### Key APIs
```swift
// Event tap
CGEventTapCreate()
CGEventTapEnable()

// Audio
AVAudioEngine()
AVAudioInputNode

// Text insertion
CGEventPost()
AXUIElementSetAttributeValue()
```

## Debugging

### Reset Permissions
```bash
tccutil reset All com.whisperkey.app
tccutil reset Microphone com.whisperkey.app
tccutil reset Accessibility com.whisperkey.app
```

### Console Filters
- Process: WhisperKey
- Subsystem: com.whisperkey

### Performance Monitoring
```bash
# CPU usage
top -pid $(pgrep WhisperKey)

# Memory
leaks WhisperKey

# File handles
lsof -p $(pgrep WhisperKey)
```

## Testing Checklist

Daily:
- [ ] Timeline updated
- [ ] Daily log entry
- [ ] Git commit with proper message

Before Phase Completion:
- [ ] All tasks checked off
- [ ] Issues documented
- [ ] Decisions recorded
- [ ] Tests passing

---
*Keep this file open in a split pane while coding*