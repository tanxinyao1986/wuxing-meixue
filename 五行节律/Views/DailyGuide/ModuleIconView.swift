import SwiftUI

/// 模块图标视图 - 星盘布局中的单个图标
struct ModuleIconView: View {
    let module: GuideModule
    let isExpanded: Bool
    let isOtherExpanded: Bool
    let geometry: GeometryProxy
    let index: Int
    let totalCount: Int

    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    /// 星盘布局的角度（从顶部开始，顺时针分布）
    private var angle: Double {
        let startAngle = -90.0 // 从顶部开始
        let angleStep = 360.0 / Double(totalCount)
        return startAngle + angleStep * Double(index)
    }

    /// 星盘布局的半径
    private var radius: CGFloat {
        min(geometry.size.width, geometry.size.height) * 0.32
    }

    /// 图标位置
    private var position: CGPoint {
        let centerX = geometry.size.width / 2
        let centerY = geometry.size.height * 0.4

        if isExpanded {
            // 展开时移动到顶部中央
            return CGPoint(x: centerX, y: geometry.size.height * 0.15)
        } else if isOtherExpanded {
            // 其他模块展开时，缩小并退到更外围
            let expandedRadius = radius * 1.3
            let x = centerX + expandedRadius * cos(angle * .pi / 180)
            let y = centerY + expandedRadius * sin(angle * .pi / 180)
            return CGPoint(x: x, y: y)
        } else {
            // 正常星盘位置
            let x = centerX + radius * cos(angle * .pi / 180)
            let y = centerY + radius * sin(angle * .pi / 180)
            return CGPoint(x: x, y: y)
        }
    }

    /// 图标缩放比例
    private var scale: CGFloat {
        if isExpanded {
            return 1.5
        } else if isOtherExpanded {
            return 0.6
        }
        return 1.0
    }

    /// 透明度
    private var opacity: Double {
        if isOtherExpanded {
            return 0.3
        }
        return 1.0
    }

    var body: some View {
        VStack(spacing: 8) {
            // 图标圆形容器
            ZStack {
                // 背景光晕
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                module.color.opacity(0.3),
                                module.color.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 30
                        )
                    )
                    .frame(width: 60, height: 60)

                // 图标
                Image(systemName: module.iconName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(module.color)
            }

            // 模块名称
            Text(module.rawValue)
                .font(.system(size: scaledFontSize, weight: .medium))
                .foregroundStyle(isExpanded ? .primary : .secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(width: 80)
        .scaleEffect(scale)
        .opacity(opacity)
        .position(position)
        .animation(.easeInOut(duration: 0.4), value: isExpanded)
        .animation(.easeInOut(duration: 0.4), value: isOtherExpanded)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(module.accessibilityLabel)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(isExpanded ? "双击收起" : "双击展开查看详情")
    }

    /// 动态字体缩放
    private var scaledFontSize: CGFloat {
        let base: CGFloat = 12
        switch dynamicTypeSize {
        case .xSmall, .small:
            return base * 0.9
        case .medium, .large:
            return base
        case .xLarge, .xxLarge:
            return base * 1.15
        default:
            return base * 1.3
        }
    }
}

#Preview {
    GeometryReader { geometry in
        ZStack {
            AppBackground()
            ForEach(Array(GuideModule.allCases.enumerated()), id: \.element.id) { index, module in
                ModuleIconView(
                    module: module,
                    isExpanded: false,
                    isOtherExpanded: false,
                    geometry: geometry,
                    index: index,
                    totalCount: GuideModule.allCases.count
                )
            }
        }
    }
}
