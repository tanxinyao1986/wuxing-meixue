import SwiftUI

/// 每日指南主视图 — 光影美学核心页面。
/// 布局分区:
///   ┌─────────────────────┐
///   │  ← 滑动箭头        │  (屏幕左右边缘)
///   │     能量光球        │  (上移至约 30% 高度)
///   │  ─── 托举弧线 ───  │  (光球下方，margin 缩至 28pt)
///   │     5 个模块图标    │
///   │                     │
///   │  ┄┄┄┄ Dock 区 ┄┄┄┄ │  (底部 80pt 不放置内容)
///   └─────────────────────┘
struct DailyGuideView: View {
    @EnvironmentObject var viewModel: DailyGuideViewModel

    var body: some View {
        GeometryReader { geo in
            let isExpanded = viewModel.expandedModule != nil
            let sphereCenterY = geo.size.height * 0.30
            // 弧线起始 Y = 光球底边 + 间隔 (光球激进缩小后调整)
            let arcTopY = sphereCenterY + 120 + 27   // 光球半径 120 + 27pt 间距（模块圈下移）

            ZStack {
                // ── 1. 背景 ──
                ElementMeshBackground(element: viewModel.currentDayInfo.element)

                // ── 2. 左右滑动箭头 ──
                if !isExpanded {
                    swipeHint(geo: geo, leading: true)
                    swipeHint(geo: geo, leading: false)
                }

                // ── 3. 中央光球 (点击 → 五行解释) — 先渲染，确保模块图标在上层 ──
                CentralRingView(dayInfo: viewModel.currentDayInfo)
                    .frame(width: 240, height: 240)
                    .contentShape(Circle())
                    .position(x: geo.size.width / 2, y: sphereCenterY)
                    .opacity(isExpanded ? 0.25 : 1.0)
                    .scaleEffect(isExpanded ? 0.7 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isExpanded)
                    .onTapGesture {
                        HapticManager.subtle()
                        viewModel.showElementInfo()
                    }

                // ── 4. 托举弧线上的模块图标 (Z-Index 高于光球) ──
                let positions = ModuleIconView.cradlePositions(
                    count: viewModel.modules.count,
                    screenWidth: geo.size.width,
                    arcTopY: arcTopY,
                    depth: 64
                )
                ForEach(Array(viewModel.modules.enumerated()), id: \.element.id) { idx, mod in
                    ModuleIconView(
                        module: mod,
                        isSelected: viewModel.expandedModule == mod,
                        isOtherSelected: isExpanded && viewModel.expandedModule != mod,
                        position: positions[idx],
                        currentElement: viewModel.currentDayInfo.element,
                        index: idx  // 传递索引用于异步悬浮动画
                    )
                    .onTapGesture {
                        HapticManager.selection()
                        viewModel.toggleModule(mod)
                    }
                }

                // ── 5. 展开的模块详情卡片 ──
                if let mod = viewModel.expandedModule {
                    ModuleDetailCard(
                        module: mod,
                        content: mod.content(for: viewModel.currentDayInfo),
                        onClose: {
                            HapticManager.subtle()
                            viewModel.collapseModule()
                        }
                    )
                    .frame(maxWidth: geo.size.width - 32)
                    .position(x: geo.size.width / 2,
                              y: geo.size.height - 80 - 200) // Dock 区上方居中
                    .transition(.opacity.combined(with: .scale(scale: 0.93)))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .sheet(isPresented: $viewModel.showElementExplanation) {
            ElementExplanationSheet(dayInfo: viewModel.currentDayInfo)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
        }
    }

    // MARK: - 极淡左 / 右滑动箭头 (智能色)
    private func swipeHint(geo: GeometryProxy, leading: Bool) -> some View {
        let el = viewModel.currentDayInfo.element
        return Image(systemName: leading ? "chevron.left" : "chevron.right")
            .font(.system(size: 18, weight: .ultraLight))
            .foregroundStyle(el.isLightBackground ? .black.opacity(0.15) : .white.opacity(0.18))
            .position(
                x: leading ? 18 : geo.size.width - 18,
                y: geo.size.height * 0.30
            )
    }
}
