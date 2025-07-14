# Setting Up whisper.cpp for WhisperKey

> **Note**: WhisperKey v1.0.0 is now available! [Download here](https://github.com/BSPLAZA/WhisperKey/releases/tag/v1.0.0)

WhisperKey requires whisper.cpp to be installed on your system for transcription. This guide will help you set it up.

## Prerequisites

- Xcode Command Line Tools
- Git  
- About 5GB free disk space (for models)
- Homebrew (optional but recommended)

## Quick Install

### Step 1: Install Xcode Command Line Tools

Open Terminal and run:
```bash
xcode-select --install
```

If you see "command line tools are already installed", you're good to go!

### Step 2: Clone and Build whisper.cpp

```bash
# Create Developer directory if it doesn't exist
mkdir -p ~/Developer
cd ~/Developer

# Clone whisper.cpp
git clone https://github.com/ggerganov/whisper.cpp.git
cd whisper.cpp

# Build with Metal support (for Apple Silicon Macs)
WHISPER_METAL=1 make -j

# For Intel Macs, use:
# make -j
```

### Step 3: Download Whisper Models

WhisperKey can download models for you, but you can also pre-download them:

```bash
cd ~/Developer/whisper.cpp/models

# Download the models (choose based on your needs)
bash ./download-ggml-model.sh base.en    # 141 MB - Fastest
bash ./download-ggml-model.sh small.en   # 465 MB - Balanced (recommended)
bash ./download-ggml-model.sh medium.en  # 1.4 GB - More accurate
bash ./download-ggml-model.sh large-v3   # 3.1 GB - Best accuracy
```

### Step 4: Verify Installation

Test that whisper.cpp works:

```bash
cd ~/Developer/whisper.cpp
./main -m models/ggml-base.en.bin samples/jfk.wav
```

You should see:
```
[00:00:00.000 --> 00:00:11.000]   And so my fellow Americans, ask not what your country can do for you, ask what you can do for your country.
```

## Model Selection Guide

| Model | Size | Speed | Accuracy | Best For |
|-------|------|-------|----------|----------|
| base.en | 141 MB | Very Fast | Good | Quick notes, reminders |
| small.en | 465 MB | Fast | Better | Daily use (recommended) |
| medium.en | 1.4 GB | Moderate | High | Professional writing |
| large-v3 | 3.1 GB | Slow | Best | Maximum accuracy |

## Troubleshooting

### "xcrun: error: invalid active developer path"

This means Xcode Command Line Tools need to be reinstalled:
```bash
sudo rm -rf /Library/Developer/CommandLineTools
xcode-select --install
```

### Build Errors on Apple Silicon

Make sure you're using the Metal flag:
```bash
make clean
WHISPER_METAL=1 make -j
```

### Build Errors on Intel Macs

Try without Metal support:
```bash
make clean
make -j
```

### "Models directory not found"

WhisperKey expects models in `~/Developer/whisper.cpp/models/`. If you installed whisper.cpp elsewhere, you'll need to wait for the custom path feature in a future update.

### Permission Denied Errors

Make sure the directories have proper permissions:
```bash
chmod -R 755 ~/Developer/whisper.cpp
```

### Out of Disk Space

The models require significant space:
- All 4 models: ~5.1 GB
- Minimum (just base.en): 141 MB

Check available space:
```bash
df -h ~
```

## Alternative: Using Homebrew

If you prefer Homebrew (note: this installs to a different location):
```bash
brew install whisper-cpp
```

However, WhisperKey currently expects models in `~/Developer/whisper.cpp/models/`, so manual installation is recommended.

## Performance Tips

1. **Start with smaller models** - base.en or small.en work well for most use cases
2. **Metal acceleration** - Significantly faster on Apple Silicon
3. **Close other apps** - Transcription uses CPU/GPU resources
4. **Good microphone** - Better audio input = better accuracy

## Next Steps

1. Launch WhisperKey
2. Go through the onboarding process
3. Download a model if you haven't already
4. Start dictating!

## Need Help?

If you encounter issues not covered here, please [open an issue](https://github.com/BSPLAZA/WhisperKey/issues) with:
- Your Mac model (Intel or Apple Silicon)
- macOS version
- The exact error message
- Steps you've tried

---
*Last updated: 2025-07-14*