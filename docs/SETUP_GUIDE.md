# WhisperKey Development Setup Guide

> Step-by-step guide to set up the development environment

## Prerequisites

- macOS 14.0 (Sonoma) or later
- Xcode 15.4 or later
- Apple Developer account (for code signing)
- Git
- Homebrew (optional but recommended)

## Step 1: Install Development Tools

### Xcode and Command Line Tools
```bash
# Install Xcode from App Store or:
xcode-select --install

# Verify installation
xcode-select -p
swift --version
```

### Additional Tools
```bash
# Install helpful development tools
brew install cmake python3 coreutils

# For documentation
brew install pandoc graphviz
```

## Step 2: Clone and Build whisper.cpp

```bash
# Clone whisper.cpp
cd ~/Developer
git clone https://github.com/ggerganov/whisper.cpp.git
cd whisper.cpp

# Build with Metal support for Apple Silicon
make clean
WHISPER_METAL=1 make -j

# Test the build
./main -m models/ggml-base.en.bin -f samples/jfk.wav
```

## Step 3: Download Whisper Models

```bash
# Download models
cd whisper.cpp/models
bash ./download-ggml-model.sh base.en
bash ./download-ggml-model.sh small.en
bash ./download-ggml-model.sh medium.en

# Verify downloads
ls -la *.bin
```

## Step 4: Convert Models to Core ML (Optional)

```bash
# Install coremltools
pip3 install coremltools whisper

# Convert models
python3 convert-whisper-to-coreml.py base.en
python3 convert-whisper-to-coreml.py small.en
```

## Step 5: Set Up Code Signing

1. Open Xcode
2. Go to Preferences → Accounts
3. Add your Apple ID
4. Manage Certificates → Create a Developer ID Application certificate

Or via command line:
```bash
security find-identity -p codesigning -v
```

## Step 6: Create WhisperKey Project

```bash
cd /Users/orion/Omni/WhisperKey

# Create Xcode project (or do it in Xcode GUI)
# Select: macOS → App
# Interface: SwiftUI
# Language: Swift
# Bundle ID: com.whisperkey.app
```

## Step 7: Configure Entitlements

Create `WhisperKey.entitlements`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.device.audio-input</key>
    <true/>
    <key>com.apple.security.automation.apple-events</key>
    <true/>
</dict>
</plist>
```

## Step 8: Test Karabiner Elements

```bash
# Install Karabiner Elements
brew install --cask karabiner-elements

# Create test configuration
mkdir -p ~/.config/karabiner/assets/complex_modifications
cat > ~/.config/karabiner/assets/complex_modifications/whisperkey.json << 'EOF'
{
  "title": "WhisperKey Test",
  "rules": [
    {
      "description": "Test F5 interception",
      "manipulators": [
        {
          "type": "basic",
          "from": {
            "key_code": "f5"
          },
          "to": [
            {
              "shell_command": "echo 'F5 pressed' > /tmp/whisperkey-test.log"
            }
          ]
        }
      ]
    }
  ]
}
EOF
```

## Step 9: Verify Permissions

```bash
# Check TCC database (read-only)
sqlite3 ~/Library/Application\ Support/com.apple.TCC/TCC.db \
  "SELECT service, client FROM access WHERE service IN ('kTCCServiceMicrophone', 'kTCCServiceAccessibility', 'kTCCServiceListenEvent');"
```

## Step 10: Set Up Development Environment

```bash
# Install development dependencies
cd /Users/orion/Omni/WhisperKey
swift package init

# Create .gitignore
cat > .gitignore << 'EOF'
.DS_Store
*.xcodeproj/xcuserdata/
*.xcworkspace/xcuserdata/
.build/
DerivedData/
*.ipa
*.dSYM.zip
*.dSYM
timeline.log
EOF
```

## Troubleshooting

### "xcrun: error: invalid active developer path"
```bash
sudo xcode-select --reset
sudo xcode-select -s /Applications/Xcode.app
```

### Whisper build fails
```bash
# Try without Metal
make clean && make -j

# Or use cmake
cmake -B build
cmake --build build --config Release
```

### Code signing issues
```bash
# Clear code signing cache
security delete-keychain ~/Library/Keychains/login.keychain-db
# Then re-add certificates in Xcode
```

## Verification Checklist

- [ ] Xcode launches and shows version 15.4+
- [ ] `swift --version` shows 5.9+
- [ ] whisper.cpp builds successfully
- [ ] Models downloaded (base.en, small.en, medium.en)
- [ ] Code signing certificate visible in Keychain
- [ ] Karabiner Elements installed and test works
- [ ] Git repository initialized

## Next Steps

1. Review the architecture in `docs-archive/planning/WhisperKey-Planning.md`
2. Start Phase 1 development
3. Update `TIMELINE.md` as you progress

---
*Last Updated: 2025-07-01*