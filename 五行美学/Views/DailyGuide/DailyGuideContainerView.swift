import SwiftUI

/// 每日指南容器 — 包裹 DailyGuideView，提供左右滑动切换日期手势。
struct DailyGuideContainerView: View {
    @EnvironmentObject var viewModel: DailyGuideViewModel
    @StateObject private var accessManager = FeatureAccessManager.shared
    @State private var dragOffset: CGFloat = 0
    @State private var showPaywall = false

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
                                // 向右滑 → 前一天
                                if canSwipeToPreviousDay {
                                    viewModel.goToPreviousDay()
                                    HapticManager.selection()
                                } else {
                                    HapticManager.warning()
                                    showPaywall = true
                                }
                            } else if value.translation.width < -threshold || value.predictedEndTranslation.width < -200 {
                                // 向左滑 → 后一天
                                if canSwipeToNextDay {
                                    viewModel.goToNextDay()
                                    HapticManager.selection()
                                } else {
                                    HapticManager.warning()
                                    showPaywall = true
                                }
                            }
                            dragOffset = 0
                        }
                    }
            )
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // MARK: - 滑动权限检查

    /// 是否可以滑到前一天
    private var canSwipeToPreviousDay: Bool {
        if accessManager.isPremium { return true }
        // 免费用户：只有当前显示的是明日时才能往回滑（回到今天）
        let calendar = Calendar.current
        let previousDay = calendar.date(byAdding: .day, value: -1, to: viewModel.selectedDate)!
        return accessManager.canAccessDate(previousDay)
    }

    /// 是否可以滑到后一天
    private var canSwipeToNextDay: Bool {
        if accessManager.isPremium { return true }
        // 免费用户：只有当前显示的是今天时才能往后滑（到明天）
        let calendar = Calendar.current
        let nextDay = calendar.date(byAdding: .day, value: 1, to: viewModel.selectedDate)!
        return accessManager.canAccessDate(nextDay)
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
                    .font(AppFont.ui(12, weight: .medium))
                Text("今天")
                    .font(AppFont.ui(13, weight: .medium))
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
