// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "MomoPetApp",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "MomoPetApp", targets: ["MomoPetApp"])
    ],
    targets: [
        .executableTarget(
            name: "MomoPetApp",
            resources: [.process("Resources")]
        ),
        .testTarget(name: "MomoPetAppTests", dependencies: ["MomoPetApp"])
    ]
)
