import SwiftUI
import Combine

/// 每日指南视图模型
@MainActor
class DailyGuideViewModel: ObservableObject {
    /// 当前选中的日期
    @Published var selectedDate: Date = Date()

    /// 当前日期信息
    @Published var currentDayInfo: DayInfo

    /// 当前展开的模块
    @Published var expandedModule: GuideModule?

    /// 是否显示五行解释sheet
    @Published var showElementExplanation: Bool = false

    /// 所有模块
    let modules = GuideModule.allCases

    init() {
        self.currentDayInfo = DayInfo.forDate(Date())
    }

    /// 更新选中日期
    func selectDate(_ date: Date) {
        selectedDate = date
        currentDayInfo = DayInfo.forDate(date)
        expandedModule = nil
    }

    /// 前往前一天
    func goToPreviousDay() {
        if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            selectDate(previousDay)
        }
    }

    /// 前往后一天
    func goToNextDay() {
        if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            selectDate(nextDay)
        }
    }

    /// 回到今天
    func goToToday() {
        selectDate(Date())
    }

    /// 展开/收起模块
    func toggleModule(_ module: GuideModule) {
        withAnimation(.easeInOut(duration: 0.4)) {
            if expandedModule == module {
                expandedModule = nil
            } else {
                HapticManager.subtle()
                expandedModule = module
            }
        }
    }

    /// 收起当前模块
    func collapseModule() {
        withAnimation(.easeInOut(duration: 0.4)) {
            expandedModule = nil
        }
    }

    /// 显示五行解释
    func showElementInfo() {
        HapticManager.subtle()
        showElementExplanation = true
    }

    /// 判断是否为今天
    var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    /// 获取农历日期字符串
    var lunarDateString: String {
        LunarCalendar.lunarDateString(for: selectedDate)
    }
}
