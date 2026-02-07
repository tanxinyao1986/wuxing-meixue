import SwiftUI

/// 五行解释Sheet — 暗态玻璃风格，与主界面视觉语言一致。
struct ElementExplanationSheet: View {
    let dayInfo: DayInfo
    @Environment(\.dismiss) var dismiss
    /// 解释页实体色背景仅 metal 足够亮，需切为暗色文字
    private var sheetLightBg: Bool { displayElement == .metal || displayElement == .earth }
    /// 解释页主体展示“幸运五行”
    private var displayElement: FiveElement { dayInfo.element }
    private var insight: ElementInsight { ElementInsightLoader.shared.insight(for: displayElement) }
    private var yiJi: YiJi { LunarYiJiProvider.shared.yiJi(for: dayInfo.date) }
    private var labelTextColor: Color {
        switch displayElement {
        case .fire, .wood, .water:
            return .white.opacity(0.92)
        case .metal:
            return Color(hex: 0x2C2C2E)
        default:
            return displayElement.primaryTextColor
        }
    }
    private var labelTitleColor: Color {
        switch displayElement {
        case .fire, .wood, .water:
            return .white.opacity(0.7)
        case .metal:
            return Color(hex: 0x4A4A4C)
        default:
            return displayElement.secondaryTextColor
        }
    }
    private var sectionTitleColor: Color {
        if displayElement == .metal {
            return Color(hex: 0x2C2C2E)
        }
        return sheetLightBg ? displayElement.color : displayElement.glowColor
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 元素图标 — 渐变圆 + 柔光晕
                    ZStack {
                        Circle()
                            .fill(sheetLightBg ? displayElement.color : displayElement.glowColor)
                            .frame(width: 120, height: 120)
                            .blur(radius: 24)
                            .opacity(sheetLightBg ? 0.25 : 0.45)

                        Circle()
                            .fill(displayElement.gradient)
                            .frame(width: 100, height: 100)
                            .shadow(color: displayElement.color.opacity(0.45), radius: 18, x: 0, y: 8)

                        Image(systemName: displayElement.iconName)
                            .font(AppFont.ui(40, weight: .light))
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 24)

                    // 元素名称
                    Text(displayElement.rawValue)
                        .font(AppFont.display(28, weight: .bold))
                        .foregroundStyle(sheetLightBg ? displayElement.color : displayElement.glowColor)
                        .shadow(color: sheetLightBg ? .clear : displayElement.coreColor.opacity(0.4), radius: 6, x: 0, y: 2)

                    // 流日干支 & 幸运五行
                    HStack(spacing: 12) {
                        labelPill(title: "流日", value: dayInfo.ganzhiDay)
                        labelPill(title: "流日五行", value: dayInfo.dayElement.rawValue)
                        labelPill(title: "幸运五行", value: dayInfo.element.rawValue)
                    }
                    .padding(.horizontal, 20)

                    // 五行解析
                    section(title: "五行解析") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(insight.opening)
                            Text(insight.direction)
                        }
                        .font(AppFont.narrative(15))
                        .lineSpacing(8)
                    }

                    // 关键词能量
                    section(title: "关键词能量") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(keywordLine)
                                .font(AppFont.calligraphy(20, weight: .semibold))
                                .tracking(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                        }
                    }

                    // 当日宜忌
                    section(title: "当日宜忌") {
                        VStack(alignment: .leading, spacing: 8) {
                            yiJiRow(title: "宜", items: yiJi.yi)
                            yiJiRow(title: "忌", items: yiJi.ji)
                        }
                        .font(AppFont.ui(14))
                    }

                    Spacer(minLength: 40)
                }
            }
            .background(
                ZStack {
                    displayElement.meshBaseColor
                    RadialGradient(
                        colors: [displayElement.meshHighlightColor.opacity(0.25), Color.clear],
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
                    .font(AppFont.ui(15, weight: .medium))
                    .foregroundStyle(sheetLightBg ? displayElement.color : displayElement.glowColor)
                    .accessibilityLabel("关闭五行解释")
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func labelPill(title: String, value: String) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(AppFont.ui(11))
                .foregroundStyle(labelTitleColor)
            Text(value)
                .font(AppFont.ui(13, weight: .semibold))
                .foregroundStyle(labelTextColor)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .opacity(displayElement == .metal ? 0.85 : 0.6)
                .overlay(
                    Capsule()
                        .stroke(displayElement == .metal ? Color.black.opacity(0.15) : Color.white.opacity(0.25), lineWidth: 0.6)
                )
        )
    }

    private func formatted(_ items: [String]) -> String {
        if items.isEmpty {
            return "无"
        }
        return items.joined(separator: " · ")
    }

    private var keywordLine: String {
        let raw = insight.keywords
        if let range = raw.range(of: "：") ?? raw.range(of: ":") {
            let tail = raw[range.upperBound...]
            return tail.trimmingCharacters(in: .whitespaces)
        }
        return raw
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AppFont.display(16, weight: .semibold))
                .foregroundStyle(sectionTitleColor)
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(sheetLightBg ? Color(hex: 0x3A3A3C) : Color.white.opacity(0.82))
        }
        .padding(.horizontal, 24)
    }

    private func yiJiRow(title: String, items: [String]) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(title)
                .font(AppFont.ui(12, weight: .semibold))
                .foregroundStyle(sheetLightBg ? displayElement.color : displayElement.glowColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(sheetLightBg ? Color.black.opacity(0.10) : Color.white.opacity(0.25), lineWidth: 0.5)
                        )
                )
            Text(formatted(items))
                .foregroundStyle(sheetLightBg ? Color(hex: 0x3A3A3C) : Color.white.opacity(0.82))
        }
    }
}

#Preview {
    ElementExplanationSheet(dayInfo: DayInfo.forDate(Date()))
}
