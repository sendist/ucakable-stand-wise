//
//  ContentView.swift
//  StandWise
//
//  Created by Sendi Setiawan on 19/05/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \User.createdAt) private var users: [User]
    private let brandGreen = Color(red: 0.05, green: 0.48, blue: 0.22)

    var body: some View {
        TabView {
            appTab(title: "Home", icon: "house") {
                if let user = users.first {
                    HomeView(user: user)
                } else {
                    ProgressView("Preparing dashboard...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

            appTab(title: "Stretching", icon: "figure.gymnastics") {
                StretchingScreen()
            }

            appTab(title: "Statistics", icon: "chart.bar.xaxis") {
                StatisticsScreen()
            }
        }
        .tint(brandGreen)
    }

    private func appTab<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationStack {
            content()
        }
        .tabItem {
            Label(title, systemImage: icon)
        }
    }
}

//#Preview("Dashboard") {
//    ContentView()
//}
#Preview("Dashboard") {
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
