import SwiftUI

/// 月历视图 - 霜白磨砂风格 (Frosty Calendar)
struct MonthlyCalendarView: View {
    @EnvironmentObject var viewModel: DailyGuideViewModel
    @Binding var selectedTab: MainTabView.Tab

    @State private var displayedMonth: Date = Date()
    @State private var showPaywall = false
    @State private var showSettings = false
    @StateObject private var accessManager = FeatureAccessManager.shared

    private let calendar = Calendar.current
    private var weekdaySymbols: [String] {
        let symbols = Calendar.current.veryShortWeekdaySymbols
        // veryShortWeekdaySymbols 已根据当前 locale 自动本地化
        return symbols
    }
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        NavigationStack {
            ZStack {
                // 底层：静态渐变背景（避免三层模糊叠加的性能开销）
                LinearGradient(
                    colors: [viewModel.currentDayInfo.element.meshMidColor,
                             viewModel.currentDayInfo.element.meshHighlightColor],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // 中层：白色磨砂覆盖层
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()

                // 内容层
                ScrollView {
                    VStack(spacing: 16) {
                        // 月份导航头
                        monthNavigationHeader
                            .padding(.top, 8)

                        // 五行图例
                        elementLegend

                        // 磨砂日历卡片
                        calendarCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100) // 为Tab Bar留空间
                }
            }
            .navigationTitle("月历")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(AppFont.ui(16, weight: .medium))
                            .foregroundStyle(viewModel.currentDayInfo.element.iconTintColor)
                    }
                    .accessibilityLabel("设置")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            displayedMonth = Date()
                            selectDate(Date())
                        }
                    } label: {
                        Text("今天")
                            .font(AppFont.ui(15, weight: .medium))
                            .foregroundStyle(viewModel.currentDayInfo.element.color)
                    }
                    .accessibilityLabel("跳转到今天")
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    // MARK: - 月份导航头
    private var monthNavigationHeader: some View {
        HStack {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    goToPreviousMonth()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 40, height: 40)
                    Image(systemName: "chevron.left")
                        .font(AppFont.ui(14, weight: .semibold))
                        .foregroundStyle(viewModel.currentDayInfo.element.cardSecondaryTextColor)
                }
            }
            .accessibilityLabel("上一个月")

            Spacer()

            Text(monthYearString)
                .font(AppFont.display(20, weight: .bold))
                .foregroundStyle(viewModel.currentDayInfo.element.cardPrimaryTextColor)

            Spacer()

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    goToNextMonth()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 40, height: 40)
                    Image(systemName: "chevron.right")
                        .font(AppFont.ui(14, weight: .semibold))
                        .foregroundStyle(viewModel.currentDayInfo.element.cardSecondaryTextColor)
                }
            }
            .accessibilityLabel("下一个月")
        }
        .padding(.vertical, 8)
    }

    // MARK: - 五行图例
    private var elementLegend: some View {
        HStack(spacing: 16) {
            ForEach(FiveElement.allCases) { element in
                HStack(spacing: 4) {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [element.calendarDotCoreColor.opacity(0.9), element.calendarDotColor],
                                center: UnitPoint(x: 0.3, y: 0.3),
                                startRadius: 0,
                                endRadius: 4
                            )
                        )
                        .frame(width: 8, height: 8)
                        .shadow(color: element.calendarDotColor.opacity(0.5), radius: 2, x: 0, y: 1)

                    Text(element.displayName)
                        .font(AppFont.ui(11, weight: .medium))
                        .foregroundStyle(Color(hex: 0x6E6E73))
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(Color.black.opacity(0.12), lineWidth: 0.5)
                )
        )
    }

    // MARK: - 磨砂日历卡片
    private var calendarCard: some View {
        VStack(spacing: 12) {
            // 星期标题行
            weekdayHeader

            // 日期网格
            calendarGrid
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.black.opacity(0.10), lineWidth: 0.8)
                )
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
        )
    }

    // MARK: - 星期标题
    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(AppFont.ui(12, weight: .bold))
                    .foregroundStyle(Color(hex: 0x6E6E73))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, 4)
    }

    // MARK: - 日历网格
    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            // 填充月初空白
            ForEach(0..<firstWeekdayOfMonth, id: \.self) { _ in
                Color.clear
                    .frame(height: 64)
            }

            // 日期单元格
            ForEach(daysInMonth, id: \.self) { date in
                CalendarDayCell(
                    date: date,
                    isToday: calendar.isDateInToday(date),
                    isSelected: calendar.isDate(date, inSameDayAs: viewModel.selectedDate),
                    element: DayInfo.forDate(date).element
                )
                .onTapGesture {
                    selectDate(date)
                }
            }
        }
    }

    // MARK: - Helpers
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("yyyyMMMM")
        return formatter.string(from: displayedMonth)
    }

    private var firstWeekdayOfMonth: Int {
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstDay = calendar.date(from: components) else { return 0 }
        return calendar.component(.weekday, from: firstDay) - 1
    }

    private var daysInMonth: [Date] {
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstDay = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: displayedMonth) else {
            return []
        }

        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay)
        }
    }

    private func goToPreviousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }

    private func goToNextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }

    private func selectDate(_ date: Date) {
        // 检查是否可以访问此日期
        if !accessManager.canAccessDate(date) {
            // 免费版：显示付费墙
            HapticManager.warning()
            showPaywall = true
            return
        }

        // 可以访问：正常选择
        HapticManager.selection()
        viewModel.selectDate(date)
        // 切换到今日Tab
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            selectedTab = .daily
        }
    }
}

#Preview {
    MonthlyCalendarView(selectedTab: .constant(.calendar))
        .environmentObject(DailyGuideViewModel())
}
