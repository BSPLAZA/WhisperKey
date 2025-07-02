// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WhisperKey",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "WhisperKey", targets: ["WhisperKey"])
    ],
    dependencies: [
        .package(url: "https://github.com/soffes/HotKey", from: "0.2.0")
    ],
    targets: [
        .executableTarget(
            name: "WhisperKey",
            dependencies: [
                .product(name: "HotKey", package: "HotKey")
            ],
            path: "WhisperKey/WhisperKey"
        )
    ]
)