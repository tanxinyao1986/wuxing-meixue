//
//  SubscriptionViewModel.swift
//  五行美学
//
//  订阅状态管理 ViewModel
//

import Foundation
import SwiftUI
import StoreKit
import Combine

@MainActor
class SubscriptionViewModel: ObservableObject {
    @Published var isPremium = false
    @Published var subscriptionStatus: SubscriptionStatus?
    @Published var isLoading = false

    private let storeManager = StoreKitManager.shared

    init() {
        Task {
            await checkSubscriptionStatus()
        }
    }

    // MARK: - 检查订阅状态

    func checkSubscriptionStatus() async {
        isLoading = true
        defer { isLoading = false }

        // 1. 先检查本地 StoreKit 状态
        let hasActiveSubscription = await storeManager.checkSubscriptionStatus()

        if hasActiveSubscription {
            isPremium = true
            // 获取实际交易详情，填充订阅状态供设置页显示
            if let transaction = await storeManager.getActiveTransaction() {
                subscriptionStatus = SubscriptionStatus(
                    userId: "",
                    productId: transaction.productID,
                    purchaseDate: transaction.purchaseDate,
                    expirationDate: transaction.expirationDate,
                    isActive: true,
                    transactionId: String(transaction.id)
                )
            }
        } else {
            // 2. 如果本地没有，检查 Supabase（跨设备同步）
            await checkSupabaseStatus()
        }
    }

    private func checkSupabaseStatus() async {
        let deviceId = await getDeviceId()
        if let status = await SupabaseManager.shared.getSubscriptionStatus(deviceId: deviceId) {
            // 检查是否过期
            if !status.isExpired {
                isPremium = true
                subscriptionStatus = status
            } else {
                // 如果过期，更新 Supabase 状态
                await SupabaseManager.shared.updateSubscriptionStatus(
                    transactionId: status.transactionId,
                    isActive: false
                )
                isPremium = false
            }
        } else {
            isPremium = false
        }
    }

    private func getDeviceId() async -> String {
        if let iCloudID = FileManager.default.ubiquityIdentityToken {
            return iCloudID.description
        }

        let key = "device_unique_id"
        if let saved = UserDefaults.standard.string(forKey: key) {
            return saved
        }

        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: key)
        return newId
    }

    // MARK: - 格式化信息

    var expirationDateString: String? {
        guard let expirationDate = subscriptionStatus?.expirationDate else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .long
        return formatter.string(from: expirationDate)
    }

    var subscriptionTypeString: String {
        guard let productId = subscriptionStatus?.productId else {
            return String(localized: "未订阅")
        }

        if productId.contains("lifetime") {
            return String(localized: "终身会员")
        } else if productId.contains("yearly") {
            return String(localized: "年度会员")
        } else if productId.contains("monthly") {
            return String(localized: "月度会员")
        } else {
            return String(localized: "会员")
        }
    }
}
