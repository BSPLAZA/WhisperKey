# WhisperKey Comprehensive Testing Guide

> Expert-level testing strategy for production-ready voice dictation

## Testing Philosophy

As a QA expert, I approach WhisperKey testing with these principles:
1. **User-centric scenarios** - Test how real users actually dictate
2. **Edge case coverage** - Find failures before users do
3. **Performance benchmarking** - Ensure consistent sub-3s response
4. **Accessibility verification** - Works for all users
5. **Security validation** - No data leaks or unauthorized access

## Test Categories

### 🔑 Permission Tests
- [ ] First-run permission flow - Clear explanation, no confusion
- [ ] Permission denied handling - Graceful degradation, clear guidance
- [ ] Permission reset and re-request - tccutil reset All com.whisperkey.WhisperKey
- [ ] TCC database corruption handling

### 🎤 Audio Tests
- [x] Multiple microphone devices - Works with built-in and external
- [ ] Bluetooth headset switching
- [ ] USB microphone hot-plug
- [ ] System audio device changes
- [ ] High sample rate devices
- [x] Silence detection accuracy - 2.5s threshold working well

### ⌨️ Hotkey Tests
- [x] Right Option key detection - Working correctly
- [x] Left Option vs Right Option - Only right triggers
- [ ] Option key with other modifiers
- [ ] External keyboard support
- [ ] Bluetooth keyboard support
- [x] Key held down behavior - Tap to start/stop model
- [x] Rapid key press handling - Debouncing works
- [ ] Hotkey during CPU intensive tasks
- [x] Hotkey in secure input mode - Properly detected
- [x] Alternative hotkeys (F13) - Available in settings

### 📝 Text Insertion Tests

#### Native macOS Apps
| App | Version | Basic Text | Rich Text | Secure Fields | Notes |
|-----|---------|------------|-----------|---------------|-------|
| TextEdit | System | ✅ | ✅ | N/A | Perfect insertion |
| Notes | System | ✅ | ✅ | N/A | Works well |
| Mail | System | ⏳ | ⏳ | N/A | - |
| Safari | System | ✅ | ✅ | ⏳ | Text fields work |
| Terminal | System | ✅ | N/A | ⏳ | Works in normal mode |
| Xcode | 15.4 | ✅ | N/A | N/A | Code editor works |

#### Third-Party Apps
| App | Version | Basic Text | Rich Text | Secure Fields | Notes |
|-----|---------|------------|-----------|---------------|-------|
| Chrome | Latest | ⏳ | ⏳ | ⏳ | Need to test |
| Slack | Latest | ✅ | ✅ | N/A | Works great |
| VS Code | Latest | ✅ | N/A | N/A | Perfect for coding |
| Discord | Latest | ⏳ | ⏳ | N/A | - |
| 1Password | 8.x | ⏳ | N/A | ⏳ | - |

Legend: ✅ Pass | ❌ Fail | ⏳ Not Tested | N/A Not Applicable

### 🧠 Whisper Model Tests
- [x] Base model accuracy - Tested
- [x] Small model accuracy - Tested  
- [x] Medium model accuracy - Tested
- [x] Model switching performance - Works well
- [ ] Memory usage per model
- [ ] Inference speed benchmarks

### 🚀 Performance Tests
- [ ] Cold start time
- [ ] Key-to-recording latency
- [ ] Speech-to-text latency
- [ ] Memory usage over time
- [ ] CPU usage during inference
- [ ] Battery impact (1 hour test)

### 🔄 State Management Tests
- [ ] Rapid start/stop cycles
- [ ] App sleep/wake handling
- [ ] System sleep/wake handling
- [ ] Memory pressure response
- [ ] Concurrent request handling

### 🌍 Edge Cases
- [ ] No microphone available
- [ ] Disk full (can't save audio)
- [ ] Model file corrupted
- [ ] Multiple displays
- [ ] Mission Control active
- [ ] Screen recording active
- [ ] Do Not Disturb mode
- [ ] Low Power Mode

## Test Scenarios

### Scenario 001: Basic Dictation Flow
**Objective**: Verify end-to-end functionality  
**Steps**:
1. Press F5 key
2. Speak "Hello world period"
3. Wait for auto-stop
4. Verify text inserted

**Expected**: "Hello world." inserted at cursor  
**Result**: ⏳ Not Tested  

### Scenario 002: Interruption Handling
**Objective**: Test dictation interruption  
**Steps**:
1. Start dictation
2. After 2 seconds, press F5 again
3. Verify immediate stop

**Expected**: Partial transcription inserted  
**Result**: ⏳ Not Tested  

### Scenario 003: Secure Field Detection
**Objective**: Verify secure field handling  
**Steps**:
1. Focus password field
2. Press F5
3. Check for warning

**Expected**: Warning shown, no recording  
**Result**: ⏳ Not Tested  

## Benchmark Results

### Model Performance (M4 Pro)

| Model | Load Time | RAM Usage | Inference/sec | Accuracy |
|-------|-----------|-----------|---------------|----------|
| base.en | - | - | - | - |
| small.en | - | - | - | - |
| medium.en | - | - | - | - |

### Latency Measurements

| Metric | Target | Actual | Notes |
|--------|--------|--------|-------|
| Key to recording | <50ms | - | - |
| First word latency | <300ms | - | - |
| End-to-end | <500ms | - | - |

## Test Automation

```bash
# Run unit tests
swift test

# Run integration tests
./scripts/run-integration-tests.sh

# Run performance benchmarks
./scripts/benchmark.sh
```

## Bug Report Template

```markdown
**Environment**: macOS version, Mac model
**WhisperKey Version**: 
**Steps to Reproduce**:
1. 
2. 

**Expected Behavior**:
**Actual Behavior**:
**Screenshots/Logs**:
**Workaround**:
```

---

## Streaming vs Non-Streaming Quality Test Results

**Test Date**: 2025-07-01 21:00 PST  
**Test Phrase**: "If streaming mode is off, you'll only see the complete transcription at the end. Make sure to enable it in the settings!"

### Streaming Mode ON (Poor Quality)
| Model | Output | Quality Score |
|-------|--------|---------------|
| base.en | "It's true.Dreamingmode isoff.you'llonlysee thePleaseWeinscription.at theend.AndMake suresure toenablein thesetting.Thanks.you" | 2/10 |
| small.en | "It'sstreamstreamingmode is off.your ownonly seethe comcomplete transition.Inscriptionat the end.Make suretoenable it insettings." | 3/10 |
| medium.en | "youIfStreetstreaming mode.mode is on.off.you'll almost" | 1/10 |

### Streaming Mode OFF (Excellent Quality)
| Model | Output | Quality Score |
|-------|--------|---------------|
| base.en | "If streaming mode is off, you'll only see the complete transcription at the end. Make sure to enable it in the settings." | 10/10 |
| small.en | "If streaming. modeis off, you'll only see the complete transcription at the end. Make sure to enable it in the settings." | 9/10 |
| medium.en | "If streaming mode. isoff, you'll only see the complete transcription at the end. Make sure to enable it in the settings." | 9/10 |

### Key Findings
1. **Streaming with 0.5s chunks is unusable** - Produces garbled, nonsensical output
2. **Non-streaming mode has near-perfect accuracy** - All models perform excellently
3. **Whisper needs 2-5s of context** - Fundamental architecture requirement
4. **Medium model not necessarily better** - Sometimes performs worse on short chunks

### Recommended Configuration
- **Default**: Non-streaming mode for accuracy
- **Streaming**: Only with 2s+ chunks and 5s context window
- **Model**: Small.en offers best balance of speed and accuracy

---

## Detailed App Testing Procedures

### Phase 1: Core App Testing

#### 1.1 TextEdit Testing
**Test Engineer Perspective**: Native text system validation

**Setup**:
1. Create test files: empty.txt, large.txt (10MB), unicode.txt, readonly.txt
2. Open TextEdit in both plain and rich text modes

**Test Cases**:
```
□ Empty document insertion at start
□ Insert between words: "Hello | world" → "Hello beautiful world"
□ Insert with selection: Select "world" → dictate "universe"
□ Multi-paragraph: Insert with \n\n gaps
□ Special chars: Test quotes "", apostrophes '', dashes —
□ Numbers: "Call me at 555-1234 extension 567"
□ Unicode: "I love 🍕 and 寿司"
□ Performance: Insert into 10MB document
□ RTF mode: Preserve bold/italic when inserting
□ Undo/Redo: Cmd+Z after insertion
```

**Expected**: All insertions preserve formatting and cursor position

#### 1.2 Terminal.app Testing  
**Security Expert Perspective**: Secure input detection

**Setup**:
```bash
# Create test scenarios
echo "Test normal input" > test.txt
vim secure_test.txt
ssh localhost  # For password prompt
```

**Test Matrix**:
```
□ Normal shell prompt: ls -la | (cursor here)
□ vim insert mode: Should work
□ vim command mode: Should detect and warn
□ nano editor: Should work
□ ssh password prompt: MUST detect and refuse
□ sudo password: MUST detect and refuse
□ MySQL password: MUST detect and refuse
□ gpg passphrase: MUST detect and refuse
□ Multi-line command with \
□ tmux/screen sessions
□ iTerm2 comparison test
```

**Security Validation**:
- Run `ioreg -l | grep SecureInput` during each test
- Verify secure input detection works 100%

#### 1.3 Safari Web Testing
**Web Compatibility Expert Perspective**

**Test Sites Checklist**:

**Google Properties**:
```
□ google.com search box
□ Gmail compose (subject and body separately)
□ Google Docs (main editor, comments, title)
□ Google Sheets (cells, formula bar)
□ YouTube comments
□ Google Forms (various field types)
```

**Social Media**:
```
□ Twitter/X: Tweet compose, replies, DMs
□ Facebook: Status, comments, Messenger
□ LinkedIn: Posts, comments, messages
□ Reddit: Post title, body, comments
□ Instagram Web: Comments, DMs
```

**Complex Scenarios**:
```
□ CodePen/JSFiddle editors
□ Contenteditable divs
□ IFrame embedded forms
□ Shadow DOM components
□ React controlled inputs
□ Vue v-model bindings
□ Auto-save forms (test race conditions)
□ Forms with validation on keyup
```

**Must Fail Gracefully**:
```
□ Password fields (<input type="password">)
□ Credit card fields
□ Date pickers
□ File upload buttons
□ Captcha fields
```

### Phase 2: Professional Tools

#### 2.1 VS Code Deep Dive
**IDE Plugin Developer Perspective**

**Test Workspace Setup**:
```bash
mkdir whisperkey-test && cd whisperkey-test
touch test.{js,py,md,json,yaml}
code .
```

**Feature Tests**:
```
□ Main editor basic insertion
□ Multiple cursors: Cmd+D → dictate
□ Column selection: Option+drag → dictate
□ IntelliSense active: Don't break autocomplete
□ Snippet expansion: Don't interfere
□ Find/Replace dialog: Both fields
□ Command palette: Should work
□ Terminal panel: Should work
□ Git commit message: Should work
□ Markdown preview: Source only
□ Jupyter notebooks: Code and markdown cells
```

**Language-Specific**:
```python
# Python: Test indentation preservation
def test():
    | # Cursor here, dictate "print hello world"
    
# JavaScript: Template literals
const msg = `Hello ${|}` # Dictate here

# JSON: Don't break syntax
{
  "key": "|" # Dictate with quotes
}
```

#### 2.2 Slack/Discord Testing
**Real-time Systems Expert**

**Slack Test Plan**:
```
□ Main message: Start typing, dictate rest
□ Thread reply: Maintain context
□ Code blocks: ``` preservation
□ Emoji triggers: :smile → Don't auto-complete
□ @mentions: @here handling
□ /commands: /remind handling
□ Edit mode: Select existing, replace
□ DM vs Channel: Both work
□ Markdown: **bold** preservation
```

**Critical**: Must not accidentally send (Enter key)

### Phase 3: Stress & Performance

#### 3.1 Memory Leak Detection
**Performance Engineer Protocol**

```bash
# 24-hour leak test
while true; do
    # Trigger dictation via AppleScript
    osascript -e 'tell application "System Events" to key code 61'
    sleep 1
    # Speak to mic
    say "Testing memory leaks"
    sleep 3
    # Check memory
    ps aux | grep WhisperKey | awk '{print $6}'
    sleep 5
done > memory_log.txt
```

**Analysis**:
- Graph memory usage over time
- Must be flat after initial spike
- No growth over 1000 cycles

#### 3.2 CPU Profiling
```bash
# Profile during heavy use
sudo dtrace -n 'profile-997 /execname == "WhisperKey"/ { @[ustack()] = count(); }'

# Instruments detailed trace
instruments -t "Time Profiler" -D trace.trace WhisperKey
```

**Targets**:
- Recording: <10% CPU
- Processing: <80% CPU
- Idle: <0.1% CPU

### Phase 4: Error Injection

#### 4.1 Failure Scenarios
**Chaos Engineering Approach**

```bash
# Disk full simulation
dd if=/dev/zero of=/tmp/bigfile bs=1m count=$(($(df / | awk 'NR==2{print $4}') - 100))

# Memory pressure
stress -m 8 --vm-bytes 1G

# CPU saturation  
stress -c 8

# Kill audio daemon
sudo killall coreaudiod

# Corrupt model file
dd if=/dev/random of=~/whisper-models/base.en bs=1k count=1

# Revoke permissions
tccutil reset Microphone com.whisperkey.WhisperKey
```

**Expected**: Graceful degradation, clear errors

### Phase 5: Accessibility Testing

#### 5.1 VoiceOver Navigation
**Accessibility Specialist Protocol**

```
□ Enable VoiceOver: Cmd+F5
□ Navigate menu: VO+M
□ Read status: VO+A
□ Change preferences: Full flow
□ Error announcements: Immediate
□ Recording status: Clear announcement
```

#### 5.2 Keyboard-Only Usage
```
□ No mouse required for any function
□ Tab order logical
□ Focus indicators visible
□ Escape cancels operations
□ Return confirms dialogs
```

### Test Result Documentation

#### Issue Tracking Format
```yaml
issue_id: WK-001
title: "Cursor jumps to end in VS Code"
severity: HIGH
app: "VS Code 1.85"
macos: "14.2"
reproduce:
  - Open VS Code
  - Place cursor mid-line
  - Dictate text
  - Observe cursor jump
expected: "Text inserted at cursor"
actual: "Text at end of line"
workaround: "None"
fix: "Use different insertion method"
```

#### Daily Test Report
```markdown
# WhisperKey Test Report - [Date]

## Summary
- Tests Run: 127
- Passed: 119
- Failed: 8
- Pass Rate: 93.7%

## Critical Issues
1. Terminal secure input detection intermittent
2. Slack sometimes sends on insertion
3. Memory leak in long recordings

## Performance
- Avg transcription time: 1.8s
- Peak memory: 187MB
- No crashes in 8hr test

## Recommendations
1. Fix P1 issues before ship
2. Add timeout for long recordings
3. Improve error messages
```

### Automated Test Suite

```python
# test_whisperkey.py
import subprocess
import time
import psutil

class WhisperKeyTests:
    def test_memory_usage(self):
        """Memory should not exceed 200MB"""
        proc = self.get_whisperkey_process()
        assert proc.memory_info().rss < 200 * 1024 * 1024
        
    def test_cpu_idle(self):
        """CPU should be <0.1% when idle"""
        proc = self.get_whisperkey_process()
        cpu_percent = proc.cpu_percent(interval=1)
        assert cpu_percent < 0.1
        
    def test_secure_field_detection(self):
        """Must detect password fields"""
        # Simulate password field focus
        # Trigger hotkey
        # Verify warning shown
        pass
```

---
*Last Updated: 2025-07-01 23:45 PST*