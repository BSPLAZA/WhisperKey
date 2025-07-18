#!/bin/bash
# Create a professional DMG installer for WhisperKey
# This version assumes the build phase is properly integrated into Xcode

set -e  # Exit on error

echo "🚀 WhisperKey DMG Creation Script"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if create-dmg is installed
if ! command -v create-dmg &> /dev/null; then
    echo -e "${RED}Error: create-dmg is not installed${NC}"
    echo "Install it with: brew install create-dmg"
    exit 1
fi

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Configuration
APP_NAME="WhisperKey"
VERSION="1.0.2"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
DMG_VOLUME_NAME="${APP_NAME}"
BUILD_DIR="${PROJECT_ROOT}/WhisperKey/build"
DMG_BUILD_DIR="${PROJECT_ROOT}/dmg-build"
DMG_BACKGROUND_DIR="${DMG_BUILD_DIR}/.background"

echo -e "${YELLOW}Building ${APP_NAME} v${VERSION}...${NC}"

# Step 1: Clean previous builds
echo "1. Cleaning previous builds..."
rm -rf "${DMG_BUILD_DIR}"
mkdir -p "${DMG_BUILD_DIR}"
mkdir -p "${DMG_BACKGROUND_DIR}"

# Step 2: Build the app (Release configuration)
echo "2. Building Release version..."
cd "${PROJECT_ROOT}/WhisperKey"
xcodebuild -project WhisperKey.xcodeproj \
           -scheme WhisperKey \
           -configuration Release \
           -derivedDataPath build \
           clean build

# Find the built app
APP_PATH="${BUILD_DIR}/Build/Products/Release/WhisperKey.app"
if [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}Error: Built app not found at ${APP_PATH}${NC}"
    exit 1
fi

echo -e "${GREEN}✓ App built successfully${NC}"

# Step 3: Verify whisper libraries are bundled
echo "3. Verifying whisper libraries..."
FRAMEWORK_COUNT=$(ls -1 "$APP_PATH/Contents/Frameworks/"*.dylib 2>/dev/null | wc -l)
if [ "$FRAMEWORK_COUNT" -lt 3 ]; then
    echo -e "${RED}Error: Expected at least 3 libraries, but found $FRAMEWORK_COUNT${NC}"
    echo -e "${RED}The Xcode build phase may not be properly configured.${NC}"
    echo "Run this to fix: ./scripts/integrate-build-phase.sh"
    exit 1
fi
echo -e "${GREEN}✓ Found $FRAMEWORK_COUNT libraries bundled${NC}"

# Step 4: Create background image with instructions
echo "4. Creating DMG background..."
# Create a simple background using ImageMagick or fallback to basic image
if command -v magick &> /dev/null || command -v convert &> /dev/null; then
    # Use ImageMagick to create background
    CONVERT_CMD="convert"
    if command -v magick &> /dev/null; then
        CONVERT_CMD="magick"
    fi
    
    $CONVERT_CMD -size 600x400 \
        -background '#f0f0f0' \
        -fill '#333333' \
        -font Arial -pointsize 24 \
        -gravity North \
        -annotate +0+30 'Install WhisperKey' \
        -fill '#666666' \
        -font Arial -pointsize 16 \
        -gravity North \
        -annotate +0+70 'Drag WhisperKey to Applications folder' \
        -stroke '#007AFF' -strokewidth 3 \
        -fill none \
        -draw "path 'M 200,200 L 350,200'" \
        -draw "path 'M 340,190 L 350,200 L 340,210'" \
        "${DMG_BACKGROUND_DIR}/background.png"
    
    echo -e "${GREEN}✓ Created custom background with arrow${NC}"
else
    # Create a basic colored background as fallback
    echo -e "${YELLOW}ImageMagick not found, creating basic background${NC}"
    # Create a simple 1x1 white pixel and use it as background
    printf '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\rIDATx\x9cc\xf8\xff\xff?\x03\x00\x00\x01\x00\x01UU\x86\x18\x00\x00\x00\x00IEND\xaeB`\x82' > "${DMG_BACKGROUND_DIR}/background.png"
fi

# Step 5: Copy app to DMG build directory
echo "5. Preparing DMG contents..."
cp -R "$APP_PATH" "${DMG_BUILD_DIR}/"
ln -s /Applications "${DMG_BUILD_DIR}/Applications"

# Step 6: Create the DMG
echo "6. Creating DMG..."
# Remove old DMG if it exists
rm -f "${PROJECT_ROOT}/${DMG_NAME}"

# Create DMG with professional layout
create-dmg \
    --volname "${DMG_VOLUME_NAME}" \
    --volicon "$APP_PATH/Contents/Resources/AppIcon.icns" \
    --background "${DMG_BACKGROUND_DIR}/background.png" \
    --window-pos 200 120 \
    --window-size 600 400 \
    --icon-size 100 \
    --icon "${APP_NAME}.app" 150 200 \
    --hide-extension "${APP_NAME}.app" \
    --app-drop-link 450 200 \
    --text-size 14 \
    --hdiutil-verbose \
    "${PROJECT_ROOT}/${DMG_NAME}" \
    "${DMG_BUILD_DIR}"

# Step 7: Verify DMG
if [ -f "${PROJECT_ROOT}/${DMG_NAME}" ]; then
    DMG_SIZE=$(du -h "${PROJECT_ROOT}/${DMG_NAME}" | cut -f1)
    echo -e "\n${GREEN}✅ DMG created successfully!${NC}"
    echo -e "📦 File: ${PROJECT_ROOT}/${DMG_NAME}"
    echo -e "📏 Size: ${DMG_SIZE}"
    
    # Calculate SHA256
    if command -v shasum &> /dev/null; then
        SHA256=$(shasum -a 256 "${PROJECT_ROOT}/${DMG_NAME}" | cut -d' ' -f1)
        echo -e "🔐 SHA256: ${SHA256}"
    fi
    
    echo -e "\n📝 Release Notes Draft:"
    echo "========================"
    echo "## WhisperKey v${VERSION}"
    echo ""
    echo "### 🐛 Bug Fixes"
    echo "- Fixed keyboard focus issue after dictation (Enter key now works immediately)"
    echo "- Improved recording indicator visibility in web browsers"
    echo ""
    echo "### ⚠️ Known Limitations"
    echo "- Brave browser URL bar requires pressing Space then Enter after dictation"
    echo "  (This is a Brave security feature, not a bug)"
    echo ""
    echo "### 📦 Download"
    echo "- **File**: ${DMG_NAME}"
    echo "- **Size**: ${DMG_SIZE}"
    echo "- **SHA256**: ${SHA256:-'[Calculate with shasum -a 256]'}"
    echo ""
    echo "### 🛡️ Security Note"
    echo "First time users: When you see \"unidentified developer\" warning:"
    echo "1. Go to System Settings → Privacy & Security"
    echo "2. Click \"Open Anyway\" next to WhisperKey"
    echo "3. Launch WhisperKey again"
    
else
    echo -e "${RED}❌ Error: DMG creation failed${NC}"
    exit 1
fi

# Cleanup
echo -e "\n7. Cleaning up..."
rm -rf "${DMG_BUILD_DIR}"

echo -e "\n${GREEN}✨ Done! DMG is ready for distribution.${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Test the DMG on a clean system"
echo "2. Upload to GitHub releases"
echo "3. Update download links"