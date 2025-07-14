#!/bin/bash

# WhisperKey Right Option Setup Script

echo "=== WhisperKey Right Option Setup ==="
echo ""
echo "This script helps you set up Right Option (⌥) as your dictation key"
echo ""

# Check if WhisperKey is running
if pgrep -x "WhisperKey" > /dev/null; then
    echo "✅ WhisperKey is running"
else
    echo "❌ WhisperKey is not running"
    echo "   Please build and run WhisperKey from Xcode first"
    exit 1
fi

# Test Right Option key
echo ""
echo "Testing Right Option key..."
echo ""
echo "Instructions:"
echo "1. Make sure WhisperKey shows 🎤 in your menu bar"
echo "2. Click in any text field"
echo "3. Press and release your RIGHT Option key (next to right Cmd)"
echo "4. You should see the 🎤 turn red (recording)"
echo "5. Press Right Option again to stop"
echo ""

# Optional: Set up with Karabiner for key remapping
echo "Optional: Remap a different key to Right Option"
echo ""
echo "If you want to use a different physical key:"
echo ""
echo "1. Install Karabiner-Elements (if not installed):"
echo "   brew install --cask karabiner-elements"
echo ""
echo "2. Popular remapping options:"
echo "   - Caps Lock → Right Option"
echo "   - Right Command → Right Option"
echo "   - § key → Right Option (international keyboards)"
echo ""

read -p "Do you want to set up Karabiner remapping? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Create Karabiner rule
    mkdir -p ~/.config/karabiner/assets/complex_modifications
    
    cat > ~/.config/karabiner/assets/complex_modifications/whisperkey_right_option.json << 'EOF'
{
  "title": "WhisperKey Right Option Remapping",
  "rules": [
    {
      "description": "Caps Lock to Right Option for WhisperKey",
      "manipulators": [
        {
          "type": "basic",
          "from": {
            "key_code": "caps_lock"
          },
          "to": [
            {
              "key_code": "right_option"
            }
          ]
        }
      ]
    }
  ]
}
EOF

    echo "✅ Karabiner rule created"
    echo ""
    echo "To activate:"
    echo "1. Open Karabiner-Elements"
    echo "2. Go to Complex Modifications → Add rule"
    echo "3. Enable 'Caps Lock to Right Option for WhisperKey'"
    echo "4. Now Caps Lock will trigger WhisperKey!"
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "WhisperKey is configured to use Right Option (⌥) for dictation."
echo "Press Right Option in any text field to start dictating!"
echo ""
echo "Tips:"
echo "- The menu bar icon shows recording status"
echo "- Press Escape while recording to cancel"
echo "- Adjust settings by clicking the 🎤 icon"