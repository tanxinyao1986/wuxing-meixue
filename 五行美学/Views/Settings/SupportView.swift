//
//  SupportView.swift
//  五行美学
//
//  内置技术支持页面
//

import SwiftUI

struct SupportView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("以传统文化为灵感的生活节律助手，提供正念提醒与生活建议。")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // 联系我们
                    cardView {
                        HStack {
                            Text("联系我们")
                                .font(.headline)
                            Text("支持")
                                .font(.caption2)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.8))
                                .cornerRadius(99)
                        }
                        Text("邮箱：bhzbtxy@163.com")
                            .foregroundColor(.secondary)
                        Text("我们通常会在 1–2 个工作日内回复。")
                            .foregroundColor(.secondary)
                    }

                    // 常见问题
                    cardView {
                        Text("常见问题")
                            .font(.headline)
                        bulletPoint("订阅/恢复购买：请在 App 内设置页点击"恢复购买"。")
                        bulletPoint("数据同步：请确保 iCloud 登录且网络正常。")
                        bulletPoint("提醒未生效：检查系统通知权限与勿扰模式。")
                    }

                    // 产品定位
                    cardView {
                        Text("产品定位")
                            .font(.headline)
                        Text("本应用不提供占卜、预测或迷信内容。建议用于生活节律与正念觉察，不构成医疗建议。")
                            .foregroundColor(.secondary)
                    }

                    Text("最后更新：2026-02-09")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("技术支持")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }

    private func cardView(@ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 1)
        )
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
