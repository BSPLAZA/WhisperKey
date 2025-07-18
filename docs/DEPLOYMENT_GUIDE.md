# WhisperKey Deployment Guide

*Step-by-step guide for building, packaging, and distributing WhisperKey*

> **Update**: v1.0.2 has been released! See the [release page](https://github.com/BSPLAZA/WhisperKey/releases/tag/v1.0.2) for the latest build with keyboard focus fixes.

## Overview

This guide covers:
1. Building a release version ✅
2. Creating a DMG installer ✅
3. Code signing (coming in v1.0.1)
4. Notarization (coming in v1.0.1)
5. Distribution methods ✅

## Prerequisites

- Xcode 14.0 or later
- macOS 12.0 or later
- Apple Developer account (for signing/notarization)
- `create-dmg` tool (for DMG creation)
- **whisper-cli binary** (Metal-enabled build for bundling)

## Building for Release

### 1. Update Version Numbers

Edit `WhisperKey/Info.plist`:
```xml
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>100</string>
```

### 2. Clean Build

```bash
cd /Users/orion/Omni/WhisperKey/WhisperKey
xcodebuild clean -project WhisperKey.xcodeproj
```

### 3. Archive Build

In Xcode:
1. Select "Any Mac (Apple Silicon, Intel)" as target
2. Product → Archive
3. Wait for build to complete

Or via command line:
```bash
xcodebuild archive \
  -project WhisperKey.xcodeproj \
  -scheme WhisperKey \
  -configuration Release \
  -archivePath build/WhisperKey.xcarchive
```

### 4. Export App

From Xcode Organizer:
1. Select the archive
2. Click "Distribute App"
3. Choose "Copy App"
4. Select destination

Or via command line:
```bash
xcodebuild -exportArchive \
  -archivePath build/WhisperKey.xcarchive \
  -exportPath build/Release \
  -exportOptionsPlist ExportOptions.plist
```

### 5. Bundle whisper-cli (Automated in v1.0.2+)

**Important**: As of v1.0.2, library bundling is fully automated in the Xcode build process.

The build automatically:
- Copies whisper-cli binary to the app bundle
- Includes all required GGML libraries (libggml.dylib, libwhisper.dylib, etc.)
- Sets correct library paths for distribution
- Works in both Debug and Release configurations

To manually verify libraries are bundled:
```bash
ls -la WhisperKey.app/Contents/MacOS/
# Should show whisper-cli and all .dylib files

otool -L WhisperKey.app/Contents/MacOS/whisper-cli
# Should show @executable_path relative paths
```

**Note**: The copy-whisper-libraries.sh script is automatically run by Xcode during every build.

## Creating DMG Installer

### 1. Install create-dmg

```bash
brew install create-dmg
```

### 2. Use Automated Script (Recommended)

As of v1.0.2, use the automated script:
```bash
cd /Users/orion/Omni/WhisperKey
./scripts/create-release-dmg.sh
```

This script:
- Builds the app with proper library bundling
- Creates a professional DMG with AI-generated background
- Includes security warning and installation instructions
- Sets proper window size (600x650) for optimal viewing

**Note**: The background image was created using ChatGPT 4o's image generation after traditional tools (ImageMagick, create-dmg text features) failed to produce readable text. AI image generation is now the recommended approach for professional DMG backgrounds.

### 3. Manual DMG Creation (Alternative)

```bash
# Build first
xcodebuild -project WhisperKey.xcodeproj \
           -scheme WhisperKey \
           -configuration Release \
           -derivedDataPath build \
           clean build

# Create DMG
create-dmg \
  --volname "WhisperKey" \
  --background "dmg-assets/dmg-background-square.png" \
  --window-pos 200 120 \
  --window-size 600 650 \
  --icon-size 80 \
  --icon "WhisperKey.app" 150 300 \
  --hide-extension "WhisperKey.app" \
  --app-drop-link 450 300 \
  --no-internet-enable \
  "WhisperKey-1.0.2.dmg" \
  "build/Build/Products/Release/WhisperKey.app"
```

### 4. Test DMG

1. Mount the DMG
2. Verify appearance
3. Test drag-to-Applications
4. Verify app launches

## Code Signing (Optional)

### 1. Prerequisites

- Apple Developer account
- Developer ID certificate installed

### 2. Sign the App

```bash
codesign --force --deep --sign "Developer ID Application: Your Name (TEAMID)" \
  --options runtime \
  --entitlements WhisperKey.entitlements \
  WhisperKey.app
```

### 3. Verify Signature

```bash
codesign --verify --verbose WhisperKey.app
spctl -a -t exec -vv WhisperKey.app
```

## Notarization (Optional)

### 1. Create ZIP for Notarization

```bash
ditto -c -k --keepParent WhisperKey.app WhisperKey.zip
```

### 2. Submit for Notarization

```bash
xcrun notarytool submit WhisperKey.zip \
  --apple-id "your@email.com" \
  --team-id "TEAMID" \
  --password "app-specific-password" \
  --wait
```

### 3. Staple Ticket

```bash
xcrun stapler staple WhisperKey.app
```

### 4. Re-create DMG

After notarization, recreate the DMG with the stapled app.

## Distribution

### GitHub Releases

1. Create new release on GitHub
2. Upload DMG file
3. Add release notes:

```markdown
## WhisperKey v1.0.0

### Features
- Local, private dictation using Whisper AI
- Right Option hotkey activation
- Multiple AI model support
- Smart text insertion with clipboard fallback

### Requirements
- macOS 12.0 or later
- whisper.cpp (setup wizard included)

### Installation
1. Download WhisperKey-1.0.0.dmg
2. Open DMG and drag to Applications
3. Launch and follow setup wizard

### Known Issues
- See [KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md)
```

### Direct Download

Host on your website:
```html
<a href="downloads/WhisperKey-1.0.0.dmg" class="download-button">
  Download WhisperKey v1.0.0
</a>
```

### Homebrew Cask (Future)

Create a cask:
```ruby
cask "whisperkey" do
  version "1.0.0"
  sha256 "SHA256_HASH_HERE"
  
  url "https://github.com/BSPLAZA/WhisperKey/releases/download/v#{version}/WhisperKey-#{version}.dmg"
  name "WhisperKey"
  desc "Privacy-focused local dictation for macOS"
  homepage "https://github.com/BSPLAZA/WhisperKey"

  app "WhisperKey.app"
  
  zap trash: [
    "~/Library/Preferences/com.whisperkey.WhisperKey.plist",
    "~/Library/Application Support/WhisperKey",
  ]
end
```

## Pre-Release Checklist

### Code
- [ ] Version numbers updated
- [ ] No debug code remaining
- [ ] All TODOs addressed
- [ ] Code signed (if applicable)

### Testing
- [ ] Clean install test
- [ ] Upgrade test
- [ ] All features working
- [ ] No crashes in 1-hour test

### Documentation
- [ ] README.md current
- [ ] CHANGELOG.md updated
- [ ] Known issues documented
- [ ] User guide complete

### Distribution
- [ ] DMG created and tested
- [ ] Release notes written
- [ ] Download links working
- [ ] File permissions correct

## Post-Release

### Monitor
- GitHub issues for bug reports
- Crash reports (if implemented)
- User feedback

### Update Process
1. Fix critical issues quickly
2. Bundle fixes in point releases
3. Communicate changes clearly

## Troubleshooting

### "App is damaged"
- Not code signed
- Solution: Right-click → Open

### "Unknown developer"
- Not notarized
- Solution: System Preferences → Security → Open Anyway

### DMG won't open
- Corrupted download
- Solution: Re-download and verify checksum

### App won't launch
- Missing dependencies
- Solution: Check Console.app for errors

---

*Last Updated: 2025-07-13 | WhisperKey v1.0.0-beta*