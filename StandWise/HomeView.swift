//
//  HomeView.swift
//  StandWise
//
//  Created by Aura Jatra on 22/05/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            Color.clear
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
    }

}

#Preview("home") {
    NavigationStack {
        HomeView()
    }
}
