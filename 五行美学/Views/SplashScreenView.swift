import SwiftUI

/// 开屏动画 —【混沌初开 · 气韵生发】v3
/// 图片已更新为透明底太极图，去除 .multiply 扣底
/// 太极放大至 300pt，动画总时长延长至 ~4s，让用户充分感受
/// 时间轴：凝聚(0-1s) → 蕴育(1-3s) → 觉醒爆发(3-4s)
struct SplashScreenView: View {

    // MARK: - 动画状态

    /// 太极图从无到有的出场
    @State private var taiChiAppeared = false
    /// 水墨光斑呼吸缩放
    @State private var breathing = false
    /// 水墨光斑整体旋转角度
    @State private var orbRotation: Double = 0
    /// Slogan 可见
    @State private var sloganVisible = false
    /// 爆发：15x 扩散 + 消隐
    @State private var burstTriggered = false
    /// 太极自转角度
    @State private var taiChiAngle: Double = 0

    var body: some View {
        ZStack {
            // ═══ Layer 0: 宣纸底 ═══
            paperBase

            // ═══ Layer 1: 五色水墨 (正片叠底) ═══
            inkFlowLayer
                .blendMode(.multiply)
                .rotationEffect(.degrees(orbRotation))
                .scaleEffect(burstTriggered ? 15.0 : 1.0)
                .opacity(burstTriggered ? 0.0 : 1.0)

            // ═══ Layer 2: 太极 + Slogan ═══
            seedLayer
                .opacity(burstTriggered ? 0.0 : 1.0)
                .scaleEffect(burstTriggered ? 2.0 : 1.0)
        }
        .ignoresSafeArea()
        .onAppear(perform: startTimeline)
    }

    // MARK: - Layer 0: 珍珠母贝宣纸底

    private var paperBase: some View {
        ZStack {
            Color(hex: 0xFAFAF5)
            NoiseTextureOverlay()
                .opacity(0.06)
        }
    }

    // MARK: - Layer 1: 五色水墨氤氲

    private static let inkColors: [Color] = [
        Color(hex: 0xA8D8B9),   // 木 — 水绿
        Color(hex: 0xFFB7B2),   // 火 — 淡绯
        Color(hex: 0xE2CFB4),   // 土 — 赭石
        Color(hex: 0xE0E0E0),   // 金 — 银灰
        Color(hex: 0xAEC6CF),   // 水 — 天青
    ]

    private var inkFlowLayer: some View {
        let scale: CGFloat = breathing ? 1.2 : 1.0

        return ZStack {
            ForEach(0..<5, id: \.self) { i in
                let angle = Double(i) * 137.5 * .pi / 180.0
                let radius: CGFloat = 65

                Circle()
                    .fill(Self.inkColors[i])
                    .frame(width: 240, height: 240)
                    .blur(radius: 90)
                    .offset(
                        x: cos(angle) * radius,
                        y: sin(angle) * radius
                    )
                    .scaleEffect(scale + CGFloat(i) * 0.03)
            }
        }
    }

    // MARK: - Layer 2: 太极种子 + Slogan

    private var seedLayer: some View {
        VStack(spacing: 24) {
            // 太极图 — 透明底图片，放大至 300pt
            Image("TaiChiSymbol")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .rotationEffect(.degrees(taiChiAngle))
                .opacity(taiChiAppeared ? 0.88 : 0.0)
                .scaleEffect(taiChiAppeared ? 1.0 : 0.3)

            // Slogan
            Text("流转 · 平衡")
                .font(AppFont.calligraphy(20, weight: .light))
                .tracking(8)
                .foregroundStyle(Color(hex: 0x6E6E73))
                .opacity(sloganVisible ? 1.0 : 0.0)
                .offset(y: sloganVisible ? 0 : 8)
        }
    }

    // MARK: - 动画时间轴 (总 ~4s)

    private func startTimeline() {

        // ── 太极缓转 (立即启动，贯穿全程) ──
        withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
            taiChiAngle = 360
        }

        // ── Phase 1 凝聚 (0s): 太极从小到大浮现 ──
        withAnimation(.spring(response: 1.2, dampingFraction: 0.7)) {
            taiChiAppeared = true
        }

        // ── Phase 2 蕴育: 光斑呼吸 (0s → 持续) ──
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            breathing = true
        }

        // ── Phase 2 蕴育: 光斑缓慢旋转 ──
        withAnimation(.linear(duration: 12.0).repeatForever(autoreverses: false)) {
            orbRotation = 360
        }

        // ── Slogan 淡入 (0.8s 延迟，太极出现后再显示) ──
        withAnimation(.easeOut(duration: 0.8).delay(0.8)) {
            sloganVisible = true
        }

        // ── Phase 3 觉醒爆发 (3.0s): 15x 穿云 + 消隐 ──
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            HapticManager.bloom()
            withAnimation(.easeIn(duration: 0.7)) {
                burstTriggered = true
            }
        }
    }
}
