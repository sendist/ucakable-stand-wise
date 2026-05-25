//
//  ScreenPage.swift
//  StandWise
//
//  Created by Aura Jatra on 22/05/26.
//

import SwiftUI

struct ScreenPage: View {
    private let brandGreen = Color(red: 0.05, green: 0.48, blue: 0.22)
    private let backgroundColor = Color(red: 0.96, green: 0.96, blue: 0.98)

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 2) {
                Text("StandWise")
                    .font(.system(size: 44, weight: .bold, design: .serif))
                    .foregroundStyle(brandGreen)

                Text("TRACK · RECOVER · RISE")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(brandGreen)
            }
            .multilineTextAlignment(.center)
        }
    }
}

#Preview("onboarding-1") {
    ScreenPage()
}
