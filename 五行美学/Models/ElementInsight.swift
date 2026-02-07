import Foundation

struct ElementInsightData: Codable {
    let elements: [String: ElementInsight]
}

struct ElementInsight: Codable {
    let opening: String
    let direction: String
    let keywords: String
    let guidance: String
}
