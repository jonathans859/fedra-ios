/// Facts about the app that more than one place needs.
///
/// The public name isn't decided yet (see PLAN.md), so every user-facing mention
/// of it goes through `displayName` instead of a literal.
public enum AppInfo {
	/// Working name, shown on the home screen and in the UI.
	public static let displayName = "Fedra"

	/// Credit required by the MIT licence of the Rust core we build on.
	public static let upstreamCredit = "Based on Fedra by Quin Gillespie and Aryan Choudhary."
}
