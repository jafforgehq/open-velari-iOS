import SwiftUI

struct SourcePill: View {
    let source: Source

    var body: some View {
        Link(destination: URL(string: source.url) ?? URL(string: "https://example.com")!) {
            Text(source.publisher)
                .font(.caption2)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(VelariColors.primary.opacity(0.1))
                .foregroundStyle(VelariColors.primary)
                .clipShape(Capsule())
        }
        .accessibilityLabel("Source: \(source.publisher)")
        .accessibilityHint("Opens in browser")
    }
}
