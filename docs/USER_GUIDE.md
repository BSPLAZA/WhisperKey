# WhisperKey User Guide

*Your complete guide to using WhisperKey for local, private dictation on macOS*

## Table of Contents

1. [Installation](#installation)
2. [Getting Started](#getting-started)
3. [Basic Usage](#basic-usage)
4. [Recording Controls](#recording-controls)
5. [Settings & Preferences](#settings--preferences)
6. [AI Models](#ai-models)
7. [Tips & Tricks](#tips--tricks)
8. [Keyboard Shortcuts](#keyboard-shortcuts)
9. [Troubleshooting](#troubleshooting)

## Installation

1. **Download**: Get [WhisperKey-1.0.0.dmg](https://github.com/BSPLAZA/WhisperKey/releases/download/v1.0.0/WhisperKey-1.0.0.dmg) (696KB)
2. **Install**: Open the DMG and drag WhisperKey to Applications
3. **First Launch**: Right-click WhisperKey and select "Open" (required for unsigned apps)
4. **Setup**: Follow the onboarding wizard

## Getting Started

### First Launch

When you first launch WhisperKey, you'll be guided through a 5-step setup wizard:

1. **Welcome** - Introduction to WhisperKey
2. **Permissions** - Grant microphone and accessibility access
3. **AI Model** - Download your first transcription model
4. **Preferences** - Configure basic settings
5. **Ready** - Start dictating!

### Menu Bar Icon

WhisperKey lives in your menu bar (top-right of your screen). Look for the microphone icon:
- **Gray mic** - Ready to record
- **Red mic** - Currently recording

Click the icon to access all features.

## Basic Usage

### Starting Dictation

1. **Position your cursor** where you want text to appear
2. **Tap Right Option (⌥)** key once to start recording
3. **Speak clearly** at a normal pace
4. **Tap Right Option (⌥)** again to stop, or wait for auto-stop

### What Happens Next

- **In a text field**: Your words appear instantly at the cursor
- **Not in a text field**: Text saves to clipboard with a notification
- **Success sound**: Glass sound = inserted at cursor
- **Clipboard sound**: Pop sound = saved to clipboard

### Recording Indicator

While recording, you'll see a floating window showing:
- Recording duration (0:15 format)
- Live audio level bars
- Warning when approaching 60-second limit

## Recording Controls

### Starting Recording
- **Primary**: Tap Right Option (⌥) key
- **Alternative**: F13 key (if configured)
- **Menu**: Click menu bar icon → "Start Recording"

### Stopping Recording
- **Manual**: Tap hotkey again
- **Auto-stop**: After 2.5 seconds of silence
- **Cancel**: Press ESC key
- **Timeout**: Automatically at 60 seconds

### Visual Feedback
- Menu bar icon turns red
- Floating timer window appears
- Audio level bars show input

### Audio Feedback
- **Start**: Tink sound
- **Stop**: Pop sound
- **Success**: Glass sound (text inserted)
- **Clipboard**: Pop sound (saved to clipboard)

## Settings & Preferences

Access settings: Click menu bar icon → "Preferences..."

### General Tab

#### Activation
- **Hotkey Selection**: Choose between Right Option or F13
- **Test Area**: Practice your hotkey

#### Behavior
- **Launch at login**: Start WhisperKey automatically
- **Show recording indicator**: Toggle floating window
- **Play feedback sounds**: Enable/disable audio cues
- **Always save to clipboard**: Keep backup copy

### Recording Tab

#### Recording Behavior
- **Auto-stop after silence**: 1.0-5.0 seconds (default: 2.5)
- **Microphone sensitivity**: 1-5 scale
  - 1 = Very Sensitive (quiet rooms)
  - 3 = Normal (most environments)
  - 5 = Least Sensitive (noisy spaces)

#### Safety Limits
- **Maximum recording**: 30-120 seconds (default: 60)

### Models Tab

#### Available Models
- **Base (141 MB)**: Fast, good for quick notes
- **Small (465 MB)**: Balanced speed and accuracy ⭐ Recommended
- **Medium (1.4 GB)**: Best accuracy, slower

To download a model:
1. Click "Download" next to desired model
2. Wait for download to complete
3. Select the radio button to activate

### Advanced Tab
- Debug logging options
- Temporary file cleanup
- Reset all settings

## AI Models

### Choosing a Model

| Model | Size | Speed | Accuracy | Best For |
|-------|------|-------|----------|----------|
| Base | 141 MB | Fast (1-2s) | Good | Quick notes, simple text |
| Small | 465 MB | Medium (2-3s) | Better | Daily use, most content |
| Medium | 1.4 GB | Slower (3-5s) | Best | Technical content, accents |

### Downloading Models

1. Open Preferences → Models tab
2. Click "Download" next to your choice
3. Progress bar shows download status
4. Model auto-activates when complete

### Switching Models

1. Open Preferences → Models tab
2. Click the radio button next to desired model
3. Change takes effect immediately

## Tips & Tricks

### For Best Results

1. **Speak clearly** - Normal pace, don't rush
2. **Pause between sentences** - Helps with punctuation
3. **Say punctuation** - "Period", "comma", "question mark"
4. **Quiet environment** - Reduces errors
5. **Good microphone** - External mics improve accuracy

### Dictation Examples

Say this | Get this
---------|----------
"Hello comma world period" | Hello, world.
"New paragraph" | [Creates new line]
"Quote hello unquote" | "hello"
"Email at gmail dot com" | email@gmail.com

### Advanced Usage

- **Multiple languages**: Use Large model (not included in beta)
- **Technical terms**: Speak slowly and clearly
- **Code dictation**: Spell out symbols
- **Long documents**: Take breaks every few paragraphs

### Privacy Tips

- WhisperKey works 100% offline
- No internet connection required
- Audio files deleted immediately
- Nothing sent to cloud services
- Your voice stays on your Mac

## Keyboard Shortcuts

### Global Shortcuts
- **Right Option (⌥)**: Start/stop recording
- **ESC**: Cancel current recording

### In Preferences Window
- **⌘,**: Open preferences
- **⌘W**: Close window
- **⌘Q**: Quit WhisperKey

### Menu Bar
- **Click**: Show menu
- **Right-click**: Show menu
- **⌘-click**: Show debug info (if enabled)

## Troubleshooting

### Common Issues

#### "Microphone access required"
1. Open System Settings → Privacy & Security
2. Click Microphone
3. Enable WhisperKey
4. Restart WhisperKey

#### "Accessibility access required"
1. Open System Settings → Privacy & Security
2. Click Accessibility
3. Enable WhisperKey
4. Restart WhisperKey

#### No text appears
- Make sure cursor is in a text field
- Check if "Always save to clipboard" is on
- Try different app (some apps block text insertion)

#### Poor accuracy
- Switch to Small or Medium model
- Reduce background noise
- Speak more clearly
- Check microphone sensitivity setting

#### Recording stops too quickly
- Increase "Auto-stop after silence" time
- Reduce microphone sensitivity
- Speak with fewer pauses

### App-Specific Notes

#### Terminal
- Works in normal mode
- Blocked in password prompts (security feature)

#### Web Browsers
- Click in text field first
- Some web apps need page refresh
- Complex editors (Google Docs) may need testing

#### Password Fields
- Recording blocked for security
- Look for warning message
- Use in username field instead

### Getting Help

- **User Guide**: You're reading it!
- **Known Issues**: Check Preferences → Help → Known Issues
- **Report Bug**: Preferences → Help → Report Issue
- **Latest Updates**: Check for app updates

---

*Last Updated: 2025-07-13 | WhisperKey v1.0.0-beta*