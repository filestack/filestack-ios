// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Filestack",
    platforms: [.iOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Filestack",
            type: .dynamic,
            targets: ["Filestack"]
        ),
    ],
    dependencies: [
        .package(name: "FilestackSDK", url: "https://github.com/filestack/filestack-swift", .upToNextMajor(from: Version(2, 6, 0))),
        .package(url: "https://github.com/marmelroy/Zip", .upToNextMajor(from: Version(2, 1, 0)))
    ],
    targets: [
        .target(
            name: "Filestack",
            dependencies: ["FilestackSDK", "Zip"],
            exclude: ["Filestack.h", "Info.plist"],
            resources: [
                .copy("VERSION")
            ]
        )
    ]
)
