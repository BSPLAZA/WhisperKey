# WhisperKey Build Integration

## Overview

As of v1.0.1, WhisperKey now includes automated library copying directly in the Xcode build process. This ensures that all required whisper.cpp libraries are properly bundled with every build.

## What's Integrated

The build process now automatically:
1. Copies `whisper-cli` binary to the app's Resources folder
2. Copies all required GGML libraries to the app's Frameworks folder
3. Fixes library paths for proper runtime linking
4. Validates that all required components are present

## Required Libraries

The following libraries are copied during build:
- `libggml.dylib` (required)
- `libggml-base.dylib` (required)
- `libggml-cpu.dylib` (required)
- `libggml-blas.dylib` (optional, for BLAS acceleration)
- `libggml-metal.dylib` (optional, for Metal acceleration)
- `libwhisper.dylib` (or versioned variants)

## Setup Instructions

### 1. Ensure whisper.cpp is Built

Before building WhisperKey, make sure whisper.cpp is properly built:

```bash
cd ~/Developer/whisper.cpp
make clean
WHISPER_METAL=1 make -j
```

### 2. Add Build Phase to Xcode (One-time Setup)

1. Open `WhisperKey.xcodeproj` in Xcode
2. Select the WhisperKey target
3. Go to Build Phases tab
4. Click + and select "New Run Script Phase"
5. Configure as follows:
   - Name: "Copy Whisper Libraries"
   - Script: `"${SRCROOT}/copy-whisper-libraries.sh"`
   - Uncheck "Based on dependency analysis"
   - Input Files:
     - `$(SRCROOT)/copy-whisper-libraries.sh`
     - `${HOME}/Developer/whisper.cpp/build/bin/whisper-cli`
   - Output Files:
     - `$(BUILT_PRODUCTS_DIR)/$(WRAPPER_NAME)/Contents/Resources/whisper-cli`
     - `$(BUILT_PRODUCTS_DIR)/$(WRAPPER_NAME)/Contents/Frameworks/`
6. Drag the phase to run after "Copy Bundle Resources" but before code signing

### 3. Build the App

Now when you build WhisperKey (Debug or Release), the libraries will be automatically copied.

## Build Script Details

The `copy-whisper-libraries.sh` script:
- Runs automatically during each build
- Validates that whisper.cpp is built
- Copies all required components
- Fixes library linking paths
- Provides clear error messages if anything is missing
- Validates the final result

## Troubleshooting

### "whisper-cli not found"
- Ensure whisper.cpp is built: `cd ~/Developer/whisper.cpp && make`

### "Library not found"
- Rebuild whisper.cpp with Metal support: `WHISPER_METAL=1 make clean && make -j`

### Build phase not running
- Ensure the script has execute permissions: `chmod +x copy-whisper-libraries.sh`
- Check that the build phase is properly configured in Xcode

## Benefits

1. **Automated**: No manual copying required
2. **Consistent**: Same process for Debug and Release builds
3. **Validated**: Script checks for missing components
4. **Maintainable**: Easy to update library requirements
5. **CI/CD Ready**: Works with command-line builds

## Future Improvements

- Auto-download and build whisper.cpp if not present
- Support for different whisper.cpp locations via build settings
- Automatic version checking for library compatibility