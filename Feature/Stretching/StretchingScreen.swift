//
//  StretchingScreen.swift
//  StandWise
//
//  Created by Aura Jatra on 22/05/26.
//

import SwiftUI

struct StretchingScreen: View {
    private let brandGreen = Color(red: 0.05, green: 0.48, blue: 0.22)

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ContentUnavailableView {
                Label("Coming Soon", systemImage: "figure.gymnastics")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(brandGreen)
            } description: {
                Text("Guided stretching routines for foot recovery are being prepared.")
            } 
            .padding(.horizontal, 24)
        }
        .navigationTitle("Stretching")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("stretching") {
    NavigationStack {
        StretchingScreen()
    }
}
