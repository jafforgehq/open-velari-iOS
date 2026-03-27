import SwiftUI

struct ShimmerView: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(0..<3, id: \.self) { _ in
                shimmerCard
            }
        }
        .padding()
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }

    private var shimmerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                shimmerRect(width: 50, height: 20)
                shimmerRect(width: 80, height: 20)
                Spacer()
                shimmerRect(width: 60, height: 16)
            }
            shimmerRect(height: 20)
            shimmerRect(width: 250, height: 16)
            shimmerRect(height: 14)
            shimmerRect(width: 200, height: 14)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }

    private func shimmerRect(width: CGFloat? = nil, height: CGFloat = 16) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(shimmerGradient)
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: .leading)
    }

    private var shimmerGradient: some ShapeStyle {
        LinearGradient(
            colors: [
                Color(.systemGray5),
                Color(.systemGray4),
                Color(.systemGray5)
            ],
            startPoint: .init(x: phase - 1, y: 0.5),
            endPoint: .init(x: phase, y: 0.5)
        )
    }
}
