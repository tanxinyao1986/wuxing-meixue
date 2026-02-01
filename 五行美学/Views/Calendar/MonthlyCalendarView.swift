import SwiftUI

/// 月历视图
struct MonthlyCalendarView: View {
    @EnvironmentObject var viewModel: DailyGuideViewModel
    @Binding var selectedTab: MainTabView.Tab

    @State private var displayedMonth: Date = Date()

    private let calendar = Calendar.current
    private let weekdaySymbols = ["日", "一", "二", "三", "四", "五", "六"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 月份导航
                    monthNavigationHeader

                    // 星期标题行
                    weekdayHeader

                    // 日期网格
                    calendarGrid
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("月历")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("今天") {
                        withAnimation {
                            displayedMonth = Date()
                            selectDate(Date())
                        }
                    }
                    .accessibilityLabel("跳转到今天")
                }
            }
        }
    }

    // MARK: - 月份导航
    private var monthNavigationHeader: some View {
        HStack {
            Button {
                withAnimation {
                    goToPreviousMonth()
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("上一个月")

            Spacer()

            VStack(spacing: 2) {
                Text(monthYearString)
                    .font(.title2.weight(.semibold))

                Text(LunarCalendar.ganzhiYear(for: displayedMonth))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                withAnimation {
                    goToNextMonth()
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("下一个月")
        }
        .padding(.vertical, 8)
    }

    // MARK: - 星期标题
    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - 日历网格
    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            // 填充月初空白
            ForEach(0..<firstWeekdayOfMonth, id: \.self) { _ in
                Color.clear
                    .frame(height: 60)
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
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月"
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
        HapticManager.selection()
        viewModel.selectDate(date)
        // 切换到今日Tab
        withAnimation {
            selectedTab = .daily
        }
    }
}

#Preview {
    MonthlyCalendarView(selectedTab: .constant(.calendar))
        .environmentObject(DailyGuideViewModel())
}
