//
//  PlantarSurveyScreen.swift
//  StandWise
//
//  Created by Aura Jatra on 22/05/26.
//

import SwiftUI

struct PlantarSurveyScreen: View {
    var onNext: () -> Void = {}

    private let brandGreen = Color(red: 0.05, green: 0.48, blue: 0.22)

    @State private var selectedSeverity: PlantarSurveyOption?
    @State private var selectedDailyHours: PlantarSurveyOption?
    @State private var selectedTypicalDay: PlantarSurveyOption?

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        header

                        SurveyOptionCard(
                            options: PlantarSurveyOption.severityOptions,
                            selection: $selectedSeverity,
                            tint: brandGreen
                        )

                        SurveySection(
                            title: "How many hours on your feet daily?",
                            options: PlantarSurveyOption.dailyHoursOptions,
                            selection: $selectedDailyHours,
                            tint: brandGreen
                        )

                        SurveySection(
                            title: "What best describes your typical day?",
                            options: PlantarSurveyOption.typicalDayOptions,
                            selection: $selectedTypicalDay,
                            tint: brandGreen
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 0)
                    .padding(.bottom, 24)
                }

                actions
                    .padding(.horizontal, 28)
                    .padding(.bottom, 20)
            }
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(.secondarySystemBackground),
                brandGreen.opacity(0.08)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How's your plantar fasciitis lately?")
                .font(.title.bold())
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text("This sets your initial safety limits. The app adjusts automatically over time.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actions: some View {
        Button(action: onNext) {
            Text("Next")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(brandGreen)
    }
}

private struct SurveySection: View {
    let title: String
    let options: [PlantarSurveyOption]
    @Binding var selection: PlantarSurveyOption?
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            SurveyOptionCard(
                options: options,
                selection: $selection,
                tint: tint
            )
        }
    }
}

private struct SurveyOptionCard: View {
    let options: [PlantarSurveyOption]
    @Binding var selection: PlantarSurveyOption?
    let tint: Color

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                Button {
                    selection = option
                } label: {
                    SurveyOptionRow(
                        option: option,
                        isSelected: selection == option,
                        tint: tint
                    )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection == option ? .isSelected : [])

                if index < options.count - 1 {
                    Divider()
                        .padding(.leading)
                }
            }
        }
        .padding(.vertical, 8)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        }
    }
}

private struct SurveyOptionRow: View {
    let option: PlantarSurveyOption
    let isSelected: Bool
    let tint: Color

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(option.title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text(option.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 12)

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .symbolRenderingMode(.hierarchical)
                .font(.title3)
                .foregroundStyle(isSelected ? tint : Color(.tertiaryLabel))
                .accessibilityHidden(true)
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

private struct PlantarSurveyOption: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String

    static let mild = PlantarSurveyOption(
        id: "mild",
        title: "Mild",
        subtitle: "Occasional discomfort, manageable"
    )

    static let moderate = PlantarSurveyOption(
        id: "moderate",
        title: "Moderate",
        subtitle: "Regular pain, especially mornings"
    )

    static let severe = PlantarSurveyOption(
        id: "severe",
        title: "Severe",
        subtitle: "Daily flare-ups, limiting activity"
    )

    static let underFourHours = PlantarSurveyOption(
        id: "under-four-hours",
        title: "Under 4 hours",
        subtitle: "Desk job"
    )

    static let fourToSevenHours = PlantarSurveyOption(
        id: "four-to-seven-hours",
        title: "4 - 7 hours",
        subtitle: "Mixed"
    )

    static let sevenPlusHours = PlantarSurveyOption(
        id: "seven-plus-hours",
        title: "7+ hours",
        subtitle: "Standing"
    )

    static let mostlySitting = PlantarSurveyOption(
        id: "mostly-sitting",
        title: "Mostly sitting",
        subtitle: "Low foot load, but poor circulation risk"
    )

    static let sittingAndStanding = PlantarSurveyOption(
        id: "sitting-and-standing",
        title: "Mix of sitting and standing",
        subtitle: "Moderate stress, manageable"
    )

    static let mostlyStanding = PlantarSurveyOption(
        id: "mostly-standing",
        title: "Mostly standing or walking",
        subtitle: "High foot fatigue & flare-up risk"
    )

    static let severityOptions = [mild, moderate, severe]
    static let dailyHoursOptions = [underFourHours, fourToSevenHours, sevenPlusHours]
    static let typicalDayOptions = [mostlySitting, sittingAndStanding, mostlyStanding]
}

#Preview("onboarding-5") {
    PlantarSurveyScreen()
}
