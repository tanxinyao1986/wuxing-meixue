import SwiftUI

/// 单个功能模块图标 — Cradle (托举弧线) 布局节点。
/// 常态：半透明磨砂 + 智能图标色；选中态：五行主色背景 + 白色图标 100%。
/// 动画：异步悬浮 (Asynchronous Floating)，每个图标有不同延迟形成波浪效果。
struct ModuleIconView: View {
    let module: GuideModule
    let isSelected: Bool
    let isOtherSelected: Bool   // 其他模块被选中时淡化
    let position: CGPoint       // 由父视图通过弧线公式计算传入
    var currentElement: FiveElement = .water  // 当前五行元素，用于适配文字颜色
    var index: Int = 0          // 图标索引，用于计算异步延迟

    /// 悬浮动画状态
    @State private var isFloating: Bool = false

    /// 悬浮偏移量：极其微小 (3pt)，形成波浪起伏
    private var floatingOffset: CGFloat {
        isFloating ? -3 : 3
    }

    /// 基于 index 的延迟，形成波浪效果
    private var floatingDelay: Double {
        Double(index) * 0.25  // 每个图标延迟 0.25s
    }

    /// 中心模块轻微上浮，增强层级与动势
    private var centerLift: CGFloat {
        let distance = abs(index - 2)
        switch distance {
        case 0: return -4
        case 1: return -2
        default: return 0
        }
    }

    var body: some View {
        VStack(spacing: 6) {
            iconCircle
            label
        }
        .position(position)
        .offset(y: floatingOffset + centerLift)
        .opacity(isOtherSelected ? 0.35 : 1.0)
        .animation(.easeInOut(duration: 0.35), value: isOtherSelected)
        .onAppear {
            startFloatingAnimation()
        }
    }

    // MARK: - 启动异步悬浮动画
    private func startFloatingAnimation() {
        withAnimation(
            .easeInOut(duration: 2.5)
            .repeatForever(autoreverses: true)
            .delay(floatingDelay)
        ) {
            isFloating = true
        }
    }

    // MARK: - 智能图标/文字颜色
    /// 金 (Metal) 背景为银白色，需要深色文字；其他保持白色体系
    private var iconColor: Color {
        if currentElement.isLightBackground {
            return isSelected ? Color.white : Color(hex: 0x333333).opacity(0.6)
        } else {
            return isSelected ? Color.white : Color.white.opacity(0.70)
        }
    }

    private var labelColor: Color {
        if currentElement.isLightBackground {
            return isSelected ? Color(hex: 0x333333) : Color(hex: 0x333333).opacity(0.6)
        } else {
            return isSelected ? Color.white : Color.white.opacity(0.70)
        }
    }

    private var strokeColor: Color {
        if currentElement.isLightBackground {
            return isSelected ? Color.clear : Color(hex: 0x333333).opacity(0.20)
        } else {
            return isSelected ? Color.clear : Color.white.opacity(0.25)
        }
    }

    // MARK: - 图标圆
    private var iconCircle: some View {
        return ZStack {
            // 背景圆 — 选中态实心色，常态磨砂 + 薄边框
            Circle()
                .fill(isSelected ? module.color : Color.clear)
                .overlay(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .opacity(isSelected ? 0 : 1)
                )
                .overlay(
                    Circle()
                        .stroke(strokeColor, lineWidth: 0.5)
                )
                .frame(width: 56, height: 56)
                .shadow(color: isSelected
                        ? module.color.opacity(0.45)
                        : .black.opacity(0.12),
                        radius: isSelected ? 12 : 6, x: 0, y: 4)

            // SF Symbol — 智能颜色
            Image(systemName: module.iconName)
                .font(.system(size: 23, weight: .light))
                .foregroundStyle(iconColor)
        }
    }

    // MARK: - 模块名 (智能颜色)
    private var label: some View {
        Text(module.displayName)
            .font(AppFont.ui(12, weight: currentElement.isLightBackground ? .semibold : .medium))
            .tracking(1)
            .foregroundStyle(labelColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .opacity(0.12)
            )
            .shadow(color: .black.opacity(0.18), radius: 1.5, x: 0, y: 0.5)
            .shadow(color: .black.opacity(0.12), radius: 0.8, x: 0, y: 0.3)
    }
}

// MARK: - 弧线位置计算工具
/// 在给定区域内将 n 个图标均匀分布在一条微笑弧线上。
/// margin 缩至 28pt，让边侧图标贴近屏幕边框，解决"挤在一起"问题。
extension ModuleIconView {
    static func cradlePositions(
        count: Int,
        screenWidth: CGFloat,
        arcTopY: CGFloat,      // 弧线两端的 Y
        depth: CGFloat         // 中心比两端低多少
    ) -> [CGPoint] {
        let margin: CGFloat = 40          // 左右边缘留白 (更松弛)
        let usableWidth = screenWidth - margin * 2
        return (0..<count).map { i in
            let t = Double(i) / Double(count - 1)         // 0 … 1
            let x = margin + usableWidth * t
            // sin(π·t): 两端 0，中心 1 → 中心 Y 最大（屏幕向下）
            let y = arcTopY + depth * sin(.pi * t)
            return CGPoint(x: x, y: y)
        }
    }
}
