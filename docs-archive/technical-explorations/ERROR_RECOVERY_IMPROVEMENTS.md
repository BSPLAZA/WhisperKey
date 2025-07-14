# WhisperKey Error Recovery UI Improvements

*Created: 2025-07-10 18:30 PST*

## Overview
Enhanced error recovery and setup experience for WhisperKey to help users when dependencies are missing or misconfigured.

## New Components Added

### 1. WhisperSetupAssistant.swift
Interactive setup wizard for whisper.cpp installation:
- **Auto-detection**: Searches common installation paths automatically
- **Install Methods**: Homebrew (recommended), manual build, or custom path
- **Step-by-step Instructions**: Copy-pasteable commands for each method
- **Progress Tracking**: Shows current step and validates installation
- **Smart Navigation**: Skips to success if already installed

Key features:
- Searches: `~/.whisperkey/bin`, `~/Developer/whisper.cpp`, `/usr/local/bin`, `/opt/homebrew/bin`
- Provides Metal-optimized build instructions
- Validates installation before proceeding

### 2. ModelMissingView.swift
Improved dialog when selected AI model is not installed:
- **Model Information**: Shows size, description, and requirements
- **Download Options**: Download now or choose different model
- **Alternative Models**: Lists installed models with quick switch
- **Progress Tracking**: Real-time download progress
- **Error Recovery**: Clear error messages with retry option

### 3. PermissionGuideView.swift
Interactive permission setup guide:
- **Visual Status**: Shows granted/pending for each permission
- **Direct Links**: Opens System Settings to exact permission page
- **Real-time Updates**: Check Again button to verify changes
- **Clear Instructions**: Step-by-step guide for granting permissions

## Integration Points

### WhisperService.swift
Updated to show interactive setup assistant instead of basic alert:
```swift
func showSetupError() {
    // Shows WhisperSetupAssistant in a window
}
```

### WhisperCppTranscriber.swift
Enhanced to show model missing dialog with recovery options:
```swift
// Shows ModelMissingView when model not found
await MainActor.run {
    ModelManager.shared.showModelMissingDialog(for: modelName)
}
```

### ErrorHandling.swift
Existing comprehensive error system enhanced with:
- Recovery suggestions for each error type
- Automatic recovery attempts for some errors
- User-friendly error banners with retry options

## User Experience Flow

### First Run Experience:
1. User launches WhisperKey
2. If whisper.cpp missing → WhisperSetupAssistant opens
3. If permissions missing → PermissionGuideView opens
4. If model missing → ModelMissingView opens

### Error Recovery Flow:
1. Error occurs (e.g., model not found)
2. Contextual dialog appears with:
   - Clear explanation of the issue
   - One-click solutions (download, switch model, etc.)
   - Alternative options
3. User takes action
4. System automatically retries

## Technical Improvements

### Dynamic Path Detection
- No more hardcoded paths
- Searches multiple common locations
- User-configurable custom paths
- Persists settings across launches

### Better Error Messages
Before: "Model not found"
After: "The selected Whisper model 'small.en' is not installed. [Download Now] [Choose Different Model]"

### Visual Feedback
- Progress indicators for downloads
- Real-time permission status
- Step completion tracking
- Success confirmations

## Testing Needed

1. **Clean System Test**
   - Remove whisper.cpp and test setup flow
   - Revoke permissions and test guide
   - Delete models and test download flow

2. **Error Scenarios**
   - Network failure during download
   - Incorrect custom path
   - Permission denial
   - Disk space issues

3. **User Paths**
   - Homebrew installation
   - Manual compilation
   - Custom locations
   - Switching between methods

## Next Steps

1. Add automated tests for error scenarios
2. Consider adding troubleshooting logs export
3. Add video tutorials for complex setups
4. Implement crash reporting with recovery suggestions

## Code Quality
- All force unwraps removed
- Proper error handling throughout
- @MainActor compliance for UI updates
- Memory-safe implementations