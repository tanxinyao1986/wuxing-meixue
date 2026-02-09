import SwiftUI

/// 五个指导模块
enum GuideModule: String, CaseIterable, Identifiable {
    case dress  = "能量着装"
    case food   = "顺时食饮"
    case space  = "身心空间"
    case action = "行动指南"
    case anchor = "心念之锚"

    var id: String { rawValue }

    /// 本地化显示名称（UI 展示用，rawValue 保持不变用于内部标识）
    var displayName: String {
        switch self {
        case .dress:  return String(localized: "能量着装")
        case .food:   return String(localized: "顺时食饮")
        case .space:  return String(localized: "身心空间")
        case .action: return String(localized: "行动指南")
        case .anchor: return String(localized: "心念之锚")
        }
    }

    /// 对应五行
    var element: FiveElement {
        switch self {
        case .dress:  return .wood
        case .food:   return .fire
        case .space:  return .earth
        case .action: return .metal
        case .anchor: return .water
        }
    }

    /// SF Symbol 图标名 — 极简线条映射
    var iconName: String {
        SymbolResolver.resolve(candidates: symbolCandidates, fallback: "questionmark")
    }

    /// 候选符号：按“精致线条/东方意象”优先级排列
    private var symbolCandidates: [String] {
        switch self {
        case .dress:
            return ["tshirt", "tshirt.fill", "hanger", "suitcase"]
        case .food:
            return ["cup.and.saucer", "cup.and.saucer.fill", "leaf", "leaf.fill"]
        case .space:
            return ["building.columns", "house", "house.fill"]
        case .action:
            return ["sailboat", "sailboat.fill", "location.north"]
        case .anchor:
            return ["heart.circle", "heart.circle.fill", "hands.and.sparkles", "hand.raised.heart", "heart"]
        }
    }

    /// 模块主色 (直接桥接五行色)
    var color: Color { element.color }

    /// VoiceOver
    var accessibilityLabel: String {
        switch self {
        case .dress:  return String(localized: "能量着装，木元素，点击查看今日穿搭建议")
        case .food:   return String(localized: "顺时食饮，火元素，点击查看今日饮食建议")
        case .space:  return String(localized: "身心空间，土元素，点击查看今日空间建议")
        case .action: return String(localized: "行动指南，金元素，点击查看今日行动建议")
        case .anchor: return String(localized: "心念之锚，水元素，点击查看今日心念建议")
        }
    }

    /// 模块内容
    /// 使用 ContentLoader 从 JSON 数据中获取基于日期的伪随机内容
    func content(for dayInfo: DayInfo) -> ModuleContent {
        let loader = ContentLoader.shared
        let mainContent = loader.getContent(for: dayInfo.element, module: self, date: dayInfo.date)
        let keywords = loader.getKeywords(for: dayInfo.element)
        let keywordsText = keywords.isEmpty ? "" : keywords.joined(separator: "·")

        switch self {
        case .dress:
            return ModuleContent(
                title: String(localized: "今日能量着装"),
                subtitle: String(localized: "与\(dayInfo.element.displayName)气共振"),
                items: [mainContent],
                tip: String(localized: "穿着能量色，让外在与内在和谐共振。")
            )
        case .food:
            return ModuleContent(
                title: String(localized: "今日顺时食饮"),
                subtitle: keywordsText.isEmpty ? String(localized: "滋养身心的选择") : keywordsText,
                items: [mainContent],
                tip: String(localized: "顺应时节，让食物成为身体的良药。")
            )
        case .space:
            return ModuleContent(
                title: String(localized: "今日身心空间"),
                subtitle: String(localized: "创造滋养的环境"),
                items: [mainContent],
                tip: String(localized: "外在空间的整洁，映射内心的清明。")
            )
        case .action:
            return ModuleContent(
                title: String(localized: "今日行动指南"),
                subtitle: String(localized: "顺势而为的智慧"),
                items: [mainContent],
                tip: String(localized: "行动与等待同样重要，关键在于时机。")
            )
        case .anchor:
            return ModuleContent(
                title: String(localized: "今日心念之锚"),
                subtitle: String(localized: "一句话的力量"),
                items: [mainContent],
                tip: String(localized: "当心绪不宁时，回到这句话，找到内心的锚点。")
            )
        }
    }
}

struct ModuleContent {
    let title:    String
    let subtitle: String
    let items:    [String]
    let tip:      String
}
