// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NovaDateRangeKit",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "NovaDateRangeKit",
            targets: ["NovaDateRangeKit"]
        )
    ],
    targets: [
        .target(
            name: "NovaDateRangeKit",
            path: "Sources/NovaDateRangeKit"
        ),
        .testTarget(
            name: "NovaDateRangeKitTests",
            dependencies: ["NovaDateRangeKit"],
            path: "Tests/NovaDateRangeKitTests"
        )
    ]
)
