//
//  NotificationManager.swift
//  StandWise
//
//  Created by Sendi Setiawan on 25/05/26.
//

import Foundation
import UserNotifications

enum StandWiseNotificationManager {
    static let warningReminderIdentifier = "standwise.warning.reminder"

    static func requestAuthorizationIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        guard settings.authorizationStatus == .notDetermined else {
            return
        }

        do {
            try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Notification authorization failed: \(error.localizedDescription)")
        }
    }

    static func sendCautionNotification() async {
        await sendCautionNotification(
            standingMinutes: 0,
            highImpactActivityTitle: nil,
            stepCapacityUsed: 0
        )
    }

    static func sendCautionNotification(
        standingMinutes: Int,
        highImpactActivityTitle: String?,
        stepCapacityUsed: Double
    ) async {
        await requestAuthorizationIfNeeded()

        let content = UNMutableNotificationContent()
        if let highImpactActivityTitle {
            content.title = "You have activity: \(highImpactActivityTitle) ahead"
            content.body = "You're at \(formattedPercentage(stepCapacityUsed)) capacity now. A short rest before you leave will help you last through the event without a flare-up."
        } else {
            content.title = "You've been standing for \(formattedDuration(minutes: standingMinutes))"
            content.body = "A 20-minute seated break now can prevent pain later today. Your body is still manageable — keep it that way."
        }
        content.sound = .default

        await addNotification(
            identifier: "standwise.caution.\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
    }

    static func sendWelcomeNotification() async {
        await requestAuthorizationIfNeeded()

        let content = UNMutableNotificationContent()
        content.title = "Welcome to StandWise"
        content.body = "Your setup is complete. StandWise will help you balance activity and recovery."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)

        await addNotification(
            identifier: "standwise.welcome.\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
    }

    static func scheduleWarningReminder(after minutes: Int) async {
        await scheduleWarningReminder(after: minutes, hasHighImpactActivityAhead: false)
    }

    static func scheduleWarningReminder(after minutes: Int, hasHighImpactActivityAhead: Bool) async {
        await requestAuthorizationIfNeeded()

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [warningReminderIdentifier])

        let content = UNMutableNotificationContent()
        content.title = hasHighImpactActivityAhead ? "StandWise warning: heavy activity ahead" : "You've exceeded your safe limit for today."
        content.body = hasHighImpactActivityAhead
            ? "You have exceeded your safe limit and still have a high-impact activity ahead. Stop now if you can."
            : "Ten minutes of rest and a short stretch now is worth far more than days of recovery. Find a seat."
        content.sound = .default

        let interval = max(TimeInterval(minutes * 60), 60)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)

        await addNotification(
            identifier: warningReminderIdentifier,
            content: content,
            trigger: trigger
        )
    }

    static func cancelWarningReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [warningReminderIdentifier])
    }

    private static func addNotification(
        identifier: String,
        content: UNNotificationContent,
        trigger: UNNotificationTrigger?
    ) async {
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule notification: \(error.localizedDescription)")
        }
    }

    private static func formattedDuration(minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60

        if hours > 0 && remainingMinutes > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(remainingMinutes)m"
        }
    }

    private static func formattedPercentage(_ value: Double) -> String {
        let percentage = max(0, Int((value * 100).rounded()))
        return "\(percentage)%"
    }
}

final class StandWiseNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }
}
