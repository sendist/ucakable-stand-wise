//
//  HealthAccessScreen.swift
//  StandWise
//
//  Created by Aura Jatra on 22/05/26.
//

import SwiftUI

struct HealthAccessScreen: View {
    var onAllowHealthAccess: () -> Void = {}
    var onSkip: () -> Void = {}

    private let brandGreen = Color(red: 0.05, green: 0.48, blue: 0.22)

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                Spacer(minLength: 28)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        header
                        permissionsCard
                        privacyNote
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 42)
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
        VStack(spacing: 22) {
            Image("Health")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .accessibilityLabel("Apple Health")

            VStack(spacing: 10) {
                Text("Health Access")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)

                Text("StandWise reads your activity data to estimate standing time and daily movement.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var permissionsCard: some View {
        VStack(spacing: 0) {
            PermissionRow(
                icon: "figure.walk",
                title: "Step Count",
                subtitle: "Auto-tracked throughout the day",
                tint: brandGreen
            )

            Divider()
                .padding(.leading)

            PermissionRow(
                icon: "figure.stand",
                title: "Stand Time",
                subtitle: "Minutes standing per hour",
                tint: brandGreen
            )
        }
        .padding(.vertical, 8)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        }
    }

    private var privacyNote: some View {
        Label {
            Text("Your data stays on your device.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        } icon: {
            Image(systemName: "lock.shield.fill")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(brandGreen)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var actions: some View {
        VStack(spacing: 14) {
            Button(action: onAllowHealthAccess) {
                Label("Allow Health Access", systemImage: "heart.text.square.fill")
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

private struct PermissionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color

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

                Image(systemName: "checkmark.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .font(.title3)
                    .foregroundStyle(tint)
                    .accessibilityLabel("Included")
            }
        } icon: {
            Image(systemName: icon)
                .symbolRenderingMode(.hierarchical)
                .font(.title2)
                .foregroundStyle(tint)
                .frame(width: 32)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview("onboarding-3") {
    HealthAccessScreen()
}
