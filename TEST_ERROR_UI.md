# Testing Error Recovery UI

## Quick Test Methods

### 1. Force Show Setup Assistant
Add this to MenuBarApp.swift temporarily:
```swift
Button("Test Setup Assistant") {
    WhisperService.shared.showSetupError()
}
```

### 2. Force Show Model Missing Dialog
```swift
Button("Test Model Missing") {
    ModelManager.shared.showModelMissingDialog(for: "large-v3")
}
```

### 3. Force Show Permission Guide
```swift
Button("Test Permissions") {
    if let appDelegate = NSApp.delegate as? AppDelegate {
        appDelegate.showPermissionGuide()
    }
}
```

## What to Look For

### WhisperSetupAssistant:
- [ ] Does it detect your current whisper.cpp installation?
- [ ] Are the install instructions clear?
- [ ] Can you copy the commands easily?
- [ ] Does the "Browse" button work for custom paths?
- [ ] Does it skip to success if already installed?

### ModelMissingView:
- [ ] Does it show the correct missing model info?
- [ ] Does "Download Now" start the download?
- [ ] Are installed models listed correctly?
- [ ] Can you switch to an installed model?
- [ ] Does the progress bar work during download?

### PermissionGuideView:
- [ ] Are current permissions shown correctly?
- [ ] Do the "Grant Access" buttons open System Settings?
- [ ] Does "Check Again" update the status?
- [ ] Can you proceed once permissions are granted?

## Real-World Test Scenarios

1. **New User Experience**
   - Delete whisper.cpp path from settings
   - See if the app guides you through setup

2. **Missing Model**
   - Select a model you don't have
   - Try to dictate
   - Should get helpful recovery options

3. **Permission Issues**
   - Revoke permissions
   - Launch app
   - Should guide through re-enabling

## Build and Run
```bash
# From Xcode:
Cmd+R to run

# Or if you want to see the app bundle:
xcodebuild -scheme WhisperKey -configuration Debug build
open ~/Library/Developer/Xcode/DerivedData/WhisperKey-*/Build/Products/Debug/WhisperKey.app
```