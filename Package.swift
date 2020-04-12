// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FRIDAY",
    platforms: [.iOS(.v10)],
    products: [
        .library(
            name: "FRIDAY",
            targets: ["FRIDAY"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.1.0")
    ],
    targets: [
       
        .target(
            name: "FRIDAY",
            dependencies: ["Alamofire"]),
    ],
    swiftLanguageVersions: [.v5]
)
