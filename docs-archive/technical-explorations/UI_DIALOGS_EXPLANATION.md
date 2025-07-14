# WhisperKey UI Dialogs Explanation

## Two Different Flows for Two Different Scenarios

### 1. OnboardingView
**When it's shown:** On first launch of WhisperKey
**Purpose:** Welcome new users and get them fully set up
**Flow:**
- Welcome screen
- Permission setup (microphone & accessibility)
- Model selection and download
- Activation key configuration
- Success!

**Key characteristic:** Comprehensive first-time setup

### 2. WhisperSetupAssistant
**When it's shown:** When user tries to use WhisperKey but whisper.cpp is missing
**Purpose:** Help users install the missing whisper.cpp dependency
**Flow:**
- Explain what's missing
- Check if already installed
- Guide through installation (Homebrew or manual)
- Verify installation
- Direct to Settings for model download

**Key characteristic:** Focused on one specific problem

## Why Two Separate Dialogs?

1. **Different contexts:**
   - Onboarding = "Welcome! Let's get everything set up"
   - Setup Assistant = "Oops, you're missing whisper.cpp"

2. **Different user states:**
   - Onboarding users are excited to start
   - Setup Assistant users are frustrated something isn't working

3. **Different scopes:**
   - Onboarding covers everything (permissions, models, keys)
   - Setup Assistant focuses only on whisper.cpp installation

## Could They Be Unified?

Technically yes, but it would create a worse user experience:
- New users would see "whisper.cpp missing" errors they don't understand
- Existing users would have to go through permissions they already granted
- The flow would be confusing with conditional steps

## Current Flow Logic

```
First Launch?
  → Show OnboardingView
  
User tries to dictate:
  - Whisper.cpp missing? → Show WhisperSetupAssistant
  - Model missing? → Show ModelMissingView
  - Permissions missing? → Show PermissionGuideView
  - Everything OK? → Start recording
```

This gives users exactly what they need, when they need it.