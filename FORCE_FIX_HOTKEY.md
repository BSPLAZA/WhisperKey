# Force Fix HotKey Linking Issue

Since HotKey is already added but not properly linked, try these solutions:

## Solution 1: Check Target Membership
1. In Xcode, select your **WhisperKey** project in navigator
2. Select the **WhisperKey** target (not the project)
3. Go to **"Frameworks, Libraries, and Embedded Content"** section
4. Click the **"+"** button
5. Select **"HotKey"** from the list
6. Click **Add**

## Solution 2: Clean Everything
```bash
# Close Xcode first, then run:
cd /Users/orion/Omni/WhisperKey
rm -rf ~/Library/Developer/Xcode/DerivedData/WhisperKey-*
rm -rf .build
rm -rf .swiftpm
rm Package.resolved
```

Then:
1. Open Xcode
2. **File → Packages → Reset Package Caches**
3. **File → Packages → Resolve Package Versions**
4. Build again

## Solution 3: Check Build Phases
1. Select WhisperKey target
2. Go to **Build Phases** tab
3. Expand **"Link Binary With Libraries"**
4. If HotKey isn't there, click **"+"** and add it

## Solution 4: Manual Package.resolved
Create this file at `/Users/orion/Omni/WhisperKey/WhisperKey/Package.resolved`:

```json
{
  "pins" : [
    {
      "identity" : "hotkey",
      "kind" : "remoteSourceControl",
      "location" : "https://github.com/soffes/HotKey",
      "state" : {
        "revision" : "c13662730cb5bc28de4a799854bbb018a90649bf",
        "version" : "0.2.0"
      }
    }
  ],
  "version" : 2
}
```

Then restart Xcode and build.