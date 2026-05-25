//
//  StandWiseApp.swift
//  StandWise
//
//  Created by Sendi Setiawan on 19/05/26.
//

import SwiftUI
import SwiftData

@main
struct StandWiseApp: App {
    var body: some Scene {
        WindowGroup {
            OnboardingView()
                .modelContainer(for: [Item.self, User.self])
        }
    }
}
