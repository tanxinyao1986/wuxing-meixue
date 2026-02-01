import SwiftUI

/// 中央圆环视图
struct CentralRingView: View {
    let dayInfo: DayInfo
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    private let ringSize: CGFloat = 200

    var body: some View {
        ZStack {
            // 外圈渐变边框
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            dayInfo.element.color.opacity(0.6),
                            dayInfo.element.color.opacity(0.2),
                            dayInfo.element.color.opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: ringSize, height: ringSize)

            // 内圈微光效果
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            dayInfo.element.color.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: ringSize / 2
                    )
                )
                .frame(width: ringSize - 4, height: ringSize - 4)

            // 内容
            VStack(spacing: 8) {
                // 公历日期 - 大字号
                Text(dayInfo.gregorianDateString)
                    .font(.system(size: scaledFontSize(base: 56), weight: .ultraLight, design: .rounded))
                    .foregroundStyle(.primary)
                    .accessibilityLabel("公历\(dayInfo.gregorianMonthString)\(dayInfo.gregorianDateString)日")

                // 农历日期
                Text(LunarCalendar.lunarDateString(for: dayInfo.date))
                    .font(.system(size: scaledFontSize(base: 14), weight: .regular))
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("农历\(LunarCalendar.lunarDateString(for: dayInfo.date))")

                // 核心关键词
                Text(dayInfo.mainKeyword)
                    .font(.system(size: scaledFontSize(base: 16), weight: .medium))
                    .foregroundStyle(dayInfo.element.color)
                    .padding(.top, 4)
                    .accessibilityLabel("今日关键词：\(dayInfo.mainKeyword)")
            }
        }
        .frame(width: ringSize, height: ringSize)
    }

    /// 根据动态字体设置缩放字号
    private func scaledFontSize(base: CGFloat) -> CGFloat {
        switch dynamicTypeSize {
        case .xSmall, .small:
            return base * 0.85
        case .medium, .large:
            return base
        case .xLarge, .xxLarge:
            return base * 1.1
        case .xxxLarge:
            return base * 1.2
        default:
            return base * 1.3
        }
    }
}

#Preview {
    ZStack {
        AppBackground()
        CentralRingView(dayInfo: DayInfo.forDate(Date()))
    }
}
