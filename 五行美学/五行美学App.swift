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
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                // 主界面 — 始终存在于底层
                MainTabView()
                    .environmentObject(viewModel)

                // 开屏动画 — 覆盖在主界面之上，消散后移除
                if showSplash {
                    SplashScreenView()
                        .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                        .zIndex(1)
                }
            }
            .onAppear {
                // 3.8s 后移除 Splash (3.0s 蕴育 + 0.7s 爆发 ≈ 3.7s，留 0.1s 余量)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.8) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}
