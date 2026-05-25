//
//  HomeView.swift
//  StandWise
//
//  Created by Aura Jatra on 22/05/26.
//

import SwiftUI

struct HomeView: View {
    @State private var isShowingSnooze = false
    @State private var activityItems = ActivityItem.sampleData
    @State private var activityEditor: ActivityEditor?

    private let brandGreen = Color(red: 0.05, green: 0.48, blue: 0.22)
    private let cautionRed = Color(.systemRed)

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    profileHeader

                    warningWidget

                    statsSection

                    activitySection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
            .background(background)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isShowingSnooze) {
            SnoozeView()
                .presentationDetents([.height(460)])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color(.systemGroupedBackground))
        }
        .sheet(item: $activityEditor) { editor in
            ActivityEditorView(editor: editor) { savedActivity in
                saveActivity(savedActivity, isNew: editor.isNew)
            } onDelete: { deletedActivity in
                deleteActivity(deletedActivity)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color(.systemGroupedBackground))
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

    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(brandGreen)
                    .frame(width: 52, height: 52)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.88))
                    }
                    .accessibilityHidden(true)

                HStack(spacing: 0) {
                    Text("Hello, ")
                        .font(.largeTitle)
                        .fontWeight(.regular)

                    Text("Peter T")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
            }

            Text("Let's keep your activity in balance today.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var warningWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("YOUR FEET ARE CURRENTLY")
                    .font(.caption.weight(.bold))

                Spacer(minLength: 12)

                Text("Mon, May 18")
                    .font(.caption)
            }
            .foregroundStyle(.primary)

            cautionBadge

            VStack(alignment: .leading, spacing: 6) {
                Text("You’ve exceeded your safe limit.")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(cautionRed)
                    .fixedSize(horizontal: false, vertical: true)

                Text("10 minutes of rest now is worth far more than days of recovery. Find a seat and do simple exercise now!")
                    .font(.callout)
                    .foregroundStyle(.primary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 12) {
                Button {
                } label: {
                    Text("OK")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                .tint(cautionRed)
                .clipShape(Capsule())

                Button {
                    isShowingSnooze = true
                } label: {
                    Text("Still Busy")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                .tint(Color(.systemGray))
                .clipShape(Capsule())
            }

            painLogLink
        }
        .padding(16)
        .background(warningBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.85), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.10), radius: 10, y: 5)
    }

    private var painLogLink: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Today’s Pain Logs")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text("6 entries")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
            }

            NavigationLink {
                PainLogView()
            } label: {
                Text("Log Pain")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(cautionRed)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(Color(.systemBackground), in: Capsule())
                    .shadow(color: .black.opacity(0.10), radius: 8, y: 4)
            }
            .buttonStyle(.plain)
            .accessibilityHint("Open pain log")
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.28), lineWidth: 1)
        }
    }

    private var cautionBadge: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(cautionRed.opacity(0.18))
                    .frame(width: 13, height: 13)

                Circle()
                    .fill(cautionRed)
                    .frame(width: 7, height: 7)
            }

            Text("WARNING")
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundStyle(cautionRed)
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.25))
                .overlay {
                    Capsule()
                        .stroke(.white.opacity(0.30), lineWidth: 1)
                }
        )
    }

    private var statsSection: some View {
        HStack(spacing: 0) {
            statItem(icon: "figure.walk", value: "5,102", label: "Steps")

            statDivider

            statItem(icon: "figure.stand", value: "3h 13m", label: "Standing")

            statDivider

            statItem(icon: "sofa.fill", value: "2h 5m", label: "Rest")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        }
    }

    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 7) {
            Image(systemName: icon)
                .font(.title2.weight(.semibold))
                .foregroundStyle(brandGreen)
                .frame(width: 44, height: 44)
                .background(brandGreen.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(spacing: 0) {
                Text(value)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)

                Text(label)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Color(.separator))
            .frame(width: 1, height: 64)
    }

    private var warningBackground: some View {
        LinearGradient(
            colors: [
                Color("WarningGradientTop"),
                Color("WarningGradientMiddle"),
                Color("WarningGradientBottom")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Activity")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)

                Spacer()

                Button {
                    activityEditor = .new()
                } label: {
                    Label("Add Activity", systemImage: "plus")
                }
                .font(.subheadline.weight(.semibold))
                .labelStyle(.titleAndIcon)
                .foregroundStyle(brandGreen)
            }

            VStack(spacing: 0) {
                ForEach(activityItems) { item in
                    Button {
                        activityEditor = .edit(item)
                    } label: {
                        ActivityRow(item: item)
                    }
                    .buttonStyle(.plain)

                    if item.id != activityItems.last?.id {
                        Divider()
                            .padding(.leading, 96)
                    }
                }
            }
            .padding(.vertical, 4)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
            }
        }
    }

    private func saveActivity(_ activity: ActivityItem, isNew: Bool) {
        var activity = activity
        activity.title = activity.title.trimmingCharacters(in: .whitespacesAndNewlines)

        if isNew {
            activityItems.append(activity)
            return
        }

        guard let index = activityItems.firstIndex(where: { $0.id == activity.id }) else {
            return
        }

        activityItems[index] = activity
    }

    private func deleteActivity(_ activity: ActivityItem) {
        activityItems.removeAll { $0.id == activity.id }
    }
}

struct ActivityItem: Identifiable {
    let id: UUID
    var title: String
    var impact: ActivityImpact
    var isAllDay: Bool
    var startDate: Date
    var endDate: Date

    init(
        id: UUID = UUID(),
        title: String,
        impact: ActivityImpact,
        isAllDay: Bool = false,
        startDate: Date,
        endDate: Date
    ) {
        self.id = id
        self.title = title
        self.impact = impact
        self.isAllDay = isAllDay
        self.startDate = startDate
        self.endDate = endDate
    }

    var time: String {
        if isAllDay {
            return "All-day"
        }

        return Self.timeFormatter.string(from: startDate)
    }

    static let sampleData = [
        ActivityItem(title: "Morning Walk", impact: .mid, startDate: sampleDate(hour: 6, minute: 0), endDate: sampleDate(hour: 7, minute: 0)),
        ActivityItem(title: "Badminton", impact: .high, startDate: sampleDate(hour: 9, minute: 30), endDate: sampleDate(hour: 10, minute: 30)),
        ActivityItem(title: "Teaching", impact: .mid, startDate: sampleDate(hour: 13, minute: 0), endDate: sampleDate(hour: 15, minute: 0)),
        ActivityItem(title: "Swimming", impact: .low, startDate: sampleDate(hour: 19, minute: 0), endDate: sampleDate(hour: 20, minute: 0))
    ]

    static func sampleDate(hour: Int, minute: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}

enum ActivityImpact: String, CaseIterable, Identifiable {
    case low = "LOW IMPACT"
    case mid = "MID IMPACT"
    case high = "HIGH IMPACT"

    var id: Self { self }

    var title: String {
        switch self {
        case .low:
            "Low Impact"
        case .mid:
            "Mid Impact"
        case .high:
            "High Impact"
        }
    }

    var color: Color {
        switch self {
        case .low:
            Color("ImpactLow")
        case .mid:
            Color("ImpactMid")
        case .high:
            Color("ImpactHigh")
        }
    }

    var foregroundColor: Color {
        switch self {
        case .mid:
            .black
        case .low, .high:
            .white
        }
    }
}

private struct ActivityRow: View {
    let item: ActivityItem

    var body: some View {
        HStack(spacing: 14) {
            Text(item.time)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 84, alignment: .leading)

            Text(item.title)
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)

            Spacer(minLength: 8)

            Text(item.impact.rawValue)
                .font(.caption2.weight(.bold))
                .foregroundStyle(item.impact.foregroundColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(item.impact.color)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color(.tertiaryLabel))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

private struct ActivityDetailPlaceholder: View {
    let item: ActivityItem

    var body: some View {
        ContentUnavailableView {
            Label(item.title, systemImage: "figure.walk")
        } description: {
            Text("Activity details will appear here.")
        }
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("home") {
    NavigationStack {
        HomeView()
    }
}
