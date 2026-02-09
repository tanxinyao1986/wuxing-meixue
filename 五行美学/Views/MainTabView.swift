import SwiftUI

/// 主导航视图 - 悬浮磨砂玻璃 Tab Bar
struct MainTabView: View {
    @EnvironmentObject var viewModel: DailyGuideViewModel
    @State private var selectedTab: Tab = .daily

    enum Tab: String {
        case daily = "今日"
        case calendar = "月历"

        var displayName: String {
            switch self {
            case .daily:    return String(localized: "今日")
            case .calendar: return String(localized: "月历")
            }
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // 内容区：opacity 切换，两个视图始终存活
                ZStack {
                    DailyGuideContainerView()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .opacity(selectedTab == .daily ? 1 : 0)
                        .allowsHitTesting(selectedTab == .daily)

                    MonthlyCalendarView(selectedTab: $selectedTab)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .opacity(selectedTab == .calendar ? 1 : 0)
                        .allowsHitTesting(selectedTab == .calendar)
                }

                // 悬浮磨砂玻璃 Tab Bar
                floatingTabBar
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - 悬浮毛玻璃 Tab Bar
    private var floatingTabBar: some View {
        HStack(spacing: 0) {
            ForEach([Tab.daily, Tab.calendar], id: \.self) { tab in
                tabItem(tab)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 32)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
        .overlay(
            Capsule()
                .stroke(
                    viewModel.currentDayInfo.element.isLightBackground
                    ? Color.black.opacity(0.10)
                    : Color.white.opacity(0.25),
                    lineWidth: 0.8
                )
        )
        .shadow(color: viewModel.currentDayInfo.element.color.opacity(0.25), radius: 20, x: 0, y: 8)
        .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
        .padding(.bottom, 40)
    }

    // MARK: - 单个 Tab 项
    private func tabItem(_ tab: Tab) -> some View {
        let isSelected = selectedTab == tab
        let element = viewModel.currentDayInfo.element

        return Button {
            HapticManager.selection()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: tab == .daily ? "sun.and.horizon" : "calendar")
                    .font(AppFont.ui(16, weight: isSelected ? .semibold : .regular))

                Text(tab.displayName)
                    .font(AppFont.ui(14, weight: isSelected ? .semibold : .medium))
            }
            .foregroundStyle(isSelected ? (element.isLightBackground ? Color(hex: 0x2C2C2E) : .white) : element.iconTintColor)
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            // 选中态胶囊用 .background 放置，自动贴合 HStack 尺寸，避免 Shape 膨胀到 proposed size
            .background {
                if isSelected {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    element.color.opacity(0.85),
                                    element.meshMidColor.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: element.color.opacity(0.4), radius: 6, x: 0, y: 3)
                }
            }
        }
        .accessibilityLabel(tab.displayName)
    }
}

#Preview {
    MainTabView()
        .environmentObject(DailyGuideViewModel())
}
