// swift-tools-version:6.0
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "FormCraft",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "FormCraft",
            targets: ["FormCraft"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "602.0.0")
    ],
    targets: [
        .target(
            name: "FormCraft",
            dependencies: ["FormCraftMacros"],
            resources: [.process("Resources")]
        ),
        .macro(
            name: "FormCraftMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "FormCraftTests",
            dependencies: ["FormCraft"]
        ),
    ]
)
