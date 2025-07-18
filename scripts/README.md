# WhisperKey Scripts

## Primary Scripts

### `create-release-dmg.sh`
**Purpose**: Creates production-ready DMG installer  
**Usage**: `./scripts/create-release-dmg.sh`  
**What it does**:
- Builds the app in Release configuration
- Bundles all required libraries (whisper-cli, GGML libs)
- Uses AI-generated background image (600x650 window)
- Creates professional DMG with drag-to-Applications UI
- Generates release notes draft with SHA256

**Note**: This is the ONLY script you need for creating releases.

### `build-and-run.sh`
**Purpose**: Quick development builds  
**Usage**: `./scripts/build-and-run.sh`  
**What it does**:
- Builds in Debug configuration
- Runs the app immediately
- Useful for development/testing

### `integrate-build-phase.sh`
**Purpose**: Adds library copying to Xcode build process  
**Usage**: One-time setup, already done for v1.0.2  
**What it does**:
- Adds "Copy Whisper Libraries" build phase to Xcode
- Ensures libraries are bundled automatically

### `fix-build-phase-output.sh`
**Purpose**: Fixes library paths for distribution  
**Usage**: Called automatically by build process  

## Archived Scripts

Old and deprecated scripts have been moved to:
- `archive/dmg-scripts/` - Old DMG creation scripts
- `archive/` - Other deprecated scripts

## Important Notes

1. **For releases**: Always use `create-release-dmg.sh`
2. **Background image**: Located at `dmg-assets/dmg-background-square.png`
3. **Version numbers**: Update in script before creating release
4. **Libraries**: Automatically bundled via Xcode build phase

## Troubleshooting

If DMG creation fails:
1. Ensure `create-dmg` is installed: `brew install create-dmg`
2. Check that background image exists in `dmg-assets/`
3. Verify Xcode build succeeds first
4. Check console output for specific errors