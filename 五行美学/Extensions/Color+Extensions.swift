import SwiftUI

// MARK: - 静态色常量 (保持外部兼容)
extension Color {
    static let appBackground      = Color(red: 0.05, green: 0.05, blue: 0.08)
    static let appBackgroundLight = Color(red: 0.96, green: 0.96, blue: 0.98)
    static let ringBorder         = Color.white.opacity(0.3)
    static let secondaryText      = Color.gray
    static let cardBackground     = Color.white.opacity(0.1)
}

// MARK: - 五行 Mesh 背景
/// 严格执行指定色值。底层 MeshGradient + 噪点覆盖 + 流体微动。
struct ElementMeshBackground: View {
    let element: FiveElement
    /// 控制 Mesh 顶点微弱变形
    @State private var phase: Double = 0
    /// 控制色相微转 (Liquid Flow)
    @State private var huePhase: Double = 0

    var body: some View {
        ZStack {
            meshLayer
                // 流体微动：色相微转 ±5度，10秒周期
                .hueRotation(.degrees(huePhase * 5))
            noiseOverlay
        }
        .ignoresSafeArea()
        .onAppear {
            startLiquidFlowAnimation()
        }
    }

    // MARK: - 启动流体微动动画
    private func startLiquidFlowAnimation() {
        // Mesh 顶点缓动
        withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
            phase = 1
        }
        // 色相微转：极其缓慢，肉眼几乎察觉不到颜色变化，只觉得"光在动"
        withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
            huePhase = 1
        }
    }

    // MARK: - Mesh / Fallback
    @ViewBuilder
    private var meshLayer: some View {
        if #available(iOS 18.0, *) {
            ZStack {
                element.meshBaseColor
                MeshGradient(width: 3, height: 3, points: points, colors: colors)
                    .blur(radius: 50)
            }
        } else {
            fallbackLayer
        }
    }

    // 控制点随 phase 缓动
    private var points: [SIMD2<Float>] {
        let d = Float(phase * 0.08)
        return [
            SIMD2(0,   0),   SIMD2(0.5 + d, 0),   SIMD2(1, 0),
            SIMD2(0,   0.5 - d), SIMD2(0.5,     0.5), SIMD2(1, 0.5 + d),
            SIMD2(0,   1),   SIMD2(0.5 - d, 1),   SIMD2(1, 1)
        ]
    }

    // 9 色矩阵 — 浅色元素(木土金)高亮主导，深色元素(火水)base 主导
    private var colors: [Color] {
        let B = element.meshBaseColor
        let M = element.meshMidColor
        let H = element.meshHighlightColor
        if element.isLightBackground {
            // 浅色体：用 M / H 实体色填充，消除黑角
            return [
                M,   H,   M,
                H,   H,   H,
                M,   H,   M
            ]
        }
        return [
            B,                  H.opacity(0.5),     B,
            M.opacity(0.7),     H.opacity(0.35),    M.opacity(0.6),
            B,                  M.opacity(0.8),     B
        ]
    }

    // iOS 17 fallback：多层径向渐变模拟
    private var fallbackLayer: some View {
        ZStack {
            // 浅色元素以 highlight 为底，深色元素以 base 为底
            element.isLightBackground ? element.meshHighlightColor : element.meshBaseColor

            RadialGradient(
                colors: [element.meshMidColor.opacity(element.isLightBackground ? 0.50 : 0.45),
                         Color.clear],
                center: UnitPoint(x: 0.4 + phase * 0.15, y: 0.18),
                startRadius: 40, endRadius: 320
            )

            RadialGradient(
                colors: [element.meshMidColor.opacity(0.35), Color.clear],
                center: UnitPoint(x: 0.65 - phase * 0.1, y: 0.72),
                startRadius: 60, endRadius: 300
            )
        }
    }

    // MARK: - Noise (纸质 / 胶片感)
    private var noiseOverlay: some View {
        NoiseTextureOverlay()
            .opacity(noiseOpacity)
    }

    private var noiseOpacity: Double {
        switch element {
        case .wood:  return 0.045
        case .fire:  return 0.035
        case .earth: return 0.055   // 暖色噪点
        case .metal: return 0.040   // 亮底需更多质感
        case .water: return 0.030
        }
    }
}

// MARK: - 噪点贴图
/// drawingGroup 一次光栅化，避免逐帧重绘。
struct NoiseTextureOverlay: View {
    var body: some View {
        Canvas { ctx, size in
            let count = Int(size.width * size.height / 55)
            for _ in 0..<count {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let a = CGFloat.random(in: 0.04...0.22)
                let r = CGFloat.random(in: 0.4...1.4)
                ctx.opacity = a
                ctx.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r)),
                    with: .color(.white)
                )
            }
        }
        .drawingGroup()
    }
}

// MARK: - 兼容层
struct AppBackground: View {
    var element: FiveElement = .water
    var body: some View { ElementMeshBackground(element: element) }
}
