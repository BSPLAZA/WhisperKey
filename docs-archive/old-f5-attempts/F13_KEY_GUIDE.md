# F13 Key Guide for Mac Users

## Where is F13 on My Mac?

### MacBook Pro/Air with Touch Bar (2016-2021)
```
[Esc] [────────────── Touch Bar ──────────────] [Power]
       ↑
       F13 appears here when you hold Fn key
```
- **How to press F13**: Hold `Fn` + tap where F13 appears on Touch Bar
- The Touch Bar shows F13-F15 when holding Fn

### MacBook Pro 14"/16" (2021+) with Physical Function Keys
```
[Esc] [F1] [F2] [F3] [F4] [F5] [F6] [F7] [F8] [F9] [F10] [F11] [F12] [Power]
```
- **No physical F13 key**
- **How to access F13**: Use combinations or external keyboard

### Magic Keyboard / External Keyboards
```
Regular Layout:
[F1] [F2] [F3] [F4] [F5] [F6] [F7] [F8] [F9] [F10] [F11] [F12]

Extended Layout (some keyboards):
[F1] [F2] [F3] [F4] [F5] [F6] [F7] [F8] [F9] [F10] [F11] [F12] [F13] [F14] [F15]
```

## How to "Press" F13 on Different Macs

### Option 1: Keyboard Viewer (Visual Method)
1. Enable "Show keyboard and emoji viewers in menu bar" in System Settings
2. Click keyboard icon in menu bar → Show Keyboard Viewer
3. Hold `Fn` key
4. Click F13 in the on-screen keyboard

### Option 2: Karabiner-Elements (Remap a Key)
```json
{
  "description": "Change right_option to F13",
  "manipulators": [{
    "type": "basic",
    "from": {"key_code": "right_option"},
    "to": [{"key_code": "f13"}]
  }]
}
```
Common remapping choices:
- Right Option → F13 (rarely used)
- Caps Lock → F13 (if you don't use caps)
- § key → F13 (on international keyboards)

### Option 3: Touch Bar Customization
On Touch Bar Macs:
1. System Settings → Keyboard → Touch Bar Settings
2. Customize Control Strip
3. Add "Expanded Control Strip" 
4. F13 will be accessible via Fn key

### Option 4: BetterTouchTool
- Map any gesture/key to F13
- Example: Three-finger tap = F13
- Or: Fn + § = F13

## Testing F13

To verify F13 is working:
```bash
# In Terminal, run:
xxd -psg

# Then press your F13 key/combination
# You should see: 1b5b32357e (the F13 key code)
# Press Ctrl+C to exit
```

## Why This Is Actually Better Than F5

1. **No accidents**: F5 is too easy to hit by mistake
2. **Customizable**: Choose your preferred key/gesture
3. **No conflicts**: F13 has zero system functions
4. **Future-proof**: Apple won't assign F13 to anything

## Recommended Setups

### For Most Users
**Right Option → F13**
- You have two option keys, rarely need both
- Easy to reach
- No muscle memory conflicts

### For Power Users  
**Caps Lock → F13**
- Caps Lock is prime real estate
- Many developers already remap it
- Single key press for dictation

### For Touch Bar Users
**Fn + Tap Touch Bar**
- Natural gesture
- Visual feedback
- No physical key needed

## Quick Setup Script

```bash
# If you want to use Karabiner to map Right Option to F13:
cat > ~/.config/karabiner/assets/complex_modifications/f13_mapping.json << EOF
{
  "title": "WhisperKey F13 Mapping",
  "rules": [{
    "description": "Right Option to F13",
    "manipulators": [{
      "type": "basic",
      "from": {
        "key_code": "right_option"
      },
      "to": [{
        "key_code": "f13"
      }]
    }]
  }]
}
EOF

echo "✅ Karabiner rule created. Enable it in Karabiner-Elements → Complex Modifications"
```

## The Bottom Line

F13 might seem weird at first, but it's actually:
- **More intentional** - No accidental activations
- **More flexible** - Put it wherever YOU want
- **More reliable** - No fighting with macOS

Think of it like a custom hotkey that Apple specifically reserved for apps like WhisperKey!