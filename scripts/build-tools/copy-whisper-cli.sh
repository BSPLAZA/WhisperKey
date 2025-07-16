#!/bin/bash
# Copy whisper-cli to app bundle Resources

RESOURCES_PATH="${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Resources"
mkdir -p "$RESOURCES_PATH"

# Copy whisper-cli from our Resources folder
cp "${SRCROOT}/WhisperKey/Resources/whisper-cli" "$RESOURCES_PATH/"
chmod +x "$RESOURCES_PATH/whisper-cli"

echo "Copied whisper-cli to app bundle at: $RESOURCES_PATH"