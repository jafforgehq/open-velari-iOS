import SwiftUI

struct DisclaimerBanner: View {
    var text: String = "AI-curated digest. Verify claims with original sources."

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "info.circle")
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
    }
}
