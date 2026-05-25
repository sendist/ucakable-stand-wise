//
//  ActivityItem.swift
//  StandWise
//

import Foundation
import SwiftUI

struct ActivityItem: Identifiable, Codable {
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

enum ActivityImpact: String, CaseIterable, Identifiable, Codable {
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
