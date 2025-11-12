// swift-tools-version:6.0
import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
]

let package = Package(
    name: "swift-w3c-trace-context",
    products: [
        .library(name: "W3CTraceContext", targets: ["W3CTraceContext"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "W3CTraceContext",
            dependencies: [
                .product(name: "OrderedCollections", package: "swift-collections"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "W3CTraceContextTests",
            dependencies: [.target(name: "W3CTraceContext")],
            swiftSettings: swiftSettings
        ),
    ]
)
