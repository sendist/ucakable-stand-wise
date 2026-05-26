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

                VStack(spacing: 24) {
                    Spacer(minLength: 24)

                    hero

                    VStack(spacing: 12) {
                        VStack(spacing: 4) {
                            Text("StandWise")
                                .font(.largeTitle.bold())

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
                    .padding(.horizontal, 24)

                    Spacer(minLength: 20)

                    VStack(spacing: 14) {
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
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var background: some View {
        Color(.systemBackground)
            .ignoresSafeArea()
    }

    private var hero: some View {
        Image("AppLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 108, height: 108)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .accessibilityHidden(true)
            .frame(maxWidth: .infinity)
    }
}

#Preview("onboarding-2") {
    WelcomeScreen()
}
