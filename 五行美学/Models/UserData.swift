//
//  UserData.swift
//  五行美学
//
//  数据持久化模型 - 支持 iCloud 同步
//

import Foundation
import SwiftData

/// 用户笔记模型
@Model
final class UserNote {
    var id: UUID
    var date: Date
    var content: String
    var element: String // 五行元素
    var createdAt: Date
    var updatedAt: Date

    init(date: Date, content: String, element: String) {
        self.id = UUID()
        self.date = date
        self.content = content
        self.element = element
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

/// 用户收藏模型
@Model
final class UserFavorite {
    var id: UUID
    var date: Date
    var element: String
    var keyword: String
    var reason: String // 收藏原因
    var createdAt: Date

    init(date: Date, element: String, keyword: String, reason: String = "") {
        self.id = UUID()
        self.date = date
        self.element = element
        self.keyword = keyword
        self.reason = reason
        self.createdAt = Date()
    }
}

/// 用户偏好设置
@Model
final class UserPreferences {
    var id: UUID
    var enableHapticFeedback: Bool
    var enableNotifications: Bool
    var preferredElement: String? // 用户偏好的五行元素
    var themeMode: String // "auto", "light", "dark"
    var updatedAt: Date

    init() {
        self.id = UUID()
        self.enableHapticFeedback = true
        self.enableNotifications = false
        self.preferredElement = nil
        self.themeMode = "auto"
        self.updatedAt = Date()
    }
}
