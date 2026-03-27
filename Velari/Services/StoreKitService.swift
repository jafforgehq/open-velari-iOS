import StoreKit

@Observable
final class StoreKitService {
    static let shared = StoreKitService()

    private let productIds = [
        "com.velari.tip.small",
        "com.velari.tip.medium",
        "com.velari.tip.large"
    ]

    var products: [Product] = []
    var purchaseState: PurchaseState = .idle
    private var updateTask: Task<Void, Never>?

    enum PurchaseState: Equatable {
        case idle
        case purchasing
        case success
        case failed(String)
    }

    init() {
        updateTask = Task {
            await listenForTransactions()
        }
    }

    deinit {
        updateTask?.cancel()
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: productIds)
                .sorted { $0.price < $1.price }
        } catch {
            products = []
        }
    }

    func purchase(_ product: Product) async {
        purchaseState = .purchasing
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                purchaseState = .success
            case .userCancelled:
                purchaseState = .idle
            case .pending:
                purchaseState = .idle
            @unknown default:
                purchaseState = .idle
            }
        } catch {
            purchaseState = .failed(error.localizedDescription)
        }
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            if let transaction = try? checkVerified(result) {
                await transaction.finish()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.unverified
        case .verified(let value):
            return value
        }
    }
}

enum StoreError: LocalizedError {
    case unverified

    var errorDescription: String? {
        "Transaction could not be verified"
    }
}
