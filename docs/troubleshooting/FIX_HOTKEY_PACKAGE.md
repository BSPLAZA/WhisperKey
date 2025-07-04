# Fix HotKey Package Issue

## Method 1: Select WhisperKey Target
In the dialog you showed:
1. Click on **"WhisperKey"** (not WhisperKeyTests or WhisperKeyUITests)
2. The checkmark should move from "None" to "WhisperKey"
3. Click **"Add Package"**

## Method 2: Remove and Re-add Package
If Method 1 doesn't work:

### 1. Remove the existing package
- In Xcode's left sidebar, find "Package Dependencies"
- Right-click on "hotkey"
- Select "Remove Package"

### 2. Clean everything
- **Clean Build Folder**: Cmd+Shift+K
- **Quit Xcode**: Cmd+Q
- Delete derived data:
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/WhisperKey-*
```

### 3. Re-open and add package
- Open WhisperKey.xcodeproj
- **File → Add Package Dependencies**
- Paste: `https://github.com/soffes/HotKey`
- Click **Add Package**
- **IMPORTANT**: Select "WhisperKey" target (not None)
- Click **Add Package**

## Method 3: Manual Package Resolution
If still having issues:

1. Close Xcode
2. In Terminal:
```bash
cd /Users/orion/Omni/WhisperKey/WhisperKey
xcodebuild -resolvePackageDependencies
```
3. Re-open Xcode and build

## Method 4: Direct SPM Integration
Add this to your project:

1. Right-click on your WhisperKey folder in Xcode
2. Select "Add Files to WhisperKey"
3. Navigate to the Package.swift we created
4. Add it to the project
5. Xcode should recognize and resolve the dependency