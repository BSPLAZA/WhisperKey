# Add HotKey Package to Xcode

## Step-by-Step Instructions

### 1. In Xcode, go to File menu
   - Click **File → Add Package Dependencies...**

### 2. Enter the package URL
   - In the search field, paste: `https://github.com/soffes/HotKey`
   - Press Enter

### 3. Configure the package
   - **Dependency Rule**: "Up to Next Major Version"
   - **Version**: 0.2.0
   - Click **Add Package**

### 4. Select products
   - When prompted, make sure **HotKey** is checked
   - **Add to Target**: WhisperKey
   - Click **Add Package**

### 5. Wait for package resolution
   - Xcode will download and integrate the package
   - This may take 10-30 seconds

### 6. Build again
   - Press **Cmd+R** to build and run

## Alternative Method (if the above doesn't work)

### Via Project Settings:
1. Select your **WhisperKey** project in the navigator
2. Select the **WhisperKey** target
3. Go to **Package Dependencies** tab
4. Click the **+** button
5. Enter: `https://github.com/soffes/HotKey`
6. Follow steps 3-6 above

## Troubleshooting

If you see "Missing package product 'HotKey'" after adding:
1. **Clean Build Folder**: Cmd+Shift+K
2. **Reset Package Caches**: File → Packages → Reset Package Caches
3. **Update to Latest Package Versions**: File → Packages → Update to Latest Package Versions
4. **Quit and restart Xcode**

## What HotKey Does

The HotKey library enables global keyboard shortcuts in macOS apps. It's what allows WhisperKey to detect when you press Right Option (⌥) from any application.