#!/bin/bash
# Create DMG installer for WhisperKey v1.0.1

DMG_NAME="WhisperKey-1.0.1.dmg"
APP_PATH="/Applications/WhisperKey-v10.app"
DMG_PATH="$HOME/Desktop/$DMG_NAME"

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "✗ App not found at $APP_PATH"
    exit 1
fi

# Remove old DMG if exists
rm -f "$DMG_PATH"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
echo "Using temp directory: $TEMP_DIR"

# Copy app to temp directory
cp -R "$APP_PATH" "$TEMP_DIR/WhisperKey.app"

# Create Applications symlink
ln -s /Applications "$TEMP_DIR/Applications"

# Create DMG
echo "Creating DMG..."
hdiutil create -volname "WhisperKey v1.0.1" \
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