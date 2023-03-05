// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FireSpotter",
     platforms: [
              .macOS(.v13),
              .iOS(.v16),
              .watchOS(.v8)
         ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "FireSpotter",
            targets: ["FireSpotter", "FBLPromises", "FirebaseAnalytics", "FirebaseAnalyticsSwift", "FirebaseCore", "FirebaseCoreInternal", "FirebaseInstallations", "GoogleAppMeasurement", "GoogleAppMeasurementIdentitySupport", "GoogleUtilities", "nanopb"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "FireSpotter", dependencies: []),
		  .binaryTarget(name: "FBLPromises", path: "Frameworks/FirebaseAnalytics/FBLPromises.xcframework"),
		  .binaryTarget(name: "FirebaseAnalytics", path: "Frameworks/FirebaseAnalytics/FirebaseAnalytics.xcframework"),
		  .binaryTarget(name: "FirebaseAnalyticsSwift", path: "Frameworks/FirebaseAnalytics/FirebaseAnalyticsSwift.xcframework"),
		  .binaryTarget(name: "FirebaseCore", path: "Frameworks/FirebaseAnalytics/FirebaseCore.xcframework"),
		  .binaryTarget(name: "FirebaseCoreInternal", path: "Frameworks/FirebaseAnalytics/FirebaseCoreInternal.xcframework"),
		  .binaryTarget(name: "FirebaseInstallations", path: "Frameworks/FirebaseAnalytics/FirebaseInstallations.xcframework"),
		  .binaryTarget(name: "GoogleAppMeasurement", path: "Frameworks/FirebaseAnalytics/GoogleAppMeasurement.xcframework"),
		  .binaryTarget(name: "GoogleAppMeasurementIdentitySupport", path: "Frameworks/FirebaseAnalytics/GoogleAppMeasurementIdentitySupport.xcframework"),
		  .binaryTarget(name: "GoogleUtilities", path: "Frameworks/FirebaseAnalytics/GoogleUtilities.xcframework"),
		  .binaryTarget(name: "nanopb", path: "Frameworks/FirebaseAnalytics/nanopb.xcframework"),
    ]
)
