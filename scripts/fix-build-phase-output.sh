#!/bin/bash
# Fix the build phase output path to avoid conflict

cd "$(dirname "$0")/.."

# Update the project file to change output path
sed -i.backup 's|Contents/Resources/whisper-cli|Contents/MacOS/whisper-cli|g' WhisperKey/WhisperKey.xcodeproj/project.pbxproj

echo "Updated build phase output path from Resources to MacOS"
echo "This avoids conflict with Xcode's file system synchronization"