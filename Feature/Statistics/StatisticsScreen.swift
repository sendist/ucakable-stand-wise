//
//  StatisticsScreen.swift
//  StandWise
//
//  Created by Aura Jatra on 22/05/26.
//

import SwiftUI
import SwiftData

struct StatisticsScreen: View {
    @Query(sort: \PainLogEntry.logTime, order: .reverse) private var painLogEntries: [PainLogEntry]

    private let brandGreen = Color(red: 0.05, green: 0.48, blue: 0.22)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header

                if painLogEntries.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 10) {
                        ForEach(painLogEntries) { entry in
                            painLogRow(entry)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 28)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Pain Log Statistics")
                .font(.title2.weight(.bold))

            Text("\(painLogEntries.count) total \(painLogEntries.count == 1 ? "entry" : "entries")")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Pain Logs", systemImage: "list.clipboard")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(brandGreen)
        } description: {
            Text("Saved pain logs will appear here.")
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    private func painLogRow(_ entry: PainLogEntry) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.painLocation)
                        .font(.headline)

                    Text(entry.logTime, format: .dateTime.month(.abbreviated).day().hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 12)

                Text("Severity \(entry.painSeverity)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(brandGreen, in: Capsule())
            }

            if let context = entry.context, !context.isEmpty {
                Text(context)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }

            HStack(spacing: 12) {
                Label(entry.stepCount.formatted(), systemImage: "figure.walk")
                Label(formattedDuration(minutes: entry.standTimeMinutes), systemImage: "figure.stand")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        }
    }

    private func formattedDuration(minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60

        if hours > 0 && remainingMinutes > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(remainingMinutes)m"
        }
    }
}

#Preview("statistics") {
    NavigationStack {
        StatisticsScreen()
            .modelContainer(for: PainLogEntry.self, inMemory: true)
    }
}
