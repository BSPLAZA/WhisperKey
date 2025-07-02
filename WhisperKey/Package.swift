// swift-tools-version: 5.9
// This file helps Xcode resolve the HotKey package dependency

import PackageDescription

let package = Package(
    name: "WhisperKeyDependencies",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/soffes/HotKey", from: "0.2.0")
    ],
    targets: []
)