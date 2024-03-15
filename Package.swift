// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CSVReader",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "CSVReader",
            targets: ["CSVReader"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "CSVReader",
            dependencies: []),
        .testTarget(
            name: "CSVReaderTests",
            dependencies: ["CSVReader"],
            resources: [
                .copy("csv")
            ]),
    ]
)
