import SwiftUI

/// 每日指南容器 — 包裹 DailyGuideView，提供左右滑动切换日期手势。
struct DailyGuideContainerView: View {
    @EnvironmentObject var viewModel: DailyGuideViewModel
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                DailyGuideView()
                    .offset(x: dragOffset)

                // 非今天时：右上角回归今天胶囊
                if !viewModel.isToday {
                    VStack {
                        HStack {
                            Spacer()
                            todayButton
                                .padding(.trailing, 20)
                                .padding(.top, 56)
                        }
                        Spacer()
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        guard viewModel.expandedModule == nil else { return }
                        dragOffset = value.translation.width * 0.35
                    }
                    .onEnded { value in
                        guard viewModel.expandedModule == nil else { return }
                        let threshold: CGFloat = 50
                        withAnimation(.easeInOut(duration: 0.28)) {
                            if value.translation.width > threshold || value.predictedEndTranslation.width > 200 {
                                viewModel.goToPreviousDay()
                                HapticManager.selection()
                            } else if value.translation.width < -threshold || value.predictedEndTranslation.width < -200 {
                                viewModel.goToNextDay()
                                HapticManager.selection()
                            }
                            dragOffset = 0
                        }
                    }
            )
        }
        .ignoresSafeArea()
    }

    // MARK: - 今天回归按钮
    private var todayButton: some View {
        Button {
            HapticManager.subtle()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                viewModel.goToToday()
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 12, weight: .medium))
                Text("今天")
                    .font(.custom("PingFang SC", size: 13))
                    .fontWeight(.medium)
            }
            .foregroundStyle(viewModel.currentDayInfo.element.primaryTextColor)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(Capsule().fill(.ultraThinMaterial))
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .accessibilityLabel("返回今天")
    }
}
