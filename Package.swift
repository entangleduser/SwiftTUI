// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "SwiftTUI",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "SwiftTUI",
            targets: ["SwiftTUI"]),
    ],
    dependencies: [
         .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SwiftTUI",
            dependencies: []),
        .testTarget(
            name: "SwiftTUITests",
            dependencies: ["SwiftTUI"]),
    ]
)

// add OpenCombine for frameworks that depend on Combine functionality
package.dependencies.append(
 .package(url: "https://github.com/OpenCombine/OpenCombine.git", from: "0.14.0")
)
for target in package.targets {
 if target.name == "SwiftTUI" {
  target.dependencies += [
   .product(
    name: "OpenCombine",
    package: "OpenCombine",
    condition: .when(platforms: [.wasi, .windows, .linux])
   )
  ]
  break
 }
}
