// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if !os(Linux)
    let targets: [Target] = [
        .target(
            name: "OG"),
        .testTarget(
            name: "OGTests",
            dependencies: ["OG"]
        ),
        .target(
            name: "OGUI",
            dependencies: ["OG"]
        ),
        .testTarget(
            name: "OGUITests",
            dependencies: ["OGUI"]
        ),
        .executableTarget(
            name: "CLI",
            dependencies: ["OG"]
        ),
    ]
#else
    let targets: [Target] = [
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
#endif

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
    targets: targets
)
