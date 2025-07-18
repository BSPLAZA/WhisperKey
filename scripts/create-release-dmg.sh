#!/bin/bash
# Create a professional DMG installer for WhisperKey with improved UX
# This script builds the app and creates a DMG with drag-to-install UI

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
           clean build || true  # Continue even if build "fails" due to sandbox

# Find the built app
APP_PATH="${BUILD_DIR}/Build/Products/Release/WhisperKey.app"
if [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}Error: Built app not found at ${APP_PATH}${NC}"
    exit 1
fi

echo -e "${GREEN}✓ App built successfully${NC}"

# Step 3: Copy libraries manually due to Xcode sandbox restrictions
echo "3. Copying whisper libraries..."
# The build phase runs but sandbox blocks it, so we copy manually here
cd "${PROJECT_ROOT}/WhisperKey"
if [ -f "copy-whisper-libraries.sh" ]; then
    BUILT_PRODUCTS_DIR="${BUILD_DIR}/Build/Products/Release" WRAPPER_NAME="WhisperKey.app" ./copy-whisper-libraries.sh || true
fi
cd "${PROJECT_ROOT}"

# Verify libraries
FRAMEWORK_COUNT=$(ls -1 "$APP_PATH/Contents/Frameworks/"*.dylib 2>/dev/null | wc -l)
if [ "$FRAMEWORK_COUNT" -lt 3 ]; then
    echo -e "${RED}Error: Expected at least 3 libraries, but found $FRAMEWORK_COUNT${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Found $FRAMEWORK_COUNT libraries bundled${NC}"

# Step 4: Use AI-generated background
echo "4. Preparing DMG background..."
# Copy our AI-generated background (created with ChatGPT 4o)
if [ -f "${PROJECT_ROOT}/dmg-assets/dmg-background-square.png" ]; then
    cp "${PROJECT_ROOT}/dmg-assets/dmg-background-square.png" "${DMG_BACKGROUND_DIR}/background.png"
    echo -e "${GREEN}✓ Using AI-generated professional background${NC}"
else
    echo -e "${RED}Error: Background image not found at dmg-assets/dmg-background-square.png${NC}"
    exit 1
fi

# Step 5: Copy app to DMG build directory
echo "5. Preparing DMG contents..."
cp -R "$APP_PATH" "${DMG_BUILD_DIR}/"
# Create Applications symlink only if it doesn't exist
if [ ! -e "${DMG_BUILD_DIR}/Applications" ]; then
    ln -s /Applications "${DMG_BUILD_DIR}/Applications"
fi
# Add README for installation instructions
if [ -f "${PROJECT_ROOT}/dmg-assets/README.txt" ]; then
    cp "${PROJECT_ROOT}/dmg-assets/README.txt" "${DMG_BUILD_DIR}/"
fi

# Step 6: Create the DMG
echo "6. Creating DMG..."
# Remove old DMG if it exists
rm -f "${PROJECT_ROOT}/${DMG_NAME}"

# Create DMG with professional layout
create-dmg \
    --volname "${DMG_VOLUME_NAME}" \
    --volicon "${APP_PATH}/Contents/Resources/AppIcon.icns" \
    --background "${DMG_BACKGROUND_DIR}/background.png" \
    --window-pos 200 120 \
    --window-size 600 650 \
    --icon-size 80 \
    --icon "${APP_NAME}.app" 150 300 \
    --hide-extension "${APP_NAME}.app" \
    --app-drop-link 450 300 \
    --no-internet-enable \
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