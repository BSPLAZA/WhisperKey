# Third-party credits for the public 1.0.x source

| Component | Contribution to WhisperKey | Upstream credit and terms |
| --- | --- | --- |
| whisper.cpp and ggml | Local inference tool and libraries. The public disk image includes `whisper-cli`, `libwhisper` and ggml libraries. | [whisper.cpp MIT license in v1.7.6](https://github.com/ggml-org/whisper.cpp/blob/v1.7.6/LICENSE) credits The ggml authors. The helper's libwhisper load command records 1.7.6 as the current library version. The upstream license is a reference; the exact bundled revision still needs verification. |
| Whisper | Speech recognition model family. The public setup code offers a separate download of converted models. | [OpenAI Whisper](https://github.com/openai/whisper#license) credits OpenAI and publishes the code and weights under MIT. The setup code uses the [converted model repository](https://huggingface.co/ggerganov/whisper.cpp). |
| HotKey | Global keyboard shortcut support. | [Sam Soffes, MIT license](https://github.com/soffes/HotKey/blob/a3cf605d7a96f6ff50e04fcb6dea6e2613cfcbe4/LICENSE). The v1.0.2 Xcode package resolution pins that revision. |

The [project license](../LICENSE) retains the existing WhisperKey Contributors notice. Each dependency retains its own attribution. Distributors should match the actual packaged code and model versions to their copyright and license texts and include those texts with the distribution. No separate license or notice file was found in the inspected v1.0.2 disk image. This list documents the repository and leaves the historical download unchanged.
