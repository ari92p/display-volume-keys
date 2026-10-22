// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "DisplayVolumeKeys",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .executable(name: "DisplayVolumeKeys", targets: ["DisplayVolumeKeys"]),
    .executable(
      name: "DisplayVolumeKeysVerification",
      targets: ["DisplayVolumeKeysVerification"]
    ),
  ],
  targets: [
    .target(name: "DisplayVolumeKeysCore", path: "Sources/DisplayVolumeKeys"),
    .executableTarget(
      name: "DisplayVolumeKeys",
      dependencies: ["DisplayVolumeKeysCore"],
      path: "Sources/DisplayVolumeKeysApp"
    ),
    .executableTarget(
      name: "DisplayVolumeKeysVerification",
      dependencies: ["DisplayVolumeKeysCore"],
      path: "Sources/DisplayVolumeKeysVerification"
    ),
    .testTarget(
      name: "DisplayVolumeKeysTests",
      dependencies: ["DisplayVolumeKeysCore"],
      path: "Tests/DisplayVolumeKeysTests"
    ),
  ],
  swiftLanguageModes: [.v5]
)
