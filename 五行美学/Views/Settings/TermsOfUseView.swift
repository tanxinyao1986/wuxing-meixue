//
//  TermsOfUseView.swift
//  五行美学
//
//  服务条款（EULA）页面
//

import SwiftUI

struct TermsOfUseView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("欢迎使用五行美学。使用本应用即表示你同意以下条款。请仔细阅读。")
                        .foregroundColor(.secondary)

                    sectionView(title: "服务说明") {
                        Text("五行美学是一款基于中国传统五行文化的生活美学应用，提供日常五行节律指导、能量着装建议等内容。本应用仅供参考，不构成医疗、心理或占卜建议。")
                            .foregroundColor(.secondary)
                    }

                    sectionView(title: "订阅服务") {
                        bulletPoint("本应用提供自动续期订阅（月度、年度）和一次性购买（终身会员）。")
                        bulletPoint("订阅费用将通过你的 Apple ID 账户收取。")
                        bulletPoint("订阅将在当前周期结束前 24 小时内自动续费，届时将从你的账户扣款。")
                        bulletPoint("你可以随时在 iPhone「设置」→ Apple ID →「订阅」中管理或取消订阅。")
                        bulletPoint("取消订阅后，你仍可使用已付费周期内的所有功能。")
                        bulletPoint("免费试用期未使用部分将在购买订阅时失效。")
                    }

                    sectionView(title: "用户行为") {
                        bulletPoint("你不得将本应用用于任何违法或未经授权的用途。")
                        bulletPoint("你不得尝试破解、反编译或以其他方式获取本应用的源代码。")
                        bulletPoint("你不得以任何方式干扰或破坏本应用的正常运行。")
                    }

                    sectionView(title: "知识产权") {
                        Text("本应用的所有内容（包括但不限于文字、图片、图标、设计和代码）均受知识产权法保护。未经书面许可，不得复制、修改或分发。")
                            .foregroundColor(.secondary)
                    }

                    sectionView(title: "免责声明") {
                        bulletPoint("本应用内容仅供文化参考与生活美学启发，不代替任何专业建议。")
                        bulletPoint("我们不对因使用本应用内容而产生的任何直接或间接损失承担责任。")
                        bulletPoint("服务可能因维护或不可抗力因素暂时中断。")
                    }

                    sectionView(title: "条款变更") {
                        Text("我们保留随时修改本条款的权利。重大变更将在应用内通知。继续使用本应用即视为接受修改后的条款。")
                            .foregroundColor(.secondary)
                    }

                    sectionView(title: "联系我们") {
                        Text("如有任何问题，请联系：bhzbtxy@163.com")
                            .foregroundColor(.secondary)
                    }

                    Text("最后更新：2026-02-13")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("服务条款")
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
