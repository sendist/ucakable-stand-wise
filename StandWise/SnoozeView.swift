//
//  SnoozeView.swift
//  StandWise
//
//  Created by Gracia Pardede on 24/05/26.
//

import SwiftUI

struct SnoozeView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedMinutes = 14

    private let minuteOptions = Array(1...15)
    private let accentBlue = Color(.systemBlue)
    private let sheetBackground = Color(.systemGroupedBackground)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerActions
                .padding(.top, 8)

            messageSection
                .padding(.top, 20)

            infoCard
                .padding(.top, 28)

            durationSection
                .padding(.top, 12)

            saveButton
                .padding(.top, 18)
                .padding(.horizontal, 72)
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 22)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(sheetBackground.ignoresSafeArea(edges: .bottom))
        .presentationBackground(sheetBackground)
        .presentationCornerRadius(28)
    }

    private var headerActions: some View {
        HStack {
            Spacer()

            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 34, height: 34)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
        }
    }

    private var messageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Okay. We’ll check back soon.")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.primary)

            Text("If you can’t sit, try shifting your weight between feet. It reduces load on one heel while standing.")
                .font(.system(size: 18))
                .foregroundStyle(.secondary)
                .lineSpacing(2)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var infoCard: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "info.circle.fill")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 3) {
                Text("Snooze 1 of 3.")
                Text("We’ll stop ping in after 3 reminders. Widget stays red until you’ve rested.")
            }
            .font(.footnote)
            .foregroundStyle(Color(.darkGray))
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(.separator).opacity(0.35), lineWidth: 1)
        }
    }

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Confirm Snooze Duration")
                .font(.system(size: 21, weight: .semibold))
                .foregroundStyle(Color(.systemGray))

            Picker("Confirm Snooze Duration", selection: $selectedMinutes) {
                ForEach(minuteOptions, id: \.self) { minute in
                    Text("\(minute) minutes")
                        .tag(minute)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(height: 136)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
    }

    private var saveButton: some View {
        Button(action: saveDuration) {
            Text("Save Duration")
                .font(.system(size: 21, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(accentBlue)
                .clipShape(Capsule())
                .shadow(color: accentBlue.opacity(0.28), radius: 20, y: 10)
        }
        .buttonStyle(.plain)
    }

    private func saveDuration() {
        dismiss()
    }
}

#Preview("snooze") {
    ZStack(alignment: .bottom) {
        Color(.systemGray4)
            .ignoresSafeArea()

        SnoozeView()
            .clipShape(.rect(topLeadingRadius: 36, topTrailingRadius: 36))
    }
}
