import SwiftUI
import UIKit

enum AppFont {
    /// 展示级：用于标题、核心数字（宋体系）
    static func display(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        preferred(names: ["Songti SC", "STSong", "Songti TC"], size: size, weight: weight, design: .serif)
    }

    /// 叙事级：用于长文、解读与段落（楷体系）
    static func narrative(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        preferred(names: ["Kaiti SC", "STKaitiSC-Regular", "STKaiti"], size: size, weight: weight, design: .serif)
    }

    /// 笔触级：用于关键词与强调（手写/毛笔感）
    static func calligraphy(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        preferred(names: ["XingKai SC", "STXingkai", "HanziPen SC", "HanziPen TC", "Kaiti SC"], size: size, weight: weight, design: .serif)
    }

    /// UI级：用于按钮、标签、辅助信息
    static func ui(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        preferred(names: ["PingFang SC", "PingFang TC"], size: size, weight: weight, design: .default)
    }

    private static func preferred(names: [String], size: CGFloat, weight: Font.Weight, design: Font.Design) -> Font {
        for name in names {
            if UIFont(name: name, size: size) != nil {
                return Font.custom(name, size: size).weight(weight)
            }
        }
        return Font.system(size: size, weight: weight, design: design)
    }
}
