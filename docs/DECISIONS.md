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

## ADR-009: Remove Streaming Mode Entirely

**Date**: 2025-07-01 23:00 PST  
**Status**: Accepted (Supersedes ADR-007)  
**Context**: After extensive testing with improved streaming algorithms
- Tested 0.5s chunks: Completely garbled (1-3/10 quality)
- Tested 2s chunks with 5s context: Better but still poor (4-6/10 quality)
- Implemented hybrid approach: Added complexity for no benefit
- User feedback: "streaming text is really bad"
**Decision**: Remove all streaming functionality and provide single mode
**Consequences**: 
- ✅ Consistent 10/10 transcription quality
- ✅ Simpler codebase (removed ~500 lines)
- ✅ Better user experience
- ✅ Easier maintenance
- ❌ No real-time feedback during speech
- ❌ 2-3 second wait after speaking
**Alternatives Considered**: 
- Keep both modes - Confusing UX with no real benefit
- Visual feedback only - Still added complexity
- Further optimization - Fundamental Whisper limitation

---

## ADR-010: Right Option Key Implementation

**Date**: 2025-07-02  
**Status**: Accepted  
**Context**: 
- HotKey library doesn't support modifier-only keys
- Users expect Right Option as default (muscle memory from other apps)
- Need to differentiate between left and right Option keys
**Decision**: 
- Use NSEvent.addGlobalMonitorForEvents for Right Option
- Check keyCode 61 specifically (Right Option)
- Keep HotKey library for other hotkey options
**Consequences**: 
- ✅ Right Option works as expected
- ✅ Can differentiate left/right modifiers
- ✅ Flexible hotkey system
- ❌ Two different hotkey implementations
**Alternatives Considered**: 
- Force users to use F13 - Poor UX
- Find different library - None support this well
- Custom implementation only - More maintenance

---

## ADR-011: Visual Recording Indicator Design

**Date**: 2025-07-02  
**Status**: Accepted  
**Context**:
- Users need clear feedback that recording is active
- Menu bar alone isn't prominent enough
- Need to show audio levels for confidence
**Decision**:
- Floating window at bottom center of screen
- 320x60px size with recording status
- Live audio level visualization
- Non-interactive (mouse events pass through)
**Consequences**:
- ✅ Clear visual feedback
- ✅ Users know when they're being heard
- ✅ Professional appearance
- ❌ Another window to manage
**Alternatives Considered**:
- Menu bar animation only - Not visible enough
- System notification - Too intrusive
- No indicator - Poor UX

---

## ADR-012: Comprehensive Error Handling System

**Date**: 2025-07-02  
**Status**: Accepted  
**Context**:
- Many failure points (permissions, audio, transcription)
- Users need clear guidance on fixing issues
- Different errors need different UI treatments
**Decision**:
- Create ErrorHandler with 30+ specific error types
- Each error has description and recovery suggestion
- Use appropriate UI (alerts, notifications, banners)
- Automatic recovery where possible
**Consequences**:
- ✅ Professional error handling
- ✅ Users can self-resolve issues
- ✅ Reduced support burden
- ❌ More code to maintain
**Alternatives Considered**:
- Generic error messages - Poor UX
- Console logging only - Users won't see
- Simple alerts for everything - Alert fatigue

---

## ADR-013: Preferences Window Architecture

**Date**: 2025-07-02  
**Status**: Accepted  
**Context**:
- Many settings to expose (hotkey, audio, models)
- Need organized, discoverable UI
- Should follow macOS design patterns
**Decision**:
- 4-tab preferences window
- SwiftUI implementation
- @AppStorage for all settings
- Immediate effect (no apply button)
**Consequences**:
- ✅ Familiar macOS pattern
- ✅ Settings persist automatically
- ✅ Clean organization
- ✅ Real-time updates
**Alternatives Considered**:
- Menu-based settings - Too cramped
- Single page - Too overwhelming
- Modal dialogs - Poor UX

---

## ADR-014: Model Download Strategy

**Date**: 2025-07-02  
**Status**: Accepted  
**Context**:
- Models are large (141MB - 2.9GB)
- Users may not have all models
- Need progress feedback for downloads
**Decision**:
- In-app download from HuggingFace
- Progress tracking with cancel support
- Download to whisper.cpp models directory
- Show download UI in preferences
**Consequences**:
- ✅ Better onboarding experience
- ✅ Users can manage models easily
- ✅ Progress visualization
- ❌ Need to handle download failures
**Alternatives Considered**:
- External download instructions - Poor UX
- Bundle models in app - Too large
- Auto-download all - Wasteful

---

## ADR-015: No Duplicate Permission Dialogs

**Date**: 2025-07-02  
**Status**: Accepted  
**Context**:
- System shows permission dialogs already
- Our additional dialogs were confusing
- Users complained about multiple popups
**Decision**:
- Trust system permission UI
- Don't show custom dialogs after system ones
- Only log that restart may be needed
**Consequences**:
- ✅ Cleaner permission flow
- ✅ Less user confusion
- ✅ Follows macOS patterns
- ❌ Less control over messaging
**Alternatives Considered**:
- Keep custom dialogs - Too annoying
- Custom permission UI - Not possible
- No permissions - App won't work

---

## ADR-016: Always Check User Configuration First

**Date**: 2025-07-09  
**Status**: Accepted  
**Context**:
- Spent 2+ hours debugging "broken" Right Option key
- Added extensive logging, removed checks, tried old code
- Turns out user had F13 selected in preferences
- The logs clearly showed this but we missed it
**Decision**:
- Always check user settings before complex debugging
- Add debug output for current preferences
- Trust the simplest explanation first
- Read logs more carefully
**Consequences**:
- ✅ Avoid wasted debugging time
- ✅ Better troubleshooting process
- ✅ Improved user support
- ❌ Feels obvious in hindsight
**Alternatives Considered**:
- Continue complex debugging - Wasteful
- Assume code is broken - Often wrong
- Skip user config checks - Source of bugs

---

## ADR-017: Simplified Hotkey Options

**Date**: 2025-07-09  
**Status**: Accepted  
**Context**:
- Had 6 hotkey options (caps lock, right option, F13-F19)
- Too many choices confused users
- Most options rarely used
**Decision**:
- Reduce to just Right Option and F13
- Remove caps lock and F14-F19
- Implement tap-to-toggle (not press-and-hold)
**Consequences**:
- ✅ Simpler user experience
- ✅ Less code to maintain
- ✅ Clearer documentation
- ❌ Some power users might want more options
**Alternatives Considered**:
- Keep all options - Too complex
- Only Right Option - Some users need F13
- Custom key combos - Too complex

---

## ADR-018: Audio Feedback for User Actions

**Date**: 2025-07-09  
**Status**: Accepted  
**Context**:
- Users wanted more feedback during recording
- Silent operation felt unresponsive
- Common request in dictation apps
**Decision**:
- Add optional system sounds:
  - "Tink" on recording start
  - "Pop" on recording stop
  - "Glass" on successful insertion
- Control via preferences toggle
**Consequences**:
- ✅ App feels more responsive
- ✅ Clear action confirmation
- ✅ Follows macOS patterns
- ❌ Some users prefer silence
**Alternatives Considered**:
- Custom sounds - More work, less native
- Visual only - Not enough feedback
- Always on - Some users hate sounds

---

## ADR-019: Multi-Language Support Strategy

**Date**: 2025-07-10  
**Status**: Proposed  
**Context**:
- Currently using English-only models (base.en, small.en, medium.en)
- Users may need to dictate in multiple languages
- Research shows Apple's auto-detection is broken since iOS 13
- Whisper supports 99 languages with built-in auto-detection
- Code-switching (mixed languages) is challenging for all systems
**Decision**:
- Phase 1: Continue with English-only for initial release
- Phase 2: Add multilingual models with manual language selection
- Phase 3: Implement Whisper's auto-detection with manual override
- Phase 4: Explore handling code-switching scenarios
- Always provide user control over language selection
**Consequences**:
- ✅ Gradual rollout reduces complexity
- ✅ Leverages Whisper's proven capabilities
- ✅ Better than Apple's broken implementation
- ✅ User control prevents frustration
- ❌ Larger model downloads (multilingual models)
- ❌ More UI complexity
**Alternatives Considered**:
- Auto-only like Apple - Too unreliable
- Manual-only - Poor UX for multilingual users
- Per-app language settings - Too complex
**Implementation Notes**:
- Use `whisper.cpp --language auto` flag
- Add language indicator to recording window
- Quick switcher in menu bar (hold Option?)
- Save last used language per session

---

## ADR-020: Future Model Flexibility

**Date**: 2025-07-10  
**Status**: Proposed  
**Context**:
- Currently tied to Whisper/whisper.cpp
- Other models emerging (MMS, USM, proprietary options)
- Name "WhisperKey" may be limiting
- Users may want choice of transcription engines
**Decision**:
- Abstract transcription interface to support multiple backends
- Keep WhisperCppTranscriber as one implementation
- Design plugin-style architecture for future models
- Consider rebranding to model-agnostic name
**Consequences**:
- ✅ Future-proof architecture
- ✅ User choice of models
- ✅ Can add cloud options later (opt-in)
- ❌ More complex codebase
- ❌ Need to maintain multiple integrations
**Alternatives Considered**:
- Stay Whisper-only - Too limiting
- Fork for each model - Maintenance nightmare
- Cloud-only future models - Privacy concern

---
*Last Updated: 2025-07-10 08:30 PST*