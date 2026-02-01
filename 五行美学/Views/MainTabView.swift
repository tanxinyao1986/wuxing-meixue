import SwiftUI

/// 主导航Tab视图
struct MainTabView: View {
    @EnvironmentObject var viewModel: DailyGuideViewModel
    @State private var selectedTab: Tab = .daily

    enum Tab: String {
        case daily = "今日"
        case calendar = "月历"
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DailyGuideContainerView()
                .tabItem {
                    Label(Tab.daily.rawValue, systemImage: "house.fill")
                }
                .tag(Tab.daily)

            MonthlyCalendarView(selectedTab: $selectedTab)
                .tabItem {
                    Label(Tab.calendar.rawValue, systemImage: "calendar")
                }
                .tag(Tab.calendar)
        }
        .tint(viewModel.currentDayInfo.element.color)
    }
}

#Preview {
    MainTabView()
        .environmentObject(DailyGuideViewModel())
}
