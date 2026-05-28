//
//  AppIntent.swift
//  Indicator
//
//  Created by Sendi Setiawan on 19/05/26.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "StandWise Status" }
    static var description: IntentDescription { "Shows your foot load status and daily activity metrics." }
}
