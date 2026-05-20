//
//  ContentView.swift
//  StandWise
//
//  Created by Sendi Setiawan on 19/05/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Query(sort: \User.createdAt) private var users: [User]

    var body: some View {
        if let user = users.first {
            HomeView(user: user)
        } else {
            OnboardingView()
        }
    }
}

#Preview("Onboarding") {
    ContentView()
        .modelContainer(for: [Item.self, User.self], inMemory: true)
}

#Preview("Home") {
    let container = try! ModelContainer(
        for: Item.self,
        User.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let user = User(name: "User", footCondition: .moderate, standCondition: .mild)
    container.mainContext.insert(user)

    return ContentView()
        .modelContainer(container)
}
