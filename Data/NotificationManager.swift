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
        await requestAuthorizationIfNeeded()

        let content = UNMutableNotificationContent()
        content.title = "StandWise caution"
        content.body = "You are getting close to today's safe activity limit. Plan a short rest soon."
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
        await requestAuthorizationIfNeeded()

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [warningReminderIdentifier])

        let content = UNMutableNotificationContent()
        content.title = "StandWise warning"
        content.body = "You have exceeded your safe limit. Rest now to reduce flare-up risk."
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
}

final class StandWiseNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }
}
