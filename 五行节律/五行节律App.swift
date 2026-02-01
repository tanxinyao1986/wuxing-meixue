import SwiftUI

@main
struct 五行节律App: App {
    @StateObject private var viewModel = DailyGuideViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(viewModel)
        }
    }
}
