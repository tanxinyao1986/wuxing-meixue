import UIKit
import CoreHaptics

/// 触觉反馈管理器 — 使用 CoreHaptics 引擎实现高级触觉体验
enum HapticManager {

    // MARK: - CoreHaptics 引擎 (懒加载，全局复用)

    private static var engine: CHHapticEngine? = {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return nil }
        do {
            let engine = try CHHapticEngine()
            engine.playsHapticsOnly = true
            engine.isAutoShutdownEnabled = true
            // 引擎被系统停止后自动重启
            engine.stoppedHandler = { reason in
                try? engine.start()
            }
            engine.resetHandler = {
                try? engine.start()
            }
            try engine.start()
            return engine
        } catch {
            return nil
        }
    }()

    // MARK: - 光球点击 — "绽放" 触感
    /// 柔和的涌起 + 短暂延迟后一个清脆的确认点，模拟光球绽开的感觉
    static func bloom() {
        guard let engine else {
            // CoreHaptics 不可用时回退
            subtle()
            return
        }
        do {
            // 第一层：柔和涌起
            let softRise = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.45),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.15)
                ],
                relativeTime: 0,
                duration: 0.12
            )
            // 第二层：清脆确认点
            let crispTap = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.35)
                ],
                relativeTime: 0.10
            )
            // 第三层：余韵扩散
            let afterglow = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.25),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
                ],
                relativeTime: 0.12,
                duration: 0.15
            )

            let pattern = try CHHapticPattern(events: [softRise, crispTap, afterglow], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            subtle()
        }
    }

    // MARK: - 模块图标点击 — 精致短促 "点按" 触感
    /// 极短的清脆触点，比系统 selection 更有质感
    static func moduleTap() {
        guard let engine else {
            selection()
            return
        }
        do {
            // 精致的双层触点：先一个极轻的预触，紧跟一个清脆主触
            let preTap = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0
            )
            let mainTap = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                ],
                relativeTime: 0.04
            )

            let pattern = try CHHapticPattern(events: [preTap, mainTap], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            selection()
        }
    }

    // MARK: - 卡片收起 — 柔和消散
    /// 轻柔的退场触感
    static func dismiss() {
        guard let engine else {
            subtle()
            return
        }
        do {
            let fadeOut = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
                ],
                relativeTime: 0,
                duration: 0.1
            )
            let softEnd = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.2),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.15)
                ],
                relativeTime: 0.08
            )

            let pattern = try CHHapticPattern(events: [fadeOut, softEnd], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            subtle()
        }
    }

    // MARK: - 基础回退方法 (保留兼容)

    /// 轻微触觉反馈
    static func subtle() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    /// 中等触觉反馈
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    /// 较强触觉反馈
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }

    /// 选择反馈
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    /// 通知反馈
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    /// 警告反馈（功能锁定时使用）
    static func warning() {
        notification(.warning)
    }
}
