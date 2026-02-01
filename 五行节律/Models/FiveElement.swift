import SwiftUI

/// 五行元素枚举
enum FiveElement: String, CaseIterable, Identifiable {
    case wood = "木"
    case fire = "火"
    case earth = "土"
    case metal = "金"
    case water = "水"

    var id: String { rawValue }

    /// 元素对应的SF Symbol图标
    var iconName: String {
        switch self {
        case .wood: return "leaf.fill"
        case .fire: return "flame.fill"
        case .earth: return "mountain.2.fill"
        case .metal: return "sparkles"
        case .water: return "drop.fill"
        }
    }

    /// 元素对应的颜色
    var color: Color {
        switch self {
        case .wood: return Color(red: 0.4, green: 0.7, blue: 0.4)
        case .fire: return Color(red: 0.9, green: 0.3, blue: 0.2)
        case .earth: return Color(red: 0.76, green: 0.6, blue: 0.3)
        case .metal: return Color(red: 0.85, green: 0.85, blue: 0.9)
        case .water: return Color(red: 0.3, green: 0.5, blue: 0.8)
        }
    }

    /// 元素的渐变色
    var gradient: LinearGradient {
        switch self {
        case .wood:
            return LinearGradient(
                colors: [Color(red: 0.2, green: 0.5, blue: 0.3), Color(red: 0.4, green: 0.7, blue: 0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .fire:
            return LinearGradient(
                colors: [Color(red: 0.9, green: 0.2, blue: 0.1), Color(red: 1.0, green: 0.5, blue: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .earth:
            return LinearGradient(
                colors: [Color(red: 0.6, green: 0.45, blue: 0.2), Color(red: 0.8, green: 0.65, blue: 0.35)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .metal:
            return LinearGradient(
                colors: [Color(red: 0.7, green: 0.7, blue: 0.75), Color(red: 0.95, green: 0.95, blue: 1.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .water:
            return LinearGradient(
                colors: [Color(red: 0.1, green: 0.3, blue: 0.6), Color(red: 0.3, green: 0.5, blue: 0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    /// 元素的详细解释
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
