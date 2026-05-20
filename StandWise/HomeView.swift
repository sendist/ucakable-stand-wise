//
//  HomeView.swift
//  StandWise
//
//  Created by Sendi Setiawan on 19/05/26.
//

import SwiftUI

struct HomeView: View {
    @State private var healthManager = HealthManager()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 48))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hello,")
                                .font(.title)
                            Text("All")
                                .font(.title.bold())
                        }

                        Spacer()
                    }
                    .padding(20)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("Today Steps", systemImage: "figure.walk")
                                .font(.headline)

                            Spacer()

                            Button {
                                Task {
                                    await healthManager.refreshTodaySteps()
                                }
                            } label: {
                                Image(systemName: "arrow.clockwise")
                            }
                            .buttonStyle(.borderless)
                            .disabled(healthManager.isLoading)
                            .accessibilityLabel("Refresh steps")
                        }

                        if healthManager.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text(healthManager.todaySteps.formatted())
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                            Text("steps today")
                                .foregroundStyle(.secondary)
                        }

                        if let errorMessage = healthManager.errorMessage {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding()
            }
            .navigationTitle("StandWise")
        }
        .task {
            await healthManager.requestAuthorizationAndFetchSteps()
        }
    }
}

#Preview {
    HomeView()
}
