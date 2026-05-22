//
//  HomeView.swift
//  StandWise
//
//  Created by Sendi Setiawan on 19/05/26.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    let user: User

    @State private var healthManager = HealthManager()

    private var indicatorColor: Color {
        let maxSteps = max(user.maxFootLoad, 1)
        let progress = Double(healthManager.todaySteps) / Double(maxSteps)

        switch progress {
        case ..<0.7:
            return .green
        case ..<1.0:
            return .yellow
        default:
            return .red
        }
    }

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
                            Text(user.name)
                                .font(.title.bold())
                        }
                        Spacer()
                    }
                    .padding(20)
                    .background(indicatorColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    stepsCard

                    ActivityCard()
                }
                .padding()
            }
            .navigationTitle("StandWise")
        }
        .task {
            await healthManager.requestAuthorizationAndFetchSteps()
        }
    }

    private var stepsCard: some View {
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
                Text("of \(user.maxFootLoad.formatted()) recommended steps")
                    .foregroundStyle(.secondary)
            }

            Divider()

            HStack {
                Label(user.condition.title, systemImage: "heart.text.square")
                Spacer()
                Text("Max \(user.maxFootLoad.formatted())")
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)

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
}

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedCondition: FootCondition = .moderate
    @State private var selectedStandCondition: StandCondition = .moderate

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How's your plantar faciitis lately?")
                            .font(.largeTitle.bold())
                        Text("This sets your initial safety limits. The app adjusts automatically over time.")
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(FootCondition.allCases) { condition in
                            ConditionSelectionButton(condition: condition, selectedCondition: $selectedCondition)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How many hours on your feet daily?")
                            .foregroundStyle(.secondary)
                        ForEach(StandCondition.allCases) { condition in
                            ConditionSelectionButton(condition: condition, selectedCondition: $selectedStandCondition)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        saveUserCondition()
                    } label: {
                        Text("Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding(24)
            }
        }
    }


    private func saveUserCondition() {
        let user = User(name: "User", footCondition: selectedCondition, standCondition: .mild)
        modelContext.insert(user)
    }
}

struct ConditionSelectionButton<T: SelectableCondition>: View {
    let condition: T
    @Binding var selectedCondition: T
    private var isSelected: Bool { selectedCondition == condition }
    
    var body: some View {
        Button {
            selectedCondition = condition
        } label: {
            HStack(spacing: 12) {
                Image(systemName: selectedCondition == condition ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(selectedCondition == condition ? .green : .secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(condition.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(condition.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(selectedCondition == condition ? Color.green.opacity(0.12) : Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview("Home") {
    HomeView(user: User(name: "User", footCondition: .moderate, standCondition: .mild))
}

#Preview("Onboarding") {
    OnboardingView()
        .modelContainer(for: User.self, inMemory: true)
}

