// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ZhiWei",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "ZhiWei", targets: ["ZhiWei"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ZhiWei",
            path: "Sources/ZhiWei",
            exclude: ["App/ZhiWeiApp.swift"]
        ),
        .testTarget(
            name: "ZhiWeiTests",
            dependencies: ["ZhiWei"],
            path: "Tests/ZhiWeiTests"
        ),
    ]
)
