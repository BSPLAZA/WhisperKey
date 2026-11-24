# Public download and installation status

The v1.0.2 release contains `WhisperKey-1.0.2.dmg`. It is a historical download. Keep your working copy if you already use WhisperKey. A verified first-time installation path is still pending.

## Inspect the historical download

1. Open the [v1.0.2 release](https://github.com/BSPLAZA/WhisperKey/releases/tag/v1.0.2) and download `WhisperKey-1.0.2.dmg` from **Assets**.
2. In Terminal, run `shasum -a 256 ~/Downloads/WhisperKey-1.0.2.dmg`. The expected SHA-256 is `3055407f81c54a6012b9621484010fc4bc4af4700bb4d0ccf0c5ceab7bc41e51`. If the digest differs, stop before opening the image. A match identifies the published bytes. Code signing and notarization are separate checks.
3. Open the disk image to inspect its contents. It contains `WhisperKey.app` and a shortcut to Applications. For this historical image, stop here and eject it. Leave macOS security protections enabled.

| What the image contains | What was verified |
| --- | --- |
| App version | The release tag is v1.0.2. The enclosed app's Info.plist says 1.0.1 (101). |
| Architecture and declared minimum OS | The app and helper are arm64. The app declares macOS 15.0 as its minimum. |
| App signature | The main app failed signature verification as unsigned. |
| Speech engine | The helper requests `@rpath/libwhisper.1.dylib`; the image supplies `libwhisper.dylib`. The helper records developer build directories as search paths and has no bundle-relative search path. |
| First run | A clean install, model setup and successful first dictation have not been verified for this image. |

## Before recommending a replacement

For each release, inspect the exact uploaded disk image and record its digest. Check the tag, bundle version, supported macOS versions and architectures against the README. Verify Developer ID signing, notarization, and Gatekeeper acceptance of the downloaded artifact. Check the packaged dependency paths and include the applicable licenses in the app.

On a clean supported Mac, test the same steps a new user will follow: open the downloaded image, copy the app into Applications, launch it with default macOS security settings, grant the requested permissions, obtain a model, then dictate a known sentence into TextEdit. Confirm that the words appear once in the intended field. Update this guide and the README with the results for the published build.
