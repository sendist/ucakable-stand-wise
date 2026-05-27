//
//  PainLogEntry.swift
//  StandWise
//
//  Created by Sendi Setiawan on 27/05/26.
//

import Foundation
import SwiftData

@Model
final class PainLogEntry {
    var logTime: Date
    var painLocation: String
    var painSeverity: Int
    var context: String?
    var stepCount: Int
    var standTimeMinutes: Int

    init(
        logTime: Date = Date(),
        painLocation: String,
        painSeverity: Int,
        context: String? = nil,
        stepCount: Int,
        standTimeMinutes: Int
    ) {
        self.logTime = logTime
        self.painLocation = painLocation
        self.painSeverity = painSeverity
        self.context = context
        self.stepCount = stepCount
        self.standTimeMinutes = standTimeMinutes
    }
}
