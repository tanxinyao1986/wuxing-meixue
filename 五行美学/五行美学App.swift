//
//  五行美学App.swift
//  五行美学
//
//  Created by 昕尧 on 2026/2/2.
//

import SwiftUI

@main
struct 五行美学App: App {
    @StateObject private var viewModel = DailyGuideViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(viewModel)
        }
    }
}
