#!/bin/bash
# Alternative approach: Instructions to manually add build phase

cat << 'EOF'
==============================================
WhisperKey Build Phase Setup Instructions
==============================================

To integrate library copying into the Xcode build process:

1. Open WhisperKey.xcodeproj in Xcode

2. Select the WhisperKey target

3. Go to Build Phases tab

4. Click the + button and select "New Run Script Phase"

5. Name it: "Copy Whisper Libraries"

6. In the script field, enter:
   "${SRCROOT}/copy-whisper-libraries.sh"

7. Uncheck "Based on dependency analysis"

8. Add Input Files:
   $(SRCROOT)/copy-whisper-libraries.sh
   ${HOME}/Developer/whisper.cpp/build/bin/whisper-cli

9. Add Output Files:
   $(BUILT_PRODUCTS_DIR)/$(WRAPPER_NAME)/Contents/Resources/whisper-cli
   $(BUILT_PRODUCTS_DIR)/$(WRAPPER_NAME)/Contents/Frameworks/

10. Drag the "Copy Whisper Libraries" phase to be:
    - AFTER "Copy Bundle Resources"
    - BEFORE any code signing phases

11. Save the project (Cmd+S)

The build phase is now integrated! The libraries will be automatically
copied every time you build the app.

IMPORTANT: Make sure whisper.cpp is built before building WhisperKey:
cd ~/Developer/whisper.cpp && make clean && WHISPER_METAL=1 make -j

==============================================
EOF