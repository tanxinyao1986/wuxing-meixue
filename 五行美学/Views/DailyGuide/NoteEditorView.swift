//
//  NoteEditorView.swift
//  五行美学
//
//  日记编辑器 - 演示如何使用数据服务
//

import SwiftUI
import SwiftData

struct NoteEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let date: Date
    let element: FiveElement

    @State private var noteContent: String = ""
    @State private var existingNote: UserNote?
    @State private var isFavorited: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 日期标题
                Text(formatDate(date))
                    .font(.headline)
                    .foregroundColor(element.color)

                // 笔记输入框
                TextEditor(text: $noteContent)
                    .frame(minHeight: 200)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                // 收藏按钮
                Button(action: toggleFavorite) {
                    HStack {
                        Image(systemName: isFavorited ? "star.fill" : "star")
                        Text(isFavorited ? "已收藏" : "收藏此日")
                    }
                    .foregroundColor(element.color)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("每日笔记")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveNote()
                        dismiss()
                    }
                    .disabled(noteContent.isEmpty)
                }
            }
            .onAppear {
                loadNote()
                checkFavorite()
            }
        }
    }

    // MARK: - 私有方法

    private func loadNote() {
        existingNote = DataService.shared.getNote(for: date, context: modelContext)
        noteContent = existingNote?.content ?? ""
    }

    private func saveNote() {
        if let existing = existingNote {
            DataService.shared.updateNote(existing, content: noteContent, context: modelContext)
        } else {
            DataService.shared.addNote(
                date: date,
                content: noteContent,
                element: element,
                context: modelContext
            )
        }
    }

    private func checkFavorite() {
        isFavorited = DataService.shared.isFavorite(date: date, context: modelContext)
    }

    private func toggleFavorite() {
        if isFavorited {
            // 取消收藏（需要先获取收藏记录）
            // 这里简化处理，实际应该从 DataService 添加方法
        } else {
            DataService.shared.addFavorite(
                date: date,
                element: element,
                keyword: "今日关键词",
                context: modelContext
            )
        }
        isFavorited.toggle()
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("yyyyMdEEEE")
        return formatter.string(from: date)
    }
}
