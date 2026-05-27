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
    @State private var isShowingSplash = true

    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if isShowingSplash {
                    SplashScreen()
                        .task {
                            try? await Task.sleep(for: .seconds(1.2))
                            isShowingSplash = false
                        }
                } else {
                    OnboardingView()
                }
            }
            .modelContainer(for: [Item.self, User.self, PainLogEntry.self])
        }
    }
}
