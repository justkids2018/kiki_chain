// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KikiIos",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "KikiIos",
            targets: ["KikiIos"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "KikiIos",
            dependencies: [],
            path: "Sources",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ]
        )
    ]
)
