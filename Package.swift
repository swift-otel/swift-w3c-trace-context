// swift-tools-version:6.2
import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),

    // https://forums.swift.org/t/experimental-support-for-lifetime-dependencies-in-swift-6-2-and-beyond/78638
    .enableExperimentalFeature("Lifetimes"),
]

let package = Package(
    name: "swift-w3c-trace-context",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(name: "W3CTraceContext", targets: ["W3CTraceContext"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "W3CTraceContext",
            dependencies: [
                .product(name: "OrderedCollections", package: "swift-collections")
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
