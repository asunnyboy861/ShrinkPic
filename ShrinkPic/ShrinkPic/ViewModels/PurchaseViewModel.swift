import SwiftUI
import StoreKit

@Observable
@MainActor
class PurchaseViewModel {

    var isProUser: Bool = false
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var showPaywall: Bool = false

    private let productID = "com.zzoutuo.ShrinkPic.pro"
    private var product: Product?
    private var transactionListener: Task<Void, Never>?

    var productPrice: String {
        product?.displayPrice ?? "$2.99"
    }

    init() {
        transactionListener = startTransactionListener()
        Task {
            await loadProduct()
            await checkPurchased()
        }
    }

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [productID])
            product = products.first
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func checkPurchased() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == productID {
                    isProUser = transaction.revocationDate == nil
                    return
                }
            }
        }
        isProUser = false
    }

    func purchase() async {
        guard let product = product else { return }
        isLoading = true
        errorMessage = nil

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    isProUser = true
                    await transaction.finish()
                }
            case .userCancelled:
                break
            case .pending:
                errorMessage = "Purchase is pending approval."
            @unknown default:
                errorMessage = "Unknown purchase result."
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func restorePurchases() async {
        isLoading = true
        do {
            try await AppStore.sync()
            await checkPurchased()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func startTransactionListener() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    self?.isProUser = true
                }
            }
        }
    }
}
