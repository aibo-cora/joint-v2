// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Joint",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Joint",
            targets: ["Joint"]),
    ],
    dependencies: [
        .package(url: "git@github.com:aibo-cora/MQTTClient-SPM.git", from: "0.15.3")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(name: "JointCore", path: "Sources/JointCore/JointCore.xcframework"),
        .target(
            name: "Joint",
            dependencies: [
                .target(name: "JointCore"),
                .product(name: "MQTTClient", package: "mqttclient-spm")
            ]
        ),
        .testTarget(
            name: "JointTests",
            dependencies: ["Joint", .product(name: "MQTTClient", package: "mqttclient-spm")]),
    ]
)
