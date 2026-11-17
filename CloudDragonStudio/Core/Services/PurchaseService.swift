import Foundation
import StoreKit

@MainActor
final class PurchaseService: ObservableObject {
    static let premiumProductID = "com.clouddragonstudio.app.premium"

    @Published private(set) var premiumProduct: Product?
    @Published private(set) var isPremiumPurchased: Bool = false
    @Published private(set) var isPurchasing: Bool = false
    @Published var statusMessage: String?

    private var updatesTask: Task<Void, Never>?

    init(initialPremium: Bool = false) {
        self.isPremiumPurchased = initialPremium
        updatesTask = Task { [weak self] in
            for await verification in Transaction.updates {
                guard let self else { break }
                if case .verified(let transaction) = verification {
                    if transaction.productID == Self.premiumProductID {
                        self.isPremiumPurchased = true
                    }
                    await transaction.finish()
                }
            }
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProducts() async {
        do {
            let products = try await Product.products(for: [Self.premiumProductID])
            premiumProduct = products.first
            await refreshEntitlements()
        } catch {
            // Keep UI graceful offline or before StoreKit config attaches
        }
    }

    func refreshEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.premiumProductID {
                isPremiumPurchased = true
                return
            }
        }
    }

    @discardableResult
    func purchasePremium() async -> Bool {
        isPurchasing = true
        defer { isPurchasing = false }

        if premiumProduct == nil {
            await loadProducts()
        }

        guard let product = premiumProduct else {
            statusMessage = "StoreKit test product unavailable."
            return false
        }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    isPremiumPurchased = true
                    await transaction.finish()
                    return true
                }
                return false
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            statusMessage = error.localizedDescription
            return false
        }
    }

    func restorePurchases() async {
        isPurchasing = true
        defer { isPurchasing = false }
        try? await AppStore.sync()
        await refreshEntitlements()
    }
}
