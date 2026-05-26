//
//  CalenderAccessScreen.swift
//  StandWise
//
//  Created by Aura Jatra on 22/05/26.
//

import SwiftUI
import UIKit

struct CalenderAccessScreen: View {
    var onAllowCalendarAccess: () -> Void = {}
    var onSkip: () -> Void = {}

    private let brandGreen = Color(red: 0.05, green: 0.48, blue: 0.22)

    var body: some View {
        ZStack {
            background

            VStack(spacing: 24) {
                Spacer(minLength: 20)

                header
                scheduleCard
                privacyNote

                Spacer(minLength: 16)

                actions
                    .padding(.horizontal, 4)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
    }

    private var background: some View {
        Color(.systemBackground)
            .ignoresSafeArea()
    }

    private var header: some View {
        VStack(spacing: 20) {
            CalendarIcon()
                .frame(width: 112, height: 112)
                .accessibilityLabel("Calendar")

            VStack(spacing: 8) {
                Text("Calendar Access")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)

                Text("StandWise reads your schedule to predict heavy days before they happen.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var scheduleCard: some View {
        VStack(spacing: 0) {
            CalendarLoadRow(
                color: Color("ImpactLow"),
                title: "Low Impact",
                subtitle: "Meetings, calls, desk work"
            )

            Divider()
                .padding(.leading)

            CalendarLoadRow(
                color: Color("ImpactMid"),
                title: "Mid Impact",
                subtitle: "Presentations and training"
            )

            Divider()
                .padding(.leading)

            CalendarLoadRow(
                color: Color("ImpactHigh"),
                title: "High Impact",
                subtitle: "Field events, outdoor work, walks"
            )
        }
        .padding(.vertical, 8)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        }
    }

    private var privacyNote: some View {
        Label {
            Text("Read only. We never edit or delete events.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        } icon: {
            Image(systemName: "calendar.badge.checkmark")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(brandGreen)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var actions: some View {
        VStack(spacing: 14) {
            Button(action: onAllowCalendarAccess) {
                Label("Allow Calendar Access", systemImage: "calendar.badge.checkmark")
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
}

private struct CalendarIcon: View {
    private let assetNames = ["calender", "Calender", "calendar", "Calendar"]

    var body: some View {
        if let image = assetNames.compactMap(UIImage.init(named:)).first {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "calendar")
                .resizable()
                .scaledToFit()
                .symbolRenderingMode(.multicolor)
        }
    }
}

private struct CalendarLoadRow: View {
    let color: Color
    let title: String
    let subtitle: String

    var body: some View {
        Label {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 12)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
        } icon: {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview("onboarding-4") {
    CalenderAccessScreen()
}
