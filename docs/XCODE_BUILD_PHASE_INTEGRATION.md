# Xcode Build Phase Integration Documentation

## Overview

This document provides comprehensive documentation on how the whisper library copying was properly integrated into the Xcode build process for WhisperKey v1.0.2.

## Background

### The Problem (v1.0.0 - v1.0.1)
- In v1.0.0, libraries were manually copied, resulting in broken releases
- In v1.0.1, we created `copy-whisper-libraries.sh` but didn't integrate it into Xcode
- Developers had to manually run the script or remember to copy libraries
- DMG creation scripts needed workarounds

### The Solution (v1.0.2)
- Properly integrated the script as an Xcode Run Script build phase
- Libraries are now automatically copied on every build
- No manual intervention required

## Integration Details

### What Was Added

A new Run Script build phase named "Copy Whisper Libraries" was added to the WhisperKey target with:

```
Name: Copy Whisper Libraries
Script: "${SRCROOT}/copy-whisper-libraries.sh"
Shell: /bin/sh
Position: After "Copy Bundle Resources" phase
```

### Build Phase Configuration

```xml
/* PBXShellScriptBuildPhase */
E5AF497618B9CE3EC5FF54F8 /* Copy Whisper Libraries */ = {
    isa = PBXShellScriptBuildPhase;
    alwaysOutOfDate = 1;  /* Always run, not based on dependency analysis */
    buildActionMask = 2147483647;
    inputPaths = (
        "$(SRCROOT)/copy-whisper-libraries.sh",
        "${HOME}/Developer/whisper.cpp/build/bin/whisper-cli",
    );
    name = "Copy Whisper Libraries";
    outputPaths = (
        "$(BUILT_PRODUCTS_DIR)/$(WRAPPER_NAME)/Contents/Resources/whisper-cli",
        "$(BUILT_PRODUCTS_DIR)/$(WRAPPER_NAME)/Contents/Frameworks/",
    );
    runOnlyForDeploymentPostprocessing = 0;
    shellPath = /bin/sh;
    shellScript = "\"${SRCROOT}/copy-whisper-libraries.sh\"";
    showEnvVarsInLog = 0;
};
```

### Key Settings Explained

1. **alwaysOutOfDate = 1**: Forces the script to run on every build, ensuring libraries are always copied
2. **Input Paths**: Declares dependencies on the script and whisper-cli binary
3. **Output Paths**: Tells Xcode what files this phase produces
4. **Position**: Runs after resources are copied but before code signing

## How It Works

### Build Flow

1. **Sources Compiled** → Swift/ObjC files compiled
2. **Frameworks Linked** → Dependencies linked
3. **Resources Copied** → Assets, xibs, etc copied
4. **Copy Whisper Libraries** → Our script runs here ← NEW!
5. **Code Signing** → App is signed
6. **Validation** → Final app validation

### What the Script Does

The `copy-whisper-libraries.sh` script:

1. **Validates Environment**
   ```bash
   APP_PATH="${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"
   ```

2. **Checks whisper.cpp**
   ```bash
   WHISPER_PATH="${HOME}/Developer/whisper.cpp"
   ```

3. **Copies Binary**
   ```bash
   cp whisper-cli "$APP_PATH/Contents/Resources/"
   ```

4. **Copies Libraries**
   - libggml.dylib (core GGML)
   - libggml-base.dylib (base operations)
   - libggml-cpu.dylib (CPU backend)
   - libggml-blas.dylib (BLAS acceleration)
   - libggml-metal.dylib (Metal acceleration)
   - libwhisper.dylib (Whisper library)

5. **Fixes Library Paths**
   ```bash
   install_name_tool -id "@rpath/$lib" "$lib"
   install_name_tool -add_rpath @executable_path/../Frameworks whisper-cli
   ```

6. **Validates Result**
   - Ensures at least 3 libraries were copied
   - Reports success/failure

## Testing the Integration

### Clean Build Test

```bash
cd /Users/orion/Omni/WhisperKey/WhisperKey

# Clean everything
xcodebuild clean
rm -rf build/

# Build fresh
xcodebuild -configuration Debug build

# Verify libraries
ls -la build/Build/Products/Debug/WhisperKey.app/Contents/Frameworks/
# Should show 6 .dylib files
```

### Release Build Test

```bash
# Build release version
xcodebuild -configuration Release build

# Check release build
ls -la build/Build/Products/Release/WhisperKey.app/Contents/Frameworks/
```

## Troubleshooting

### Build Phase Not Running

1. Check Xcode shows "Copy Whisper Libraries" in Build Phases
2. Ensure script has execute permissions:
   ```bash
   chmod +x copy-whisper-libraries.sh
   ```
3. Check build logs for script output

### Libraries Not Found

1. Ensure whisper.cpp is built:
   ```bash
   cd ~/Developer/whisper.cpp
   WHISPER_METAL=1 make clean && make -j
   ```

2. Check paths in error messages
3. Verify WHISPER_PATH in script

### "Library not verified" Error

This means the libraries were copied but linking failed. Check:
1. Library compatibility (architecture)
2. install_name_tool errors in build log

## Benefits

### For Developers
- No manual steps required
- Can't forget to copy libraries
- Works in Xcode GUI and command line
- Consistent builds every time

### For Users
- Apps always have required libraries
- No "library not found" crashes
- Smaller download if libraries change

### For CI/CD
- No special build scripts needed
- Standard xcodebuild works
- Easy to integrate with GitHub Actions

## Migration Notes

### From Manual Process
If you were manually copying libraries:
1. Delete any manual copy commands from build scripts
2. Remove workarounds from DMG creation scripts
3. Just build normally - it's automatic now!

### From v1.0.1 Workaround
The temporary workaround in `create-release-dmg.sh` is no longer needed:
```bash
# DELETE THIS SECTION:
# Step 2.5: Run library copy script manually
```

Use `create-release-dmg-proper.sh` instead.

## Future Improvements

1. **Auto-download whisper.cpp**: If not found, clone and build automatically
2. **Version checking**: Ensure library versions are compatible
3. **Universal binary support**: Handle both arm64 and x86_64 libraries
4. **Selective copying**: Only copy needed libraries based on configuration

## Files Involved

- `/WhisperKey.xcodeproj/project.pbxproj` - Xcode project file (modified)
- `/copy-whisper-libraries.sh` - The script that copies libraries
- `/scripts/integrate-build-phase.sh` - Automation script that did the integration
- `/scripts/create-release-dmg-proper.sh` - Clean DMG script without workarounds

## Verification Checklist

- [x] Build phase appears in Xcode UI
- [x] Clean build includes libraries
- [x] Release build includes libraries  
- [x] DMG creation works without manual steps
- [x] Libraries are properly linked (otool -L)
- [x] App runs on clean system

## Summary

The integration is now complete and permanent. Every build will automatically include the required whisper libraries without any manual intervention. This is the proper, professional solution that scales to teams and CI/CD environments.