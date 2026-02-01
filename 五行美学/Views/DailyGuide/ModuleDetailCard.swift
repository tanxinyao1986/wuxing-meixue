import SwiftUI

/// 模块详情卡片 - 毛玻璃效果
struct ModuleDetailCard: View {
    let module: GuideModule
    let content: ModuleContent
    let onClose: () -> Void

    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题区域
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(content.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(content.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // 关闭按钮
                Button {
                    onClose()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("关闭详情卡片")
            }

            Divider()
                .background(module.color.opacity(0.3))

            // 内容列表
            VStack(alignment: .leading, spacing: 12) {
                ForEach(content.items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(module.color)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)

                        Text(item)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            // 提示语
            if !content.tip.isEmpty {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)

                    Text(content.tip)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .italic()
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: module.color.opacity(0.2), radius: 20, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(module.color.opacity(0.3), lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(module.rawValue)详情")
    }
}

#Preview {
    ZStack {
        AppBackground()

        ModuleDetailCard(
            module: .dress,
            content: GuideModule.dress.content(for: DayInfo.forDate(Date())),
            onClose: {}
        )
        .padding()
    }
}
