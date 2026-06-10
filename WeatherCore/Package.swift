// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WeatherCore",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "WeatherCore",
            targets: ["WeatherCore"]),
    ],
    targets: [
        .target(
            name: "WeatherCore",
            dependencies: [],
            resources: [.process("Resources")]),
        .testTarget(
            name: "WeatherCoreTests",
            dependencies: ["WeatherCore"]),
    ],
    swiftLanguageModes: [.v5]
)
