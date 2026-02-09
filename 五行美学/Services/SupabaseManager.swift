//
//  SupabaseManager.swift
//  五行美学
//
//  Supabase 数据库管理器
//

import Foundation
import Combine

@MainActor
class SupabaseManager {
    static let shared = SupabaseManager()

    // Supabase 项目配置
    private let supabaseURL = "https://eavuaaxzmhvgnrqxijkr.supabase.co"
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVhdnVhYXh6bWh2Z25ycXhpamtyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA1MzkxMTQsImV4cCI6MjA4NjExNTExNH0.J2dzAIxxsFGw2NMJ6Lk6QPXirlvX6WkPSDQlIZz-xhA"

    private init() {}

    // MARK: - 保存订阅信息

    func saveSubscription(data: [String: Any]) async {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/subscriptions") else {
            print("❌ 无效的 URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data)

            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    print("✅ 订阅信息已保存到 Supabase")
                } else {
                    print("❌ 保存失败，状态码: \(httpResponse.statusCode)")
                }
            }
        } catch {
            print("❌ 保存订阅信息失败: \(error)")
        }
    }

    // MARK: - 查询订阅状态

    func getSubscriptionStatus(deviceId: String) async -> SubscriptionStatus? {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/subscriptions?device_id=eq.\(deviceId)&is_active=eq.true&order=purchase_date.desc&limit=1") else {
            print("❌ 无效的 URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                let subscriptions = try decoder.decode([SubscriptionStatusResponse].self, from: data)

                if let latest = subscriptions.first {
                    return SubscriptionStatus(
                        userId: latest.device_id,
                        productId: latest.product_id,
                        purchaseDate: latest.purchase_date,
                        expirationDate: latest.expiration_date,
                        isActive: latest.is_active,
                        transactionId: latest.transaction_id
                    )
                }
            }
        } catch {
            print("❌ 查询订阅状态失败: \(error)")
        }

        return nil
    }

    // MARK: - 更新订阅状态（用于过期处理）

    func updateSubscriptionStatus(transactionId: String, isActive: Bool) async {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/subscriptions?transaction_id=eq.\(transactionId)") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")

        let updateData = ["is_active": isActive]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: updateData)
            let (_, _) = try await URLSession.shared.data(for: request)
            print("✅ 订阅状态已更新")
        } catch {
            print("❌ 更新订阅状态失败: \(error)")
        }
    }
}

// MARK: - 响应模型

private struct SubscriptionStatusResponse: Codable {
    let device_id: String
    let product_id: String
    let transaction_id: String
    let purchase_date: Date
    let expiration_date: Date?
    let is_active: Bool
    let product_type: String
}
