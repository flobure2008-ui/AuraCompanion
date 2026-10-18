// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AuraCompanion",
    defaultLocalization: "fr",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AuraCompanion",
            targets: ["AuraCompanion"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AuraCompanion",
            dependencies: [],
            path: "AuraCompanion",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
