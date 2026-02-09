//
//  DataService.swift
//  五行美学
//
//  数据服务 - 简化数据操作
//

import Foundation
import SwiftData

@MainActor
class DataService {
    static let shared = DataService()

    private init() {}

    // MARK: - 笔记操作

    /// 添加笔记
    func addNote(date: Date, content: String, element: FiveElement, context: ModelContext) {
        let note = UserNote(date: date, content: content, element: element.rawValue)
        context.insert(note)
        try? context.save()
    }

    /// 获取指定日期的笔记
    func getNote(for date: Date, context: ModelContext) -> UserNote? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<UserNote>(
            predicate: #Predicate { note in
                note.date >= startOfDay && note.date < endOfDay
            }
        )

        return try? context.fetch(descriptor).first
    }

    /// 更新笔记
    func updateNote(_ note: UserNote, content: String, context: ModelContext) {
        note.content = content
        note.updatedAt = Date()
        try? context.save()
    }

    /// 删除笔记
    func deleteNote(_ note: UserNote, context: ModelContext) {
        context.delete(note)
        try? context.save()
    }

    // MARK: - 收藏操作

    /// 添加收藏
    func addFavorite(date: Date, element: FiveElement, keyword: String, reason: String = "", context: ModelContext) {
        let favorite = UserFavorite(
            date: date,
            element: element.rawValue,
            keyword: keyword,
            reason: reason
        )
        context.insert(favorite)
        try? context.save()
    }

    /// 获取所有收藏
    func getAllFavorites(context: ModelContext) -> [UserFavorite] {
        let descriptor = FetchDescriptor<UserFavorite>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// 检查是否已收藏某日
    func isFavorite(date: Date, context: ModelContext) -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<UserFavorite>(
            predicate: #Predicate { favorite in
                favorite.date >= startOfDay && favorite.date < endOfDay
            }
        )

        return (try? context.fetch(descriptor).first) != nil
    }

    /// 删除收藏
    func deleteFavorite(_ favorite: UserFavorite, context: ModelContext) {
        context.delete(favorite)
        try? context.save()
    }

    // MARK: - 偏好设置

    /// 获取用户偏好（如果不存在则创建默认）
    func getPreferences(context: ModelContext) -> UserPreferences {
        let descriptor = FetchDescriptor<UserPreferences>()
        if let preferences = try? context.fetch(descriptor).first {
            return preferences
        } else {
            let preferences = UserPreferences()
            context.insert(preferences)
            try? context.save()
            return preferences
        }
    }

    /// 更新偏好设置
    func updatePreferences(_ preferences: UserPreferences, context: ModelContext) {
        preferences.updatedAt = Date()
        try? context.save()
    }
}
