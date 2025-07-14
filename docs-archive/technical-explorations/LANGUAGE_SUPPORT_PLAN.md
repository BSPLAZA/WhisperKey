# WhisperKey Language Support Implementation Plan

> Technical roadmap for adding multi-language dictation capabilities

## Current State (v1.0.0)

- **Models**: English-only (base.en, small.en, medium.en)
- **UI**: No language selection
- **Architecture**: Hardcoded for English

## Research Findings

### Apple Dictation Reality
- Advertises automatic language detection
- Users report it's "completely broken" since iOS 13
- Languages switch randomly mid-dictation
- Manual switching required via keyboard

### Whisper Capabilities
- **99 languages supported**
- Built-in language detection
- Special tokens for language identification
- Strong multilingual performance

### Code-Switching Challenges
- Mixed languages in single utterance
- Limited training data
- 14.2% error rate even with latest techniques
- All systems struggle with this

## Implementation Phases

### Phase 1: Manual Language Selection (v1.1)

**UI Changes**:
```swift
// Add to PreferencesView
@AppStorage("dictationLanguage") var dictationLanguage = "en"

// Language picker
Picker("Language", selection: $dictationLanguage) {
    Text("English").tag("en")
    Text("Spanish").tag("es")
    Text("French").tag("fr")
    Text("German").tag("de")
    Text("Italian").tag("it")
    Text("Portuguese").tag("pt")
    Text("Russian").tag("ru")
    Text("Japanese").tag("ja")
    Text("Chinese").tag("zh")
    // ... more languages
}
```

**Model Changes**:
- Download multilingual models (base, small, medium)
- Remove .en suffix from model names
- Update WhisperCppTranscriber to pass language parameter

**Implementation**:
```swift
// WhisperCppTranscriber.swift
func transcribe(audioFileURL: URL, language: String = "en") async throws -> String {
    let args = [
        whisperPath,
        "-m", modelPath,
        "-f", audioFileURL.path,
        "-l", language,  // Add language parameter
        // ... other args
    ]
}
```

### Phase 2: Auto-Detection with Override (v1.2)

**UI Additions**:
```swift
// Add auto-detect option
Picker("Language", selection: $dictationLanguage) {
    Text("Auto-Detect").tag("auto")
    Divider()
    Text("English").tag("en")
    // ... other languages
}

// Show detected language in recording indicator
if dictationLanguage == "auto" {
    Text("Detected: \(detectedLanguage)")
        .font(.caption)
        .foregroundColor(.secondary)
}
```

**Implementation**:
```swift
// Use whisper.cpp auto detection
if language == "auto" {
    args.append(contentsOf: ["--language", "auto"])
} else {
    args.append(contentsOf: ["-l", language])
}

// Parse detected language from output
// whisper.cpp outputs: "auto-detected language: en (p = 0.995117)"
```

### Phase 3: Quick Language Switching (v1.3)

**Hotkey Combinations**:
- `Cmd+Opt+1-9`: Quick switch to preset languages
- Long-press recording button: Language picker
- Menu bar submenu for recent languages

**UI/UX**:
```swift
// Recent languages in menu bar
Menu("Recent Languages") {
    ForEach(recentLanguages, id: \.self) { lang in
        Button(languageName(for: lang)) {
            dictationLanguage = lang
        }
    }
}
```

### Phase 4: Model Abstraction (v2.0)

**Protocol Design**:
```swift
protocol TranscriptionEngine {
    var name: String { get }
    var supportedLanguages: [String] { get }
    var requiresInternet: Bool { get }
    
    func transcribe(
        audioURL: URL,
        language: String?,
        options: TranscriptionOptions
    ) async throws -> TranscriptionResult
}

struct TranscriptionResult {
    let text: String
    let detectedLanguage: String?
    let confidence: Float?
    let alternativeTexts: [String]?
}
```

**Implementations**:
```swift
class WhisperTranscriptionEngine: TranscriptionEngine { }
class WhisperCppTranscriptionEngine: TranscriptionEngine { }
class FutureMLTranscriptionEngine: TranscriptionEngine { }
// Potential: GoogleCloudSTT, AzureSTT, AWSTranscribe (opt-in)
```

## Technical Considerations

### Model Storage
```
~/Library/Application Support/WhisperKey/Models/
├── whisper/
│   ├── base.en.bin (English-only)
│   ├── base.bin (Multilingual)
│   ├── small.en.bin
│   ├── small.bin
│   └── ...
└── future-engine/
    └── model.bin
```

### Performance Impact
- Multilingual models are larger
- Language detection adds ~100ms latency
- Consider caching detected language for session

### UI/UX Guidelines
1. **Always show current language** in status
2. **Quick access** to language switching
3. **Visual confirmation** when language changes
4. **Warn about code-switching** limitations
5. **Persist language choice** per app/context

## Migration Strategy

### From English-Only to Multilingual
1. Keep English models as default
2. Download multilingual on first non-English selection
3. Migrate user preferences seamlessly
4. Show one-time explanation of new features

### Database Schema
```swift
// Future: Track language usage
struct DictationSession {
    let timestamp: Date
    let language: String
    let detectedLanguage: String?
    let wordCount: Int
    let appBundleID: String
}
```

## Testing Requirements

### Language Coverage
- Test top 10 languages by user base
- Verify RTL languages (Arabic, Hebrew)
- Test character-based languages (Chinese, Japanese)
- Verify accent handling within languages

### Edge Cases
- Language switching mid-sentence
- Unsupported language handling
- Network failure during model download
- Disk space issues with large models

## Future Possibilities

### Smart Features
- **Per-app language memory**: Remember language by app
- **Contact-based language**: Detect language by recipient
- **Time-based patterns**: Morning Spanish, evening English
- **Accent adaptation**: Learn user's specific accent

### Advanced Integration
- **Translation mode**: Dictate in one language, insert in another
- **Language learning mode**: Show both languages
- **Pronunciation feedback**: For language learners
- **Custom vocabularies**: Per-language technical terms

## Competition Analysis

| Feature | Apple | Dragon | Otter | WhisperKey (Future) |
|---------|-------|---------|-------|-------------------|
| Languages | 60+ | 6 | 3 | 99 |
| Auto-detect | Broken | No | No | Yes |
| Code-switching | Poor | No | No | Warned |
| Offline | Yes | Yes | No | Yes |
| Custom vocab | Limited | Yes | No | Planned |
| Price | Free | $699 | $16.99/mo | Free |

## Success Metrics

- Language detection accuracy > 95%
- Language switch time < 2 seconds
- User satisfaction with non-English > 4.5/5
- Support top 20 languages by usage
- Zero data sent to cloud (privacy)

---
*Created: 2025-07-10 08:30 PST*