// swift-tools-version: 6.0
// FedraModel is pure Swift: view models, settings and formatting. It talks to the
// Rust core only through protocols, so it builds and tests with plain SwiftPM on
// Windows and Linux (see CLAUDE.md). FedraCore (the UniFFI bindings plus the
// XCFramework) is added in M2 and builds on macOS only.
import PackageDescription

let package = Package(
	name: "FedraKit",
	platforms: [
		.iOS(.v18),
		.macOS(.v15),
	],
	products: [
		.library(name: "FedraModel", targets: ["FedraModel"]),
	],
	targets: [
		.target(name: "FedraModel"),
		.testTarget(name: "FedraModelTests", dependencies: ["FedraModel"]),
	]
)
