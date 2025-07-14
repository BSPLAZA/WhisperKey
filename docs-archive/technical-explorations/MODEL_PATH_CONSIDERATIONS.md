# Model Path Considerations

## Current State

WhisperKey currently expects Whisper models to be located at:
```
~/Developer/whisper.cpp/models/
```

This path is hardcoded in `WhisperCppTranscriber.swift`.

## Issues

1. **Not all users have models there** - Some may have downloaded whisper.cpp elsewhere
2. **Duplicate downloads** - Users might already have models but in different location
3. **Disk space waste** - Models are large (141MB - 2.9GB each)

## Proposed Solutions

### Option 1: User Preference (Recommended)
Add a setting in Preferences → Advanced:
```swift
@AppStorage("customModelPath") var customModelPath = ""

// Use custom path if set, otherwise default
let modelPath = customModelPath.isEmpty ? 
    "~/Developer/whisper.cpp/models" : customModelPath
```

### Option 2: Auto-Detection
Scan common locations on first launch:
```swift
let commonPaths = [
    "~/Developer/whisper.cpp/models",
    "~/whisper.cpp/models",
    "~/Documents/whisper/models",
    "/usr/local/share/whisper/models",
    "~/.whisper/models"  // Common for Python whisper
]
```

### Option 3: Model Import
Let users drag-and-drop or browse for model files:
- Copy to app's Application Support directory
- Verify model format
- Show in Models tab

### Option 4: Symbolic Links
Document how users can symlink their existing models:
```bash
ln -s /path/to/existing/models ~/Developer/whisper.cpp/models
```

## Recommendation

For v1.1, implement Option 1 (User Preference):
- Simple to implement
- Gives users control
- No auto-scanning complexity
- Can add auto-detection later

For v2.0, add Option 2 (Auto-Detection):
- Scan on first launch
- Let user confirm found models
- Remember user's choice

## Implementation Notes

1. **Validate path exists** before using
2. **Check for model files** in selected directory
3. **Fallback to default** if custom path invalid
4. **Update onboarding** to mention model location

---
*Created: 2025-07-10 09:05 PST*