#!/bin/bash
# Copy whisper-cli and all required libraries to the app bundle

APP_PATH="$1"
if [ -z "$APP_PATH" ]; then
    echo "Usage: $0 <app-path>"
    exit 1
fi

echo "Copying whisper-cli and libraries to $APP_PATH..."

# Create directories
mkdir -p "$APP_PATH/Contents/Resources"
mkdir -p "$APP_PATH/Contents/Frameworks"

# Copy whisper-cli binary
if [ -f ~/Developer/whisper.cpp/build/bin/whisper-cli ]; then
    cp ~/Developer/whisper.cpp/build/bin/whisper-cli "$APP_PATH/Contents/Resources/"
    echo "✓ Copied whisper-cli"
else
    echo "✗ whisper-cli not found at ~/Developer/whisper.cpp/build/bin/whisper-cli"
    exit 1
fi

# Copy all whisper libraries
echo "Copying whisper libraries..."
cp ~/Developer/whisper.cpp/build/src/libwhisper.1.7.2.dylib "$APP_PATH/Contents/Frameworks/" 2>/dev/null || \
cp ~/Developer/whisper.cpp/build/src/libwhisper.1.7.6.dylib "$APP_PATH/Contents/Frameworks/" 2>/dev/null || \
cp ~/Developer/whisper.cpp/build/src/libwhisper.1.dylib "$APP_PATH/Contents/Frameworks/" 2>/dev/null || \
echo "Warning: Could not find exact whisper library version"

# Copy any libwhisper files
cp ~/Developer/whisper.cpp/build/src/libwhisper*.dylib "$APP_PATH/Contents/Frameworks/" 2>/dev/null

# Also copy the main libwhisper.dylib if it exists
if [ -f ~/Developer/whisper.cpp/build/src/libwhisper.dylib ]; then
    cp ~/Developer/whisper.cpp/build/src/libwhisper.dylib "$APP_PATH/Contents/Frameworks/"
fi

# Copy GGML libraries
echo "Copying GGML libraries..."
cp ~/Developer/whisper.cpp/build/ggml/src/libggml.dylib "$APP_PATH/Contents/Frameworks/" 2>/dev/null && echo "✓ Copied libggml.dylib"
cp ~/Developer/whisper.cpp/build/ggml/src/libggml-base.dylib "$APP_PATH/Contents/Frameworks/" 2>/dev/null && echo "✓ Copied libggml-base.dylib"
cp ~/Developer/whisper.cpp/build/ggml/src/libggml-cpu.dylib "$APP_PATH/Contents/Frameworks/" 2>/dev/null && echo "✓ Copied libggml-cpu.dylib"
cp ~/Developer/whisper.cpp/build/ggml/src/ggml-blas/libggml-blas.dylib "$APP_PATH/Contents/Frameworks/" 2>/dev/null && echo "✓ Copied libggml-blas.dylib"
cp ~/Developer/whisper.cpp/build/ggml/src/ggml-metal/libggml-metal.dylib "$APP_PATH/Contents/Frameworks/" 2>/dev/null && echo "✓ Copied libggml-metal.dylib"

# Fix library paths in whisper-cli
cd "$APP_PATH/Contents/Resources"
install_name_tool -add_rpath @executable_path/../Frameworks whisper-cli 2>/dev/null

# Update library references
for lib in ../Frameworks/*.dylib; do
    if [ -f "$lib" ]; then
        lib_name=$(basename "$lib")
        # Fix the library's own install name
        install_name_tool -id "@rpath/$lib_name" "../Frameworks/$lib_name" 2>/dev/null
        
        # Fix references between libraries
        for other_lib in ../Frameworks/*.dylib; do
            if [ -f "$other_lib" ]; then
                other_lib_name=$(basename "$other_lib")
                # Update references to this library in other libraries
                install_name_tool -change "@rpath/$lib_name" "@rpath/$lib_name" "../Frameworks/$other_lib_name" 2>/dev/null
                install_name_tool -change "$lib_name" "@rpath/$lib_name" "../Frameworks/$other_lib_name" 2>/dev/null
            fi
        done
        
        # Fix references in whisper-cli
        if [[ "$lib_name" == libwhisper* ]]; then
            install_name_tool -change "@rpath/libwhisper.1.dylib" "@rpath/$lib_name" whisper-cli 2>/dev/null
            install_name_tool -change "libwhisper.1.dylib" "@rpath/$lib_name" whisper-cli 2>/dev/null
        fi
    fi
done

echo "✓ Whisper components copied and paths fixed"

# List what was copied
echo "Contents of Frameworks directory:"
ls -la "$APP_PATH/Contents/Frameworks/"