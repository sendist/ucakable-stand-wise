//
//  SplashScreen.swift
//  StandWise
//
//  Created by Aura Jatra on 22/05/26.
//

import SwiftUI

struct SplashScreen: View {
    private let brandGreen = Color(red: 0.05, green: 0.48, blue: 0.22)
    private let backgroundColor = Color(red: 0.96, green: 0.96, blue: 0.98)

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 10) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88, height: 88)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .accessibilityHidden(true)

                Text("StandWise")
                    .font(.largeTitle.bold())
                    .foregroundStyle(brandGreen)

                Text("TRACK · RECOVER · RISE")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(brandGreen)
            }
            .multilineTextAlignment(.center)
        }
    }
}

#Preview("onboarding-1") {
    SplashScreen()
}
