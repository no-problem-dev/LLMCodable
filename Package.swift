// swift-tools-version: 6.2

import PackageDescription
import CompilerPluginSupport

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
        // Core library
        .library(
            name: "LLMCodable",
            targets: ["LLMCodable"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", .upToNextMajor(from: "600.0.0")),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", .upToNextMajor(from: "1.4.0")),
    ],
    targets: [
        // MARK: - Core Library
        .target(
            name: "LLMCodable",
            dependencies: ["LLMCodableMacros"],
            path: "Sources/LLMCodable"
        ),

        // MARK: - Macros
        .macro(
            name: "LLMCodableMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            path: "Sources/LLMCodableMacros"
        ),

        // MARK: - Tests
        .testTarget(
            name: "LLMCodableTests",
            dependencies: ["LLMCodable"]
        ),
        .testTarget(
            name: "LLMCodableMacrosTests",
            dependencies: [
                "LLMCodableMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
