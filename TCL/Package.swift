// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VolumeGuard",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "VolumeGuard", targets: ["VolumeGuard"])],
    targets: [
        .target(name: "StorageProbe", publicHeadersPath: "include"),
        .executableTarget(name: "VolumeGuard", dependencies: ["StorageProbe"]),
        .testTarget(name: "VolumeGuardTests", dependencies: ["VolumeGuard"])
    ]
)
