import SwiftUI
import StoreKit

struct TipJarView: View {
    @State private var storeKit = StoreKitService.shared

    private let tipInfo: [(id: String, emoji: String, label: String)] = [
        ("com.velari.tip.small", "\u{2615}", "Small Tip"),
        ("com.velari.tip.medium", "\u{1F355}", "Medium Tip"),
        ("com.velari.tip.large", "\u{1F680}", "Large Tip"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Support Velari")
                .font(.headline)

            Text("Velari is free and open. Tips help keep the project going.")
                .font(.caption)
                .foregroundStyle(.secondary)

            if storeKit.products.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding()
                    Spacer()
                }
            } else {
                ForEach(storeKit.products, id: \.id) { product in
                    tipButton(product)
                }
            }

            if storeKit.purchaseState == .success {
                Label("Thank you for your support!", systemImage: "heart.fill")
                    .font(.subheadline)
                    .foregroundStyle(VelariColors.primary)
                    .transition(.scale.combined(with: .opacity))
            }

            if case .failed(let message) = storeKit.purchaseState {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .animation(.spring, value: storeKit.purchaseState)
        .task {
            await storeKit.loadProducts()
        }
    }

    private func tipButton(_ product: Product) -> some View {
        let info = tipInfo.first { $0.id == product.id }

        return Button {
            Task { await storeKit.purchase(product) }
        } label: {
            HStack {
                Text(info?.emoji ?? "\u{1F381}")
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(info?.label ?? product.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(product.displayPrice)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if storeKit.purchaseState == .purchasing {
                    ProgressView()
                } else {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(VelariColors.primary)
                }
            }
            .padding(12)
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .disabled(storeKit.purchaseState == .purchasing)
    }
}
