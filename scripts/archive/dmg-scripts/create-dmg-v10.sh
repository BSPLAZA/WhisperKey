#!/bin/bash
# Create DMG installer for WhisperKey v10

DMG_NAME="WhisperKey-1.0.1-test-v10.dmg"
APP_PATH="$HOME/Desktop/WhisperKey-v10.app"
DMG_PATH="$HOME/Desktop/$DMG_NAME"

# Remove old DMG if exists
rm -f "$DMG_PATH"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
echo "Using temp directory: $TEMP_DIR"

# Copy app to temp directory
cp -R "$APP_PATH" "$TEMP_DIR/"

# Create Applications symlink
ln -s /Applications "$TEMP_DIR/Applications"

# Create DMG
echo "Creating DMG..."
hdiutil create -volname "WhisperKey v1.0.1 Test v10" \
    -srcfolder "$TEMP_DIR" \
    -ov \
    -format UDZO \
    "$DMG_PATH"

# Clean up
rm -rf "$TEMP_DIR"

# Show result
if [ -f "$DMG_PATH" ]; then
    echo "✓ DMG created successfully: $DMG_PATH"
    ls -lh "$DMG_PATH"
else
    echo "✗ Failed to create DMG"
    exit 1
fi