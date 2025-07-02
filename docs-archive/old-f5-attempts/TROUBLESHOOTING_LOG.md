# WhisperKey Troubleshooting Log

## Current Issues (2025-07-01)

### Issue 1: Accessibility Permission Loop
- **Symptom**: Clicking "Start Listening" triggers accessibility permission dialog even though it's already granted
- **Expected**: Should recognize existing permission and start listening

### Issue 2: F5 Still Triggers System Dictation
- **Symptom**: Despite Karabiner-Elements configuration, F5 key still opens system dictation dialog
- **Expected**: F5 should be intercepted and trigger WhisperKey instead

## What We've Tried So Far

### 1. CGEventTap Implementation
- Created `KeyCaptureService.swift` with basic CGEventTap
- Added event masks for keyDown, keyUp, NSSystemDefined (type 14), and flagsChanged
- Attempted to intercept F5 (keycode 0x60) and dictation key (0x00cf)
- **Result**: Partial - could detect keys but couldn't prevent system dictation

### 2. IOKit HID Implementation
- Created `IOKitF5Monitor.swift` using IOHIDManager
- Monitored both keyboard page (F5 key) and consumer page (dictation key)
- **Result**: Could detect keys but no ability to block system handling

### 3. Enhanced Key Capture Service
- Combined CGEventTap + IOKit approaches
- Added timeout handling and duplicate prevention
- Added support for alternative shortcuts (⌘⇧D, F13)
- **Result**: Better detection but core issues persist

### 4. Karabiner-Elements Integration
- Created configuration to remap F5 → F13
- Installed config at `~/.config/karabiner/assets/complex_modifications/whisperkey.json`
- Created installation script
- **Result**: Config installed but F5 still triggers system dictation

### 5. System Dictation Disable Script
- Created script to disable via defaults:
  ```bash
  defaults write com.apple.HIToolbox AppleDictationAutoEnable -int 0
  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 162 "{enabled = 0;}"
  ```
- **Result**: Not verified if this actually worked

### 6. Permission Handling Updates
- Modified `requestAccessibilityPermission()` to check before prompting
- Used `AXIsProcessTrusted()` without options first
- **Result**: Still prompting even when permission exists

## Key Code References
- F5 standard key: `0x60`
- F5 dictation (NSSystemDefined): `0x00cf`
- NSSystemDefined event type: `14`
- Special system key subtype: `8`
- Key down state: `0x0A`

## Files Modified
1. `KeyCaptureService.swift` - Original implementation
2. `IOKitF5Monitor.swift` - IOKit approach
3. `EnhancedKeyCaptureService.swift` - Combined approach
4. `ContentView.swift` - Updated to use EnhancedKeyCaptureService
5. `WhisperKeyApp.swift` - Updated service reference
6. `Info.plist` - Has accessibility usage description

## Research Findings
- macOS handles F5 dictation at system level before apps can intercept
- CGEventTap has limitations with system-defined events
- Karabiner-Elements should work at kernel level but isn't
- NSSystemDefined events are poorly documented
- Accessibility permission checks can be cached/stale

## Next Steps for Diagnosis

### 1. Verify Current State
- Check actual accessibility permission status
- Verify Karabiner is actually intercepting
- Check if system dictation is truly disabled
- Examine bundle identifier consistency

### 2. Debug Accessibility Permission
- Check TCC database directly
- Look for bundle ID mismatches
- Test with fresh user account
- Check code signing

### 3. Debug Karabiner Integration
- Verify rule is enabled in Karabiner UI
- Check Karabiner event viewer
- Test F5 → F13 mapping works
- Check Karabiner has Input Monitoring permission

### 4. Alternative Approaches to Consider
- Use Accessibility API instead of CGEventTap
- Create launch agent with special privileges
- Use private APIs (if acceptable)
- Implement as Karabiner plugin