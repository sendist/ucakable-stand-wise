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
    @State private var shouldOpenPainLog = false

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
                    OnboardingView(shouldOpenPainLog: $shouldOpenPainLog)
                }
            }
            .modelContainer(for: [Item.self, User.self, PainLogEntry.self])
            .onOpenURL { url in
                guard url.scheme == "standwise", url.host == "pain-log" else {
                    return
                }

                isShowingSplash = false
                shouldOpenPainLog = true
            }
        }
    }
}
