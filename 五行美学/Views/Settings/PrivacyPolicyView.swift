//
//  PrivacyPolicyView.swift
//  五行美学
//
//  内置隐私政策页面
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("本政策说明我们如何收集、使用与保护你的信息。若你使用本应用，即视为同意本政策。")
                        .foregroundColor(.secondary)

                    sectionView(title: "我们收集的信息") {
                        bulletPoint("账户与订阅相关信息（用于验证订阅状态）。")
                        bulletPoint("设备标识（用于订阅关联与防止重复计费）。")
                        bulletPoint("应用内使用数据（用于提升体验与稳定性）。")
                    }

                    sectionView(title: "我们如何使用信息") {
                        bulletPoint("提供与维护订阅服务。")
                        bulletPoint("改进产品体验与性能。")
                        bulletPoint("响应用户请求与技术支持。")
                        Text("订阅与支付由 Apple 处理，我们不会获取或存储你的完整支付信息。")
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }

                    sectionView(title: "信息共享") {
                        Text("我们不会向第三方出售你的个人信息。除法律要求或提供服务所必需的情形外，不会共享。")
                            .foregroundColor(.secondary)
                    }

                    sectionView(title: "数据存储与安全") {
                        Text("我们采取合理的技术与管理措施保护信息安全，但无法保证绝对安全。")
                            .foregroundColor(.secondary)
                    }

                    sectionView(title: "你的选择") {
                        bulletPoint("你可以通过系统设置管理通知权限。")
                        bulletPoint("你可以随时取消订阅（通过 App Store 订阅管理）。")
                    }

                    sectionView(title: "联系我们") {
                        Text("如有隐私相关问题，请联系：bhzbtxy@163.com")
                            .foregroundColor(.secondary)
                    }

                    Text("最后更新：2026-02-09")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("隐私政策")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }

    private func sectionView(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content()
        }
    }

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.secondary)
            Text(text)
                .foregroundColor(.secondary)
        }
    }
}
