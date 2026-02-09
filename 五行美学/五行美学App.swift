//
//  五行美学App.swift
//  五行美学
//
//  Created by 昕尧 on 2026/2/2.
//

import SwiftUI
import SwiftData

@main
struct 五行美学App: App {
    @StateObject private var viewModel = DailyGuideViewModel()
    @State private var showSplash = true
    /// 延迟加载主界面，避免 Splash 期间双重渲染导致内存峰值
    @State private var mainViewReady = false

    // SwiftData 容器配置 - 支持 iCloud 同步
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserNote.self,
            UserFavorite.self,
            UserPreferences.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            // 启用 iCloud 同步
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("无法创建 ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                // 主界面 — 延迟到 Splash 爆发阶段再加载，避免内存峰值
                if mainViewReady {
                    MainTabView()
                        .environmentObject(viewModel)
                        .transition(.identity)
                }

                // 开屏动画 — 覆盖在主界面之上，消散后移除
                if showSplash {
                    SplashScreenView()
                        .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                        .zIndex(1)
                }
            }
            .onAppear {
                // 2.5s 时预加载主界面（Splash 爆发前，用户看不到）
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    mainViewReady = true
                }
                // 3.8s 后移除 Splash
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.8) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showSplash = false
                    }
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
