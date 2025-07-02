# WhisperKey Architecture Decision Records (ADRs)

> Document all significant technical decisions and their rationale

## ADR Template

```markdown
## ADR-XXX: [Decision Title]
**Date**: YYYY-MM-DD  
**Status**: [Proposed | Accepted | Deprecated | Superseded by ADR-XXX]  
**Context**: [Why this decision needed to be made]  
**Decision**: [What we decided]  
**Consequences**: [What happens as a result]  
**Alternatives Considered**: [Other options evaluated]
```

---

## ADR-001: Documentation-First Development Approach

**Date**: 2025-07-01  
**Status**: Accepted  
**Context**: Need to track complex development with many technical decisions and potential gotchas  
**Decision**: Establish comprehensive documentation structure before writing code  
**Consequences**: 
- Slight upfront time investment
- Better decision tracking
- Easier to resume after breaks
- Knowledge preserved for debugging  
**Alternatives Considered**: 
- Ad-hoc documentation (rejected: too easy to lose insights)
- Post-development documentation (rejected: details get forgotten)

---

## ADR-002: Use CGEventTap for Primary Key Interception

**Date**: 2025-07-01  
**Status**: Superseded by ADR-005  
**Context**: Need to intercept F5 media key system-wide on macOS  
**Decision**: Use CGEventTap as primary method over IOKit HID  
**Consequences**: 
- More reliable for media keys
- Must handle 1-second timeout carefully
- Requires dedicated thread for event processing
- Need Accessibility permissions  
**Alternatives Considered**: 
- IOKit HID Manager (backup option)
- Karabiner Elements integration (fallback)
- Custom kernel extension (too complex)

---

## ADR-003: Core ML vs whisper.cpp for Inference

**Date**: 2025-07-01  
**Status**: Proposed  
**Context**: Need to choose Whisper implementation for M4 Pro optimization  
**Decision**: TBD - Need to benchmark both options  
**Consequences**: TBD  
**Alternatives Considered**: 
- Core ML (better M4 optimization potential)
- whisper.cpp (proven, more control)
- Both with runtime selection (complex but flexible)

---

## ADR-004: Swift Actors for Concurrency Model

**Date**: 2025-07-01  
**Status**: Accepted  
**Context**: Audio processing requires careful thread management  
**Decision**: Use Swift 5.9 actors for audio pipeline and state management  
**Consequences**: 
- Type-safe concurrency
- Prevents race conditions
- Requires Swift 5.9+
- Some C++ interop complexity  
**Alternatives Considered**: 
- Grand Central Dispatch (more error-prone)
- NSOperationQueue (outdated)
- Combine framework (overkill for this use case)

---

## Future Decision Points

- [ ] Model format: GGML vs Core ML vs both
- [ ] Text insertion primary method
- [ ] Update distribution mechanism
- [ ] Logging framework choice
- [ ] Testing framework selection

---

## ADR-005: Pivot to Menu Bar App with Configurable Hotkeys

**Date**: 2025-07-01  
**Status**: Accepted  
**Context**: 
- F5 is intercepted by macOS at system level for dictation
- CGEventTap cannot reliably block system-reserved keys  
- Even Karabiner-Elements has issues with F5 on newer Macs
- Accessibility permission shows false positives (TCC database issues)
- Fighting the system leads to poor user experience  
**Decision**: 
- Switch to menu bar app architecture
- Use HotKey library (Carbon-based, proven to work)
- Default to F13 key (no system conflicts)
- Allow user-configurable hotkeys
- Stop trying to intercept F5  
**Consequences**: 
- ✅ Reliable hotkey interception
- ✅ No permission issues or TCC database problems
- ✅ Better user experience
- ✅ Menu bar shows recording status
- ❌ Not using F5 (but document workarounds)
- ❌ Uses deprecated Carbon APIs (but they work)  
**Alternatives Considered**: 
- Continue fighting F5 - Too unreliable
- Use NSEvent monitors - Can't capture system keys
- Create kernel extension - Overkill, deprecated
- Hijack system dictation window - Complex, fragile

---

## ADR-006: Use Proven Libraries Over Custom Solutions

**Date**: 2025-07-01  
**Status**: Accepted  
**Context**:
- Custom CGEventTap implementation was complex
- Many edge cases and system conflicts
- Reinventing the wheel for solved problems  
**Decision**:
- Use HotKey library for global shortcuts
- Consider KeyboardShortcuts by Sindre Sorhus for UI later
- Focus on core functionality (Whisper integration)  
**Consequences**:
- ✅ Faster development
- ✅ Battle-tested code
- ✅ Less maintenance burden
- ❌ Additional dependency  
**Alternatives Considered**:
- Write custom hotkey handling - Too complex
- Use only NSEvent - Limited capabilities

---

## ADR-007: Streaming vs Non-Streaming Transcription Architecture

**Date**: 2025-07-01 21:00 PST  
**Status**: Accepted  
**Context**: 
- Users expect real-time text appearance like native dictation
- Whisper requires significant audio context (2-5s) for accuracy
- Small audio chunks (0.5s) produce completely garbled output
- Tested comprehensively with multiple models and chunk sizes
**Decision**: 
- Implement both streaming and non-streaming modes
- Non-streaming as default for accuracy
- Streaming uses 2s chunks with 5s context window
- Acknowledge fundamental Whisper limitation for real-time use
**Consequences**: 
- ✅ Perfect accuracy in non-streaming mode
- ✅ User choice between accuracy and feedback
- ❌ Streaming has 2-3 second latency minimum
- ❌ Cannot achieve true real-time like native dictation
**Alternatives Considered**: 
- whisper-stream binary - Gives up control over audio pipeline
- 0.5s chunks - Completely unusable output quality
- Apple Speech Recognition - Would work but requires different architecture
- Hybrid approach - Too complex for initial version

**Test Results Documented**:
Test phrase accuracy comparison showed streaming mode produces garbled text while non-streaming is near-perfect across all models.

---

## ADR-008: Continue as Learning Project Despite Market Saturation

**Date**: 2025-07-01 21:15 PST  
**Status**: Accepted  
**Context**:
- Discovered 10+ existing solutions (MacWhisper, SuperWhisper, etc.)
- Many are open source with similar features
- No clear differentiation for WhisperKey currently
- Success probability <5% as commercial product
**Decision**:
- Continue development as learning project
- Focus on technical excellence over market viability
- Keep architecture flexible for future innovation
- Document all learnings thoroughly
**Consequences**:
- ✅ No pressure for commercial success
- ✅ Freedom to experiment with approaches
- ✅ Learning opportunity for future projects
- ❌ Limited motivation without clear user need
**Alternatives Considered**:
- Abandon project - Loses learning opportunity
- Pivot to niche market - Premature without research
- Contribute to existing project - Less learning value

---
*Last Updated: 2025-07-01 21:30 PST*