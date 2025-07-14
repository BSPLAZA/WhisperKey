#!/usr/bin/env swift

import Cocoa
import ApplicationServices

print("=== WhisperKey Accessibility Permission Diagnostic ===")
print("")

// Check current process info
print("Process Information:")
print("  - Process Name: \(ProcessInfo.processInfo.processName)")
print("  - Bundle ID: \(Bundle.main.bundleIdentifier ?? "nil")")
print("  - Executable Path: \(Bundle.main.executablePath ?? "nil")")
print("")

// Check if running from Xcode
let isXcodeAttached = getenv("__XCODE_BUILT_PRODUCTS_DIR_PATHS") != nil
print("Environment:")
print("  - Running from Xcode: \(isXcodeAttached)")
print("  - Running in sandbox: \(ProcessInfo.processInfo.environment["APP_SANDBOX_CONTAINER_ID"] != nil)")
print("")

// Check accessibility status
print("Accessibility Status:")
print("  - AXIsProcessTrusted(): \(AXIsProcessTrusted())")

// Check without prompting
let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
print("  - AXIsProcessTrustedWithOptions(prompt: false): \(AXIsProcessTrustedWithOptions(options))")
print("")

// Get list of trusted apps if possible
print("Checking TCC database (may require admin):")
let tccPath = NSHomeDirectory() + "/Library/Application Support/com.apple.TCC/TCC.db"
if FileManager.default.fileExists(atPath: tccPath) {
    print("  - TCC database exists at: \(tccPath)")
} else {
    print("  - TCC database not found at expected location")
}

print("")
print("Recommendations:")
print("1. If running from Xcode, try running the built app directly from:")
print("   /Users/orion/Library/Developer/Xcode/DerivedData/WhisperKey-*/Build/Products/Debug/WhisperKey.app")
print("2. Make sure the app is code-signed (even with ad-hoc signature)")
print("3. Check System Settings > Privacy & Security > Accessibility")
print("4. Look for 'com.whisperkey.WhisperKey' in the list")
print("")

// Try to prompt for permission if not trusted
if !AXIsProcessTrusted() {
    print("Would you like to request accessibility permission? (y/n)")
    if let response = readLine(), response.lowercased() == "y" {
        let promptOptions: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let _ = AXIsProcessTrustedWithOptions(promptOptions)
        print("Permission dialog should have appeared. Please grant access and run this script again.")
    }
}