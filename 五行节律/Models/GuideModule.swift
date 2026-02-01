import SwiftUI

/// 五个指导模块
enum GuideModule: String, CaseIterable, Identifiable {
    case dress = "能量着装"
    case food = "顺时食饮"
    case space = "身心空间"
    case action = "行动指南"
    case anchor = "心念之锚"

    var id: String { rawValue }

    /// 模块对应的五行元素
    var element: FiveElement {
        switch self {
        case .dress: return .wood
        case .food: return .fire
        case .space: return .earth
        case .action: return .metal
        case .anchor: return .water
        }
    }

    /// 模块图标
    var iconName: String {
        element.iconName
    }

    /// 模块颜色
    var color: Color {
        element.color
    }

    /// VoiceOver无障碍标签
    var accessibilityLabel: String {
        switch self {
        case .dress: return "能量着装，木元素，点击查看今日穿搭建议"
        case .food: return "顺时食饮，火元素，点击查看今日饮食建议"
        case .space: return "身心空间，土元素，点击查看今日空间建议"
        case .action: return "行动指南，金元素，点击查看今日行动建议"
        case .anchor: return "心念之锚，水元素，点击查看今日心念建议"
        }
    }

    /// 获取模块内容（占位符）
    func content(for dayInfo: DayInfo) -> ModuleContent {
        switch self {
        case .dress:
            return ModuleContent(
                title: "今日能量着装",
                subtitle: "与\(dayInfo.element.rawValue)气共振",
                items: [
                    "主色调：\(dayInfo.element.color.description)",
                    "推荐款式：舒适自然的剪裁",
                    "配饰建议：简约而有质感",
                    "材质推荐：天然纤维面料"
                ],
                tip: "穿着能量色，让外在与内在和谐共振。"
            )
        case .food:
            return ModuleContent(
                title: "今日顺时食饮",
                subtitle: "滋养身心的选择",
                items: [
                    "晨起：温水唤醒身体",
                    "早餐：均衡营养开启一天",
                    "午餐：适量进食，不过饱",
                    "晚餐：清淡为主，早食为宜"
                ],
                tip: "顺应时节，让食物成为身体的良药。"
            )
        case .space:
            return ModuleContent(
                title: "今日身心空间",
                subtitle: "创造滋养的环境",
                items: [
                    "整理桌面，清理杂物",
                    "开窗通风，让能量流动",
                    "点一支清香或摆放绿植",
                    "调整灯光至舒适亮度"
                ],
                tip: "外在空间的整洁，映射内心的清明。"
            )
        case .action:
            return ModuleContent(
                title: "今日行动指南",
                subtitle: "顺势而为的智慧",
                items: [
                    "宜：开始新项目、学习新技能",
                    "宜：与人沟通、表达想法",
                    "慎：做重大决定前多思考",
                    "忌：急躁冒进、强求结果"
                ],
                tip: "行动与等待同样重要，关键在于时机。"
            )
        case .anchor:
            return ModuleContent(
                title: "今日心念之锚",
                subtitle: "一句话的力量",
                items: [
                    "「此刻，我与自然同频共振。」",
                    "「我信任生命的节奏。」",
                    "「每一步都是最好的安排。」"
                ],
                tip: "当心绪不宁时，回到这句话，找到内心的锚点。"
            )
        }
    }
}

/// 模块内容结构
struct ModuleContent {
    let title: String
    let subtitle: String
    let items: [String]
    let tip: String
}
