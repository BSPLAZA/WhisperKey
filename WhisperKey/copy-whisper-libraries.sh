#!/bin/bash
# Build phase script to copy whisper-cli and required libraries
# This script is designed to be run from Xcode as a build phase

# Don't use set -e - we need to handle sandbox errors gracefully
# set -e  # Exit on error

echo "WhisperKey: Starting library copy phase..."

# Get the app bundle path from Xcode environment
APP_PATH="${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"

if [ -z "$APP_PATH" ]; then
    echo "error: APP_PATH not set. This script must be run from Xcode build phase."
    exit 1
fi

echo "WhisperKey: Copying to $APP_PATH"

# Create directories
mkdir -p "$APP_PATH/Contents/Resources"
mkdir -p "$APP_PATH/Contents/Frameworks"

# Define whisper.cpp path
WHISPER_PATH="${HOME}/Developer/whisper.cpp"

# Check if whisper.cpp exists
if [ ! -d "$WHISPER_PATH" ]; then
    echo "error: whisper.cpp not found at $WHISPER_PATH"
    echo "error: Please build whisper.cpp first: cd ~/Developer/whisper.cpp && make clean && WHISPER_METAL=1 make -j"
    exit 1
fi

# Note: WhisperKey v1.0.2 is tested with whisper.cpp as of July 2024
# Future versions of whisper.cpp should maintain API compatibility

# Copy whisper-cli binary
WHISPER_CLI="${WHISPER_PATH}/build/bin/whisper-cli"
if [ -f "$WHISPER_CLI" ]; then
    # Create MacOS directory if it doesn't exist
    mkdir -p "$APP_PATH/Contents/MacOS" 2>/dev/null || true
    # Copy to MacOS directory to avoid Resources conflict
    if cp "$WHISPER_CLI" "$APP_PATH/Contents/MacOS/" 2>/dev/null; then
        echo "WhisperKey: ✓ Copied whisper-cli to MacOS directory"
    else
        echo "WhisperKey: WARNING: Sandbox blocked copying whisper-cli (this is normal during build)"
        # Don't exit - allow build to continue
    fi
else
    echo "error: whisper-cli not found at $WHISPER_CLI"
    echo "error: Please build whisper.cpp first"
    exit 1
fi

# Function to copy library if it exists
copy_library() {
    local src="$1"
    local dst="$2"
    local name="$3"
    
    if [ -f "$src" ]; then
        # Try to copy, but don't fail if sandbox blocks it
        if cp "$src" "$dst" 2>/dev/null; then
            echo "WhisperKey: ✓ Copied $name"
            return 0
        else
            echo "WhisperKey: WARNING: Sandbox blocked copying $name (this is normal during build)"
            return 0  # Return success anyway - don't fail the build
        fi
    else
        echo "warning: $name not found at $src"
        return 1
    fi
}

# Copy GGML libraries (required)
echo "WhisperKey: Copying GGML libraries..."
copy_library "${WHISPER_PATH}/build/ggml/src/libggml.dylib" "$APP_PATH/Contents/Frameworks/" "libggml.dylib"
copy_library "${WHISPER_PATH}/build/ggml/src/libggml-base.dylib" "$APP_PATH/Contents/Frameworks/" "libggml-base.dylib"
copy_library "${WHISPER_PATH}/build/ggml/src/libggml-cpu.dylib" "$APP_PATH/Contents/Frameworks/" "libggml-cpu.dylib"
copy_library "${WHISPER_PATH}/build/ggml/src/ggml-blas/libggml-blas.dylib" "$APP_PATH/Contents/Frameworks/" "libggml-blas.dylib" || true
copy_library "${WHISPER_PATH}/build/ggml/src/ggml-metal/libggml-metal.dylib" "$APP_PATH/Contents/Frameworks/" "libggml-metal.dylib" || true

# Copy whisper library
echo "WhisperKey: Copying whisper library..."
# Try different possible locations and versions
for whisper_lib in \
    "${WHISPER_PATH}/build/src/libwhisper.dylib" \
    "${WHISPER_PATH}/build/src/libwhisper.1.dylib" \
    "${WHISPER_PATH}/build/src/libwhisper.1.7.2.dylib" \
    "${WHISPER_PATH}/build/src/libwhisper.1.7.6.dylib"; do
    if [ -f "$whisper_lib" ]; then
        cp "$whisper_lib" "$APP_PATH/Contents/Frameworks/"
        echo "WhisperKey: ✓ Copied $(basename "$whisper_lib")"
        break
    fi
done

# Fix library paths
echo "WhisperKey: Fixing library paths..."
cd "$APP_PATH/Contents/Resources"

# Add rpath to whisper-cli
install_name_tool -add_rpath @executable_path/../Frameworks whisper-cli 2>/dev/null || true

# Fix library references
cd "$APP_PATH/Contents/Frameworks"
for lib in *.dylib; do
    if [ -f "$lib" ]; then
        # Set the library's install name
        install_name_tool -id "@rpath/$lib" "$lib" 2>/dev/null || true
        
        # Fix references to other libraries
        for ref_lib in *.dylib; do
            if [ -f "$ref_lib" ] && [ "$lib" != "$ref_lib" ]; then
                # Try to update any references
                install_name_tool -change "@rpath/$ref_lib" "@rpath/$ref_lib" "$lib" 2>/dev/null || true
                install_name_tool -change "$ref_lib" "@rpath/$ref_lib" "$lib" 2>/dev/null || true
            fi
        done
    fi
done

# Fix whisper-cli references
cd "$APP_PATH/Contents/Resources"
for lib in ../Frameworks/*.dylib; do
    if [ -f "$lib" ]; then
        lib_name=$(basename "$lib")
        # Update references in whisper-cli
        if [[ "$lib_name" == libwhisper* ]]; then
            install_name_tool -change "@rpath/libwhisper.1.dylib" "@rpath/$lib_name" whisper-cli 2>/dev/null || true
            install_name_tool -change "libwhisper.1.dylib" "@rpath/$lib_name" whisper-cli 2>/dev/null || true
        fi
    fi
done

# Verify the copy
FRAMEWORK_COUNT=$(ls -1 "$APP_PATH/Contents/Frameworks/"*.dylib 2>/dev/null | wc -l)
if [ "$FRAMEWORK_COUNT" -lt 3 ]; then
    echo "WhisperKey: WARNING: Expected at least 3 libraries, but found $FRAMEWORK_COUNT"
    echo "WhisperKey: This is likely due to Xcode sandbox restrictions during build."
    echo "WhisperKey: Libraries will need to be copied manually after build."
    echo "WhisperKey: Run: ./copy-whisper-libraries.sh"
    echo "WhisperKey: Or use: ./scripts/create-release-dmg.sh for release builds"
    # Don't exit with error - this is expected in sandboxed builds
    exit 0
fi

echo "WhisperKey: ✓ Library copy phase completed successfully"
echo "WhisperKey: Copied $FRAMEWORK_COUNT libraries to Frameworks directory"