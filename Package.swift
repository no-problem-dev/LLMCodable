// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "LLMCodable",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "LLMCodable",
            targets: ["LLMCodable"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", .upToNextMajor(from: "1.4.0")),
    ],
    targets: [
        .target(
            name: "LLMCodable",
            path: "Sources/LLMCodable"
        ),
        .testTarget(
            name: "LLMCodableTests",
            dependencies: ["LLMCodable"]
        ),
    ]
)
