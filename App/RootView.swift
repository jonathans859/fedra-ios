import FedraModel
import SwiftUI

/// Placeholder until sign-in lands (M3). It already follows the house rules:
/// semantic fonts, a real header, one clear element per piece of information.
struct RootView: View {
	var body: some View {
		NavigationStack {
			VStack(spacing: 16) {
				Text("Not signed in")
					.font(.title2)
					.accessibilityAddTraits(.isHeader)
				Text("Signing in to a Mastodon server comes in a later build.")
					.font(.body)
					.multilineTextAlignment(.center)
				Text(AppInfo.upstreamCredit)
					.font(.footnote)
					.foregroundStyle(.secondary)
					.multilineTextAlignment(.center)
			}
			.padding()
			.navigationTitle(AppInfo.displayName)
		}
	}
}

#Preview {
	RootView()
}
