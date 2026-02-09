//
//  PurchaseProduct.swift
//  五行美学
//
//  应用内购买产品模型
//

import Foundation
import StoreKit

/// 购买产品类型
enum PurchaseProductType: String, Codable {
    case monthly = "monthly_subscription"
    case yearly = "yearly_subscription"
    case lifetime = "lifetime_purchase"
}

/// 产品信息模型
struct PurchaseProduct: Identifiable {
    let id: String
    let type: PurchaseProductType
    let product: Product

    var displayName: String {
        product.displayName
    }

    /// 本地化显示名称（覆盖 StoreKit 的 displayName，确保多语言正确）
    var localizedDisplayName: String {
        switch type {
        case .monthly:  return String(localized: "月度会员")
        case .yearly:   return String(localized: "年度会员")
        case .lifetime: return String(localized: "终身会员")
        }
    }

    /// 本地化描述
    var localizedDescription: String {
        switch type {
        case .monthly:  return String(localized: "解锁全部功能，每月自动续费。")
        case .yearly:   return String(localized: "每月仅3元")
        case .lifetime: return String(localized: "所有五行节律功能")
        }
    }

    var description: String {
        product.description
    }

    var price: String {
        product.displayPrice
    }

    var localizedPrice: Decimal {
        product.price
    }
}

/// 用户订阅状态
struct SubscriptionStatus: Codable {
    let userId: String
    let productId: String
    let purchaseDate: Date
    let expirationDate: Date?
    let isActive: Bool
    let transactionId: String

    var isExpired: Bool {
        guard let expiration = expirationDate else {
            return false // 终身购买永不过期
        }
        return expiration < Date()
    }
}
