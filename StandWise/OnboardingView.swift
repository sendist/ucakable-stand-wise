//
//  OnboardingView.swift
//  StandWise
//
//  Created by Aura Jatra on 22/05/26.
//

import SwiftUI
import EventKit
import HealthKit

struct OnboardingView: View {
    @State private var step: OnboardingStep = .splash
    @State private var isOnboardingCompleted = false
    @State private var healthStore = HKHealthStore()
    @State private var eventStore = EKEventStore()

    var body: some View {
        if isOnboardingCompleted {
            ContentView()
        } else {
            currentStep
                .animation(.easeInOut(duration: 0.25), value: step)
        }
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
        isOnboardingCompleted = true
    }

    private func requestHealthAccess() {
        Task {
            if HKHealthStore.isHealthDataAvailable() {
                do {
                    try await healthStore.requestAuthorization(toShare: [], read: healthReadTypes)
                } catch {
                    print("Health authorization failed: \(error.localizedDescription)")
                }
            }

            goToNextStep()
        }
    }

    private func requestCalendarAccess() {
        Task {
            do {
                _ = try await eventStore.requestFullAccessToEvents()
            } catch {
                print("Calendar authorization failed: \(error.localizedDescription)")
            }

            goToNextStep()
        }
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
