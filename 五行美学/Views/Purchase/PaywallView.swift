//
//  PaywallView.swift
//  五行美学
//
//  付费墙视图 - 使用 SubscriptionStoreView
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject private var storeManager = StoreKitManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var isPurchasingLifetime = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false

    // 订阅组 ID（来自 Configuration.storekit）
    private let subscriptionGroupID = "21542433"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 顶部标题
                    headerView

                    // Apple SubscriptionStoreView（自动续期订阅）
                    subscriptionSection

                    // 分割线
                    dividerView

                    // 终身会员（一次性购买，SubscriptionStoreView 不支持）
                    lifetimeSection

                    // 恢复购买
                    restoreButton
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await storeManager.loadProducts()
        }
        .alert("购买成功", isPresented: $showSuccess) {
            Button("好的") {
                dismiss()
            }
        } message: {
            Text("恭喜！你已成功解锁所有五行节律功能")
        }
        .alert("购买失败", isPresented: $showError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - 子视图

    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange, .red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("解锁完整体验")
                .font(.system(size: 28, weight: .bold))

            Text("开启五行智慧之旅")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }

    private var subscriptionSection: some View {
        SubscriptionStoreView(groupID: subscriptionGroupID) {
            // 自定义营销内容
            VStack(spacing: 16) {
                FeatureRow(icon: "calendar", title: "完整日历", description: "查看全年五行节律")
                FeatureRow(icon: "book.fill", title: "深度解读", description: "获取详细的五行指导")
                FeatureRow(icon: "square.grid.2x2.fill", title: "桌面小组件", description: "精美便捷的桌面小组件")
                FeatureRow(icon: "icloud.fill", title: "多设备同步", description: "iCloud 自动同步")
            }
            .padding()
        }
        .subscriptionStoreButtonLabel(.multiline)
        .storeButton(.visible, for: .restorePurchases)
        .subscriptionStorePolicyDestination(for: .privacyPolicy) {
            PrivacyPolicyView()
        }
        .subscriptionStorePolicyDestination(for: .termsOfService) {
            TermsOfUseView()
        }
        .onInAppPurchaseCompletion { _, result in
            switch result {
            case .success(.success(_)):
                await FeatureAccessManager.shared.checkPremiumStatus()
                showSuccess = true
            case .success(.pending):
                break
            case .success(.userCancelled):
                break
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            @unknown default:
                break
            }
        }
    }

    private var dividerView: some View {
        HStack {
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(height: 1)
            Text("或")
                .font(.footnote)
                .foregroundColor(.secondary)
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(height: 1)
        }
        .padding(.horizontal)
    }

    private var lifetimeSection: some View {
        VStack(spacing: 12) {
            if let lifetimeProduct = storeManager.products.first(where: { $0.type == .lifetime }) {
                VStack(spacing: 8) {
                    Text(lifetimeProduct.localizedDisplayName)
                        .font(.headline)

                    Text(lifetimeProduct.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(lifetimeProduct.price)
                        .font(.title2.bold())
                        .foregroundColor(.primary)

                    Button {
                        Task {
                            await handleLifetimePurchase(lifetimeProduct)
                        }
                    } label: {
                        HStack {
                            if isPurchasingLifetime {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("一次购买，终身使用")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isPurchasingLifetime)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .padding(.horizontal)
            }
        }
    }

    private var restoreButton: some View {
        Button {
            Task {
                await storeManager.restorePurchases()
                await FeatureAccessManager.shared.checkPremiumStatus()
            }
        } label: {
            Text("恢复购买")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 20)
    }

    // MARK: - 方法

    private func handleLifetimePurchase(_ product: PurchaseProduct) async {
        isPurchasingLifetime = true
        defer { isPurchasingLifetime = false }

        do {
            let transaction = try await storeManager.purchase(product.product)
            if transaction != nil {
                await FeatureAccessManager.shared.checkPremiumStatus()
                showSuccess = true
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - 功能行组件

struct FeatureRow: View {
    let icon: String
    let title: LocalizedStringKey
    let description: LocalizedStringKey

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

#Preview {
    PaywallView()
}
