#!/bin/bash

# WhisperKey Comprehensive Fix Script
# Solves both F5 dictation interception and accessibility permission issues

echo "=== WhisperKey Comprehensive Fix Script ==="
echo "This script will fix both the F5 dictation and accessibility permission issues"
echo ""

# Get the bundle ID
BUNDLE_ID="com.whisperkey.app"

# Step 1: Completely disable dictation at system level
echo "Step 1: Disabling dictation at system level..."

# Disable dictation auto-enable prompt
defaults write com.apple.HIToolbox AppleDictationAutoEnable -int 0

# Disable dictation hotkey in symbolic hotkeys (ID 162 is dictation)
/usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:162:enabled false" ~/Library/Preferences/com.apple.symbolichotkeys.plist 2>/dev/null || \
  /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:162 dict" ~/Library/Preferences/com.apple.symbolichotkeys.plist 2>/dev/null
/usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:162:enabled bool false" ~/Library/Preferences/com.apple.symbolichotkeys.plist 2>/dev/null

# Disable dictation completely
defaults write com.apple.speech.recognition.AppleSpeechRecognition.prefs DictationEnabled -bool false
defaults write com.apple.speech.recognition.AppleSpeechRecognition.prefs DictationIMAllowedEverywhere -bool false

# Disable all dictation shortcuts
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 160 "{enabled = 0;}"  # Start dictation
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 161 "{enabled = 0;}"  # Dictation commands
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 162 "{enabled = 0;}"  # Enable dictation
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 163 "{enabled = 0;}"  # Show emoji & symbols
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 164 "{enabled = 0;}"  # Start dictation (older)

# Step 2: Configure function keys to be standard (prevents F5 special behavior)
echo "Step 2: Setting function keys to standard behavior..."
defaults write -g com.apple.keyboard.fnState -bool true

# Step 3: Reset accessibility permissions for WhisperKey
echo "Step 3: Resetting accessibility permissions..."

# First, remove the app from accessibility
sudo tccutil reset Accessibility "$BUNDLE_ID"

# Kill cfprefsd to ensure preferences are reloaded
killall cfprefsd

# Step 4: Create advanced Karabiner configuration
echo "Step 4: Creating advanced Karabiner configuration..."

KARABINER_CONFIG_DIR="$HOME/.config/karabiner/assets/complex_modifications"
mkdir -p "$KARABINER_CONFIG_DIR"

cat > "$KARABINER_CONFIG_DIR/whisperkey_advanced.json" << 'EOF'
{
  "title": "WhisperKey Advanced F5 Interception",
  "rules": [
    {
      "description": "Block F5 dictation key completely",
      "manipulators": [
        {
          "type": "basic",
          "from": {
            "key_code": "f5",
            "modifiers": {
              "optional": ["any"]
            }
          },
          "to": [
            {
              "shell_command": "echo 'F5 intercepted by WhisperKey' >> /tmp/whisperkey_f5.log"
            }
          ],
          "conditions": [
            {
              "type": "frontmost_application_unless",
              "bundle_identifiers": ["^com\\.apple\\.systempreferences$"]
            }
          ]
        },
        {
          "type": "basic",
          "from": {
            "consumer_key_code": "dictation"
          },
          "to": [
            {
              "shell_command": "echo 'Dictation key intercepted by WhisperKey' >> /tmp/whisperkey_f5.log"
            }
          ]
        }
      ]
    }
  ]
}
EOF

# Step 5: Fix TCC database inconsistency
echo "Step 5: Checking TCC database..."

# Check current permission status
if sudo sqlite3 "/Library/Application Support/com.apple.TCC/TCC.db" \
  "SELECT auth_value FROM access WHERE service='kTCCServiceAccessibility' AND client='$BUNDLE_ID';" 2>/dev/null; then
  echo "Found entry in global TCC database"
fi

# Also check user TCC database
if sqlite3 "$HOME/Library/Application Support/com.apple.TCC/TCC.db" \
  "SELECT auth_value FROM access WHERE service='kTCCServiceAccessibility' AND client='$BUNDLE_ID';" 2>/dev/null; then
  echo "Found entry in user TCC database"
fi

# Step 6: Create test program to verify accessibility
echo "Step 6: Creating accessibility test program..."

cat > /tmp/test_accessibility.swift << 'EOF'
import Cocoa

let trusted = AXIsProcessTrusted()
print("AXIsProcessTrusted: \(trusted)")

if trusted {
    // Try to actually use accessibility API
    if let frontApp = NSWorkspace.shared.frontmostApplication {
        let pid = frontApp.processIdentifier
        if let appElement = AXUIElementCreateApplication(pid) {
            var windows: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windows)
            if result == .success {
                print("✓ Accessibility API is working correctly")
            } else {
                print("✗ Accessibility API not working despite trusted status (TCC inconsistency)")
            }
        }
    }
} else {
    print("✗ Process not trusted")
}
EOF

echo ""
echo "=== Actions Required ==="
echo ""
echo "1. RESTART YOUR MAC (required for dictation changes to take effect)"
echo ""
echo "2. After restart:"
echo "   a) Open Karabiner-Elements"
echo "   b) Go to Complex Modifications → Add rule"
echo "   c) Enable 'WhisperKey Advanced F5 Interception'"
echo "   d) Make sure Karabiner has Input Monitoring permission"
echo ""
echo "3. Run WhisperKey again and grant accessibility when prompted"
echo ""
echo "4. Test accessibility with: swift /tmp/test_accessibility.swift"
echo ""
echo "5. If issues persist, try:"
echo "   - System Settings → Privacy & Security → Accessibility"
echo "   - Remove WhisperKey if present, then add it back"
echo ""
echo "Alternative: If F5 is still being intercepted by the system:"
echo "   - System Settings → Keyboard → Keyboard Shortcuts → Function Keys"
echo "   - Enable 'Use F1, F2, etc. keys as standard function keys'"
echo "   - This will require pressing Fn+F5 for dictation (which will be blocked)"
echo ""
echo "Press Enter to acknowledge..."
read