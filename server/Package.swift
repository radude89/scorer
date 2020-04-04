// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "ScorerServer",
    products: [
        .library(name: "ScorerServer", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        .package(url: "https://github.com/JohnSundell/Files.git", from: "4.0.0"),
        .package(path: "../ios/ScorerFoundation")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor", "ScorerFoundation", "Files"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
