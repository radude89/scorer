// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Site",
    products: [
        .executable(name: "Site", targets: ["Site"])
    ],
    dependencies: [
        .package(url: "https://github.com/johnsundell/publish.git", from: "0.3.0")
    ],
    targets: [
        .target(
            name: "Site",
            dependencies: ["Publish"]
        )
    ]
)