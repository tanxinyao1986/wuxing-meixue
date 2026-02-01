import Foundation

/// 农历日历工具
struct LunarCalendar {
    private static let chineseCalendar: Calendar = {
        var calendar = Calendar(identifier: .chinese)
        calendar.locale = Locale(identifier: "zh_CN")
        return calendar
    }()

    private static let lunarMonths = [
        "正月", "二月", "三月", "四月", "五月", "六月",
        "七月", "八月", "九月", "十月", "冬月", "腊月"
    ]

    private static let lunarDays = [
        "初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
        "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
        "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"
    ]

    private static let heavenlyStems = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
    private static let earthlyBranches = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]

    /// 获取农历月份字符串
    static func lunarMonth(for date: Date) -> String {
        let month = chineseCalendar.component(.month, from: date)
        let isLeapMonth = chineseCalendar.component(.yearForWeekOfYear, from: date) != 0
        let prefix = isLeapMonth ? "闰" : ""
        return prefix + (lunarMonths[safe: month - 1] ?? "")
    }

    /// 获取农历日期字符串
    static func lunarDay(for date: Date) -> String {
        let day = chineseCalendar.component(.day, from: date)
        return lunarDays[safe: day - 1] ?? ""
    }

    /// 获取完整农历日期字符串
    static func lunarDateString(for date: Date) -> String {
        let month = lunarMonth(for: date)
        let day = lunarDay(for: date)
        return "\(month)\(day)"
    }

    /// 获取简短农历显示（日历单元格用）
    /// 初一显示月份名，其他显示日期
    static func shortLunarString(for date: Date) -> String {
        let day = chineseCalendar.component(.day, from: date)
        if day == 1 {
            return lunarMonth(for: date)
        }
        return lunarDay(for: date)
    }

    /// 判断是否为特殊农历日期（初一、十五）
    static func isSpecialLunarDay(for date: Date) -> Bool {
        let day = chineseCalendar.component(.day, from: date)
        return day == 1 || day == 15
    }

    /// 获取干支年
    static func ganzhiYear(for date: Date) -> String {
        let year = chineseCalendar.component(.year, from: date)
        let stemIndex = (year - 1) % 10
        let branchIndex = (year - 1) % 12
        return heavenlyStems[stemIndex] + earthlyBranches[branchIndex] + "年"
    }
}

// MARK: - Array Safe Subscript
private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
