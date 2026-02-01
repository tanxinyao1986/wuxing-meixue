import Foundation

/// 每日信息数据模型
struct DayInfo: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let element: FiveElement
    let mainKeyword: String

    /// 获取公历日期格式化字符串
    var gregorianDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    /// 获取公历月份
    var gregorianMonthString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月"
        return formatter.string(from: date)
    }

    /// 获取星期
    var weekdayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    /// 获取完整日期字符串
    var fullDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: date)
    }

    static func == (lhs: DayInfo, rhs: DayInfo) -> Bool {
        Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
    }
}

// MARK: - 示例数据生成
extension DayInfo {
    /// 根据日期生成DayInfo（简化版五行计算）
    static func forDate(_ date: Date) -> DayInfo {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1

        // 简化的五行计算：根据日期轮转
        let elementIndex = dayOfYear % 5
        let element = FiveElement.allCases[elementIndex]

        // 根据五行生成关键词
        let keyword = keywordForElement(element, dayOfYear: dayOfYear)

        return DayInfo(date: date, element: element, mainKeyword: keyword)
    }

    private static func keywordForElement(_ element: FiveElement, dayOfYear: Int) -> String {
        let keywords: [FiveElement: [String]] = [
            .wood: ["生发舒展", "萌芽向上", "春意盎然", "蓬勃生长", "枝繁叶茂"],
            .fire: ["热情洋溢", "光明璀璨", "心神明亮", "温暖如阳", "灿烂绽放"],
            .earth: ["厚德载物", "稳重踏实", "包容万象", "根基稳固", "滋养万物"],
            .metal: ["去芜存菁", "锐意进取", "清明肃杀", "精纯无杂", "果断决绝"],
            .water: ["静水流深", "智慧如渊", "柔韧不屈", "润物无声", "顺势而为"]
        ]

        let elementKeywords = keywords[element] ?? ["平和安宁"]
        return elementKeywords[dayOfYear % elementKeywords.count]
    }
}
