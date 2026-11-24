# WhisperKey

WhisperKey is a macOS menu bar app that turns speech into text. The public 1.0.x source runs transcription locally with whisper.cpp and OpenAI Whisper models. During setup, the app offers to download a selected model from Hugging Face. Dictation requires microphone access. Inserting text into another app uses macOS Accessibility permission.

## Can I install it?

**We recommend waiting for a verified installer for a first-time install.** The latest public [release, v1.0.2](https://github.com/BSPLAZA/WhisperKey/releases/tag/v1.0.2), has an unsigned disk-image app that identifies itself as **1.0.1, build 101**. Its executable is Apple Silicon only and declares macOS 15.0 as its minimum. The bundled transcription helper also references a library filename missing from the app. A working first dictation on a clean Mac has not been established for this download.

[Inspect the download and its checksum](docs/INSTALL.md) · [All public releases](https://github.com/BSPLAZA/WhisperKey/releases)

## How dictation works

The intended flow for the public 1.0.x app is to select a model, focus an editable field in an app such as TextEdit, tap Right Option, speak, and tap Right Option again. The app transcribes locally and attempts to insert the words at the cursor. Results depend on the target app and its permissions. Review the text before sending or saving it.

## Source and contributions

- To inspect the public source at release time, use the [v1.0.2 tag](https://github.com/BSPLAZA/WhisperKey/tree/v1.0.2). The default branch can contain later changes.
- For development, start with the [contributor guide](CONTRIBUTING.md). For a security report, follow the [security policy](SECURITY.md).
- WhisperKey's project source carries the [MIT license](LICENSE), copyright (c) 2025 WhisperKey Contributors. See [third-party credits](docs/THIRD_PARTY.md) for the engine, model and hotkey library.
