import SwiftUI

struct OnboardingPageView: View {
    let systemImage: String
    let title: String
    let description: String
    var imageColor: Color = VelariColors.primary

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: systemImage)
                .font(.system(size: 80))
                .foregroundStyle(imageColor)
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: 12) {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
        .padding()
    }
}
