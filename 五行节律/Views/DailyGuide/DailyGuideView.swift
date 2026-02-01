import SwiftUI

/// 每日指南主视图
struct DailyGuideView: View {
    @EnvironmentObject var viewModel: DailyGuideViewModel
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        GeometryReader { geometry in
            let isExpanded = viewModel.expandedModule != nil
            let centerY = geometry.size.height * 0.4

            ZStack {
                // 星盘布局 - 五个模块图标
                ForEach(Array(viewModel.modules.enumerated()), id: \.element.id) { index, module in
                    ModuleIconView(
                        module: module,
                        isExpanded: viewModel.expandedModule == module,
                        isOtherExpanded: isExpanded && viewModel.expandedModule != module,
                        geometry: geometry,
                        index: index,
                        totalCount: viewModel.modules.count
                    )
                    .onTapGesture {
                        viewModel.toggleModule(module)
                    }
                }

                // 中央圆环
                CentralRingView(dayInfo: viewModel.currentDayInfo)
                    .position(x: geometry.size.width / 2, y: centerY)
                    .opacity(isExpanded ? 0.3 : 1)
                    .scaleEffect(isExpanded ? 0.6 : 1)
                    .animation(.easeInOut(duration: 0.4), value: isExpanded)

                // 点睛之笔 - 五行元素图标按钮
                elementButton
                    .position(
                        x: geometry.size.width / 2,
                        y: centerY - (isExpanded ? 60 : 100)
                    )
                    .opacity(isExpanded ? 0 : 1)
                    .animation(.easeInOut(duration: 0.4), value: isExpanded)

                // 展开的模块详情卡片
                if let expandedModule = viewModel.expandedModule {
                    ModuleDetailCard(
                        module: expandedModule,
                        content: expandedModule.content(for: viewModel.currentDayInfo),
                        onClose: {
                            viewModel.collapseModule()
                        }
                    )
                    .frame(maxWidth: geometry.size.width - 40)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.6)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.9, anchor: .top)),
                        removal: .opacity.combined(with: .scale(scale: 0.9, anchor: .top))
                    ))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .sheet(isPresented: $viewModel.showElementExplanation) {
            ElementExplanationSheet(element: viewModel.currentDayInfo.element)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    /// 点睛之笔 - 五行元素按钮
    private var elementButton: some View {
        Button {
            viewModel.showElementInfo()
        } label: {
            ZStack {
                Circle()
                    .fill(viewModel.currentDayInfo.element.color.opacity(0.2))
                    .frame(width: 36, height: 36)

                Image(systemName: viewModel.currentDayInfo.element.iconName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(viewModel.currentDayInfo.element.color)
            }
        }
        .accessibilityLabel("今日五行：\(viewModel.currentDayInfo.element.rawValue)，点击查看详细解释")
    }
}

#Preview {
    ZStack {
        AppBackground()
        DailyGuideView()
    }
    .environmentObject(DailyGuideViewModel())
}
