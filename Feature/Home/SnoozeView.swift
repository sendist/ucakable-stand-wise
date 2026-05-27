//
//  SnoozeView.swift
//  StandWise
//
//  Created by Gracia Pardede on 24/05/26.
//

import SwiftUI

struct SnoozeView: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (Int) -> Void

    @AppStorage("warningSnoozeMinutes") private var storedSnoozeMinutes = 14
    @State private var selectedMinutes: Int

    private let minuteOptions = Array(1...15)
    private let brandGreen = Color(red: 0.05, green: 0.48, blue: 0.22)

    init(onSave: @escaping (Int) -> Void = { _ in }) {
        self.onSave = onSave
        let savedMinutes = UserDefaults.standard.object(forKey: "warningSnoozeMinutes") as? Int
        _selectedMinutes = State(initialValue: savedMinutes ?? 14)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                messageSection

                infoCard

                durationCard

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 44)
            .padding(.bottom, 28)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(background)
            .navigationTitle("Snooze")
            .navigationBarTitleDisplayMode(.inline)
            .tint(brandGreen)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveDuration()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .background(background)
    }

    private var background: some View {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
    }

    private var messageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Okay. We’ll check back soon.")
                .font(.headline.bold())
                .foregroundStyle(.primary)

            Text("If you can’t sit, try shifting your weight between feet. It reduces load on one heel while standing.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        
    }

    private var infoCard: some View {
        Label {
            VStack(alignment: .leading, spacing: 3) {
                Text("Snooze 1 of 3.")
                    .font(.footnote.weight(.semibold))
                Text("We’ll stop pinging after 3 reminders. Widget stays red until you’ve rested.")
                    .font(.footnote)
            }
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        } icon: {
            ZStack {
                Circle()
                    .fill(brandGreen)
                    .frame(width: 18, height: 18)

                Text("i")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var durationCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Snooze Duration")
                .font(.headline.bold())
                .foregroundStyle(.primary)

            Picker("Duration", selection: $selectedMinutes) {
                ForEach(minuteOptions, id: \.self) { minute in
                    Text("\(minute) minutes")
                        .tag(minute)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(height: 124)
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func saveDuration() {
        let minutes = selectedMinutes == 0 ? 14 : selectedMinutes
        storedSnoozeMinutes = minutes
        onSave(minutes)
        dismiss()
    }
}

#Preview("snooze") {
    SnoozeView()
}
