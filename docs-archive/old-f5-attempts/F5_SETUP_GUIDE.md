# WhisperKey F5 Setup Guide

## Quick Setup (Recommended)

Run this command in Terminal:
```bash
cd /path/to/WhisperKey
./scripts/install-karabiner-config.sh
```

This will:
1. Check if Karabiner-Elements is installed (and offer to install it)
2. Install the WhisperKey configuration
3. Open Karabiner-Elements for you to enable the rule

## Manual Setup Options

### Option 1: Use Karabiner-Elements (Most Reliable)

1. **Install Karabiner-Elements**
   ```bash
   brew install --cask karabiner-elements
   ```
   Or download from: https://karabiner-elements.pqrs.org

2. **Enable WhisperKey Rule**
   - Open Karabiner-Elements
   - Go to "Complex Modifications" → "Add rule"
   - Import from file: `karabiner-config/whisperkey.json`
   - Enable "Remap F5 dictation key to F13"

3. **WhisperKey will now intercept F13 instead of F5**

### Option 2: Disable System Dictation

1. **Run the disable script**
   ```bash
   ./scripts/disable-system-dictation.sh
   ```

2. **Or manually disable**
   - System Settings → Keyboard → Dictation → Turn Off
   - Remove F5 shortcut if present

### Option 3: Use Alternative Shortcuts

WhisperKey also supports:
- **⌘⇧D** (Command+Shift+D) - Works without any setup
- **F13** - If you have an extended keyboard
- **Double-tap Right Command** - With Karabiner config

## Troubleshooting

### F5 still triggers system dictation
1. Make sure Karabiner-Elements is running
2. Check that the WhisperKey rule is enabled
3. Try logging out and back in

### Permission Issues
1. Grant Accessibility permission to WhisperKey
2. Grant Input Monitoring permission to Karabiner-Elements
3. If prompted multiple times, try: `tccutil reset All com.whisperkey.WhisperKey`

### Testing Your Setup
1. Open TextEdit
2. Press your chosen dictation key
3. You should see a WhisperKey notification (not system dictation)

## Understanding the Technical Challenge

macOS processes the F5 dictation key at a very low level, before most applications can intercept it. This is why we need either:
- Karabiner-Elements (kernel extension level interception)
- System dictation disabled
- Alternative shortcuts

## Which Method Should I Use?

- **Karabiner-Elements**: Best if you want to keep using F5
- **Disable System Dictation**: Simplest if you don't use system dictation
- **Alternative Shortcuts**: Good if you can't install additional software