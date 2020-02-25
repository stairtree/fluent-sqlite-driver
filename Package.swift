// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "fluent-sqlite-driver",
    platforms: [
       .macOS(.v10_14)
    ],
    products: [
        .library(name: "FluentSQLiteDriver", targets: ["FluentSQLiteDriver"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent-kit.git", from: "1.0.0-beta.5"),
        .package(url: "https://github.com/vapor/sqlite-kit.git", from: "4.0.0-beta.2"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "FluentSQLiteDriver", dependencies: [
            "FluentKit",
            "FluentSQL",
            "Logging",
            "SQLiteKit",
        ]),
        .testTarget(name: "FluentSQLiteDriverTests", dependencies: [
            "FluentBenchmark",
            "FluentSQLiteDriver"
        ]),
    ]
)
