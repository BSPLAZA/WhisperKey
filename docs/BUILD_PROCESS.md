# WhisperKey Build Process Documentation

## Overview

This document explains the WhisperKey build process, particularly the library bundling mechanism and how to handle Xcode sandbox restrictions.

## The Sandbox Issue

### Problem
When building in Release configuration, Xcode's sandbox prevents build scripts from writing to the app bundle's Frameworks directory. You'll see errors like:
```
error: Sandbox: cp(5077) deny(1) file-write-create .../WhisperKey.app/Contents/Frameworks/libggml.dylib
```

### Why This Happens
- Xcode runs build phases in a sandboxed environment for security
- Release builds have stricter sandboxing than Debug builds
- The sandbox blocks file writes to certain directories during build phases
- This affects both local builds and CI/CD pipelines

### Solution
We handle this by running the library copying **after** the build completes, outside the sandbox:

1. **During Build**: The "Copy Whisper Libraries" build phase attempts to copy but may fail
2. **After Build**: We run the same script manually without sandbox restrictions
3. **Result**: Libraries are properly bundled in the final app

## Build Configurations

### Local Development (Debug)
```bash
# Simple build - usually works without issues
xcodebuild build -project WhisperKey.xcodeproj -scheme WhisperKey -configuration Debug
```

### Release Builds
```bash
# Build (may show sandbox errors - that's OK)
xcodebuild build -project WhisperKey.xcodeproj \
  -scheme WhisperKey \
  -configuration Release \
  ONLY_ACTIVE_ARCH=NO || true

# Then manually copy libraries
BUILT_PRODUCTS_DIR="path/to/build/Products/Release" \
WRAPPER_NAME="WhisperKey.app" \
./copy-whisper-libraries.sh
```

### CI/CD Pipeline
Our GitHub Actions workflow handles this automatically:
1. Builds whisper.cpp from source
2. Runs xcodebuild (ignoring sandbox errors)
3. Manually copies libraries after build
4. Verifies all libraries are bundled

## Library Requirements

WhisperKey requires these libraries from whisper.cpp:
- `whisper-cli` - The main executable
- `libggml.dylib` - Core GGML functionality
- `libggml-base.dylib` - Base operations
- `libggml-cpu.dylib` - CPU backend
- `libggml-blas.dylib` - BLAS acceleration (optional)
- `libggml-metal.dylib` - Metal acceleration (optional)
- `libwhisper.dylib` - Whisper library

## The Copy Script

The `copy-whisper-libraries.sh` script:
1. Expects whisper.cpp at `~/Developer/whisper.cpp`
2. Copies whisper-cli to `Contents/MacOS/`
3. Copies all .dylib files to `Contents/Frameworks/`
4. Fixes library paths using `install_name_tool`
5. Validates at least 3 core libraries are present

## Creating Release DMGs

Use the automated script which handles everything:
```bash
./scripts/create-release-dmg.sh
```

This script:
1. Builds the app (ignoring sandbox errors)
2. Manually copies libraries
3. Creates a professional DMG with all dependencies

## Troubleshooting

### "Operation not permitted" errors during build
**This is normal for Release builds.** The build will continue and libraries will be copied afterward.

### Libraries missing from final app
Check that:
1. whisper.cpp is built at `~/Developer/whisper.cpp`
2. The copy script ran after the build
3. You're looking in the correct directories:
   - Binary: `WhisperKey.app/Contents/MacOS/whisper-cli`
   - Libraries: `WhisperKey.app/Contents/Frameworks/*.dylib`

### CI/CD build failures
The CI workflow:
1. Builds whisper.cpp from source
2. Handles sandbox restrictions automatically
3. Verifies library bundling

If CI fails, check:
- whisper.cpp built successfully
- Libraries are in the expected locations
- The copy script has correct permissions

## Important Notes

1. **Never remove the `|| true` from build commands** - it's there to handle sandbox errors
2. **Always verify libraries after Release builds** - count should be ≥3
3. **The sandbox issue is an Xcode limitation** - not a bug in our build process
4. **This affects all macOS apps** that bundle dynamic libraries

## References

- [Xcode Build Settings Reference](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [Code Signing and Sandboxing](https://developer.apple.com/documentation/security)
- Original issue discussions in PR #4 and PR #6