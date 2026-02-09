//
//  PaywallView.swift
//  五行美学
//
//  付费墙视图
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject private var storeManager = StoreKitManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var selectedProduct: PurchaseProduct?
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景渐变
                LinearGradient(
                    colors: [Color(hex: "1a1a2e"), Color(hex: "16213e")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 30) {
                        // 顶部标题
                        headerView

                        // 功能列表
                        featuresView

                        // 产品列表
                        if storeManager.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            productsView
                        }

                        // 购买按钮
                        purchaseButton

                        // 底部链接
                        footerLinks
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
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
                .foregroundColor(.white)

            Text("开启五行智慧之旅")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.top, 20)
    }

    private var featuresView: some View {
        VStack(alignment: .leading, spacing: 16) {
            FeatureRow(icon: "calendar", title: "完整日历", description: "查看全年五行节律")
            FeatureRow(icon: "book.fill", title: "深度解读", description: "获取详细的五行指导")
            FeatureRow(icon: "square.grid.2x2.fill", title: "桌面小组件", description: "精美便捷的桌面小组件")
            FeatureRow(icon: "icloud.fill", title: "多设备同步", description: "iCloud 自动同步")
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }

    /// 产品排序：月度 → 年度 → 终身
    private var sortedProducts: [PurchaseProduct] {
        let order: [PurchaseProductType] = [.monthly, .yearly, .lifetime]
        return storeManager.products.sorted { a, b in
            (order.firstIndex(of: a.type) ?? 0) < (order.firstIndex(of: b.type) ?? 0)
        }
    }

    private var productsView: some View {
        VStack(spacing: 12) {
            ForEach(sortedProducts) { product in
                ProductCard(
                    product: product,
                    isSelected: selectedProduct?.id == product.id
                ) {
                    selectedProduct = product
                }
            }
        }
    }

    private var purchaseButton: some View {
        Button {
            Task {
                await handlePurchase()
            }
        } label: {
            HStack {
                if isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("立即订阅")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(16)
        }
        .disabled(selectedProduct == nil || isPurchasing)
        .opacity(selectedProduct == nil ? 0.5 : 1)
    }

    private var footerLinks: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await storeManager.restorePurchases()
                }
            } label: {
                Text("恢复购买")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
            }

            HStack(spacing: 20) {
                Link("隐私政策", destination: URL(string: "https://yourwebsite.com/privacy")!)
                Text("·")
                Link("使用条款", destination: URL(string: "https://yourwebsite.com/terms")!)
            }
            .font(.caption)
            .foregroundColor(.white.opacity(0.5))
        }
        .padding(.bottom, 20)
    }

    // MARK: - 方法

    private func handlePurchase() async {
        guard let selected = selectedProduct else { return }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let transaction = try await storeManager.purchase(selected.product)
            if transaction != nil {
                // 刷新会员状态
                await FeatureAccessManager.shared.checkPremiumStatus()
                // 显示中文成功提示
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
                .foregroundColor(.yellow)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()
        }
    }
}

// MARK: - 产品卡片组件

struct ProductCard: View {
    let product: PurchaseProduct
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(product.localizedDisplayName)
                            .font(.headline)

                        if product.type == .yearly {
                            Text("最划算")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                    }

                    Text(product.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(product.price)
                        .font(.title3.bold())

                    if product.type == .monthly {
                        Text("每月")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    } else if product.type == .yearly {
                        Text("每年")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .green : .white.opacity(0.3))
            }
            .padding()
            .background(
                isSelected
                    ? Color.white.opacity(0.2)
                    : Color.white.opacity(0.1)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .foregroundColor(.white)
    }
}

#Preview {
    PaywallView()
}
