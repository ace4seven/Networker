// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Networker",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "Networker",
            targets: ["Networker"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.6.2")
    ],
    targets: [
        .target(
            name: "Networker",
            dependencies: [
                "Alamofire"
            ]),
        .testTarget(
            name: "NetworkerTests",
            dependencies: ["Networker"]),
    ]
)
