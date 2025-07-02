# WhisperKey Pre-Release Test Checklist

> Final verification before shipping to users

## 🚀 Launch Readiness Criteria

**Version**: 1.0.0  
**Test Date**: ___________  
**Tester**: ___________  
**Build**: ___________  

---

## Critical Path Testing (P0 - Must Pass 100%)

### 🔐 Security
- [ ] Password fields detected and refused in ALL browsers
- [ ] Terminal secure input (sudo/ssh) detected
- [ ] No audio files left on disk after use
- [ ] No network connections made (verified with Little Snitch)
- [ ] Clipboard not modified unnecessarily

### 🎯 Core Functionality  
- [ ] Right Option hotkey works consistently
- [ ] Audio recording starts within 100ms
- [ ] Transcription completes within 3s for 10s audio
- [ ] Text inserted at correct cursor position
- [ ] Works with all three models (base/small/medium)

### 🏥 Error Handling
- [ ] No microphone: Shows clear error
- [ ] No permissions: Guides to System Settings  
- [ ] Model missing: Offers download
- [ ] Disk full: Graceful failure
- [ ] App already running: Single instance enforced

---

## Compatibility Matrix (P1 - Must Pass 90%)

### Native Apps
| App | Basic | Rich Text | Secure | Notes |
|-----|-------|-----------|--------|-------|
| TextEdit | ☐ | ☐ | N/A | |
| Mail | ☐ | ☐ | N/A | |
| Notes | ☐ | ☐ | ☐ | |
| Messages | ☐ | N/A | N/A | |
| Terminal | ☐ | N/A | ☐ | |

### Browsers
| Browser | Text | Password | Forms | Notes |
|---------|------|----------|-------|-------|
| Safari | ☐ | ☐ | ☐ | |
| Chrome | ☐ | ☐ | ☐ | |
| Firefox | ☐ | ☐ | ☐ | |
| Edge | ☐ | ☐ | ☐ | |

### Dev Tools
| Tool | Editor | Terminal | Search | Notes |
|------|--------|----------|--------|-------|
| VS Code | ☐ | ☐ | ☐ | |
| Xcode | ☐ | ☐ | ☐ | |
| Terminal | ☐ | N/A | N/A | |
| iTerm2 | ☐ | N/A | N/A | |

### Communication
| App | Messages | Threads | Code | Notes |
|-----|----------|---------|------|-------|
| Slack | ☐ | ☐ | ☐ | |
| Discord | ☐ | ☐ | ☐ | |
| Teams | ☐ | ☐ | N/A | |
| Zoom | ☐ | N/A | N/A | |

---

## Performance Benchmarks (P1)

### Response Times
| Metric | Target | Actual | Pass |
|--------|--------|--------|------|
| Hotkey → Recording | <100ms | ___ms | ☐ |
| Stop → Processing | <200ms | ___ms | ☐ |
| 10s audio → Result | <3s | ___s | ☐ |
| Text insertion | <100ms | ___ms | ☐ |

### Resource Usage
| Metric | Target | Actual | Pass |
|--------|--------|--------|------|
| Idle CPU | <0.1% | ___% | ☐ |
| Recording CPU | <10% | ___% | ☐ |
| Processing CPU | <80% | ___% | ☐ |
| Memory (idle) | <50MB | ___MB | ☐ |
| Memory (active) | <200MB | ___MB | ☐ |

---

## Stress Testing (P2)

- [ ] 100 consecutive transcriptions without crash
- [ ] 60-second recording processes correctly
- [ ] 10 rapid start/stops handled gracefully
- [ ] Works after 24 hours of uptime
- [ ] No memory leaks detected
- [ ] Handles system sleep/wake cycles

---

## Edge Cases (P2)

- [ ] No microphone connected
- [ ] Bluetooth audio switching mid-recording
- [ ] Disk space <100MB
- [ ] 50+ apps open
- [ ] Multiple displays
- [ ] Different keyboard layouts
- [ ] VoiceOver enabled
- [ ] Low Power Mode

---

## User Experience (P1)

### First Run
- [ ] Permissions clearly explained
- [ ] No confusion about hotkey
- [ ] Model selection intuitive
- [ ] Success on first try

### Daily Use  
- [ ] Menu bar icon clear states
- [ ] Recording feedback obvious
- [ ] Errors explain solutions
- [ ] Preferences discoverable
- [ ] Quit really quits

### Accessibility
- [ ] VoiceOver fully supported
- [ ] Keyboard navigation complete
- [ ] High contrast visible
- [ ] Text size respected

---

## Release Blockers

List any issues that MUST be fixed before release:

1. ________________________________
2. ________________________________
3. ________________________________

---

## Sign-off

### Engineering
- [ ] All P0 tests pass
- [ ] No P1 blockers
- [ ] Performance acceptable
- [ ] Code review complete

**Engineer**: _____________ **Date**: _______

### QA
- [ ] Test plan executed
- [ ] No critical bugs
- [ ] UX acceptable
- [ ] Docs accurate

**QA**: _____________ **Date**: _______

### Product
- [ ] Meets requirements
- [ ] User feedback positive
- [ ] Ready for release
- [ ] Support prepared

**PM**: _____________ **Date**: _______

---

## Post-Release Monitoring

- [ ] Crash reports configured
- [ ] Analytics enabled
- [ ] Support channel ready
- [ ] Update mechanism tested
- [ ] Rollback plan prepared

---

*Use this checklist for final go/no-go decision*