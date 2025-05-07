// swift-tools-version:5.9

import PackageDescription

let package = Package(
  name: "ShokumemoAPI",
  platforms: [
    .iOS(.v12),
    .macOS(.v10_14),
    .tvOS(.v12),
    .watchOS(.v5),
  ],
  products: [
    .library(name: "ShokumemoAPI", targets: ["ShokumemoAPI"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apollographql/apollo-ios", exact: "1.21.0"),
  ],
  targets: [
    .target(
      name: "ShokumemoAPI",
      dependencies: [
        .product(name: "ApolloAPI", package: "apollo-ios"),
      ],
      path: "./Sources"
    ),
  ]
)
