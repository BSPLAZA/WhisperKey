#!/bin/bash
#
# Temporarily disable system dictation to test WhisperKey
#

echo "Current dictation settings:"
defaults read com.apple.HIToolbox AppleDictationAutoEnable

echo ""
echo "To disable F5 dictation key system-wide:"
echo "defaults write com.apple.HIToolbox AppleDictationAutoEnable -int 0"
echo ""
echo "To re-enable later:"
echo "defaults write com.apple.HIToolbox AppleDictationAutoEnable -int 1"
echo ""
echo "You may need to log out and back in for changes to take effect."