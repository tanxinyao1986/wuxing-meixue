import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct FiveElementsEntry: TimelineEntry {
    let date: Date
    let dayElement: FiveElement
    let luckyElement: FiveElement
    let keyword: String
    let ganzhiDay: String
}

// MARK: - Timeline Provider

struct FiveElementsProvider: TimelineProvider {
    func placeholder(in context: Context) -> FiveElementsEntry {
        FiveElementsEntry(
            date: Date(),
            dayElement: .wood,
            luckyElement: .fire,
            keyword: "生发",
            ganzhiDay: "甲子"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (FiveElementsEntry) -> Void) {
        completion(entry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FiveElementsEntry>) -> Void) {
        let now = Date()
        let entry = entry(for: now)
        // 下次更新：明日零点
        let next = Ganzhi.calendar.startOfDay(for: now).addingTimeInterval(86400)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func entry(for date: Date) -> FiveElementsEntry {
        let dayBranch = Ganzhi.dayBranch(for: date)
        let ganzhiDay = Ganzhi.ganzhiDay(for: date)
        let dayElement = FiveElement.elementForBranch(dayBranch)
        let lucky = FiveElement.luckyElement(for: dayBranch)
        let keyword = FiveElement.keywordLine(for: lucky)
        return FiveElementsEntry(
            date: date,
            dayElement: dayElement,
            luckyElement: lucky,
            keyword: keyword,
            ganzhiDay: ganzhiDay
        )
    }
}

// MARK: - Widget Entry View

struct FiveElementsWidgetEntryView: View {
    let entry: FiveElementsEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        content
            .containerBackground(entry.luckyElement.backgroundColor, for: .widget)
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }

    // MARK: - Small Widget

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(Self.smallDateFormatter.string(from: entry.date))
                .font(.system(size: 24, weight: .light, design: .serif))
                .foregroundStyle(primaryText)

            Text(String(localized: "流日 · \(entry.ganzhiDay)"))
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(secondaryText)

            Text(String(localized: "幸运五行 · \(entry.luckyElement.displayName)"))
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(secondaryText)
        }
        .padding(16)
    }

    // MARK: - Medium Widget

    private var mediumView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(Self.mediumDateFormatter.string(from: entry.date))
                .font(.system(size: 26, weight: .light, design: .serif))
                .foregroundStyle(primaryText)

            HStack(spacing: 8) {
                pill(title: String(localized: "流日"), value: entry.ganzhiDay)
                pill(title: String(localized: "流日五行"), value: entry.dayElement.displayName)
                pill(title: String(localized: "幸运五行"), value: entry.luckyElement.displayName)
            }

            Text(entry.keyword)
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundStyle(primaryText)
                .tracking(2)
        }
        .padding(16)
    }

    // MARK: - Shared Formatters (缓存，避免重复创建)

    private static let smallDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.setLocalizedDateFormatFromTemplate("MMMd")
        return f
    }()

    private static let mediumDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.setLocalizedDateFormatFromTemplate("yyyyMMMd")
        return f
    }()

    // MARK: - Colors

    private var primaryText: Color {
        entry.luckyElement.isLightBackground ? Color(hex: 0x2C2C2E) : .white
    }

    private var secondaryText: Color {
        entry.luckyElement.isLightBackground ? Color(hex: 0x636366) : Color.white.opacity(0.8)
    }

    private func pill(title: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(secondaryText)
            Text(value)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(primaryText)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(.white.opacity(entry.luckyElement.isLightBackground ? 0.45 : 0.18))
        )
    }
}

// MARK: - Widget Configuration

struct FiveElementsWidget: Widget {
    let kind: String = "FiveElementsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FiveElementsProvider()) { entry in
            FiveElementsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(String(localized: "五行节律"))
        .description(String(localized: "今日五行摘要"))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct FiveElementsWidgetBundle: WidgetBundle {
    var body: some Widget {
        FiveElementsWidget()
    }
}

// MARK: - Five Element Enum (Widget 独立副本)

enum FiveElement: String, CaseIterable {
    case wood  = "木"
    case fire  = "火"
    case earth = "土"
    case metal = "金"
    case water = "水"

    var displayName: String {
        switch self {
        case .wood:  return String(localized: "木")
        case .fire:  return String(localized: "火")
        case .earth: return String(localized: "土")
        case .metal: return String(localized: "金")
        case .water: return String(localized: "水")
        }
    }

    var isLightBackground: Bool {
        self == .metal || self == .earth
    }

    var backgroundColor: Color {
        switch self {
        case .wood:  return Color(hex: 0x2E6B4A)
        case .fire:  return Color(hex: 0xFF6B35)
        case .earth: return Color(hex: 0xA07E50)
        case .metal: return Color(hex: 0xDADDE2)
        case .water: return Color(hex: 0x004080)
        }
    }

    static func elementForBranch(_ branch: String) -> FiveElement {
        switch branch {
        case "子", "亥": return .water
        case "寅", "卯": return .wood
        case "巳", "午": return .fire
        case "申", "酉": return .metal
        case "辰", "戌", "丑", "未": return .earth
        default: return .earth
        }
    }

    static func luckyElement(for branch: String) -> FiveElement {
        switch branch {
        case "子", "亥": return .wood   // 水生木
        case "寅", "卯": return .fire   // 木生火
        case "巳", "午": return .earth  // 火生土
        case "申", "酉": return .water  // 金生水
        case "辰", "戌", "丑", "未": return .metal  // 土生金
        default: return .earth
        }
    }

    static func keywordLine(for element: FiveElement) -> String {
        switch element {
        case .wood:  return String(localized: "仁爱 · 创造 · 舒展")
        case .fire:  return String(localized: "礼仪 · 表达 · 升腾")
        case .earth: return String(localized: "承载 · 稳健 · 转化")
        case .metal: return String(localized: "秩序 · 决断 · 收敛")
        case .water: return String(localized: "智慧 · 流动 · 潜藏")
        }
    }
}

// MARK: - Ganzhi 干支计算 (缓存 Calendar 实例)

enum Ganzhi {
    private static let heavenlyStems = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
    private static let earthlyBranches = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]

    /// 共享 Calendar 实例（避免重复创建）
    static let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone.current
        return cal
    }()

    /// 校准基准日：1986-01-20 为甲子日
    private static let baseDate: Date = {
        var components = DateComponents()
        components.year = 1986
        components.month = 1
        components.day = 20
        return calendar.date(from: components) ?? Date(timeIntervalSince1970: 0)
    }()

    private static let baseDayStart: Date = {
        calendar.startOfDay(for: baseDate)
    }()

    /// 干支日索引 (0...59)
    private static func dayIndex(for date: Date) -> Int {
        let target = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: baseDayStart, to: target).day ?? 0
        return ((days % 60) + 60) % 60
    }

    /// 获取地支
    static func dayBranch(for date: Date) -> String {
        earthlyBranches[dayIndex(for: date) % 12]
    }

    /// 获取干支日名称
    static func ganzhiDay(for date: Date) -> String {
        let idx = dayIndex(for: date)
        return heavenlyStems[idx % 10] + earthlyBranches[idx % 12]
    }
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
