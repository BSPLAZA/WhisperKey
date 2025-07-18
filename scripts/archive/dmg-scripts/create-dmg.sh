#!/bin/bash

# WhisperKey DMG Creation Script
# Creates a professional DMG installer for distribution

set -e  # Exit on error

echo "🎯 WhisperKey DMG Creator"
echo "========================"

# Configuration
APP_NAME="WhisperKey"
VERSION="1.0.0"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
VOLUME_NAME="${APP_NAME} ${VERSION}"
TEMP_DIR="dmg-temp"
BACKGROUND_IMG="dmg-background.png"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Prerequisites:${NC}"
echo "1. Build release version in Xcode first (Product → Archive → Export)"
echo "2. Place the exported WhisperKey.app in the build/ directory"
echo ""
read -p "Have you exported WhisperKey.app to the build/ directory? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please build and export the app first."
    exit 1
fi

# Check if app exists
if [ ! -d "build/WhisperKey.app" ]; then
    echo "❌ Error: build/WhisperKey.app not found!"
    echo "Please export the app from Xcode to the build/ directory"
    exit 1
fi

echo -e "\n${GREEN}✓ Found WhisperKey.app${NC}"

# Clean up any existing temp directory
echo "🧹 Cleaning up old files..."
rm -rf "$TEMP_DIR"
rm -f "$DMG_NAME"

# Create temp directory structure
echo "📁 Creating DMG structure..."
mkdir -p "$TEMP_DIR"

# Copy the app
echo "📋 Copying WhisperKey.app..."
cp -R "build/WhisperKey.app" "$TEMP_DIR/"

# Create Applications symlink
echo "🔗 Creating Applications symlink..."
ln -s /Applications "$TEMP_DIR/Applications"

# Create a simple background image if it doesn't exist
if [ ! -f "$BACKGROUND_IMG" ]; then
    echo "🎨 Creating DMG background..."
    # Create a simple background using ImageMagick if available, otherwise skip
    if command -v convert &> /dev/null; then
        convert -size 600x400 xc:'#1e1e1e' \
            -fill '#ffffff' -pointsize 24 -gravity north \
            -annotate +0+40 'WhisperKey Installation' \
            -fill '#666666' -pointsize 14 \
            -annotate +0+100 'Drag WhisperKey to Applications folder' \
            "$BACKGROUND_IMG"
    else
        echo "⚠️  ImageMagick not found, skipping background creation"
    fi
fi

# Create temporary DMG
echo "💿 Creating temporary DMG..."
hdiutil create -volname "$VOLUME_NAME" -srcfolder "$TEMP_DIR" -ov -format UDRW temp.dmg

# Mount the temporary DMG
echo "🔧 Mounting temporary DMG..."
DEVICE=$(hdiutil attach -readwrite -noverify temp.dmg | egrep '^/dev/' | sed 1q | awk '{print $1}')

# Wait for mount
sleep 2

# Apply custom settings with AppleScript
echo "🎨 Customizing DMG appearance..."
osascript <<EOT
tell application "Finder"
    tell disk "$VOLUME_NAME"
        open
        
        -- Window settings
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {400, 100, 1000, 500}
        
        -- Icon view options
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 72
        
        -- Icon positions
        set position of item "WhisperKey.app" of container window to {150, 200}
        set position of item "Applications" of container window to {450, 200}
        
        -- Background (if exists)
        try
            set background picture of viewOptions to file ".background:${BACKGROUND_IMG}"
        end try
        
        close
        open
        
        update without registering applications
        delay 2
    end tell
end tell
EOT

# Finalize the DMG
echo "🏁 Finalizing DMG..."
sync
hdiutil detach "$DEVICE"

# Convert to compressed DMG
echo "🗜️  Compressing DMG..."
hdiutil convert temp.dmg -format UDZO -imagekey zlib-level=9 -o "$DMG_NAME"

# Clean up
echo "🧹 Cleaning up..."
rm -rf "$TEMP_DIR"
rm -f temp.dmg

# Sign the DMG if developer ID is available
if security find-identity -p basic -v | grep -q "Developer ID"; then
    echo "✍️  Signing DMG..."
    codesign --force --sign "Developer ID Application" "$DMG_NAME"
else
    echo "⚠️  No Developer ID found, DMG will not be signed"
    echo ""
    echo "📝 Note for users:"
    echo "Since this app is unsigned, macOS will show a security warning."
    echo "Users need to right-click the app and select 'Open' to bypass it."
fi

# Verify the DMG
echo "🔍 Verifying DMG..."
hdiutil verify "$DMG_NAME"

# Get file size
SIZE=$(du -h "$DMG_NAME" | cut -f1)

echo -e "\n${GREEN}✅ Success!${NC}"
echo "📦 Created: $DMG_NAME ($SIZE)"
echo ""
echo "Next steps:"
echo "1. Test the DMG on a clean system"
echo "2. Upload to GitHub releases"
echo "3. Consider notarizing for Gatekeeper approval"

# Offer to open the DMG
read -p "Would you like to open the DMG to test it? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "$DMG_NAME"
fi