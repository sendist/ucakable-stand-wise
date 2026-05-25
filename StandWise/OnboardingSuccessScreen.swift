//
//  OnboardingSuccessScreen.swift
//  StandWise
//
//  Created by Aura Jatra on 22/05/26.
//

import SwiftUI

struct OnboardingSuccessScreen: View {
    var onOpenDashboard: () -> Void = {}

    private let brandGreen = Color(red: 0.05, green: 0.48, blue: 0.22)

    var body: some View {
        ZStack {
            background

            VStack(spacing: 24) {
                Spacer(minLength: 20)

                header
                activeCard

                Spacer(minLength: 16)

                actions
                    .padding(.horizontal, 4)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
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
        VStack(spacing: 24) {
            ZStack {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(brandGreen.gradient)
                    .shadow(color: brandGreen.opacity(0.24), radius: 18, y: 10)

                Image(systemName: "checkmark")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.green)
                    .accessibilityHidden(true)
            }
            .frame(width: 120, height: 120)
            .accessibilityLabel("Setup complete")

            VStack(spacing: 8) {
                Text("You're all set.")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)

                Text("StandWise will work silently. You'll only hear from it when it matters.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var activeCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("ACTIVE NOW")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            VStack(spacing: 0) {
                SuccessStatusRow(
                    color: .green,
                    title: "Health background tracking",
                    isEnabled: true
                )

                SuccessStatusRow(
                    color: .green,
                    title: "Calendar predictive alerts",
                    isEnabled: true
                )

                SuccessStatusRow(
                    color: .green,
                    title: "Proactive notifications",
                    isEnabled: true
                )

                SuccessStatusRow(
                    color: .yellow,
                    title: "Personalization kicks in after 7 days",
                    isEnabled: false
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        }
    }

    private var actions: some View {
        Button(action: onOpenDashboard) {
            Text("Open Dashboard")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(brandGreen)
    }
}

private struct SuccessStatusRow: View {
    let color: Color
    let title: String
    let isEnabled: Bool

    var body: some View {
        Label {
            Text(title)
                .font(.body.weight(.semibold))
                .foregroundStyle(isEnabled ? .primary : .secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        } icon: {
            Circle()
                .fill(color.gradient)
                .frame(width: 12, height: 12)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
}

#Preview("onboarding-6") {
    OnboardingSuccessScreen()
}
