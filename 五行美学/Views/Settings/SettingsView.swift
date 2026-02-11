//
//  SettingsView.swift
//  五行美学
//
//  设置页面 - 包含订阅管理
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var subscriptionVM = SubscriptionViewModel()
    @State private var showPaywall = false
    @State private var versionTapCount = 0
    @State private var showResetAlert = false
    @State private var showResetDone = false
    @State private var showContactAlert = false
    @State private var showPrivacyPolicy = false
    @State private var showSupport = false

    var body: some View {
        NavigationStack {
            List {
                // 订阅状态部分
                Section {
                    if subscriptionVM.isPremium {
                        premiumStatusView
                    } else {
                        freeStatusView
                    }
                } header: {
                    Text("会员状态")
                }

                // 通用设置
                Section {
                    Toggle("触觉反馈", isOn: .constant(true))
                    Toggle("通知提醒", isOn: .constant(false))
                } header: {
                    Text("通用")
                }

                // 关于部分
                Section {
                    Button("隐私政策") {
                        showPrivacyPolicy = true
                    }
                    Button("技术支持") {
                        showSupport = true
                    }
                    Button("联系我们") {
                        showContactAlert = true
                    }
                } header: {
                    Text("关于")
                }

                // 免责声明
                Section {
                    Text("本应用基于传统文化与生活方式的灵感提示，帮助你建立生活节律与正念觉察，不提供占卜、预测或迷信内容。")
                    Text("内容为一般生活方式建议，不构成医疗诊断或治疗意见；如有健康问题请咨询专业医护人员。")
                } header: {
                    Text("免责声明")
                }

                // 版本信息（连续点击5次触发开发者重置）
                Section {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        versionTapCount += 1
                        if versionTapCount >= 5 {
                            versionTapCount = 0
                            showResetAlert = true
                        }
                    }
                }
            }
            .navigationTitle("设置")
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showSupport) {
            SupportView()
        }
        .alert("开发者重置", isPresented: $showResetAlert) {
            Button("确认重置", role: .destructive) {
                resetToNewUser()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("将清除本地会员状态，App 将恢复为免费版显示。\n（StoreKit 沙盒购买记录需在「设置 > App Store > 沙盒账户」中清除）")
        }
        .alert("联系作者", isPresented: $showContactAlert) {
            Button("复制邮箱") {
                UIPasteboard.general.string = "bhzbtxy@163.com"
            }
            Button("关闭", role: .cancel) {}
        } message: {
            Text("如有问题，请联系邮箱：\nbhzbtxy@163.com")
        }
        .alert("重置完成", isPresented: $showResetDone) {
            Button("好的") {}
        } message: {
            Text("请重启 App 以确保所有状态生效")
        }
        .task {
            await subscriptionVM.checkSubscriptionStatus()
        }
    }

    // MARK: - 会员状态视图

    private var premiumStatusView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .font(.title2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(subscriptionVM.subscriptionTypeString)
                        .font(.headline)

                    if let expirationDate = subscriptionVM.expirationDateString {
                        Text("到期时间：\(expirationDate)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("永久有效")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }

            // 恢复购买按钮
            Button {
                Task {
                    await StoreKitManager.shared.restorePurchases()
                    await subscriptionVM.checkSubscriptionStatus()
                }
            } label: {
                Text("恢复购买")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
    }

    private var freeStatusView: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Image(systemName: "star.circle")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)

                Text("免费版本")
                    .font(.headline)

                Text("升级以解锁所有功能")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Button {
                showPaywall = true
            } label: {
                Text("查看订阅选项")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }

            Button {
                Task {
                    await StoreKitManager.shared.restorePurchases()
                    await subscriptionVM.checkSubscriptionStatus()
                }
            } label: {
                Text("恢复购买")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical)
    }

    // MARK: - 开发者重置

    private func resetToNewUser() {
        // 清除本地会员状态
        FeatureAccessManager.shared.isPremium = false
        StoreKitManager.shared.purchasedProductIDs = []

        // 清除 UserDefaults 中的设备 ID 和订阅缓存
        UserDefaults.standard.removeObject(forKey: "device_unique_id")

        // 刷新 ViewModel 状态
        subscriptionVM.isPremium = false

        showResetDone = true
    }
}

#Preview {
    SettingsView()
}
