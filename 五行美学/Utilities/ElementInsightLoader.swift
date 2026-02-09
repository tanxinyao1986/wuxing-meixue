import Foundation

final class ElementInsightLoader {
    static let shared = ElementInsightLoader()

    private var data: ElementInsightData?

    private init() {
        loadData()
    }

    /// 获取当前语言对应的 JSON 文件名后缀
    private static var languageSuffix: String {
        let preferred = Locale.preferredLanguages.first ?? "zh-Hans"
        if preferred.hasPrefix("zh-Hant") || preferred.hasPrefix("zh-TW") || preferred.hasPrefix("zh-HK") {
            return "_zh-Hant"
        } else if preferred.hasPrefix("ja") {
            return "_ja"
        }
        return ""
    }

    private func loadData() {
        let suffix = Self.languageSuffix
        let resourceName = suffix.isEmpty ? "ElementInsights" : "ElementInsights\(suffix)"

        let url = findJSON(named: resourceName) ?? findJSON(named: "ElementInsights")

        guard let jsonURL = url else {
            print("[ElementInsightLoader] Error: ElementInsights.json not found in bundle")
            return
        }

        do {
            let jsonData = try Data(contentsOf: jsonURL)
            data = try JSONDecoder().decode(ElementInsightData.self, from: jsonData)
            print("[ElementInsightLoader] Successfully loaded \(jsonURL.lastPathComponent)")
        } catch {
            print("[ElementInsightLoader] Error decoding JSON: \(error)")
        }
    }

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

    func insight(for element: FiveElement) -> ElementInsight {
        if let insight = data?.elements[element.rawValue] {
            return insight
        }
        return ElementInsight(
            opening: String(localized: "当日五行能量澄明。"),
            direction: String(localized: "顺势而为，回到当下。"),
            keywords: String(localized: "今日能量关键词：平和 · 稳定 · 觉知"),
            guidance: String(localized: "让心绪安定，行动自然清晰。")
        )
    }
}
