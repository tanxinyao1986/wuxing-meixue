//
//  StoreKitManager.swift
//  五行美学
//
//  StoreKit 2 购买管理器
//

import Foundation
import StoreKit
import Combine

@MainActor
class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()

    @Published var products: [PurchaseProduct] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false

    // App Store Connect 产品 ID
    private let productIDs: [String] = [
        "com.xinyao.wuxing.monthly",    // 月订阅
        "com.xinyao.wuxing.yearly",     // 年订阅
        "com.xinyao.wuxing.lifetime"    // 终身购买
    ]

    private var updates: Task<Void, Never>?

    init() {
        updates = observeTransactionUpdates()
    }

    deinit {
        updates?.cancel()
    }

    // MARK: - 加载产品

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let storeProducts = try await Product.products(for: productIDs)

            products = storeProducts.map { product in
                let type: PurchaseProductType
                if product.id.contains("monthly") {
                    type = .monthly
                } else if product.id.contains("yearly") {
                    type = .yearly
                } else {
                    type = .lifetime
                }
                return PurchaseProduct(id: product.id, type: type, product: product)
            }

            await updatePurchasedProducts()
        } catch {
            print("❌ 加载产品失败: \(error)")
        }
    }

    // MARK: - 购买产品

    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)

            // 保存到 Supabase
            await saveToSupabase(transaction: transaction, product: product)

            await transaction.finish()
            await updatePurchasedProducts()

            return transaction

        case .userCancelled:
            print("⚠️ 用户取消购买")
            return nil

        case .pending:
            print("⏳ 购买待处理（如家长批准）")
            return nil

        @unknown default:
            return nil
        }
    }

    // MARK: - 恢复购买

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            print("❌ 恢复购买失败: \(error)")
        }
    }

    // MARK: - 检查订阅状态

    func checkSubscriptionStatus() async -> Bool {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productType == .autoRenewable {
                    return true
                }
                if transaction.productType == .nonConsumable {
                    return true
                }
            }
        }
        return false
    }

    // MARK: - 私有方法

    private func updatePurchasedProducts() async {
        var purchased: Set<String> = []

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchased.insert(transaction.productID)
            }
        }

        purchasedProductIDs = purchased
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await self?.updatePurchasedProducts()
                    await FeatureAccessManager.shared.checkPremiumStatus()
                    await transaction.finish()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    private func saveToSupabase(transaction: Transaction, product: Product) async {
        // 构造订阅数据
        let deviceId = await getDeviceId()

        let subscriptionData: [String: Any] = [
            "device_id": deviceId,
            "product_id": transaction.productID,
            "transaction_id": String(transaction.id),
            "purchase_date": ISO8601DateFormatter().string(from: transaction.purchaseDate),
            "expiration_date": transaction.expirationDate.map { ISO8601DateFormatter().string(from: $0) } as Any,
            "is_active": true,
            "product_type": getProductType(product).rawValue
        ]

        await SupabaseManager.shared.saveSubscription(data: subscriptionData)
    }

    private func getDeviceId() async -> String {
        // 使用 iCloud 用户 ID 或生成唯一设备 ID
        if let iCloudID = FileManager.default.ubiquityIdentityToken {
            return iCloudID.description
        }

        // 如果没有 iCloud，使用 UserDefaults 保存的 UUID
        let key = "device_unique_id"
        if let saved = UserDefaults.standard.string(forKey: key) {
            return saved
        }

        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: key)
        return newId
    }

    private func getProductType(_ product: Product) -> PurchaseProductType {
        if product.id.contains("monthly") {
            return .monthly
        } else if product.id.contains("yearly") {
            return .yearly
        } else {
            return .lifetime
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
