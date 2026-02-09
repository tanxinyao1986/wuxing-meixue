//
//  FeatureAccessManager.swift
//  五行美学
//
//  功能访问控制管理器 - 管理免费版和会员版的功能差异
//

import Foundation
import SwiftUI
import Combine

@MainActor
class FeatureAccessManager: ObservableObject {
    static let shared = FeatureAccessManager()

    @Published var isPremium: Bool = false

    private var subscriptionVM: SubscriptionViewModel?
    private var cancellables = Set<AnyCancellable>()

    private init() {
        // 监听 StoreKitManager 购买状态变化，自动刷新会员状态
        StoreKitManager.shared.$purchasedProductIDs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] productIDs in
                guard let self else { return }
                if !productIDs.isEmpty {
                    self.isPremium = true
                }
            }
            .store(in: &cancellables)

        Task {
            await checkPremiumStatus()
        }
    }

    // MARK: - 检查会员状态

    func checkPremiumStatus() async {
        // 先检查 StoreKitManager 是否已有已购产品
        if !StoreKitManager.shared.purchasedProductIDs.isEmpty {
            isPremium = true
            return
        }
        if subscriptionVM == nil {
            subscriptionVM = SubscriptionViewModel()
        }
        await subscriptionVM?.checkSubscriptionStatus()
        isPremium = subscriptionVM?.isPremium ?? false
    }

    // MARK: - 月历访问控制

    /// 检查是否可以查看指定日期
    func canAccessDate(_ date: Date) -> Bool {
        if isPremium {
            return true
        }

        // 免费版：只能看今天和明天
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: today)!

        let targetDate = calendar.startOfDay(for: date)

        return targetDate >= today && targetDate < dayAfterTomorrow
    }

    /// 获取月历可访问的日期范围
    func accessibleDateRange() -> ClosedRange<Date>? {
        if isPremium {
            return nil // 无限制
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        return today...tomorrow
    }

    // MARK: - 模块访问控制

    /// 检查是否可以访问指定模块（使用 GuideModule）
    func canAccessModule(_ module: GuideModule) -> Bool {
        if isPremium {
            return true
        }

        // 免费版只能访问这两个模块
        return module == .dress || module == .anchor
    }

    /// 旧版枚举保留兼容（可选）
    enum ModuleType: String {
        case energyDressing = "能量着装"    // 免费
        case mindAnchor = "心念之锚"        // 免费
        case element = "五行"               // 付费
        case lucky = "宜忌"                 // 付费
        case timing = "时辰"                // 付费
    }

    /// 检查是否可以访问指定模块（旧版兼容）
    func canAccessModuleType(_ module: ModuleType) -> Bool {
        if isPremium {
            return true
        }

        return module == .energyDressing || module == .mindAnchor
    }

    /// 获取模块锁定信息
    func getModuleLockInfo(_ module: ModuleType) -> ModuleLockInfo {
        if canAccessModuleType(module) {
            return ModuleLockInfo(isLocked: false, reason: nil)
        } else {
            return ModuleLockInfo(
                isLocked: true,
                reason: String(localized: "订阅会员解锁所有模块")
            )
        }
    }

    // MARK: - 五行卡片访问控制

    /// 五行卡片详情是否可见
    var canViewElementCardDetails: Bool {
        return isPremium
    }

    // MARK: - 小组件访问控制

    /// 是否可以安装小组件
    var canInstallWidget: Bool {
        return isPremium
    }
}

// MARK: - 辅助模型

struct ModuleLockInfo {
    let isLocked: Bool
    let reason: String?
}
