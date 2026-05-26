//
//  StandWiseApp.swift
//  StandWise
//
//  Created by Sendi Setiawan on 19/05/26.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct StandWiseApp: App {
    private let notificationDelegate = StandWiseNotificationDelegate()

    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

    var body: some Scene {
        WindowGroup {
            OnboardingView()
                .modelContainer(for: [Item.self, User.self])
        }
    }
}
