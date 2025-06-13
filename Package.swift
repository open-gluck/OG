// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OG",
    platforms: [
        .iOS("17.0"),
        .watchOS("10.0"),
        .macOS("15.0"),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "OG",
            targets: ["OG"]
        ),
        .library(
            name: "OGUI",
            targets: ["OGUI"]
        ),
        .executable(
            name: "cli",
            targets: ["CLI"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "OG"),
        .testTarget(
            name: "OGTests",
            dependencies: ["OG"]
        ),
        .testTarget(
            name: "SwiftUI"
        ),
        .target(
            name: "OGUI",
            dependencies: ["OG"]
        ),
        .testTarget(
            name: "OGUITests",
            dependencies: ["SwiftUI", "OGUI"]
        ),
        .executableTarget(
            name: "CLI",
            dependencies: ["SwiftUI", "OG"]
        ),
    ]
)
