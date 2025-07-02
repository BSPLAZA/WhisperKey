# WhisperKey Accessibility Permission Diagnosis

## Summary of Issues

The main issue is that `AXIsProcessTrusted()` returns `false` even when accessibility permission appears to be granted in System Settings. This is preventing WhisperKey from capturing global keyboard events.

## Root Causes Identified

### 1. **Multiple Running Instances**
- Found multiple WhisperKey processes running simultaneously
- One process (PID 77061) is stuck in "SX" state (stopped/traced by debugger)
- This can confuse the TCC system about which process has permission

### 2. **Bundle Identifier Mismatch**
- App bundle ID: `com.whisperkey.WhisperKey`
- Successfully reset permissions using: `tccutil reset Accessibility com.whisperkey.WhisperKey`
- This suggests the bundle ID is correctly registered

### 3. **Code Signing Issues**
- App is signed with ad-hoc signature only
- No TeamIdentifier set
- No hardened runtime enabled
- This can cause macOS to treat each build as a different app

### 4. **Development vs Production Environment**
- Running from Xcode DerivedData directory
- Each rebuild gets a new path, which macOS might treat as a new app
- The app is marked as `LSUIElement` (menu bar app) which has special handling

## Solutions

### Immediate Fix
1. **Kill all existing WhisperKey processes:**
   ```bash
   sudo killall -9 WhisperKey
   ```

2. **Reset accessibility permissions:**
   ```bash
   tccutil reset Accessibility com.whisperkey.WhisperKey
   ```

3. **Run the app directly (not from Xcode):**
   ```bash
   open "/Users/orion/Library/Developer/Xcode/DerivedData/WhisperKey-*/Build/Products/Debug/WhisperKey.app"
   ```

4. **Grant permission when prompted**

### Long-term Solutions

1. **Proper Code Signing**
   - Get a Developer ID certificate
   - Enable hardened runtime
   - Add proper entitlements for accessibility

2. **Install to Applications Folder**
   - Copy the app to `/Applications/`
   - This gives it a stable location that macOS recognizes

3. **Add Entitlements**
   Consider adding to WhisperKey.entitlements:
   ```xml
   <key>com.apple.security.automation.apple-events</key>
   <true/>
   ```

4. **Check Permission Before Each Operation**
   The code already does this correctly in `EnhancedKeyCaptureService.swift`

## Testing Steps

1. Open System Settings > Privacy & Security > Accessibility
2. Look for WhisperKey in the list
3. If present, toggle it off and on
4. If not present, run the app and it should prompt
5. After granting, restart the app

## Code Verification

The accessibility check code in `EnhancedKeyCaptureService.swift` is correct:
- Line 30: `if AXIsProcessTrusted()`
- Line 59: `return AXIsProcessTrusted()`
- Line 71: `guard AXIsProcessTrusted() else {`

The issue is not with the code, but with how macOS is tracking the app's permissions.

## Next Steps

1. Clean build the project
2. Archive and export a proper release build
3. Move to `/Applications/`
4. Reset permissions and re-grant
5. Test with the production build

This should resolve the accessibility permission issues.