import Foundation

/// 内容加载器 - 单例模式
/// 负责从 Bundle 加载五行文案数据，并提供基于日期的伪随机内容获取
final class ContentLoader {

    // MARK: - Singleton

    static let shared = ContentLoader()

    // MARK: - Properties

    private var data: FiveElementsData?

    /// 数据是否已加载
    var isLoaded: Bool {
        data != nil
    }

    // MARK: - Initialization

    private init() {
        loadData()
    }

    // MARK: - Data Loading

    /// 获取当前语言对应的 JSON 文件名后缀
    private static var languageSuffix: String {
        let preferred = Locale.preferredLanguages.first ?? "zh-Hans"
        if preferred.hasPrefix("zh-Hant") || preferred.hasPrefix("zh-TW") || preferred.hasPrefix("zh-HK") {
            return "_zh-Hant"
        } else if preferred.hasPrefix("ja") {
            return "_ja"
        }
        return "" // 简体中文（基础文件）
    }

    /// 从 Bundle 加载 JSON 数据（根据当前语言选择对应文件）
    private func loadData() {
        let suffix = Self.languageSuffix
        let resourceName = suffix.isEmpty ? "FiveElementsData" : "FiveElementsData\(suffix)"

        // 优先加载对应语言文件，回退到基础文件
        let url = findJSON(named: resourceName) ?? findJSON(named: "FiveElementsData")

        guard let jsonURL = url else {
            print("[ContentLoader] Error: FiveElementsData.json not found in bundle")
            print("[ContentLoader] Bundle path: \(Bundle.main.bundlePath)")
            return
        }

        do {
            let jsonData = try Data(contentsOf: jsonURL)
            let decoder = JSONDecoder()
            data = try decoder.decode(FiveElementsData.self, from: jsonData)
            print("[ContentLoader] Successfully loaded \(jsonURL.lastPathComponent)")
        } catch {
            print("[ContentLoader] Error decoding JSON: \(error)")
        }
    }

    /// 在 Bundle 中查找指定名称的 JSON 文件
    private func findJSON(named name: String) -> URL? {
        if let url = Bundle.main.url(forResource: name, withExtension: "json") {
            return url
        }
        if let url = Bundle.main.url(forResource: name, withExtension: "json", subdirectory: "Resources") {
            return url
        }
        if let resourcePath = Bundle.main.resourcePath {
            let fileManager = FileManager.default
            if let enumerator = fileManager.enumerator(atPath: resourcePath) {
                while let filename = enumerator.nextObject() as? String {
                    if filename.hasSuffix("\(name).json") {
                        return URL(fileURLWithPath: resourcePath).appendingPathComponent(filename)
                    }
                }
            }
        }
        return nil
    }

    /// 手动重新加载数据（用于调试或热更新）
    func reloadData() {
        loadData()
    }

    // MARK: - Content Access

    /// 获取指定元素和模块的内容
    /// 使用基于日期的伪随机算法，确保同一天返回相同内容
    /// - Parameters:
    ///   - element: 五行元素
    ///   - module: 指南模块
    ///   - date: 日期（默认为今天）
    /// - Returns: 对应的文案内容，如果数据未加载则返回默认文案
    func getContent(for element: FiveElement, module: GuideModule, date: Date = Date()) -> String {
        guard let data = data else {
            return getDefaultContent(for: module)
        }

        let contents = data.elements.content(for: element).modules.contents(for: module)

        guard !contents.isEmpty else {
            return getDefaultContent(for: module)
        }

        // 基于日期的伪随机索引
        let index = dateBasedIndex(for: date, element: element, module: module, count: contents.count)
        return contents[index]
    }

    /// 获取指定元素和模块的所有内容
    /// - Parameters:
    ///   - element: 五行元素
    ///   - module: 指南模块
    /// - Returns: 所有文案内容数组
    func getAllContents(for element: FiveElement, module: GuideModule) -> [String] {
        guard let data = data else {
            return [getDefaultContent(for: module)]
        }
        return data.elements.content(for: element).modules.contents(for: module)
    }

    /// 获取指定元素的关键词
    /// - Parameter element: 五行元素
    /// - Returns: 关键词数组
    func getKeywords(for element: FiveElement) -> [String] {
        guard let data = data else {
            return []
        }
        return data.elements.content(for: element).keywords
    }

    /// 获取指定元素的单条关键词（基于日期稳定）
    func keyword(for element: FiveElement, date: Date = Date()) -> String {
        let keywords = getKeywords(for: element)
        guard !keywords.isEmpty else {
            return String(localized: "平和安宁")
        }
        let index = dateBasedIndex(for: date, element: element, salt: "keyword", count: keywords.count)
        return keywords[index]
    }

    /// 获取随机内容（纯随机，每次调用可能不同）
    /// - Parameters:
    ///   - element: 五行元素
    ///   - module: 指南模块
    /// - Returns: 随机选取的文案内容
    func getRandomContent(for element: FiveElement, module: GuideModule) -> String {
        guard let data = data else {
            return getDefaultContent(for: module)
        }

        let contents = data.elements.content(for: element).modules.contents(for: module)
        return contents.randomElement() ?? getDefaultContent(for: module)
    }

    // MARK: - Private Methods

    /// 基于日期的伪随机索引生成
    /// 同一天、同一元素、同一模块返回相同索引
    private func dateBasedIndex(for date: Date, element: FiveElement, module: GuideModule, count: Int) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        // 创建唯一的哈希种子
        var hasher = Hasher()
        hasher.combine(components.year)
        hasher.combine(components.month)
        hasher.combine(components.day)
        hasher.combine(element.rawValue)
        hasher.combine(module.rawValue)

        let hashValue = hasher.finalize()
        // 确保索引为正数
        let positiveHash = abs(hashValue)
        return positiveHash % count
    }

    /// 基于日期 + salt 的伪随机索引（用于关键词等非模块场景）
    private func dateBasedIndex(for date: Date, element: FiveElement, salt: String, count: Int) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        var hasher = Hasher()
        hasher.combine(components.year)
        hasher.combine(components.month)
        hasher.combine(components.day)
        hasher.combine(element.rawValue)
        hasher.combine(salt)

        let hashValue = hasher.finalize()
        let positiveHash = abs(hashValue)
        return positiveHash % count
    }

    /// 获取默认内容（数据未加载时的备用）
    private func getDefaultContent(for module: GuideModule) -> String {
        switch module {
        case .dress:
            return String(localized: "今日宜穿舒适自然的衣物，让身心与自然和谐共振。")
        case .food:
            return String(localized: "顺应时节，选择当季食材，滋养身心。")
        case .space:
            return String(localized: "整理空间，让能量自由流动，创造宁静的环境。")
        case .action:
            return String(localized: "顺势而为，把握时机，让行动与自然节律同步。")
        case .anchor:
            return String(localized: "此刻，我与自然同频共振，内心平静而有力量。")
        }
    }
}
