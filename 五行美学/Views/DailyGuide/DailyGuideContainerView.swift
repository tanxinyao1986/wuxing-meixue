import SwiftUI

/// 每日指南容器视图 - 支持左右滑动切换日期
struct DailyGuideContainerView: View {
    @EnvironmentObject var viewModel: DailyGuideViewModel
    @State private var dragOffset: CGFloat = 0
    @GestureState private var isDragging = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                AppBackground()

                // 主内容
                DailyGuideView()
                    .offset(x: dragOffset)

                // 今日按钮（非今天时显示）
                if !viewModel.isToday {
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                HapticManager.subtle()
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    viewModel.goToToday()
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.uturn.backward")
                                    Text("今天")
                                }
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.ultraThinMaterial, in: Capsule())
                            }
                            .accessibilityLabel("返回今天")
                            .padding(.trailing, 20)
                            .padding(.top, 8)
                        }
                        Spacer()
                    }
                }
            }
            .gesture(
                DragGesture()
                    .updating($isDragging) { _, state, _ in
                        state = true
                    }
                    .onChanged { value in
                        // 只有在模块未展开时允许滑动
                        guard viewModel.expandedModule == nil else { return }
                        dragOffset = value.translation.width * 0.4
                    }
                    .onEnded { value in
                        guard viewModel.expandedModule == nil else { return }

                        let threshold: CGFloat = 50
                        let velocity = value.predictedEndTranslation.width

                        withAnimation(.easeInOut(duration: 0.3)) {
                            if value.translation.width > threshold || velocity > 200 {
                                // 向右滑动 - 前一天
                                viewModel.goToPreviousDay()
                                HapticManager.selection()
                            } else if value.translation.width < -threshold || velocity < -200 {
                                // 向左滑动 - 后一天
                                viewModel.goToNextDay()
                                HapticManager.selection()
                            }
                            dragOffset = 0
                        }
                    }
            )
        }
    }
}

#Preview {
    DailyGuideContainerView()
        .environmentObject(DailyGuideViewModel())
}
