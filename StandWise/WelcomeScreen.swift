//
//  WelcomeScreen.swift
//  StandWise
//
//  Created by Aura Jatra on 22/05/26.
//

import SwiftUI

struct WelcomeScreen: View {
    var onGetStarted: () -> Void = {}

    private let brandGreen = Color(red: 0.05, green: 0.48, blue: 0.22)

    var body: some View {
        NavigationStack {
            ZStack {
                background

                VStack(spacing: 28) {
                    Spacer(minLength: 32)

                    hero

                    VStack(spacing: 14) {
                        VStack(spacing: 4) {
                            Text("StandWise")
                                .font(.system(.largeTitle, design: .serif, weight: .bold))

                            Text("TRACK · RECOVER · RISE")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }

                        Text("Smart foot care for people who are always on the move.")
                            .font(.subheadline.weight(.medium))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.primary)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 28)

                    Spacer(minLength: 24)

                    VStack(spacing: 18) {
                        Button(action: onGetStarted) {
                            Text("Get Started")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .tint(brandGreen)

                        Text("Requires Apple Watch and Calendar access")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 22)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(.secondarySystemBackground),
                brandGreen.opacity(0.12)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var hero: some View {
        ZStack {
            Circle()
                .fill(.thinMaterial)
                .frame(width: 184, height: 184)
                .shadow(color: brandGreen.opacity(0.18), radius: 22, y: 12)

            Circle()
                .strokeBorder(brandGreen.opacity(0.2), lineWidth: 1)
                .frame(width: 184, height: 184)

            Image(systemName: "figure.walk.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 88, weight: .regular))
                .foregroundStyle(brandGreen)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("onboarding-2") {
    WelcomeScreen()
}
