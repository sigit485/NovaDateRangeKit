// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CalendarDateRangePicker",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "CalendarDateRangePicker",
            targets: ["CalendarDateRangePicker"]
        )
    ],
    targets: [
        .target(
            name: "CalendarDateRangePicker",
            path: "Sources/CalendarDateRangePicker"
        ),
        .testTarget(
            name: "CalendarDateRangePickerTests",
            dependencies: ["CalendarDateRangePicker"],
            path: "Tests/CalendarDateRangePickerTests"
        )
    ]
)
