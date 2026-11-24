import Testing
@testable import FedraModel

@Test func displayNameIsNotEmpty() {
	#expect(!AppInfo.displayName.isEmpty)
}

@Test func creditNamesUpstreamAuthors() {
	#expect(AppInfo.upstreamCredit.contains("Quin Gillespie"))
	#expect(AppInfo.upstreamCredit.contains("Aryan Choudhary"))
}
