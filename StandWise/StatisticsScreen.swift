//
//  StatisticsScreen.swift
//  StandWise
//
//  Created by Aura Jatra on 22/05/26.
//

import SwiftUI

struct StatisticsScreen: View {
    private let brandGreen = Color(red: 0.05, green: 0.48, blue: 0.22)

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ContentUnavailableView {
                Label("Coming Soon", systemImage: "chart.bar.xaxis")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(brandGreen)
            } description: {
                Text("Recovery insights and standing trends will appear here.")
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("statistics") {
    NavigationStack {
        StatisticsScreen()
    }
}
