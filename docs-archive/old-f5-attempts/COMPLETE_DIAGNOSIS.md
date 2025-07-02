# Complete WhisperKey Diagnosis & Solutions

## Issue Summary

### 1. Accessibility Permission Loop ✅ DIAGNOSED
**Root Cause**: Multiple WhisperKey processes, ad-hoc signing, running from DerivedData
**Solution**: Kill processes, reset permissions, run from stable location

### 2. F5 Still Triggers System Dictation ✅ DIAGNOSED  
**Root Cause**: Karabiner-Elements lacks Input Monitoring permission
**Solution**: Grant Input Monitoring to karabiner_grabber and karabiner_observer

## Detailed Findings

### Accessibility Permission Issue
1. **Stuck Process**: Found WhisperKey process (PID 77061) in stopped/traced state
2. **Ad-hoc Signing**: App only has ad-hoc signature, causing macOS to treat rebuilds as new apps
3. **Unstable Location**: Running from Xcode DerivedData means path changes with rebuilds
4. **TCC Confusion**: macOS permission system gets confused by multiple instances

### F5 Interception Issue
1. **Karabiner Running**: ✅ All processes active
2. **Configuration Loaded**: ✅ WhisperKey rules properly configured
3. **Input Monitoring**: ❌ NOT GRANTED - This is why F5 isn't intercepted
4. **Virtual HID**: Not ready due to missing permission

## Step-by-Step Solution

### 1. Run the Complete Fix Script
```bash
cd /Users/orion/Omni/WhisperKey
./scripts/fix-all-issues.sh
```

This script will:
- Kill stuck processes
- Reset permissions
- Guide you through granting Input Monitoring
- Test Karabiner configuration
- Launch WhisperKey properly

### 2. Manual Permission Grants

#### For Karabiner-Elements:
1. System Settings → Privacy & Security → Input Monitoring
2. Enable:
   - `karabiner_grabber`
   - `karabiner_observer`
3. If not listed, add from `/Library/Application Support/org.pqrs/Karabiner-Elements/bin/`

#### For WhisperKey:
1. System Settings → Privacy & Security → Accessibility
2. Enable WhisperKey when it appears after first run

### 3. Verification Steps

#### Test Karabiner:
1. Open Karabiner-EventViewer
2. Press F5
3. Should show as "f13" not "f5"

#### Test WhisperKey:
1. Click "Start Listening"
2. Open TextEdit
3. Press F5 - should NOT open system dictation
4. Should see WhisperKey notification

## Why This Happened

### macOS Security Model
- macOS 10.14+ requires explicit permissions for:
  - Accessibility (for CGEventTap)
  - Input Monitoring (for keyboard interception)
- Permissions are tied to app signature and location

### Development vs Production
- Development builds from Xcode are treated differently
- Each rebuild can be seen as a "new" app
- Solution: Install to `/Applications/` for stability

### Karabiner Requirements
- Needs Input Monitoring to modify keyboard input
- Without it, reads keys but can't modify them
- This permission is often missed during setup

## Long-term Recommendations

1. **Proper Code Signing**
   - Get Developer ID certificate
   - Enable hardened runtime
   - Add proper entitlements

2. **Stable Installation**
   - Always test from `/Applications/`
   - Create proper installer/DMG

3. **First-Run Experience**
   - Add setup wizard explaining permissions
   - Check permissions before operations
   - Guide users through Karabiner setup

4. **Alternative Approach**
   - Consider making WhisperKey a Karabiner complex modification
   - This would eliminate the need for separate accessibility permission

## Code Verification

The code itself is correct:
- `EnhancedKeyCaptureService.swift` properly checks permissions
- Event tap implementation follows best practices
- Alternative shortcuts (⌘⇧D) work as fallback

The issues were entirely permission/configuration related, not code bugs.