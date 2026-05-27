//
//  OnboardingView.swift
//  StandWise
//
//  Created by Aura Jatra on 22/05/26.
//

import EventKit
import HealthKit
import PhotosUI
import SwiftUI
import SwiftData
import UIKit

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \User.createdAt) private var users: [User]

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var step: OnboardingStep = .splash
    @State private var isOnboardingCompleted = false
    @State private var profileName = ""
    @State private var profileImageData: Data?

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

        case .profileSetup:
            ProfileSetupScreen(
                name: profileName,
                profileImageData: profileImageData,
                onContinue: saveProfileAndContinue,
                onSkip: goToNextStep
            )

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
        createOrUpdateUserIfNeeded()
        hasCompletedOnboarding = true
        isOnboardingCompleted = true

        Task {
            await StandWiseNotificationManager.sendWelcomeNotification()
        }
    }

    private func saveProfileAndContinue(name: String, profileImageData: Data?) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        profileName = trimmedName
        self.profileImageData = profileImageData
        goToNextStep()
    }

    private func createOrUpdateUserIfNeeded() {
        let savedName = profileName.isEmpty ? "User" : profileName

        if let user = users.first {
            user.name = savedName
            user.profileImageData = profileImageData

            do {
                try modelContext.save()
            } catch {
                print("Failed to update onboarding user: \(error.localizedDescription)")
            }

            return
        }

        let user = User(
            name: savedName,
            footCondition: .moderate,
            standCondition: .moderate,
            profileImageData: profileImageData
        )
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

        if let standTime = HKObjectType.quantityType(forIdentifier: .appleStandTime) {
            types.insert(standTime)
        }

        if let sleepAnalysis = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            types.insert(sleepAnalysis)
        }

        return types
    }
}

private enum OnboardingStep {
    case splash
    case welcome
    case profileSetup
    case healthAccess
    case calendarAccess
    case plantarSurvey
    case success

    var next: OnboardingStep? {
        switch self {
        case .splash:
            .welcome
        case .welcome:
            .profileSetup
        case .profileSetup:
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

private struct ProfileSetupScreen: View {
    let name: String
    let profileImageData: Data?
    var onContinue: (String, Data?) -> Void = { _, _ in }
    var onSkip: () -> Void = {}

    @State private var draftName: String
    @State private var draftImageData: Data?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isLoadingPhoto = false

    private let brandGreen = Color(red: 0.05, green: 0.48, blue: 0.22)

    init(
        name: String,
        profileImageData: Data?,
        onContinue: @escaping (String, Data?) -> Void = { _, _ in },
        onSkip: @escaping () -> Void = {}
    ) {
        self.name = name
        self.profileImageData = profileImageData
        self.onContinue = onContinue
        self.onSkip = onSkip
        _draftName = State(initialValue: name)
        _draftImageData = State(initialValue: profileImageData)
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer(minLength: 20)

                VStack(spacing: 10) {
                    Text("Set up your profile")
                        .font(.title.bold())
                        .multilineTextAlignment(.center)

                    Text("Add a name and picture for your dashboard.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                profilePhotoPicker

                TextField("Name", text: $draftName)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                    }

                Spacer(minLength: 16)

                VStack(spacing: 14) {
                    Button {
                        onContinue(draftName, draftImageData)
                    } label: {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(brandGreen)

                    Button("Skip for Now", action: onSkip)
                        .buttonStyle(.plain)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .onChange(of: selectedPhoto) {
            loadSelectedPhoto()
        }
    }

    private var profilePhotoPicker: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            ZStack(alignment: .bottomTrailing) {
                profilePhoto

                Image(systemName: "camera.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(brandGreen, in: Circle())
                    .overlay {
                        Circle()
                            .strokeBorder(Color(.systemBackground), lineWidth: 3)
                    }
            }
        }
        .buttonStyle(.plain)
        .disabled(isLoadingPhoto)
        .accessibilityLabel("Choose profile picture")
    }

    @ViewBuilder
    private var profilePhoto: some View {
        if isLoadingPhoto {
            ProgressView()
                .frame(width: 128, height: 128)
                .background(brandGreen.opacity(0.10), in: Circle())
        } else if let draftImageData,
                  let uiImage = UIImage(data: draftImageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 128, height: 128)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                }
        } else {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 118))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(brandGreen)
                .frame(width: 128, height: 128)
        }
    }

    private func loadSelectedPhoto() {
        guard let selectedPhoto else {
            return
        }

        isLoadingPhoto = true

        Task {
            defer {
                Task { @MainActor in
                    isLoadingPhoto = false
                }
            }

            guard let data = try? await selectedPhoto.loadTransferable(type: Data.self),
                  let resizedData = resizedJPEGData(from: data) else {
                return
            }

            await MainActor.run {
                draftImageData = resizedData
            }
        }
    }

    private func resizedJPEGData(from data: Data) -> Data? {
        guard let image = UIImage(data: data) else {
            return nil
        }

        let maxLength: CGFloat = 512
        let scale = min(maxLength / max(image.size.width, image.size.height), 1)
        let targetSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        return resizedImage.jpegData(compressionQuality: 0.82)
    }
}

#Preview("onboarding-flow") {
    OnboardingView()
}
