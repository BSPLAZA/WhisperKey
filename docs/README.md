# WhisperKey Documentation Hub

> Local dictation app using Whisper AI - Complete privacy, superior performance

## 🚀 Project Status

**Current Phase**: Environment Setup (Phase 0)  
**Current Focus**: Setting up development environment  
**Current Blocker**: None  
**Last Updated**: 2025-07-01

## 📍 Quick Navigation

### Core Documentation
- [📅 Timeline](TIMELINE.md) - Development progress tracking
- [📝 Daily Log](DAILY_LOG.md) - Daily development notes
- [🎯 Decisions](DECISIONS.md) - Architecture decisions record
- [🔧 Issues & Solutions](ISSUES_AND_SOLUTIONS.md) - Problem/solution archive
- [📖 API Reference](API_REFERENCE.md) - Internal API documentation
- [🧪 Testing Guide](TESTING_GUIDE.md) - Test scenarios and results
- [⚙️ Setup Guide](SETUP_GUIDE.md) - Environment setup instructions

### Planning Documents
- [Original Plan](../docs-archive/planning/WhisperKey-Planning.md) - Initial planning document

## 🎯 Current Sprint Goals

1. Set up development environment
2. Build whisper.cpp with Metal support
3. Create basic Xcode project structure
4. Implement proof-of-concept key interception

## 📊 Progress Overview

| Phase | Status | Planned | Actual | Notes |
|-------|--------|---------|--------|-------|
| Phase 0: Setup | 🟡 In Progress | 1 day | - | Environment setup |
| Phase 1: Core Prototype | ⏳ Not Started | 4 days | - | - |
| Phase 2: Audio Pipeline | ⏳ Not Started | 3 days | - | - |
| Phase 3: Whisper Integration | ⏳ Not Started | 4 days | - | - |
| Phase 4: Text Processing | ⏳ Not Started | 3 days | - | - |
| Phase 5: UI Polish | ⏳ Not Started | 3 days | - | - |
| Phase 6: Optimization | ⏳ Not Started | 2 days | - | - |
| Phase 7: Testing | ⏳ Not Started | 4 days | - | - |

## 🔑 Key Decisions Made

1. **Architecture**: MVVM with Swift Actors for concurrency
2. **Key Interception**: CGEventTap (primary) with Karabiner fallback
3. **Audio**: AVAudioEngine with 16kHz sampling
4. **Models**: Core ML format for M4 optimization

## 🛠 Development Commands

```bash
# Update documentation
./scripts/update-timeline.sh "Phase 0" "completed" "8 hours"
./scripts/new-decision.sh "Switched to Core ML for better M4 performance"
./scripts/log-issue.sh "CGEventTap timeout" "Process events async"

# Build commands
cd /Users/orion/Omni/WhisperKey
# ... (to be added)
```

## 📋 Quick Checklist

- [ ] Development environment ready
- [ ] whisper.cpp compiled with Metal
- [ ] Xcode project created
- [ ] Signing certificates configured
- [ ] Documentation structure established

---
*Auto-generated navigation. Update via README template.*
*Created: 2025-07-01 00:02 PST*