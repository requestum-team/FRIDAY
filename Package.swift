// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FRIDAY",
    products: [
        
        .library(
            name: "FRIDAY",
            targets: ["FRIDAY"]),
    ],
    dependencies: [
         .package(url: "https://github.com/Alamofire/Alamofire.git", from: "4.0.0")
    ],
    targets: [
       
        .target(
            name: "FRIDAY",
            dependencies: ["Alamofire"]),
    ],
    swiftLanguageVersions: [.v4, .v5]
)
