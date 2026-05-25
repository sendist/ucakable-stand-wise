//
//  ActivityEditorView.swift
//  StandWise
//
//  Created by Gracia Pardede on 25/05/26.
//

import SwiftUI

struct ActivityEditor: Identifiable {
    let id = UUID()
    let isNew: Bool
    var activity: ActivityItem

    static func new() -> ActivityEditor {
        let startDate = ActivityItem.sampleDate(hour: 8, minute: 0)
        let endDate = ActivityItem.sampleDate(hour: 10, minute: 0)
        return ActivityEditor(
            isNew: true,
            activity: ActivityItem(
                title: "",
                impact: .mid,
                startDate: startDate,
                endDate: endDate
            )
        )
    }

    static func edit(_ activity: ActivityItem) -> ActivityEditor {
        ActivityEditor(isNew: false, activity: activity)
    }
}

struct ActivityEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let isNew: Bool
    let onSave: (ActivityItem) -> Void
    let onDelete: (ActivityItem) -> Void

    @State private var activity: ActivityItem

    init(
        editor: ActivityEditor,
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
                    Picker("Level", selection: $activity.impact) {
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
            .background(Color(.systemGroupedBackground))
            .navigationTitle(isNew ? "New Activity" : trimmedTitle)
            .navigationBarTitleDisplayMode(.inline)
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
        .background(Color(.systemGroupedBackground))
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

#Preview("add") {
    ActivityEditorView(
        editor: .new(),
        onSave: { _ in },
        onDelete: { _ in }
    )
}

#Preview("edit") {
    ActivityEditorView(
        editor: .edit(
            ActivityItem(
                title: "Morning Walk",
                impact: .mid,
                startDate: ActivityItem.sampleDate(hour: 6, minute: 0),
                endDate: ActivityItem.sampleDate(hour: 7, minute: 0)
            )
        ),
        onSave: { _ in },
        onDelete: { _ in }
    )
}
