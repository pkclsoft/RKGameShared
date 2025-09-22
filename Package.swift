// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RKGameShared",
    platforms: [
        .macOS(.v12), .iOS(.v15), .tvOS(.v26)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "RKGameShared",
            targets: ["RKGameShared"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/pkclsoft/CGExtKit", from: "1.0.0"),
        .package(url: "https://github.com/pkclsoft/UXKit", from: "0.10.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "RKGameShared",
            dependencies:  ["CGExtKit", "UXKit"]
        ),
        .testTarget(
            name: "RKGameSharedTests",
            dependencies: ["RKGameShared"]
        ),
    ]
)
