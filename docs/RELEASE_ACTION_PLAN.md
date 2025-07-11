# WhisperKey Release Action Plan

*Last Updated: 2025-07-10 12:30 PST*

## 🎯 Mission
Transform WhisperKey from a working prototype into a delightful product that users can successfully install and use without frustration.

## 📋 Current Status

### What We Have
- ✅ Beautiful, functional UI
- ✅ Solid core transcription
- ✅ Privacy-first architecture
- ✅ Good documentation structure

### What's Blocking Release
- 🔴 Hardcoded path: `/Users/orion/Developer/whisper.cpp`
- 🔴 No error recovery when whisper.cpp missing
- 🔴 Force unwraps that will crash
- 🟡 No automated setup

## 🚀 Action Plan

### Phase 1: Critical Fixes (TODAY - 2 days)

#### 1.1 Fix Hardcoded Paths ✅ COMPLETE (2025-07-10 18:45)
**File**: `WhisperCppTranscriber.swift`
```swift
// Current (BROKEN):
let whisperPath = "/Users/orion/Developer/whisper.cpp/build/bin/whisper-cli"

// Fix:
private func findWhisperCpp() -> String? {
    let searchPaths = [
        "~/.whisperkey/bin/whisper-cli",
        "~/Developer/whisper.cpp/build/bin/whisper-cli",
        "/usr/local/bin/whisper-cli",
        "/opt/homebrew/bin/whisper-cli"
    ]
    // Implementation details...
}
```

**File**: `ModelManager.swift`
```swift
// Current (BROKEN):
private let modelPath = NSString(string: "~/Developer/whisper.cpp/models").expandingTildeInPath

// Fix:
@AppStorage("modelsPath") private var customModelsPath = ""
private var modelPath: String {
    if !customModelsPath.isEmpty {
        return customModelsPath
    }
    return findModelsDirectory() ?? "~/.whisperkey/models"
}
```

#### 1.2 Add Whisper Detection (2 hours)
Create `WhisperService.swift`:
```swift
@MainActor
class WhisperService: ObservableObject {
    static let shared = WhisperService()
    
    @Published var isAvailable = false
    @Published var whisperPath: String?
    @Published var modelsPath: String?
    @Published var setupError: String?
    
    func checkAvailability() {
        // Search for whisper-cli
        // Verify it works
        // Find models directory
        // Update published properties
    }
    
    func showSetupAssistant() {
        // Guide user through setup
    }
}
```

#### 1.3 Remove Force Unwraps (2 hours)
Search and replace all `try!`, `as!`, `!` with proper error handling:
```swift
// Before:
let audioData = try! Data(contentsOf: fileURL)

// After:
guard let audioData = try? Data(contentsOf: fileURL) else {
    DebugLogger.log("Failed to load audio file at: \(fileURL)")
    throw WhisperKeyError.audioLoadFailed
}
```

#### 1.4 Error Recovery UI ✅ COMPLETE (2025-07-10 18:30)
Add helpful error dialogs:
```swift
struct SetupRequiredView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Setup Required")
                .font(.title)
            
            Text("WhisperKey needs whisper.cpp to work.")
                .multilineTextAlignment(.center)
            
            HStack {
                Button("Setup Guide") {
                    NSWorkspace.shared.open(URL(string: "https://github.com/BSPLAZA/WhisperKey/blob/main/docs/WHISPER_SETUP.md")!)
                }
                
                Button("Choose Custom Path") {
                    // File picker
                }
            }
        }
        .frame(width: 400, height: 300)
    }
}
```

### Phase 2: User Experience (Day 3-4)

#### 2.1 First-Run Experience
- Detect if whisper.cpp is missing
- Show friendly setup wizard
- Offer to download models
- Test setup before completing

#### 2.2 Preferences Enhancement
Add "Advanced" section:
- Custom whisper.cpp path
- Custom models path
- Reset to defaults
- Verify installation

#### 2.3 Better Error Messages
Replace technical errors with helpful guidance:
```swift
enum UserFacingErrors {
    case whisperNotFound
    case modelsNotFound
    case noMicrophone
    case diskFull
    
    var message: String {
        switch self {
        case .whisperNotFound:
            return "WhisperKey needs whisper.cpp installed. Click 'Setup Guide' for instructions."
        // etc...
        }
    }
}
```

### Phase 3: Release Preparation (Day 5)

#### 3.1 Testing Checklist
- [ ] Test on clean Mac (no dev tools)
- [ ] Test with whisper.cpp in different locations
- [ ] Test all error scenarios
- [ ] Test permission flows
- [ ] Test on Intel Mac
- [ ] Test on minimum macOS version

#### 3.2 Documentation Updates
- [ ] Update README with beta warnings
- [ ] Create troubleshooting guide
- [ ] Add FAQ section
- [ ] Record setup video

#### 3.3 Release Package
```
WhisperKey-1.0.0-beta.dmg
├── WhisperKey.app (signed)
├── README.pdf
├── Setup Guide.pdf
└── Applications (alias)
```

## 📅 Timeline

### Day 1 (Today)
- [ ] Morning: Fix hardcoded paths
- [ ] Afternoon: Add whisper detection
- [ ] Evening: Test on clean system

### Day 2
- [ ] Morning: Remove force unwraps
- [ ] Afternoon: Error recovery UI
- [ ] Evening: Integration testing

### Day 3
- [ ] Morning: First-run experience
- [ ] Afternoon: Documentation
- [ ] Evening: Create beta release

### Day 4
- [ ] Gather feedback
- [ ] Fix critical issues
- [ ] Prepare 1.0.0 release

## 🔄 Git Strategy

### Option A: Fix First, Then Commit (RECOMMENDED)
```bash
# Work on fixes locally
# Test thoroughly
# Then one clean commit:
git add -A
git commit -m "Fix critical issues for v1.0.0 release

- Replace hardcoded paths with dynamic detection
- Add whisper.cpp availability checking
- Remove all force unwraps
- Add helpful error recovery UI
- Improve first-run experience

Ready for beta release"
```

### Option B: Commit Progress (Not Recommended)
- Risk: Broken state in history
- Benefit: Can revert if needed

**Recommendation**: Fix first, test thoroughly, then commit once.

## 🎯 Success Criteria

### For Beta Release
- [ ] Works on clean Mac without "/Users/orion" path
- [ ] Shows helpful error if whisper.cpp missing
- [ ] Doesn't crash on any error
- [ ] Can recover from all failure modes
- [ ] Documentation is clear about beta status

### For 1.0.0 Release
- [ ] All beta feedback addressed
- [ ] Automated installer available
- [ ] <1% crash rate
- [ ] >90% successful first-run
- [ ] 5-star initial reviews

## 🚧 What We're NOT Doing Yet

Intentionally deferring to v1.1:
- Bundled whisper.cpp binary
- Automatic model downloads
- Multi-language UI
- App Store release
- Windows/Linux support

## 📝 Communication Plan

### In README
```markdown
## ⚠️ Beta Release

This is our first public release! Current limitations:
- Requires manual whisper.cpp installation (guide included)
- English models only in UI
- Some setup required

We're working on a one-click installer for v1.1!
```

### In Error Messages
Always include:
1. What went wrong
2. Why it matters
3. How to fix it
4. Where to get help

### In Releases
Be transparent about:
- What works
- What doesn't
- What's coming
- How to contribute

## 🎉 Definition of Done

WhisperKey is ready when:
1. New user can download and use it successfully
2. Errors are helpful, not confusing
3. Setup is documented clearly
4. Code is clean and maintainable
5. We're proud to share it

## 📍 Next Steps

1. Start with section 1.1 (Fix Hardcoded Paths)
2. Test each fix thoroughly
3. Update this document with progress
4. Celebrate small wins!

---

*Remember: We're building something people will use every day. Every detail matters.*