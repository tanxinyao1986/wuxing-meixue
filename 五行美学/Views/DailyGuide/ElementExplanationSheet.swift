import SwiftUI

/// 五行解释Sheet — 暗态玻璃风格，与主界面视觉语言一致。
struct ElementExplanationSheet: View {
    let element: FiveElement
    @Environment(\.dismiss) var dismiss
    /// 解释页实体色背景仅 metal 足够亮，需切为暗色文字
    private var sheetLightBg: Bool { element == .metal || element == .earth }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // 元素图标 — 渐变圆 + 柔光晕
                    ZStack {
                        Circle()
                            .fill(sheetLightBg ? element.color : element.glowColor)
                            .frame(width: 120, height: 120)
                            .blur(radius: 24)
                            .opacity(sheetLightBg ? 0.25 : 0.45)

                        Circle()
                            .fill(element.gradient)
                            .frame(width: 100, height: 100)
                            .shadow(color: element.color.opacity(0.45), radius: 18, x: 0, y: 8)

                        Image(systemName: element.iconName)
                            .font(.system(size: 40, weight: .light))
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 24)

                    // 元素名称
                    Text(element.rawValue)
                        .font(.custom("PingFang SC", size: 28))
                        .fontWeight(.bold)
                        .foregroundStyle(sheetLightBg ? element.color : element.glowColor)
                        .shadow(color: sheetLightBg ? .clear : element.coreColor.opacity(0.4), radius: 6, x: 0, y: 2)

                    // 解释内容
                    Text(element.explanation)
                        .font(.custom("PingFang SC", size: 15))
                        .foregroundStyle(sheetLightBg ? Color(hex: 0x3A3A3C) : Color.white.opacity(0.82))
                        .multilineTextAlignment(.leading)
                        .lineSpacing(9)
                        .padding(.horizontal, 24)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 40)
                }
            }
            .background(
                ZStack {
                    element.meshBaseColor
                    RadialGradient(
                        colors: [element.meshHighlightColor.opacity(0.25), Color.clear],
                        center: UnitPoint(x: 0.5, y: 0.15),
                        startRadius: 40,
                        endRadius: 280
                    )
                }
                .ignoresSafeArea()
            )
            .navigationTitle("今日五行")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(sheetLightBg ? element.color : element.glowColor)
                    .accessibilityLabel("关闭五行解释")
                }
            }
        }
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    ElementExplanationSheet(element: .wood)
}
