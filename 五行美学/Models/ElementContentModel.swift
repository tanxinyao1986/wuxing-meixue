import Foundation

/// 五行文案数据根结构
struct FiveElementsData: Codable {
    let version: String
    let elements: ElementsContainer
}

/// 五行元素容器
struct ElementsContainer: Codable {
    let wood: ElementContent
    let fire: ElementContent
    let earth: ElementContent
    let metal: ElementContent
    let water: ElementContent

    /// 根据 FiveElement 枚举获取对应内容
    func content(for element: FiveElement) -> ElementContent {
        switch element {
        case .wood: return wood
        case .fire: return fire
        case .earth: return earth
        case .metal: return metal
        case .water: return water
        }
    }
}

/// 单个元素的内容
struct ElementContent: Codable {
    let elementName: String
    let keywords: [String]
    let modules: ModulesContent
}

/// 模块内容容器
struct ModulesContent: Codable {
    let attire: [String]   // 能量着装
    let diet: [String]     // 顺时食饮
    let space: [String]    // 身心空间
    let action: [String]   // 行动指南
    let anchor: [String]   // 心念之锚

    /// 根据 GuideModule 枚举获取对应内容数组
    func contents(for module: GuideModule) -> [String] {
        switch module {
        case .dress: return attire
        case .food: return diet
        case .space: return space
        case .action: return action
        case .anchor: return anchor
        }
    }
}

/// 模块类型枚举（用于类型安全的访问）
enum ModuleType: String, CaseIterable {
    case attire
    case diet
    case space
    case action
    case anchor

    /// 转换为 GuideModule
    var guideModule: GuideModule {
        switch self {
        case .attire: return .dress
        case .diet: return .food
        case .space: return .space
        case .action: return .action
        case .anchor: return .anchor
        }
    }
}
