// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QRGifKit",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "QRGifKit",
            targets: ["QRGifKit"]),
    ],
    dependencies: [
        // Add any external dependencies here
    ],
    targets: [
        .target(
            name: "QRGifKit",
            dependencies: []),
        .testTarget(
            name: "QRGifKitTests",
            dependencies: ["QRGifKit"]),
    ]
)
