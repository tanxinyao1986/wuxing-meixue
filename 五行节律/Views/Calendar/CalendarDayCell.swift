import SwiftUI

/// 日历日期单元格
struct CalendarDayCell: View {
    let date: Date
    let isToday: Bool
    let isSelected: Bool
    let element: FiveElement

    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 4) {
            // 公历日期
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: scaledFontSize(base: 16), weight: isToday ? .bold : .regular))
                .foregroundStyle(textColor)

            // 农历日期
            Text(LunarCalendar.shortLunarString(for: date))
                .font(.system(size: scaledFontSize(base: 10)))
                .foregroundStyle(lunarTextColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(
            Group {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(element.color.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(element.color, lineWidth: 2)
                        )
                } else if isToday {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.accentColor.opacity(0.15))
                }
            }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("双击选择此日期")
    }

    // MARK: - Styling
    private var textColor: Color {
        if isSelected {
            return element.color
        } else if isToday {
            return .accentColor
        }
        return .primary
    }

    private var lunarTextColor: Color {
        let isSpecialDay = LunarCalendar.isSpecialLunarDay(for: date)
        if isSelected {
            return element.color.opacity(0.8)
        } else if isSpecialDay {
            return .orange
        }
        return .secondary
    }

    private var accessibilityDescription: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        let gregorian = formatter.string(from: date)
        let lunar = LunarCalendar.lunarDateString(for: date)

        var description = "\(gregorian)，农历\(lunar)"
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
    HStack {
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
    }
    .padding()
}
