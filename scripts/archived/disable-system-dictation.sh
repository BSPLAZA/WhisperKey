#!/bin/bash

# Script to disable system dictation to allow WhisperKey to intercept F5

echo "Disabling system dictation to allow WhisperKey to intercept F5 key..."

# Disable dictation
defaults write com.apple.HIToolbox AppleDictationAutoEnable -int 0

# Remove F5 as dictation shortcut
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 162 "{enabled = 0;}"

echo "System dictation disabled."
echo ""
echo "You may need to:"
echo "1. Log out and log back in"
echo "2. Or go to System Settings > Keyboard > Dictation and manually disable it"
echo ""
echo "To re-enable system dictation later:"
echo "defaults write com.apple.HIToolbox AppleDictationAutoEnable -int 1"