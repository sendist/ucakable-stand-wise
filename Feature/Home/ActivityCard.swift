//
//  ActivityCard.swift
//  StandWise
//
//  Created by Sendi Setiawan on 20/05/26.
//

import Foundation
import SwiftUI

struct ActivityCard: View {
    @AppStorage("activityCardImpacts") private var storedActivityImpacts = Data()
    @AppStorage("activityCardManualActivities") private var storedManualActivities = Data()

    @State private var eventManager = EventManager()
    @State private var activityImpacts: [String: ActivityImpact] = [:]
    @State private var manualActivities: [ActivityItem] = []
    @State private var activityEditor: ActivityCardEditor?
    @State private var didLoadStoredState = false

    private let brandGreen = Color(red: 0.05, green: 0.48, blue: 0.22)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            if eventManager.hasCalendarAccess || !manualActivities.isEmpty {
                activityList
            }

            if !eventManager.hasCalendarAccess {
                calendarPermissionPrompt
            }

            if let errorMessage = eventManager.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .task {
            loadStoredStateIfNeeded()
            await eventManager.refreshTodayActivities()
        }
        .sheet(item: $activityEditor) { editor in
            ActivityCardEditorView(editor: editor) { savedActivity in
                saveActivity(savedActivity, isNew: editor.isNew)
            } onDelete: { deletedActivity in
                deleteActivity(deletedActivity)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color(.systemGroupedBackground))
        }
    }

    private var header: some View {
        HStack {
            Text("Your Activity")
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)

            Spacer()

            Button {
                activityEditor = ActivityCardEditor.new()
            } label: {
                Label("Add Activity", systemImage: "plus")
            }
            .font(.subheadline.weight(.semibold))
            .labelStyle(.titleAndIcon)
            .foregroundStyle(brandGreen)

            Button {
                Task {
                    if eventManager.hasCalendarAccess {
                        await eventManager.refreshTodayActivities()
                    } else {
                        await eventManager.requestAuthorizationAndFetchTodayActivities()
                    }
                }
            } label: {
                Image(systemName: eventManager.hasCalendarAccess ? "arrow.clockwise" : "calendar.badge.plus")
            }
            .buttonStyle(.borderless)
            .disabled(eventManager.isLoading)
            .accessibilityLabel(eventManager.hasCalendarAccess ? "Refresh calendar activities" : "Allow calendar access")
        }
    }

    private var calendarPermissionPrompt: some View {
        VStack(alignment: .leading, spacing: 12) {
            if eventManager.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("Calendar")
                    .font(.title.bold())
                Text("Allow access to show today's activity list")
                    .foregroundStyle(.secondary)
            }

            Divider()

            Button {
                Task {
                    await eventManager.requestAuthorizationAndFetchTodayActivities()
                }
            } label: {
                Label("Allow Calendar Access", systemImage: "calendar.badge.plus")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(brandGreen)
            .disabled(eventManager.isLoading)
        }
    }

    @ViewBuilder
    private var activityList: some View {
        if eventManager.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, alignment: .leading)
        } else if manualActivities.isEmpty && eventManager.todayActivities.isEmpty {
            Text("No calendar activities today")
                .foregroundStyle(.secondary)
        } else {
            VStack(spacing: 0) {
                ForEach(manualActivities) { activity in
                    manualActivityRow(activity)

                    if activity.id != manualActivities.last?.id || !eventManager.todayActivities.isEmpty {
                        Divider()
                            .padding(.leading, 32)
                    }
                }

                ForEach(eventManager.todayActivities) { activity in
                    calendarActivityRow(activity)

                    if activity.id != eventManager.todayActivities.last?.id {
                        Divider()
                            .padding(.leading, 32)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func manualActivityRow(_ activity: ActivityItem) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: activity.isAllDay ? "sun.max" : "clock")
                .foregroundStyle(.secondary)
                .frame(width: 20)

            Button {
                activityEditor = ActivityCardEditor.edit(activity)
            } label: {
                VStack(alignment: .leading, spacing: 3) {
                    Text(activity.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(activity.time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Manual")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            impactMenu(for: activity)
        }
        .padding(.vertical, 10)
    }

    private func calendarActivityRow(_ activity: CalendarActivity) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: activity.isAllDay ? "sun.max" : "clock")
                .foregroundStyle(.secondary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 3) {
                Text(activity.title)
                    .font(.subheadline.weight(.semibold))
                Text(activity.timeRangeText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(activity.calendarTitle)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            impactMenu(for: activity)
        }
        .padding(.vertical, 10)
    }

    private func impactMenu(for activity: CalendarActivity) -> some View {
        let selectedImpact = activityImpacts[activity.id, default: .mid]

        return Menu {
            ForEach(ActivityImpact.allCases) { impact in
                Button {
                    activityImpacts[activity.id] = impact
                    saveActivityImpacts()
                } label: {
                    if selectedImpact == impact {
                        Label(impact.title, systemImage: "checkmark")
                    } else {
                        Text(impact.title)
                    }
                }
            }
        } label: {
            Text(selectedImpact.rawValue)
                .font(.caption2.weight(.bold))
                .foregroundStyle(selectedImpact.foregroundColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(selectedImpact.color)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        .accessibilityLabel("Impact for \(activity.title)")
    }

    private func impactMenu(for activity: ActivityItem) -> some View {
        Menu {
            ForEach(ActivityImpact.allCases) { impact in
                Button {
                    updateManualActivity(activity, impact: impact)
                } label: {
                    if activity.impact == impact {
                        Label(impact.title, systemImage: "checkmark")
                    } else {
                        Text(impact.title)
                    }
                }
            }
        } label: {
            Text(activity.impact.rawValue)
                .font(.caption2.weight(.bold))
                .foregroundStyle(activity.impact.foregroundColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(activity.impact.color)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        .accessibilityLabel("Impact for \(activity.title)")
    }

    private func saveActivity(_ activity: ActivityItem, isNew: Bool) {
        var activity = activity
        activity.title = activity.title.trimmingCharacters(in: .whitespacesAndNewlines)

        if isNew {
            manualActivities.append(activity)
        } else if let index = manualActivities.firstIndex(where: { $0.id == activity.id }) {
            manualActivities[index] = activity
        }

        saveManualActivities()
    }

    private func deleteActivity(_ activity: ActivityItem) {
        manualActivities.removeAll { $0.id == activity.id }
        saveManualActivities()
    }

    private func updateManualActivity(_ activity: ActivityItem, impact: ActivityImpact) {
        guard let index = manualActivities.firstIndex(where: { $0.id == activity.id }) else {
            return
        }

        manualActivities[index].impact = impact
        saveManualActivities()
    }

    private func loadStoredStateIfNeeded() {
        guard !didLoadStoredState else {
            return
        }

        didLoadStoredState = true

        if let decodedImpacts = try? JSONDecoder().decode([String: ActivityImpact].self, from: storedActivityImpacts) {
            activityImpacts = decodedImpacts
        }

        if let decodedActivities = try? JSONDecoder().decode([ActivityItem].self, from: storedManualActivities) {
            manualActivities = decodedActivities
        }
    }

    private func saveActivityImpacts() {
        storedActivityImpacts = (try? JSONEncoder().encode(activityImpacts)) ?? Data()
    }

    private func saveManualActivities() {
        storedManualActivities = (try? JSONEncoder().encode(manualActivities)) ?? Data()
    }
}

private struct ActivityCardEditor: Identifiable {
    let id = UUID()
    let isNew: Bool
    var activity: ActivityItem

    static func new() -> ActivityCardEditor {
        let startDate = ActivityItem.sampleDate(hour: 8, minute: 0)
        let endDate = ActivityItem.sampleDate(hour: 10, minute: 0)
        return ActivityCardEditor(
            isNew: true,
            activity: ActivityItem(
                title: "",
                impact: .mid,
                startDate: startDate,
                endDate: endDate
            )
        )
    }

    static func edit(_ activity: ActivityItem) -> ActivityCardEditor {
        ActivityCardEditor(isNew: false, activity: activity)
    }
}

private struct ActivityCardEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let isNew: Bool
    let onSave: (ActivityItem) -> Void
    let onDelete: (ActivityItem) -> Void

    @State private var activity: ActivityItem

    private let brandGreen = Color(red: 0.05, green: 0.48, blue: 0.22)

    init(
        editor: ActivityCardEditor,
        onSave: @escaping (ActivityItem) -> Void,
        onDelete: @escaping (ActivityItem) -> Void
    ) {
        self.isNew = editor.isNew
        self.onSave = onSave
        self.onDelete = onDelete
        _activity = State(initialValue: editor.activity)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $activity.title)
                        .textInputAutocapitalization(.words)
                }
                .listRowBackground(Color(.secondarySystemGroupedBackground))

                Section {
                    Picker("Impact", selection: $activity.impact) {
                        ForEach(ActivityImpact.allCases) { impact in
                            Text(impact.title).tag(impact)
                        }
                    }

                    Toggle("All-day", isOn: $activity.isAllDay)

                    DatePicker(
                        "Start",
                        selection: $activity.startDate,
                        displayedComponents: activity.isAllDay ? [.date] : [.date, .hourAndMinute]
                    )

                    DatePicker(
                        "End",
                        selection: $activity.endDate,
                        displayedComponents: activity.isAllDay ? [.date] : [.date, .hourAndMinute]
                    )
                }
                .listRowBackground(Color(.secondarySystemGroupedBackground))

                if !isNew {
                    Section {
                        Button("Delete Activity", role: .destructive) {
                            onDelete(activity)
                            dismiss()
                        }
                    }
                    .listRowBackground(Color(.secondarySystemGroupedBackground))
                }
            }
            .scrollContentBackground(.hidden)
            .background(background)
            .navigationTitle(isNew ? "New Activity" : trimmedTitle)
            .navigationBarTitleDisplayMode(.inline)
            .tint(brandGreen)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isNew ? "Add" : "Done") {
                        save()
                    }
                    .disabled(trimmedTitle.isEmpty)
                }
            }
        }
        .background(background)
    }

    private var background: some View {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
    }

    private func save() {
        activity.title = trimmedTitle

        if activity.endDate < activity.startDate {
            activity.endDate = activity.startDate
        }

        onSave(activity)
        dismiss()
    }

    private var trimmedTitle: String {
        activity.title.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
