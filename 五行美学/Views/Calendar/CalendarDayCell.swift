import SwiftUI

/// 日历日期单元格 - 带五行彩色圆点指示器
struct CalendarDayCell: View {
    let date: Date
    let isToday: Bool
    let isSelected: Bool
    let element: FiveElement

    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 3) {
            // 公历日期
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: scaledFontSize(base: 17), weight: isToday ? .bold : .medium))
                .foregroundStyle(textColor)

            // 农历日期
            Text(LunarCalendar.shortLunarString(for: date))
                .font(.system(size: scaledFontSize(base: 9)))
                .foregroundStyle(lunarTextColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            // 五行彩色圆点指示器
            elementIndicator
        }
        .frame(maxWidth: .infinity)
        .frame(height: 64)
        .background(cellBackground)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("双击选择此日期")
    }

    // MARK: - 五行彩色圆点指示器
    private var elementIndicator: some View {
        ZStack {
            // 外层光晕
            Circle()
                .fill(element.calendarDotColor.opacity(0.3))
                .frame(width: 10, height: 10)
                .blur(radius: 2)

            // 核心圆点
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            element.calendarDotCoreColor.opacity(0.9),
                            element.calendarDotColor
                        ],
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: 4
                    )
                )
                .frame(width: 6, height: 6)
                .shadow(color: element.calendarDotColor.opacity(0.5), radius: 2, x: 0, y: 1)
        }
        .padding(.top, 2)
    }

    // MARK: - 单元格背景
    @ViewBuilder
    private var cellBackground: some View {
        if isSelected {
            // 选中状态：五行色渐变实心圆
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [
                            element.color.opacity(0.8),
                            element.meshMidColor.opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    element.color.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: element.color.opacity(0.4), radius: 8, x: 0, y: 4)
        } else if isToday {
            // 今天：淡色高亮
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(element.color.opacity(0.4), lineWidth: 0.75)
                )
        } else {
            Color.clear
        }
    }

    // MARK: - 样式
    private var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return element.color
        }
        return Color(white: 0.25)
    }

    private var lunarTextColor: Color {
        let isSpecialDay = LunarCalendar.isSpecialLunarDay(for: date)
        if isSelected {
            return Color.white.opacity(0.85)
        } else if isSpecialDay {
            return .orange
        }
        return Color(white: 0.5)
    }

    private var accessibilityDescription: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        let gregorian = formatter.string(from: date)
        let lunar = LunarCalendar.lunarDateString(for: date)

        var description = "\(gregorian)，农历\(lunar)，\(element.rawValue)日"
        if isToday {
            description += "，今天"
        }
        if isSelected {
            description += "，已选中"
        }
        return description
    }

    private func scaledFontSize(base: CGFloat) -> CGFloat {
        switch dynamicTypeSize {
        case .xSmall, .small:
            return base * 0.9
        case .medium, .large:
            return base
        case .xLarge, .xxLarge:
            return base * 1.1
        default:
            return base * 1.2
        }
    }
}

#Preview {
    ZStack {
        Color(white: 0.95)
        HStack(spacing: 8) {
            CalendarDayCell(
                date: Date(),
                isToday: true,
                isSelected: false,
                element: .wood
            )

            CalendarDayCell(
                date: Date(),
                isToday: false,
                isSelected: true,
                element: .fire
            )

            CalendarDayCell(
                date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
                isToday: false,
                isSelected: false,
                element: .water
            )

            CalendarDayCell(
                date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
                isToday: false,
                isSelected: false,
                element: .earth
            )
        }
        .padding()
    }
}
