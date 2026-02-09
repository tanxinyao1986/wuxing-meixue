import SwiftUI

/// 模块详情卡片 — 极简透明玻璃风格
struct ModuleDetailCard: View {
    let module: GuideModule
    let content: ModuleContent
    let onClose: () -> Void
    var isLocked: Bool = false
    var onUnlock: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerRow
            divider
            if isLocked {
                lockedContent
            } else {
                itemsList
                if !content.tip.isEmpty { tipRow }
            }
        }
        .padding(20)
        .background(cardBG)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(module.displayName)\(String(localized: "详情"))")
    }

    // MARK: - 锁定内容（模糊 + 解锁按钮）
    private var lockedContent: some View {
        ZStack {
            // 模糊的内容预览
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(content.items.enumerated()), id: \.offset) { i, item in
                    HStack(alignment: .center, spacing: 10) {
                        Text("\(i + 1)")
                            .font(AppFont.ui(11, weight: .bold))
                            .foregroundStyle(module.color)
                            .frame(width: 20, height: 20)
                            .background(Circle().fill(module.color.opacity(0.2)))
                        Text(item)
                            .font(AppFont.narrative(14))
                            .tracking(0.5)
                            .foregroundStyle(module.element.cardPrimaryTextColor)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .blur(radius: 6)
            .allowsHitTesting(false)

            // 解锁按钮
            VStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(module.color)
                Button {
                    onUnlock?()
                } label: {
                    Text("解锁完整内容")
                        .font(AppFont.ui(14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule().fill(
                                LinearGradient(
                                    colors: [module.color, module.color.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        )
                }
            }
        }
    }

    // MARK: - Header Icon
    /// 火/金用渐变实心圆（朱砂红 / 流光金），其余用半透明色圆。
    private var headerIcon: some View {
        let el = module.element
        let hasGradient = (el == .fire || el == .metal)
        return ZStack {
            if el == .fire {
                Circle().fill(LinearGradient(colors: [Color(hex: 0xFF3B30), Color(hex: 0xFF9500)],
                                              startPoint: .bottomLeading, endPoint: .topTrailing))
            } else if el == .metal {
                Circle().fill(LinearGradient(colors: [Color(hex: 0xC7C7CC), Color(hex: 0xFFFFFF)],
                                              startPoint: .bottomLeading, endPoint: .topTrailing))
            } else {
                Circle().fill(module.color.opacity(0.25))
            }
            Image(systemName: module.iconName)
                .font(AppFont.ui(15, weight: .light))
                .foregroundStyle(hasGradient ? Color.white : module.color)
        }
        .frame(width: 34, height: 34)
    }

    // MARK: - Header
    private var headerRow: some View {
        let el = module.element
        return HStack {
            HStack(spacing: 10) {
                headerIcon
                VStack(alignment: .leading, spacing: 2) {
                    Text(content.title)
                        .font(AppFont.display(16, weight: .semibold))
                        .foregroundStyle(el.cardPrimaryTextColor)
                    Text(content.subtitle)
                        .font(AppFont.ui(12))
                        .tracking(1)
                        .foregroundStyle(el.cardSecondaryTextColor)
                }
            }
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(AppFont.ui(12, weight: .medium))
                    .foregroundStyle(el.cardSecondaryTextColor)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(.black.opacity(0.06)))
            }
            .accessibilityLabel(String(localized: "关闭"))
        }
    }

    private var divider: some View {
        Capsule()
            .fill(module.color.opacity(0.35))
            .frame(height: 1)
    }

    // MARK: - 内容列表
    private var itemsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(content.items.enumerated()), id: \.offset) { i, item in
                HStack(alignment: .center, spacing: 10) {
                    Text("\(i + 1)")
                        .font(AppFont.ui(11, weight: .bold))
                        .foregroundStyle(module.color)
                        .frame(width: 20, height: 20)
                        .background(Circle().fill(module.color.opacity(0.2)))
                    Text(item)
                        .font(AppFont.narrative(14))
                        .tracking(0.5)
                        .foregroundStyle(module.element.cardPrimaryTextColor)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    // MARK: - Tip
    private var tipRow: some View {
        HStack(spacing: 8) {
            Image(systemName: "lightbulb")
                .font(AppFont.ui(13, weight: .light))
                .foregroundStyle(Color(hex: 0xFFD54F))
            Text(content.tip)
                .font(AppFont.narrative(13))
                .tracking(0.5)
                .foregroundStyle(module.element.cardSecondaryTextColor)
                .italic()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: 0xFFD54F).opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: 0xFFD54F).opacity(0.18), lineWidth: 0.5)
                )
        )
    }

    // MARK: - 卡片底
    private var cardBG: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black.opacity(0.10), lineWidth: 0.6)
            )
            .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 8)
    }
}
