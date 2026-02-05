import SwiftUI

/// 五行元素枚举 — 严格执行指定 HEX 色值体系
enum FiveElement: String, CaseIterable, Identifiable {
    case wood  = "木"
    case fire  = "火"
    case earth = "土"
    case metal = "金"
    case water = "水"

    var id: String { rawValue }

    // MARK: - 智能背景分类
    /// 木、土、金 Mesh 整体偏亮 → 文字用深色；火、水 整体偏深 → 文字用白色
    var isLightBackground: Bool {
        switch self {
        case .wood, .fire, .earth, .metal: return true
        case .water:                return false
        }
    }

    // MARK: - 智能文字色 (随背景明暗自动切换)
    var primaryTextColor: Color {
        isLightBackground ? Color(hex: 0x2C2C2E) : .white
    }
    var secondaryTextColor: Color {
        isLightBackground ? Color(hex: 0x636366) : .white.opacity(0.6)
    }
    var subtleTextColor: Color {
        isLightBackground ? Color(hex: 0x8E8E93) : .white.opacity(0.40)
    }
    /// 图标未选中色
    var iconTintColor: Color {
        isLightBackground ? Color(hex: 0x3A3A3C) : .white.opacity(0.70)
    }

    // MARK: - 图标 (保留用于五行解释页)
    var iconName: String {
        switch self {
        case .wood:  return "leaf"
        case .fire:  return "flame"
        case .earth: return "mountain.2"
        case .metal: return "sparkles"
        case .water: return "drop"
        }
    }

    // MARK: - 主色 (图标高亮、指示点、卡片边缘等场景)
    var color: Color {
        switch self {
        case .wood:  return Color(hex: 0x6BAF6B)  // 中绿
        case .fire:  return Color(hex: 0xFF3B30)  // 正红
        case .earth: return Color(hex: 0xE6C229)  // 暖金
        case .metal: return Color(hex: 0xD1D1D6)  // 冷银色
        case .water: return Color(hex: 0x00AEEF)  // 青蓝
        }
    }

    // MARK: - Mesh Background 色系

    /// 底色 — 浅色元素用 M/H 铺满；深色元素用 B 打底
    var meshBaseColor: Color {
        switch self {
        case .wood:  return Color(hex: 0x2E6B4A)  // 林绿
        case .fire:  return Color(hex: 0xFF6B35)  // 橙红底
        case .earth: return Color(hex: 0xA07E50)  // 深拿铁 (Dark Latte)
        case .metal: return Color(hex: 0xF2F2F7)  // 极浅灰
        case .water: return Color(hex: 0x004080)  // 深海蓝
        }
    }

    /// 光影 / 柔光色
    var meshHighlightColor: Color {
        switch self {
        case .wood:  return Color(hex: 0xD4E8B6)  // 青柠檬柔光
        case .fire:  return Color(hex: 0xFFCC00)  // 明黄柔光
        case .earth: return Color(hex: 0xD2B48C)  // 深肉桂色 (Deep Cinnamon)
        case .metal: return Color(hex: 0xFFFFFF)  // 纯白高光
        case .water: return Color(hex: 0x00AEEF)  // 青蓝外晕
        }
    }

    /// 中间过渡色
    var meshMidColor: Color {
        switch self {
        case .wood:  return Color(hex: 0x4A9A6E)  // 林地中调
        case .fire:  return Color(hex: 0xFF9500)  // 橙红过渡
        case .earth: return Color(hex: 0x9C6515)  // 深焦糖 (Deep Caramel)
        case .metal: return Color(hex: 0xD1D1D6)  // 冷银色
        case .water: return Color(hex: 0x0060A0)  // 深海蓝中调
        }
    }

    // MARK: - Energy Sphere 色系

    /// 内核实心色 (高饱和)
    var coreColor: Color {
        switch self {
        case .wood:  return Color(hex: 0x5A9E5A)  // 深翠绿
        case .fire:  return Color(hex: 0xFF3B30)  // 正红
        case .earth: return Color(hex: 0xC68E17)  // 焦糖色
        case .metal: return Color(hex: 0xC7C7CC)  // 冷银深调
        case .water: return Color(hex: 0x006699)  // 深海蓝中调
        }
    }

    /// 内辉光色 (较亮, blur 层)
    var glowColor: Color {
        switch self {
        case .wood:  return Color(hex: 0xD4E8B6)  // 青柠檬
        case .fire:  return Color(hex: 0xFF9500)  // 橙红辉光
        case .earth: return Color(hex: 0xF5D0A9)  // 杏色辉光
        case .metal: return Color(hex: 0xF2F2F7)  // 极浅灰辉光
        case .water: return Color(hex: 0x00AEEF)  // 青蓝
        }
    }

    // MARK: - 日历圆点色 (火单独高亮，金改为冷银)
    var calendarDotColor: Color {
        switch self {
        case .fire:   return Color(hex: 0xFF3B30)  // 正红
        case .metal:  return Color(hex: 0xD1D1D6)  // 冷银色
        default:      return color
        }
    }
    var calendarDotCoreColor: Color {
        switch self {
        case .fire:   return Color(hex: 0xE04030)  // 深朱核心
        case .metal:  return Color(hex: 0xC7C7CC)  // 冷银深调
        default:      return coreColor
        }
    }

    // MARK: - 渐变 (ElementExplanationSheet 用)
    var gradient: LinearGradient {
        switch self {
        case .wood:
            return LinearGradient(colors: [Color(hex: 0x2E6B4A), Color(hex: 0x6BAF6B)],
                                  startPoint: .bottom, endPoint: .top)
        case .fire:
            return LinearGradient(colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF3B30)],
                                  startPoint: .bottom, endPoint: .top)
        case .earth:
            return LinearGradient(colors: [Color(hex: 0xC68E17), Color(hex: 0xF5D0A9)],
                                  startPoint: .bottom, endPoint: .top)
        case .metal:
            return LinearGradient(colors: [Color(hex: 0xC7C7CC), Color(hex: 0xFFFFFF)],
                                  startPoint: .bottom, endPoint: .top)
        case .water:
            return LinearGradient(colors: [Color(hex: 0x004080), Color(hex: 0x00AEEF)],
                                  startPoint: .bottom, endPoint: .top)
        }
    }

    // MARK: - 详细解释文本
    var explanation: String {
        switch self {
        case .wood:
            return """
            【木】生发之气

            木主生长、舒展、条达。今日木气当令，万物萌发，适宜：

            • 开始新的计划与项目
            • 学习新知识、拓展视野
            • 户外活动，亲近自然
            • 表达创意，展现自我

            情志宜疏，忌郁结。保持心情舒畅，让生命能量自然流动。
            """
        case .fire:
            return """
            【火】明亮之气

            火主热情、光明、向上。今日火气当令，心神明亮，适宜：

            • 社交活动，增进感情
            • 演讲表达，展现魅力
            • 艺术创作，激发灵感
            • 重要决策，明辨是非

            情志宜喜，忌躁。让内心的热情温暖他人，而非灼伤自己。
            """
        case .earth:
            return """
            【土】承载之气

            土主稳重、包容、滋养。今日土气当令，厚德载物，适宜：

            • 整理空间，归纳物品
            • 照顾家人，关怀他人
            • 反思总结，沉淀经验
            • 饮食养生，调理脾胃

            情志宜思，忌虑。在稳定中找到力量，在包容中获得智慧。
            """
        case .metal:
            return """
            【金】收敛之气

            金主肃杀、决断、精纯。今日金气当令，去芜存菁，适宜：

            • 断舍离，清理不需要的事物
            • 完成收尾工作
            • 精简流程，提高效率
            • 冥想静心，内观自省

            情志宜收，忌悲。学会放下，在减法中找到生命的本质。
            """
        case .water:
            return """
            【水】蛰藏之气

            水主智慧、柔韧、潜藏。今日水气当令，静水流深，适宜：

            • 阅读思考，汲取智慧
            • 休息养神，储备能量
            • 倾听他人，理解包容
            • 随机应变，顺势而为

            情志宜静，忌恐。像水一样柔软而有力量，适应任何环境。
            """
        }
    }
}

// MARK: - Color Hex
extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >>  8) & 0xFF) / 255.0,
            blue:  Double( hex        & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}
