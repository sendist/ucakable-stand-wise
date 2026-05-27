//
//  User.swift
//  StandWise
//
//  Created by Sendi Setiawan on 20/05/26.
//

import Foundation
import SwiftData

protocol SelectableCondition: Identifiable, Hashable, CaseIterable {
    var title: String { get }
    var description: String { get }
}

enum FootCondition: String, SelectableCondition {
    case mild
    case moderate
    case severe

    var id: String { rawValue }

    var title: String {
        switch self {
        case .mild:
            "Mild"
        case .moderate:
            "Moderate"
        case .severe:
            "Severe"
        }
    }

    var maxSteps: Int {
        switch self {
        case .mild:
            5_000
        case .moderate:
            4_000
        case .severe:
            3_000
        }
    }

    var description: String {
        switch self {
        case .mild:
            "Occasional discomfort, manageable"
        case .moderate:
            "Regular pain, especially mornings"
        case .severe:
            "Daily flare-ups, limiting activity"

        }
    }
}

enum StandCondition: String, SelectableCondition {
    case mild
    case moderate
    case severe

    var id: String { rawValue }

    var title: String {
        switch self {
        case .mild:
            "Under 4 hours"
        case .moderate:
            "4 - 7 hours"
        case .severe:
            "+7 hours"
        }
    }

    var maxHours: Int {
        switch self {
        case .mild:
            5_000
        case .moderate:
            4_000
        case .severe:
            3_000
        }
    }

    var description: String {
        switch self {
        case .mild:
            "Desk Job"
        case .moderate:
            "Mixed"
        case .severe:
            "Standing"

        }
    }
}

@Model
final class User {
    var name: String
    var footCondition: String
    var standCondition: String
    var maxFootLoad: Int
    @Attribute(.externalStorage) var profileImageData: Data?
    var createdAt: Date

    init(
        name: String,
        footCondition: FootCondition,
        standCondition: StandCondition,
        maxFootLoad: Int? = nil,
        profileImageData: Data? = nil,
        createdAt: Date = Date()
    ) {
        self.name = name
        self.footCondition = footCondition.rawValue
        self.standCondition = standCondition.rawValue
        self.maxFootLoad = maxFootLoad ?? footCondition.maxSteps
        self.profileImageData = profileImageData
        self.createdAt = createdAt
    }

    var condition: FootCondition {
        FootCondition(rawValue: footCondition) ?? .moderate
    }
}
