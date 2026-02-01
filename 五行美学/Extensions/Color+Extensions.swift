import SwiftUI

extension Color {
    /// App主背景色 - 深邃的深色
    static let appBackground = Color(red: 0.05, green: 0.05, blue: 0.08)

    /// App浅色背景
    static let appBackgroundLight = Color(red: 0.96, green: 0.96, blue: 0.98)

    /// 中央圆环边框色
    static let ringBorder = Color.white.opacity(0.3)

    /// 次要文本颜色
    static let secondaryText = Color.gray

    /// 卡片背景色
    static let cardBackground = Color.white.opacity(0.1)
}

// MARK: - 动态背景
struct AppBackground: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Group {
            if colorScheme == .dark {
                ZStack {
                    // 深色渐变背景
                    LinearGradient(
                        colors: [
                            Color(red: 0.03, green: 0.03, blue: 0.06),
                            Color(red: 0.08, green: 0.06, blue: 0.12),
                            Color(red: 0.05, green: 0.05, blue: 0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    // 微妙的噪点纹理
                    NoiseTexture()
                        .opacity(0.03)
                }
            } else {
                ZStack {
                    // 浅色渐变背景
                    LinearGradient(
                        colors: [
                            Color(red: 0.98, green: 0.98, blue: 1.0),
                            Color(red: 0.95, green: 0.95, blue: 0.98),
                            Color(red: 0.96, green: 0.96, blue: 0.99)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    // 微妙的噪点纹理
                    NoiseTexture()
                        .opacity(0.02)
                }
            }
        }
        .ignoresSafeArea()
    }
}

/// 噪点纹理视图
struct NoiseTexture: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<Int(size.width * size.height / 100) {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let opacity = CGFloat.random(in: 0.1...0.3)

                context.opacity = opacity
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: 1, height: 1)),
                    with: .color(.white)
                )
            }
        }
    }
}
