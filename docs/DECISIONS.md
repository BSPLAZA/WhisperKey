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
**Status**: Proposed  
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
*Last Updated: 2025-07-01*