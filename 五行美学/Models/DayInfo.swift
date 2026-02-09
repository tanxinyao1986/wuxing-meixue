import Foundation

/// 每日信息数据模型
struct DayInfo: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    /// 幸运五行（全局 UI 与内容以此为准）
    let element: FiveElement
    let mainKeyword: String
    let ganzhiDay: String
    let luckyElement: FiveElement
    /// 流日地支对应五行（用于对照显示）
    let dayElement: FiveElement

    /// 获取公历日期格式化字符串
    var gregorianDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    /// 获取公历月份
    var gregorianMonthString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMM")
        return formatter.string(from: date)
    }

    /// 获取星期
    var weekdayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("EEEE")
        return formatter.string(from: date)
    }

    /// 获取完整日期字符串
    var fullDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("yyyyMd")
        return formatter.string(from: date)
    }

    static func == (lhs: DayInfo, rhs: DayInfo) -> Bool {
        Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
    }
}

// MARK: - 示例数据生成
extension DayInfo {
    /// 根据日期生成 DayInfo（基于流日干支与地支五行）
    static func forDate(_ date: Date) -> DayInfo {
        let dayBranch = LunarCalendar.dayBranch(for: date)
        let dayElement = elementForBranch(dayBranch)
        let ganzhiDay = LunarCalendar.ganzhiDay(for: date)
        let lucky = luckyElement(for: dayBranch)
        let keyword = ContentLoader.shared.keyword(for: lucky, date: date)

        return DayInfo(
            date: date,
            element: lucky,
            mainKeyword: keyword,
            ganzhiDay: ganzhiDay,
            luckyElement: lucky,
            dayElement: dayElement
        )
    }

    private static func elementForBranch(_ branch: String) -> FiveElement {
        switch branch {
        case "子", "亥":
            return .water
        case "寅", "卯":
            return .wood
        case "巳", "午":
            return .fire
        case "申", "酉":
            return .metal
        case "辰", "戌", "丑", "未":
            return .earth
        default:
            return .earth
        }
    }

    /// 独家配方：按相生关系获取幸运五行
    private static func luckyElement(for branch: String) -> FiveElement {
        switch branch {
        case "子", "亥":
            return .wood   // 水生木
        case "寅", "卯":
            return .fire   // 木生火
        case "巳", "午":
            return .earth  // 火生土
        case "申", "酉":
            return .water  // 金生水
        case "辰", "戌", "丑", "未":
            return .metal  // 土生金
        default:
            return .earth
        }
    }
}
