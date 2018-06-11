// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyParse",
    products: [
        .library(name: "SwiftyParse", targets: ["SwiftyParse"]),
    ],
    dependencies: [

    ],
    targets: [
        .target(
            name: "SwiftyParse",
            dependencies: []),
    ]
)
