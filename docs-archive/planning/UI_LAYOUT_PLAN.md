# UI Layout Plan - WhisperKey Dialogs

## Recording Indicator Issues

### Current Problems
1. Text "Recording" getting truncated with ellipses
2. Timer not resetting between sessions
3. Window width might be too small again
4. "ESC to cancel" taking up space

### Proposed Fix
```
┌─────────────────────────────────────┐
│     🔴 Recording  0:03              │  <- No truncation
│  ████████░░░░░░░░░░░░░░░░░░░░░░░░  │  <- Audio levels
│  Stopping in 8s                     │  <- Only show when <10s
└─────────────────────────────────────┘
Width: 400px (increased from 380px)
Height: 60px (reduced from 70px)
```

### Timer Reset Fix
- Reset timer in `RecordingIndicatorManager.showRecordingIndicator()`
- Clear timer in `hideRecordingIndicator()`
- Use `@State` properly for timer management

## Onboarding Dialog Issues

### Current Problems
1. Elements overlapping
2. Poor spacing
3. Dialog keeps showing repeatedly
4. Accessibility permission flow broken
5. Navigation buttons poorly placed

### Proper Layout Structure
```
┌────────────────────────────────────────┐
│                                        │
│          [App Icon - Pulse]            │
│                                        │
│         Welcome to WhisperKey          │
│                                        │
│   ┌──────────────────────────────┐    │
│   │                              │    │
│   │    [Step Content Area]       │    │
│   │                              │    │
│   │    Proper spacing here       │    │
│   │                              │    │
│   └──────────────────────────────┘    │
│                                        │
│   •  ○  ○  ○  [Progress dots]         │
│                                        │
│   [Previous]              [Next]       │
│                                        │
└────────────────────────────────────────┘
Window: 600x600 (keep current)
Content padding: 40px all sides
Button spacing: 30px from bottom
```

### Step-by-Step Content

**Step 1: Welcome**
- Icon with pulse animation
- Title and brief description
- Clean, uncluttered

**Step 2: How It Works**
- Clear explanation
- Visual of tap-to-toggle
- Mention ESC or re-tap to cancel here

**Step 3: Permissions**
- Two clear buttons with status
- Microphone permission
- Accessibility permission
- Show actual status

**Step 4: Download Model**
- Model selection
- Download progress
- Skip option

### Onboarding Show Logic
```swift
// Only show if:
// 1. First launch (no UserDefaults.firstLaunchComplete)
// 2. User clicks "Show Onboarding" menu item
// 3. NOT on every app launch

@AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false

// In MenuBarApp
.onAppear {
    if !hasCompletedOnboarding {
        showOnboarding()
    }
}
```

## Settings Dialog Improvements

### Current State
- Using SettingsSection components ✓
- Icons for each section ✓
- Good spacing mostly ✓

### Minor Tweaks Needed
- Ensure consistent padding
- Check scroll view behavior
- Verify all text is visible

## Implementation Priority

1. **Fix Recording Indicator** (Critical)
   - Reset timer between sessions
   - Increase width to prevent truncation
   - Remove ESC hint

2. **Fix Onboarding Flow** (High)
   - Fix overlapping elements
   - Fix show/hide logic
   - Fix permission flow
   - Move ESC/re-tap info here

3. **Polish Settings** (Low)
   - Minor spacing adjustments only

## Code Organization

### RecordingIndicator.swift
```swift
// Add to RecordingIndicatorManager
func resetTimer() {
    // Call this in showRecordingIndicator()
}

// Update width
.frame(width: 400, height: 60)

// Remove ESC hint view entirely
```

### OnboardingView.swift
```swift
// Fix structure
VStack(spacing: 0) {
    // Content area with proper padding
    VStack {
        // Step content
    }
    .padding(40)
    .frame(maxHeight: .infinity)
    
    // Progress dots
    HStack { ... }
    .padding(.bottom, 20)
    
    // Navigation buttons  
    HStack {
        Button("Previous") { ... }
        Spacer()
        Button(isLastStep ? "Done" : "Next") { ... }
    }
    .padding(.horizontal, 40)
    .padding(.bottom, 30)
}
```

---
*Created: 2025-07-10 08:50 PST*