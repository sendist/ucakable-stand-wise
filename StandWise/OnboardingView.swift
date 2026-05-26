//
//  OnboardingView.swift
//  StandWise
//
//  Created by Aura Jatra on 22/05/26.
//

import EventKit
import HealthKit
import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \User.createdAt) private var users: [User]

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var step: OnboardingStep = .splash
    @State private var isOnboardingCompleted = false

    private let healthStore = HKHealthStore()
    private let eventStore = EKEventStore()

    var body: some View {
        Group {
            if hasCompletedOnboarding || isOnboardingCompleted {
                ContentView()
            } else {
                currentStep
            }
        }
        .animation(.easeInOut(duration: 0.25), value: step)
    }

    @ViewBuilder
    private var currentStep: some View {
        switch step {
        case .splash:
            ScreenPage()
                .task {
                    try? await Task.sleep(for: .seconds(1.2))
                    goToNextStep()
                }

        case .welcome:
            WelcomeScreen(onGetStarted: goToNextStep)

        case .healthAccess:
            HealthAccessScreen(
                onAllowHealthAccess: requestHealthAccess,
                onSkip: goToNextStep
            )

        case .calendarAccess:
            CalenderAccessScreen(
                onAllowCalendarAccess: requestCalendarAccess,
                onSkip: goToNextStep
            )

        case .plantarSurvey:
            PlantarSurveyScreen(onNext: goToNextStep)

        case .success:
            OnboardingSuccessScreen(onOpenDashboard: completeOnboarding)
        }
    }

    private func goToNextStep() {
        guard let nextStep = step.next else {
            completeOnboarding()
            return
        }

        step = nextStep
    }

    private func completeOnboarding() {
        createDefaultUserIfNeeded()
        hasCompletedOnboarding = true
        isOnboardingCompleted = true

        Task {
            await StandWiseNotificationManager.sendWelcomeNotification()
        }
    }

    private func createDefaultUserIfNeeded() {
        guard users.isEmpty else {
            return
        }

        let user = User(name: "User", footCondition: .moderate, standCondition: .moderate)
        modelContext.insert(user)

        do {
            try modelContext.save()
        } catch {
            print("Failed to save onboarding user: \(error.localizedDescription)")
        }
    }

    private func requestHealthAccess() {
        Task { @MainActor in
            defer { goToNextStep() }

            guard hasInfoPlistValue(for: "NSHealthShareUsageDescription") else {
                print("Missing NSHealthShareUsageDescription in the built app Info.plist.")
                return
            }

            guard HKHealthStore.isHealthDataAvailable() else {
                return
            }

            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthReadTypes)
            } catch {
                print("Health authorization failed: \(error.localizedDescription)")
            }
        }
    }

    private func requestCalendarAccess() {
        Task { @MainActor in
            defer { goToNextStep() }

            guard hasInfoPlistValue(for: "NSCalendarsFullAccessUsageDescription") else {
                print("Missing NSCalendarsFullAccessUsageDescription in the built app Info.plist.")
                return
            }

            do {
                _ = try await eventStore.requestFullAccessToEvents()
            } catch {
                print("Calendar authorization failed: \(error.localizedDescription)")
            }
        }
    }

    private func hasInfoPlistValue(for key: String) -> Bool {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            return false
        }

        return value.isEmpty == false
    }

    private var healthReadTypes: Set<HKObjectType> {
        var types: Set<HKObjectType> = []

        if let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount) {
            types.insert(stepCount)
        }

        if let standHour = HKObjectType.categoryType(forIdentifier: .appleStandHour) {
            types.insert(standHour)
        }

        return types
    }
}

private enum OnboardingStep {
    case splash
    case welcome
    case healthAccess
    case calendarAccess
    case plantarSurvey
    case success

    var next: OnboardingStep? {
        switch self {
        case .splash:
            .welcome
        case .welcome:
            .healthAccess
        case .healthAccess:
            .calendarAccess
        case .calendarAccess:
            .plantarSurvey
        case .plantarSurvey:
            .success
        case .success:
            nil
        }
    }
}

#Preview("onboarding-flow") {
    OnboardingView()
}
