import SwiftUI

/// 今日光球 — 三层 2D 模糊光晕叠加，无实体感，纯"自发光体"。
/// 禅意呼吸动画：Scale↑ → Opacity↓ → Blur↑ 三维协同，4s 极慢周期。
/// 架构：光晕层(动) + 内核层(微动) + 文字层(静止)
struct CentralRingView: View {
    let dayInfo: DayInfo

    /// 0→1 循环，驱动光晕呼吸动画
    @State private var breath: Double = 0
    /// 内核微呼吸，幅度极小
    @State private var coreBreath: Double = 0
    /// 太极纹理旋转
    @State private var taiChiRotation: Double = 0

    var body: some View {
        ZStack {
            // ═══ 中间层：视觉效果层 (Visual Effect Layer) ═══
            atmosphereLayer   // Layer 3 — 最外，极大模糊（明显呼吸）
                .allowsHitTesting(false)
            innerGlowLayer    // Layer 2 — 中层辉光（明显呼吸）

            // ═══ 内核层：承载文字的容器 (Core Layer) ═══
            coreLayer         // Layer 1 — 内核实心（微弱呼吸）

            // ═══ 太极纹理层：若隐若现，缓慢旋转 ═══
            taiChiLayer

            // ═══ 最顶层：内容层 (Content Layer - 绝对静止) ═══
            textLayer         // 文字始终锐利，不参与任何动画
        }
        .onAppear {
            startBreathingAnimation()
            startTaiChiRotation()
        }
    }

    // MARK: - 启动呼吸动画
    private func startBreathingAnimation() {
        // 光晕层：明显的呼吸效果
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            breath = 1
        }
        // 内核层：极其微弱的呼吸，延迟启动形成层次感
        withAnimation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true).delay(0.5)) {
            coreBreath = 1
        }
    }

    // MARK: - 启动太极缓慢旋转
    private func startTaiChiRotation() {
        withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
            taiChiRotation = 360
        }
    }

    // MARK: - Layer 3: Atmosphere (外逸散) — 明显呼吸
    /// 极大圆, 呼吸时：scale↑ blur↑ opacity↓
    private var atmosphereLayer: some View {
        Circle()
            .fill(dayInfo.element.glowColor)
            .frame(width: atmosphereSize, height: atmosphereSize)
            .scaleEffect(1.0 + breath * 0.18)        // 1.0 → 1.18 (扩张)
            .opacity(0.28 - breath * 0.14)            // 0.28 → 0.14 (变淡)
            .blur(radius: 50 + breath * 15)           // 50 → 65 (边缘虚化)
    }

    // MARK: - Layer 2: Inner Glow (内辉光) — 明显呼吸
    /// 中圆, 呼吸时：scale↑ blur↑ opacity↓
    private var innerGlowLayer: some View {
        Circle()
            .fill(dayInfo.element.glowColor)
            .frame(width: innerGlowSize, height: innerGlowSize)
            .scaleEffect(1.0 + breath * 0.15)        // 1.0 → 1.15 (扩张)
            .opacity(0.75 - breath * 0.18)            // 0.75 → 0.57 (变淡)
            .blur(radius: 8 + breath * 8)             // 8 → 16 (边缘虚化)
    }

    // MARK: - 尺寸常量
    private let sphereSize: CGFloat = 240
    private let innerGlowSize: CGFloat = 150
    private let atmosphereSize: CGFloat = 300
    private let taiChiSize: CGFloat = 220

    private var taiChiBlendMode: BlendMode {
        if dayInfo.element == .metal || dayInfo.element == .earth {
            return .softLight
        }
        return .overlay
    }

    private var taiChiOpacity: Double {
        if dayInfo.element == .metal || dayInfo.element == .earth {
            return 0.48
        }
        return 0.38
    }

    // MARK: - Layer 1: Core (内核容器) — 极微弱呼吸
    /// 毛玻璃容器，染色 opacity 微弱变化，维持玻璃质感但不透底
    private var coreLayer: some View {
        Circle()
            .fill(Color.clear)
            .frame(width: sphereSize, height: sphereSize)
            .scaleEffect(1.0 + coreBreath * 0.02)      // 1.0 → 1.02 (几乎不可察觉)
            .shadow(color: .clear, radius: 0, x: 0, y: 0)
    }

    // MARK: - TaiChi Layer (内核纹理层)
    private var taiChiLayer: some View {
        Image("TaiChiSymbol")
            .resizable()
            .scaledToFit()
            .frame(width: taiChiSize, height: taiChiSize)
            .blendMode(taiChiBlendMode)
            .opacity(taiChiOpacity)
            .rotationEffect(.degrees(taiChiRotation))
            .blur(radius: 0.35)
            .clipShape(Circle().inset(by: 6))
            .allowsHitTesting(false)
            .compositingGroup()
            .drawingGroup()
    }

    // MARK: - Text (最顶层 — 绝对静止，始终锐利)
    /// 文字独立于所有动画，保持 opacity: 1.0 和清晰度
    private var textLayer: some View {
        VStack(spacing: 3) {
            // 大日期数字 — Serif Light，纯白
            Text(dayInfo.gregorianDateString)
                .font(AppFont.display(58, weight: .light))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)

            // 农历 — PingFang SC + tracking
            Text(LunarCalendar.lunarDateString(for: dayInfo.date))
                .font(AppFont.ui(12))
                .tracking(2)
                .foregroundStyle(dayInfo.element.isLightBackground ? dayInfo.element.primaryTextColor.opacity(0.65) : .white.opacity(0.75))
                .shadow(color: .black.opacity(0.20), radius: 3, x: 0, y: 1)

            // 核心关键词 — 24pt Bold 纯白
            Text(dayInfo.mainKeyword)
                .font(AppFont.calligraphy(26, weight: .semibold))
                .tracking(2)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.30), radius: 5, x: 0, y: 2)
        }
    }
}
