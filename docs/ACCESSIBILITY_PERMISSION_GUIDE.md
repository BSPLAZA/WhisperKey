# How to Grant Accessibility Permission to WhisperKey

## The Issue

macOS only allows the accessibility permission dialog to be shown **once per app**. After that, you must grant permission manually through System Settings.

## Manual Steps to Grant Permission

### macOS Ventura/Sonoma (13.0+)

1. **Open System Settings** (not System Preferences)
2. Click **Privacy & Security** in the sidebar
3. Click **Accessibility** 
4. You may need to click the **lock icon** at the bottom and enter your password
5. Look for **WhisperKey** in the list:
   - **If it's there**: Make sure the toggle switch is ON ✓
   - **If it's NOT there**: 
     - Click the **+** button
     - Navigate to `/Applications/WhisperKey.app` (or wherever you have it)
     - Click **Open**
6. **Important**: After granting permission, you must **restart WhisperKey**

### macOS Monterey and earlier (12.x and below)

1. Open **System Preferences**
2. Click **Security & Privacy**
3. Click the **Privacy** tab
4. Select **Accessibility** from the left sidebar
5. Click the **lock icon** and authenticate
6. Check the box next to **WhisperKey** (or add it with the + button)
7. **Restart WhisperKey**

## Why This Permission is Needed

WhisperKey needs accessibility permission to:
- Insert transcribed text at your cursor position
- Work in any application across your Mac
- Detect which text field has focus

## Troubleshooting

### WhisperKey doesn't appear in the list
1. Make sure WhisperKey is running
2. Click the + button and manually add it
3. Navigate to the app location (usually `/Applications/WhisperKey.app`)

### Permission granted but still not working
1. **Restart WhisperKey** (this is required!)
2. If still not working, try logging out and back in
3. As a last resort, restart your Mac

### The Grant button does nothing
This is expected behavior - macOS only shows the system dialog once. Follow the manual steps above.

## Quick Access

WhisperKey now includes an "Open System Settings" button that will take you directly to the Accessibility settings page.

---
*Created: 2025-07-10 09:20 PST*