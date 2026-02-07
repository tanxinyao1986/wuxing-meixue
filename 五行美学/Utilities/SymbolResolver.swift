import UIKit

enum SymbolResolver {
    static func resolve(candidates: [String], fallback: String) -> String {
        for name in candidates {
            if UIImage(systemName: name) != nil {
                return name
            }
        }
        return fallback
    }
}
