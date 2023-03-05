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
			targets: [
				"FireSpotter", "FBLPromises", "FirebaseAnalytics", "FirebaseAnalyticsSwift", "FirebaseCore", "FirebaseCoreInternal", "FirebaseInstallations", "GoogleAppMeasurement", "GoogleAppMeasurementIdentitySupport", "GoogleUtilities", "nanopb",
				
				"FirebaseAuth", "GTMSessionFetcher",
				
				"FirebaseCrashlytics", "FirebaseSessions", "GoogleDataTransport", "PromisesSwift",
				
				"abseil", "BoringSSL-GRPC", "FirebaseCoreExtension", "FirebaseFirestore", "FirebaseFirestoreSwift", "FirebaseSharedSwift", "gRPC-C++", "gRPC-Core", "leveldb-library", "Libuv-gRPC"
			]),
	],
	dependencies: [
		// Dependencies declare other packages that this package depends on.
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages which this package depends on.
		.target(name: "FireSpotter", dependencies: [], resources: [
			.copy("info.plist"),
			.copy("roots.pem"),
		]),
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
		
		.binaryTarget(name: "FirebaseAuth", path: "Frameworks/FirebaseAuth/FirebaseAuth.xcframework"),
		.binaryTarget(name: "GTMSessionFetcher", path: "Frameworks/FirebaseAuth/GTMSessionFetcher.xcframework"),
		
		.binaryTarget(name: "FirebaseCrashlytics", path: "Frameworks/FirebaseCrashlytics/FirebaseCrashlytics.xcframework"),
		.binaryTarget(name: "FirebaseSessions", path: "Frameworks/FirebaseCrashlytics/FirebaseSessions.xcframework"),
		.binaryTarget(name: "GoogleDataTransport", path: "Frameworks/FirebaseCrashlytics/GoogleDataTransport.xcframework"),
		.binaryTarget(name: "PromisesSwift", path: "Frameworks/FirebaseCrashlytics/PromisesSwift.xcframework"),
		
		.binaryTarget(name: "abseil", path: "Frameworks/FirebaseFireStore/abseil.xcframework"),
		.binaryTarget(name: "BoringSSL-GRPC", path: "Frameworks/FirebaseFireStore/BoringSSL-GRPC.xcframework"),
		.binaryTarget(name: "FirebaseCoreExtension", path: "Frameworks/FirebaseFireStore/FirebaseCoreExtension.xcframework"),
		.binaryTarget(name: "FirebaseFirestore", path: "Frameworks/FirebaseFireStore/FirebaseFirestore.xcframework"),
		.binaryTarget(name: "FirebaseFirestoreSwift", path: "Frameworks/FirebaseFireStore/FirebaseFirestoreSwift.xcframework"),
		.binaryTarget(name: "FirebaseSharedSwift", path: "Frameworks/FirebaseFireStore/FirebaseSharedSwift.xcframework"),
		.binaryTarget(name: "gRPC-C++", path: "Frameworks/FirebaseFireStore/gRPC-C++.xcframework"),
		.binaryTarget(name: "gRPC-Core", path: "Frameworks/FirebaseFireStore/gRPC-Core.xcframework"),
		.binaryTarget(name: "leveldb-library", path: "Frameworks/FirebaseFireStore/leveldb-library.xcframework"),
		.binaryTarget(name: "Libuv-gRPC", path: "Frameworks/FirebaseFireStore/Libuv-gRPC.xcframework"),
	]
)
