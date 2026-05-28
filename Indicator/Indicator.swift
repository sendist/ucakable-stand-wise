//
//  Indicator.swift
//  Indicator
//
//  Created by Sendi Setiawan on 19/05/26.
//

import WidgetKit
import SwiftUI
import HealthKit

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            metrics: StandWiseWidgetMetrics(
                stepCount: 3_120,
                standingMinutes: 185,
                status: .safe
            ),
            configuration: ConfigurationAppIntent()
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            metrics: context.isPreview ? .preview : await StandWiseWidgetMetricsProvider().todayMetrics(),
            configuration: configuration
        )
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate) ?? currentDate
        let metrics = await StandWiseWidgetMetricsProvider().todayMetrics()
        let entry = SimpleEntry(date: currentDate, metrics: metrics, configuration: configuration)

        return Timeline(entries: [entry], policy: .after(refreshDate))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let metrics: StandWiseWidgetMetrics
    let configuration: ConfigurationAppIntent
}

struct IndicatorEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 4) {
                statusMark

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.metrics.status.title)
                        .font(.default.weight(.heavy))
                        .foregroundStyle(entry.metrics.status.tint)

//                    Text(entry.metrics.status.message)
//                        .font(.caption)
//                        .foregroundStyle(.primary.opacity(0.78))
//                        .lineLimit(2)
//                        .minimumScaleFactor(0.85)
                }
            }

            VStack(alignment: .center, spacing: 12) {
                HStack(spacing: 10) {
                    metricView(
                        icon: "figure.walk",
                        value: entry.metrics.stepCount.formatted(),
                        label: "Steps"
                    )
                    
                    metricView(
                        icon: "figure.stand",
                        value: formattedDuration(minutes: entry.metrics.standingMinutes),
                        label: "Standing"
                    )
                }
            }
            .frame(maxWidth: .infinity)

            Link(destination: StandWiseWidgetDeepLink.painLogURL) {
                Label("Log Pain", systemImage: "plus.circle.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                    .background(entry.metrics.status.tint, in: Capsule())
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) {
            entry.metrics.status.backgroundColor
        }
        .widgetURL(StandWiseWidgetDeepLink.painLogURL)
    }

    private var statusMark: some View {
        ZStack {
            Circle()
                .fill(entry.metrics.status.tint.opacity(0.18))
                .frame(width: 28, height: 28)

            Image(systemName: entry.metrics.status.symbolName)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(entry.metrics.status.tint)
        }
    }

    private func metricView(icon: String, value: String, label: String) -> some View {
        VStack(alignment: .center, spacing: 5) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(entry.metrics.status.tint)

            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

//            Text(label)
//                .font(.caption2.weight(.semibold))
//                .foregroundStyle(.secondary)
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

struct Indicator: Widget {
    let kind: String = "Indicator"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            IndicatorEntryView(entry: entry)
        }
        .configurationDisplayName("StandWise Status")
        .description("Track your foot load, steps, and standing duration.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        ConfigurationAppIntent()
    }

    fileprivate static var starEyes: ConfigurationAppIntent {
        ConfigurationAppIntent()
    }
}

#Preview(as: .systemSmall) {
    Indicator()
} timeline: {
    SimpleEntry(date: .now, metrics: .preview, configuration: .smiley)
    SimpleEntry(
        date: .now,
        metrics: StandWiseWidgetMetrics(stepCount: 3_250, standingMinutes: 315, status: .caution),
        configuration: .smiley
    )
    SimpleEntry(
        date: .now,
        metrics: StandWiseWidgetMetrics(stepCount: 4_250, standingMinutes: 390, status: .warning),
        configuration: .starEyes
    )
}

private enum StandWiseWidgetDeepLink {
    static let painLogURL = URL(string: "standwise://pain-log")!
}

struct StandWiseWidgetMetrics {
    let stepCount: Int
    let standingMinutes: Int
    let status: StandWiseWidgetStatus

    static let preview = StandWiseWidgetMetrics(
        stepCount: 3_120,
        standingMinutes: 185,
        status: .safe
    )
}

enum StandWiseWidgetStatus {
    case safe
    case caution
    case warning

    var title: String {
        switch self {
        case .safe:
            "Safe"
        case .caution:
            "Caution"
        case .warning:
            "Warning"
        }
    }

    var message: String {
        switch self {
        case .safe:
            "Within today's safe range."
        case .caution:
            "Getting close to your limit."
        case .warning:
            "Safe limit exceeded. Rest soon."
        }
    }

    var symbolName: String {
        switch self {
        case .safe:
            "checkmark"
        case .caution:
            "exclamationmark"
        case .warning:
            "exclamationmark.triangle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .safe:
            Color(red: 0.05, green: 0.48, blue: 0.22)
        case .caution:
            Color(.systemYellow)
        case .warning:
            Color(.systemRed)
        }
    }

    var backgroundColor: Color {
        switch self {
        case .safe:
            Color(red: 0.05, green: 0.48, blue: 0.22).opacity(0.12)
        case .caution:
            Color(.systemYellow).opacity(0.18)
        case .warning:
            Color(.systemRed).opacity(0.16)
        }
    }
}

private struct StandWiseWidgetMetricsProvider {
    private let healthStore = HKHealthStore()
    private let stepLimit = 4_000
    private let standingLimitMinutes = 8 * 60

    func todayMetrics() async -> StandWiseWidgetMetrics {
        guard HKHealthStore.isHealthDataAvailable(),
              let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let standTimeType = HKQuantityType.quantityType(forIdentifier: .appleStandTime) else {
            return StandWiseWidgetMetrics(stepCount: 0, standingMinutes: 0, status: .safe)
        }

        do {
            let stepCount = try await fetchTodaySteps(for: stepType)
            let standingMinutes = try await fetchTodayStandingMinutes(for: standTimeType)
            let progress = max(
                Double(stepCount) / Double(stepLimit),
                Double(standingMinutes) / Double(standingLimitMinutes)
            )

            return StandWiseWidgetMetrics(
                stepCount: stepCount,
                standingMinutes: standingMinutes,
                status: status(for: progress)
            )
        } catch {
            return StandWiseWidgetMetrics(stepCount: 0, standingMinutes: 0, status: .safe)
        }
    }

    private func status(for progress: Double) -> StandWiseWidgetStatus {
        switch progress {
        case 1.0...:
            .warning
        case 0.7..<1.0:
            .caution
        default:
            .safe
        }
    }

    private func fetchTodaySteps(for stepType: HKQuantityType) async throws -> Int {
        try await fetchTodayQuantity(for: stepType, unit: .count())
    }

    private func fetchTodayStandingMinutes(for standTimeType: HKQuantityType) async throws -> Int {
        try await fetchTodayQuantity(for: standTimeType, unit: .minute())
    }

    private func fetchTodayQuantity(for type: HKQuantityType, unit: HKUnit) async throws -> Int {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let value = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: Int(value.rounded()))
            }

            healthStore.execute(query)
        }
    }
}
