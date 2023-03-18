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
        .library(name: "Joint", targets: ["Joint"]),
    ],
    dependencies: [
        .package(url: "https://github.com/aibo-cora/MQTTClient-SPM.git", from: "0.15.3")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(name: "JointCore", url: "https://github.com/aibo-cora/joint-v2/releases/download/0.6.1/JointCore.xcframework.zip", checksum: "8cf4b983af7c4b3b5e4fc7f7494b2f3a0951eefffe4a744f53b9f2106608a006"),
        .target(
            name: "Joint",
            dependencies: [.target(name: "JointCore"), .product(name: "MQTTClient", package: "mqttclient-spm")]
        ),
        .testTarget(
            name: "JointTests",
            dependencies: ["Joint", .product(name: "MQTTClient", package: "mqttclient-spm")]),
    ]
)
