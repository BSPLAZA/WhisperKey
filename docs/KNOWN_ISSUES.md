# WhisperKey Known Issues

*Last Updated: 2025-07-13 14:00 PST*

## Current Known Issues (v1.0.0-beta)

### 1. System Sounds Captured in Transcription
**Severity**: Low  
**Symptoms**: System notification sounds may appear in transcriptions as "(bell dings)" or similar  
**Cause**: Microphone captures ambient sounds including system audio  
**Workaround**: Mute system sounds during dictation or ignore transcribed sounds  
**Fix**: Future versions may implement frequency filtering  

### 2. Recording Indicator Behind Full-Screen Apps
**Severity**: Low  
**Symptoms**: The floating recording window may appear behind full-screen applications  
**Cause**: macOS window level limitations  
**Workaround**: Use WhisperKey in windowed mode or check menu bar icon (turns red)  
**Fix**: Investigating higher window level options  

### 3. No Text Formatting Preservation
**Severity**: Medium  
**Symptoms**: All text is inserted as plain text, losing any formatting  
**Cause**: Current implementation uses plain text only  
**Workaround**: Apply formatting after insertion  
**Fix**: Rich text support planned for v2.0  

### 4. Single Audio Device Support
**Severity**: Low  
**Symptoms**: Doesn't handle audio device switching during recording  
**Cause**: Audio session locked to initial device  
**Workaround**: Stop and restart recording after switching devices  
**Fix**: Dynamic audio device handling in future update  

### 5. No Custom Vocabulary Support
**Severity**: Low  
**Symptoms**: Technical terms or names may be transcribed incorrectly  
**Cause**: Using base Whisper models without customization  
**Workaround**: Use clipboard and manually correct  
**Fix**: Custom vocabulary feature planned for v2.0  

### 6. English Models Only
**Severity**: Medium  
**Symptoms**: Only English transcription available  
**Cause**: Beta release focused on English models  
**Workaround**: None - multilingual support coming  
**Fix**: Multilingual models planned for v2.0  

## Fixed Issues (Resolved in Beta)

### ✅ Text Insertion Not Working (Issue #022)
**Fixed**: 2025-07-13  
**Was**: Text always went to clipboard instead of cursor  
**Solution**: Fixed optional chaining bug and added proper fallback logic  

### ✅ Settings Not Persisting
**Fixed**: 2025-07-11  
**Was**: Changed settings reverted on restart  
**Solution**: Now properly reading from UserDefaults  

### ✅ Permission Dialog Crashes
**Fixed**: 2025-07-11  
**Was**: App crashed when dismissing permission dialogs  
**Solution**: Proper window lifecycle management  

### ✅ Duplicate Permission Requests
**Fixed**: 2025-07-02  
**Was**: Both system and app showed permission dialogs  
**Solution**: Removed redundant app dialogs  

## Platform-Specific Issues

### macOS Ventura (13.x)
- Fully supported, no known issues

### macOS Sonoma (14.x)
- Fully supported, no known issues

### macOS Sequoia (15.x)
- Fully supported, built and tested on 15.0

### Intel Macs
- Supported but slower transcription
- Recommend using base.en model for better performance

### Apple Silicon (M1/M2/M3/M4)
- Optimized with Metal acceleration
- All models perform well

## App-Specific Behaviors

### Terminal.app
- Secure input mode blocks recording (by design)
- Works normally in regular terminal mode

### Password Managers
- Recording blocked in password fields (security feature)
- Works in username and notes fields

### Web Browsers
- Some web apps may need page refresh after granting permissions
- Complex web editors (Google Docs) work but may need testing

## Reporting New Issues

Found a bug? Please report it:
1. Check this list first
2. Search existing [GitHub Issues](https://github.com/BSPLAZA/WhisperKey/issues)
3. Create new issue with:
   - macOS version
   - WhisperKey version
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots if applicable

---
*For development issues and solutions, see [ISSUES_AND_SOLUTIONS.md](ISSUES_AND_SOLUTIONS.md)*