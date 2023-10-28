// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OG",
    platforms: [
        .iOS("16.0"),
        .watchOS("9.1"),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "OG",
            targets: ["OG"]
        ),
        .library(
            name: "DiablyLib",
            targets: ["DiablyLib"]
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
            name: "DiablyLib",
            dependencies: ["OG"]
        ),
        .testTarget(
            name: "DiablyLibTests",
            dependencies: ["SwiftUI", "DiablyLib"]
        ),
        .executableTarget(
            name: "CLI",
            dependencies: ["SwiftUI", "OG"]
        ),
    ]
)
