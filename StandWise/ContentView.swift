//
//  ContentView.swift
//  StandWise
//
//  Created by Sendi Setiawan on 19/05/26.
//

import SwiftUI

struct ContentView: View {
    private let brandGreen = Color(red: 0.05, green: 0.48, blue: 0.22)

    var body: some View {
        TabView {
            appTab(title: "Home", icon: "house") {
                HomeView()
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

#Preview("Dashboard") {
    ContentView()
}
