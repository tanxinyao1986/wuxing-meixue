import Foundation

final class ElementInsightLoader {
    static let shared = ElementInsightLoader()

    private var data: ElementInsightData?

    private init() {
        loadData()
    }

    private func loadData() {
        var url: URL?

        url = Bundle.main.url(forResource: "ElementInsights", withExtension: "json")

        if url == nil {
            url = Bundle.main.url(forResource: "ElementInsights", withExtension: "json", subdirectory: "Resources")
        }

        if url == nil {
            if let resourcePath = Bundle.main.resourcePath {
                let fileManager = FileManager.default
                if let enumerator = fileManager.enumerator(atPath: resourcePath) {
                    while let filename = enumerator.nextObject() as? String {
                        if filename.hasSuffix("ElementInsights.json") {
                            url = URL(fileURLWithPath: resourcePath).appendingPathComponent(filename)
                            break
                        }
                    }
                }
            }
        }

        guard let jsonURL = url else {
            print("[ElementInsightLoader] Error: ElementInsights.json not found in bundle")
            return
        }

        do {
            let jsonData = try Data(contentsOf: jsonURL)
            data = try JSONDecoder().decode(ElementInsightData.self, from: jsonData)
        } catch {
            print("[ElementInsightLoader] Error decoding JSON: \(error)")
        }
    }

    func insight(for element: FiveElement) -> ElementInsight {
        if let insight = data?.elements[element.rawValue] {
            return insight
        }
        return ElementInsight(
            opening: "当日五行能量澄明。",
            direction: "顺势而为，回到当下。",
            keywords: "今日能量关键词：平和 · 稳定 · 觉知",
            guidance: "让心绪安定，行动自然清晰。"
        )
    }
}
