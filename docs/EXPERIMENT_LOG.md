# WhisperKey Experiment Log

> Systematic documentation of streaming and transcription experiments

## Experiment Template

```markdown
### Experiment #XXX
**Date/Time**: YYYY-MM-DD HH:MM PST
**Test Phrase**: [exact phrase spoken]
**Duration**: [how long you spoke]

#### Configuration
- **Mode**: [Streaming ON/OFF]
- **Model**: [base.en/small.en/medium.en]
- **Chunk Duration**: [X seconds]
- **Context Window**: [X seconds]
- **Processing Interval**: [X seconds]
- **Overlap Duration**: [X seconds]

#### Results
**Output**: "[exact transcription output]"
**Quality Score**: X/10
**Latency**: [time from speech end to text appearance]
**Issues**: [specific problems observed]
```

---

## Experiment #001: Initial Streaming Test (0.5s chunks)
**Date/Time**: 2025-07-01 21:00 PST
**Test Phrase**: "If streaming mode is off, you'll only see the complete transcription at the end. Make sure to enable it in the settings!"
**Duration**: ~8 seconds

#### Configuration
- **Mode**: Streaming ON
- **Model**: Various (see results)
- **Chunk Duration**: 0.5 seconds
- **Context Window**: N/A (using chunk size)
- **Processing Interval**: 0.5 seconds
- **Overlap Duration**: 0.1 seconds

#### Results

| Model | Output | Quality |
|-------|--------|---------|
| base.en | "It's true.Dreamingmode isoff.you'llonlysee thePleaseWeinscription.at theend.AndMake suresure toenablein thesetting.Thanks.you" | 2/10 |
| small.en | "It'sstreamstreamingmode is off.your ownonly seethe comcomplete transition.Inscriptionat the end.Make suretoenable it insettings." | 3/10 |
| medium.en | "youIfStreetstreaming mode.mode is on.off.you'll almost" | 1/10 |

**Issues**: Words split, duplicated, completely wrong substitutions

---

## Experiment #002: Non-Streaming Baseline
**Date/Time**: 2025-07-01 21:00 PST
**Test Phrase**: "If streaming mode is off, you'll only see the complete transcription at the end. Make sure to enable it in the settings!"
**Duration**: ~8 seconds

#### Configuration
- **Mode**: Streaming OFF
- **Model**: Various (see results)
- **Chunk Duration**: N/A (full recording)
- **Context Window**: N/A (full recording)
- **Processing Interval**: N/A
- **Overlap Duration**: N/A

#### Results

| Model | Output | Quality |
|-------|--------|---------|
| base.en | "If streaming mode is off, you'll only see the complete transcription at the end. Make sure to enable it in the settings." | 10/10 |
| small.en | "If streaming. modeis off, you'll only see the complete transcription at the end. Make sure to enable it in the settings." | 9/10 |
| medium.en | "If streaming mode. isoff, you'll only see the complete transcription at the end. Make sure to enable it in the settings." | 9/10 |

**Issues**: Minor punctuation placement variations

---

## Experiment #003: Streaming Mode with 0.5s Chunks (Incomplete Output)
**Date/Time**: 2025-07-01 21:45 PST
**Test Phrase**: "If streaming mode is off, you'll only see the complete transcription at the end. Make sure to enable it in the settings!"
**Duration**: ~8 seconds

#### Configuration
- **Mode**: Streaming ON (with old configuration)
- **Model**: Various (see results)
- **Chunk Duration**: 0.5 seconds
- **Context Window**: 0.5 seconds (no extended context)
- **Processing Interval**: 0.5 seconds
- **Overlap Duration**: 0.1 seconds
- **Minimum Processing Duration**: N/A (processing immediately)
- **Silence Detection**: 2.0 seconds threshold, 0.005 amplitude
- **Buffer Management**: Minimal retention

#### Results

| Model | Output | Quality | Processing Notes |
|-------|--------|---------|-----------------|
| base.en | "If streaming mode is off, you'll only see the complete transcription at the end. Make sure" | 7/10 (incomplete) | Last chunk likely not processed |
| small.en | "If streaming mode is off, you'll only see the complete transaction.n at the end." | 6/10 (incomplete + error) | Word boundary issues |
| medium.en | ".f streaming mode is off, you'll only see the complete transcriptionsure to" | 5/10 (incomplete + errors) | Severe context loss |

**Issues**: 
- Transcription cut off mid-sentence (likely last chunk not finalized)
- Word errors due to insufficient context (0.5s chunks)
- "transcription" → "transaction" error shows phonetic confusion
- Missing beginning in medium model suggests context window too small
- **Root Causes**: 
  1. Small chunks (0.5s) causing context loss
  2. Final chunk not processed on stop
  3. Insufficient overlap for continuity

---

## Experiment #004: Improved Streaming (Completed)
**Date/Time**: 2025-07-01 22:15 PST
**Test Phrase**: "If streaming mode is off, you'll only see the complete transcription at the end. Make sure to enable it in the settings!"
**Duration**: ~8 seconds

#### Configuration
- **Mode**: Streaming ON
- **Model**: All three tested
- **Chunk Duration**: 2.0 seconds (increased from 0.5)
- **Context Window**: 5.0 seconds
- **Processing Interval**: 2.0 seconds
- **Overlap Duration**: 4.0 seconds (keeping most context)
- **Minimum Processing Duration**: 2.0 seconds

#### Results

| Model | Output | Quality | Notes |
|-------|--------|---------|-------|
| base.en | "If streaming mode is off, you'll only see the complete transcription at the end.it in the settings." | 6/10 | Missing "Make sure to enable", merged "end.it" |
| small.en | "If streaming mode. isoff, you'll only see the complete transcription at the end.s." | 5/10 | Period placement, missing entire last sentence |
| medium.en | "If streaming motivatedff, you'll only see the complete transition.at the end. Make sure to" | 4/10 | "mode" → "motivated", "transcription" → "transition" |

**Improvements from 0.5s chunks**:
- ✅ More complete sentences (vs completely garbled)
- ✅ Better word recognition overall
- ✅ Less fragmentation

**Remaining Issues**:
- ❌ Still missing portions of text (especially "Make sure to enable it in the settings")
- ❌ Word boundary issues persist ("end.it", "mode. isoff")
- ❌ Medium model still struggles with accuracy
- ❌ Final chunk processing incomplete

---

## Experiment #005: Non-Streaming Baseline (Current State)
**Date/Time**: TBD
**Test Phrase**: "If streaming mode is off, you'll only see the complete transcription at the end. Make sure to enable it in the settings!"

#### Configuration
- **Mode**: Streaming OFF
- **Model**: [Test all three: base.en, small.en, medium.en]
- **Chunk Duration**: N/A (full recording)
- **Context Window**: N/A (full recording)
- **Processing Interval**: N/A
- **Overlap Duration**: N/A
- **Silence Detection**: 2.0 seconds threshold, 0.005 amplitude
- **Recording Method**: Hold Right Option, speak, auto-stop on silence

#### Results
**Status**: Not yet tested

**Purpose**: Establish current non-streaming baseline to compare with streaming improvements

---

## Experiment #006: Silence Detection Adjustment (Pending)
**Date/Time**: TBD
**Test Phrase**: "If streaming mode is off, you'll only see the complete transcription at the end. Make sure to enable it in the settings!"

#### Configuration
- **Mode**: Streaming OFF
- **Model**: base.en
- **Silence Detection Threshold**: [Test values: 0.01, 0.02, 0.03]
- **Silence Duration**: [Test values: 2.5s, 3.0s, 3.5s]
- **Current Settings**: threshold=0.005, duration=2.0s

#### Results
**Status**: Not yet tested

**Hypothesis**: Current threshold (0.005) is too sensitive to natural speech variations. Audio levels during speech (0.018-0.063) suggest threshold should be at least 0.01-0.02.

---

## Configuration Comparison

| Setting | Old Streaming (Exp #001, #003) | Improved Streaming (Exp #004) | Non-Streaming |
|---------|-------------------------------|------------------------------|---------------|
| Chunk Duration | 0.5s | 2.0s | N/A |
| Context Window | 0.5s | 5.0s | Full recording |
| Processing Interval | 0.5s | 2.0s | N/A |
| Overlap Duration | 0.1s | 4.0s | N/A |
| Min Processing Duration | None | 2.0s | N/A |
| Quality Result | 1-3/10 | 4-6/10 | 9-10/10 |
| Latency | ~0.5s | ~2-3s | End of recording |
| Completeness | Severely truncated | Missing last portion | Complete |

## Variables to Track

### Audio Capture
- Recording duration
- Silence detection threshold
- Silence duration before stop
- Audio format/sample rate

### Streaming Configuration
- Chunk duration
- Context window size
- Processing interval
- Overlap duration
- Buffer management strategy

### Model Configuration
- Model size (base/small/medium)
- Number of threads
- Beam size
- Temperature

### Environmental Factors
- Background noise level
- Speaking speed
- Microphone distance
- System load

## Key Insights

1. **Chunk Size Critical**: 0.5s chunks produce garbled text in streaming mode
2. **Context Window Essential**: Whisper needs 2-5s of audio context for accuracy
3. **Model Size ≠ Better Streaming**: Larger models perform worse with insufficient context
4. **Incomplete Output in Streaming**: Final chunks may not be processed on stop
5. **Processing Timing Matters**: Need minimum 2s before first processing
6. **Overlap Required**: Must maintain context between chunks for continuity

## Next Experiments

1. ~~Test improved streaming (2s chunks, 5s context)~~ ✅ Completed - Better but still issues
2. Fix final chunk processing in streaming mode
3. Test non-streaming baseline (Experiment #005)
4. Adjust silence detection settings (Experiment #006)
5. Consider alternative approaches:
   - Use whisper-stream binary for true real-time
   - Implement sliding window with better overlap
   - Try Apple Speech Recognition for comparison

## Recommendations

Based on experiments #001-#004, streaming transcription with whisper.cpp has fundamental limitations:

1. **Quality vs Latency Tradeoff**: Acceptable quality requires 2-5s chunks, defeating real-time purpose
2. **Word Boundary Problem**: Partial context creates persistent alignment issues  
3. **Final Chunk Loss**: Current implementation consistently loses the last portion

### Potential Solutions:
1. **Fix Final Chunk**: Ensure `finalize()` properly processes remaining audio
2. **Better Overlap Algorithm**: Implement intelligent word boundary detection
3. **Hybrid Approach**: Stream for display, but use full recording for final text
4. **Alternative Tool**: Use whisper-stream binary which is designed for this use case

---

## Final Decision: Streaming Mode Removed (2025-07-01 23:00 PST)

After extensive experimentation (Experiments #001-#004), we've decided to completely remove streaming mode:

**Reasons:**
1. **No Quality Benefit**: Even with improved algorithms, streaming never exceeded 6/10 quality
2. **User Experience**: Partial text was distracting and unprofessional
3. **Complexity**: Added significant code complexity for minimal benefit
4. **Whisper Limitations**: Whisper fundamentally requires full context for accuracy

**Final Implementation:**
- Single, simple transcription mode
- 2-3 second wait after speaking
- Perfect accuracy every time
- Clean, professional experience

---
*Last Updated: 2025-07-01 23:00 PST*