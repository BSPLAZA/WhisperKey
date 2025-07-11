# Critical Fixes Needed Before Release

## 🔴 MUST FIX - Hardcoded Path Issue

The app currently has hardcoded paths that will break for most users:

### Current Code (BROKEN):
```swift
// ModelManager.swift
private let modelPath = NSString(string: "~/Developer/whisper.cpp/models").expandingTildeInPath

// WhisperCppTranscriber.swift  
let whisperPath = "/Users/orion/Developer/whisper.cpp/build/bin/whisper-cli"
```

### Required Fix:

#### Option 1: Search Common Locations (Quick Fix)
```swift
struct WhisperPaths {
    static func findWhisperCpp() -> String? {
        let commonPaths = [
            "~/Developer/whisper.cpp/build/bin/whisper-cli",
            "/usr/local/bin/whisper-cli",
            "/opt/homebrew/bin/whisper-cli",
            "~/.whisperkey/bin/whisper-cli"
        ]
        
        for path in commonPaths {
            let expanded = NSString(string: path).expandingTildeInPath
            if FileManager.default.fileExists(atPath: expanded) {
                return expanded
            }
        }
        return nil
    }
    
    static func findModelsDirectory() -> String? {
        // Similar search logic
    }
}
```

#### Option 2: Add to Preferences (Better)
```swift
// Add to PreferencesView.swift
@AppStorage("whisperCppPath") private var whisperCppPath = ""
@AppStorage("modelsPath") private var modelsPath = ""

// Add UI for users to set paths
```

#### Option 3: Bundle Everything (Best for Users)
- Include pre-built whisper-cli binary in app bundle
- Download models to Application Support directory
- No user configuration needed

## 🟡 Other Critical Issues

### 1. Force Unwraps That Will Crash
```swift
// WhisperCppTranscriber.swift line 139
let audioData = try! Data(contentsOf: fileURL)  // WILL CRASH!
```

Fix:
```swift
do {
    let audioData = try Data(contentsOf: fileURL)
} catch {
    DebugLogger.log("Failed to load audio file: \(error)")
    return "Error: Could not load audio file"
}
```

### 2. Shell Command Injection Risk
```swift
// WhisperCppTranscriber.swift
let arguments = ["-m", modelPath, "-f", audioPath, ...]
```

Fix: Validate paths contain no special characters:
```swift
func sanitizePath(_ path: String) -> String? {
    // Only allow alphanumeric, /, -, _, .
    let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "/-_."))
    guard path.rangeOfCharacter(from: allowed.inverted) == nil else {
        return nil
    }
    return path
}
```

### 3. Missing Error Recovery
Currently if whisper.cpp is missing, the app just fails silently.

Add:
```swift
// In DictationService
if !WhisperPaths.isWhisperAvailable() {
    showError(WhisperKeyError.whisperNotFound(
        "WhisperKey requires whisper.cpp to be installed. " +
        "Please see setup instructions."
    ))
    return
}
```

## 📝 Release Readiness Checklist

### Before v1.0 Release:
- [ ] Fix hardcoded paths (CRITICAL)
- [ ] Remove all force unwraps
- [ ] Add path validation
- [ ] Add whisper.cpp detection
- [ ] Test on clean system
- [ ] Add error recovery

### For v1.1:
- [ ] Bundle whisper binary
- [ ] Auto-installer
- [ ] Model manager improvements

## Testing Script

Create test script to verify fixes:
```bash
#!/bin/bash
# Test WhisperKey on clean system

# 1. Move whisper.cpp to non-standard location
mv ~/Developer/whisper.cpp ~/Desktop/whisper-test

# 2. Launch WhisperKey
open /Applications/WhisperKey.app

# 3. Should show error with instructions
# 4. Set custom path in preferences
# 5. Verify it works
```

## Communication with Users

### In README:
```markdown
## ⚠️ Beta Release Notes

This is our first public release! Please note:
- You must install whisper.cpp separately (automated installer coming in v1.1)
- Default paths may need adjustment in Settings
- Please report any issues you encounter
```

### In Error Messages:
```swift
enum UserFriendlyErrors {
    static let whisperNotFound = """
    WhisperKey couldn't find whisper.cpp on your system.
    
    Please either:
    1. Install it to the default location (see setup guide)
    2. Set a custom path in Settings → Advanced
    
    Need help? See our setup guide.
    """
}
```

## Recommendation

### For v1.0.0 Release:
1. Add path search functionality (Option 1 above)
2. Add clear error messages
3. Document known limitations
4. Mark as "Beta" release

### For v1.1.0:
1. Bundle whisper binary
2. Create installer app
3. Remove "Beta" label

This approach lets us release sooner while being transparent about limitations.