# WhisperKey Testing Guide

> Comprehensive testing scenarios and results tracking

## Test Categories

### 🔑 Permission Tests
- [ ] First-run permission flow
- [ ] Permission denied handling
- [ ] Permission reset and re-request
- [ ] TCC database corruption handling

### 🎤 Audio Tests
- [ ] Multiple microphone devices
- [ ] Bluetooth headset switching
- [ ] USB microphone hot-plug
- [ ] System audio device changes
- [ ] High sample rate devices
- [ ] Silence detection accuracy

### ⌨️ Key Interception Tests
- [ ] F5 key detection
- [ ] Fn+F5 passthrough
- [ ] Other media keys non-interference
- [ ] External keyboard support
- [ ] Key held down behavior
- [ ] Rapid key press handling

### 📝 Text Insertion Tests

#### Native macOS Apps
| App | Version | Basic Text | Rich Text | Secure Fields | Notes |
|-----|---------|------------|-----------|---------------|-------|
| TextEdit | System | ⏳ | ⏳ | N/A | - |
| Notes | System | ⏳ | ⏳ | ⏳ | - |
| Mail | System | ⏳ | ⏳ | N/A | - |
| Safari | System | ⏳ | ⏳ | ⏳ | - |
| Terminal | System | ⏳ | N/A | ⏳ | Special handling needed |
| Xcode | 15.4 | ⏳ | N/A | N/A | - |

#### Third-Party Apps
| App | Version | Basic Text | Rich Text | Secure Fields | Notes |
|-----|---------|------------|-----------|---------------|-------|
| Chrome | Latest | ⏳ | ⏳ | ⏳ | - |
| Slack | Latest | ⏳ | ⏳ | N/A | - |
| VS Code | Latest | ⏳ | N/A | N/A | - |
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
*Last Updated: 2025-07-01 21:30 PST*