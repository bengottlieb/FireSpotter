// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "FireSpotter",
	platforms: [
		.macOS(.v14),
		.iOS(.v17),
		.watchOS(.v10)
	],
	products: [
		// Products define the executables and libraries produced by a package, and make them visible to other packages.
		.library(
			name: "FireSpotter",
			targets: [
				"FireSpotter",
				
				"FBLPromises", "FirebaseAnalytics", "FirebaseCore", "FirebaseCoreInternal", "FirebaseInstallations", "GoogleAppMeasurement", "GoogleAppMeasurementIdentitySupport", "GoogleUtilities", "nanopb",
				
				"FirebaseAuth", "RecaptchaInterop", "GTMSessionFetcher",
				
				"FirebaseCrashlytics", "FirebaseRemoteConfigInterop", "FirebaseSessions", "GoogleDataTransport", "Promises",
				
				"absl", "FirebaseFirestore", "FirebaseFirestoreInternal", "FirebaseSharedSwift", "grpc", "grpcpp", "leveldb", "openssl_grpc",
				
				"FirebaseAppCheckInterop", "FirebaseAuthInterop", "FirebaseStorage",
				
				"FirebaseDatabase",
				
				"FirebaseVertexAI",
				
				"FirebaseMessaging"
				
			]),
	],
	dependencies: [
		.package(url: "https://github.com/ios-tooling/suite", from: "1.2.11"),
		.package(url: "https://github.com/ios-tooling/journalist", from: "1.0.12"),
		.package(url: "https://github.com/ios-tooling/crossplatformkit", from: "1.0.13"),
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages which this package depends on.
		.target(name: "FireSpotter", dependencies: [
			.product(name: "Suite", package: "Suite"),
			.product(name: "Journalist", package: "Journalist"),
			.product(name: "CrossPlatformKit", package: "CrossPlatformKit"),
		], resources: [
			.copy("Resources/info.plist"),
			.copy("Resources/roots.pem"),
		]),
		.binaryTarget(name: "FBLPromises", path: "Frameworks/FirebaseAnalytics/FBLPromises.xcframework"),
		.binaryTarget(name: "FirebaseAnalytics", path: "Frameworks/FirebaseAnalytics/FirebaseAnalytics.xcframework"),
		.binaryTarget(name: "FirebaseCore", path: "Frameworks/FirebaseAnalytics/FirebaseCore.xcframework"),
		.binaryTarget(name: "FirebaseCoreInternal", path: "Frameworks/FirebaseAnalytics/FirebaseCoreInternal.xcframework"),
		.binaryTarget(name: "FirebaseInstallations", path: "Frameworks/FirebaseAnalytics/FirebaseInstallations.xcframework"),
		.binaryTarget(name: "GoogleAppMeasurement", path: "Frameworks/FirebaseAnalytics/GoogleAppMeasurement.xcframework"),
		.binaryTarget(name: "GoogleAppMeasurementIdentitySupport", path: "Frameworks/FirebaseAnalytics/GoogleAppMeasurementIdentitySupport.xcframework"),
		.binaryTarget(name: "GoogleUtilities", path: "Frameworks/FirebaseAnalytics/GoogleUtilities.xcframework"),
		.binaryTarget(name: "nanopb", path: "Frameworks/FirebaseAnalytics/nanopb.xcframework"),
		
		.binaryTarget(name: "FirebaseAuth", path: "Frameworks/FirebaseAuth/FirebaseAuth.xcframework"),
		.binaryTarget(name: "RecaptchaInterop", path: "Frameworks/FirebaseAuth/RecaptchaInterop.xcframework"),
		.binaryTarget(name: "GTMSessionFetcher", path: "Frameworks/FirebaseAuth/GTMSessionFetcher.xcframework"),
		
		.binaryTarget(name: "FirebaseCrashlytics", path: "Frameworks/FirebaseCrashlytics/FirebaseCrashlytics.xcframework"),
		.binaryTarget(name: "FirebaseSessions", path: "Frameworks/FirebaseCrashlytics/FirebaseSessions.xcframework"),
		.binaryTarget(name: "FirebaseRemoteConfigInterop", path: "Frameworks/FirebaseCrashlytics/FirebaseRemoteConfigInterop.xcframework"),
		.binaryTarget(name: "GoogleDataTransport", path: "Frameworks/FirebaseCrashlytics/GoogleDataTransport.xcframework"),
		.binaryTarget(name: "Promises", path: "Frameworks/FirebaseCrashlytics/Promises.xcframework"),
		
		.binaryTarget(name: "absl", path: "Frameworks/FirebaseFireStore/absl.xcframework"),
		.binaryTarget(name: "FirebaseFirestore", path: "Frameworks/FirebaseFireStore/FirebaseFirestore.xcframework"),
		.binaryTarget(name: "FirebaseFirestoreInternal", path: "Frameworks/FirebaseFireStore/FirebaseFirestoreInternal.xcframework"),
		.binaryTarget(name: "FirebaseSharedSwift", path: "Frameworks/FirebaseFireStore/FirebaseSharedSwift.xcframework"),
		.binaryTarget(name: "grpc", path: "Frameworks/FirebaseFireStore/grpc.xcframework"),
		.binaryTarget(name: "grpcpp", path: "Frameworks/FirebaseFireStore/grpcpp.xcframework"),
		.binaryTarget(name: "leveldb", path: "Frameworks/FirebaseFireStore/leveldb.xcframework"),
		.binaryTarget(name: "openssl_grpc", path: "Frameworks/FirebaseFireStore/openssl_grpc.xcframework"),

		.binaryTarget(name: "FirebaseAppCheckInterop", path: "Frameworks/FirebaseStorage/FirebaseAppCheckInterop.xcframework"),
		.binaryTarget(name: "FirebaseAuthInterop", path: "Frameworks/FirebaseStorage/FirebaseAuthInterop.xcframework"),
		.binaryTarget(name: "FirebaseStorage", path: "Frameworks/FirebaseStorage/FirebaseStorage.xcframework"),

		.binaryTarget(name: "FirebaseDatabase", path: "Frameworks/FirebaseDatabase/FirebaseDatabase.xcframework"),

		.binaryTarget(name: "FirebaseVertexAI", path: "Frameworks/FirebaseVertexAI/FirebaseVertexAI.xcframework"),

		.binaryTarget(name: "FirebaseMessaging", path: "Frameworks/FirebaseMessaging/FirebaseMessaging.xcframework"),
	]
)
