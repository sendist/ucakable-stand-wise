//
//  EventManager.swift
//  StandWise
//
//  Created by Sendi Setiawan on 20/05/26.
//

import EventKit
import Foundation
import Observation

struct CalendarActivity: Identifiable, Hashable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let calendarTitle: String

    var timeRangeText: String {
        if isAllDay {
            return "All day"
        }

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}

@MainActor
@Observable
final class EventManager {
    var todayActivities: [CalendarActivity] = []
    var isLoading = false
    var errorMessage: String?
    var hasCalendarAccess = EKEventStore.authorizationStatus(for: .event) == .fullAccess

    private let eventStore = EKEventStore()

    func requestAuthorizationAndFetchTodayActivities() async {
        isLoading = true
        errorMessage = nil

        do {
            try await requestCalendarAccessIfNeeded()
            hasCalendarAccess = true
            todayActivities = await fetchTodayActivities()
        } catch {
            hasCalendarAccess = false
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refreshTodayActivities() async {
        guard EKEventStore.authorizationStatus(for: .event) == .fullAccess else {
            hasCalendarAccess = false
            todayActivities = []
            errorMessage = nil
            return
        }

        hasCalendarAccess = true
        isLoading = true
        errorMessage = nil
        todayActivities = await fetchTodayActivities()
        isLoading = false
    }

    private func requestCalendarAccessIfNeeded() async throws {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .fullAccess:
            return
        case .notDetermined:
            let granted = try await eventStore.requestFullAccessToEvents()
            if !granted {
                throw EventManagerError.authorizationDenied
            }
        case .denied, .restricted, .writeOnly:
            throw EventManagerError.authorizationDenied
        @unknown default:
            throw EventManagerError.authorizationDenied
        }
    }

    private func fetchTodayActivities() async -> [CalendarActivity] {
        let store = eventStore

        return await Task.detached(priority: .userInitiated) {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: Date())
            guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
                return []
            }

            let predicate = store.predicateForEvents(
                withStart: startOfDay,
                end: endOfDay,
                calendars: nil
            )

            return store.events(matching: predicate)
                .filter { $0.status != .canceled }
                .sorted { $0.startDate < $1.startDate }
                .map { event in
                    CalendarActivity(
                        id: event.eventIdentifier ?? "\(event.calendarItemIdentifier)-\(event.startDate.timeIntervalSince1970)",
                        title: event.title ?? "Untitled Event",
                        startDate: event.startDate,
                        endDate: event.endDate,
                        isAllDay: event.isAllDay,
                        calendarTitle: event.calendar.title
                    )
                }
        }.value
    }
}

enum EventManagerError: LocalizedError {
    case authorizationDenied

    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            "Calendar permission was not granted."
        }
    }
}
