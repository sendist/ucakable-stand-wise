//
//  HealthManager.swift
//  StandWise
//
//  Created by Sendi Setiawan on 20/05/26.
//

import Foundation
import HealthKit
import Observation
@MainActor
@Observable
final class HealthManager {
    var todaySteps: Int = 0
    var todayStandingMinutes: Int = 0
    var todaySleepMinutes: Int = 0
    var isLoading = false
    var errorMessage: String?

    private let healthStore = HKHealthStore()

    func requestAuthorizationAndFetchSteps() async {
        await requestAuthorizationAndFetchTodayMetrics()
    }

    func refreshTodaySteps() async {
        await refreshTodayMetrics()
    }

    func requestAuthorizationAndFetchTodayMetrics() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "Health data is not available on this device."
            return
        }

        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            errorMessage = "Step count is not available."
            return
        }

        guard let standTimeType = HKQuantityType.quantityType(forIdentifier: .appleStandTime) else {
            errorMessage = "Standing time is not available."
            return
        }

        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            errorMessage = "Sleep analysis is not available."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await requestAuthorization(reading: [stepType, standTimeType, sleepType])
            todaySteps = try await fetchTodaySteps(for: stepType)
            todayStandingMinutes = try await fetchTodayStandingMinutes(for: standTimeType)
            todaySleepMinutes = try await fetchTodaySleepMinutes(for: sleepType)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refreshTodayMetrics() async {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            errorMessage = "Step count is not available."
            return
        }

        guard let standTimeType = HKQuantityType.quantityType(forIdentifier: .appleStandTime) else {
            errorMessage = "Standing time is not available."
            return
        }

        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            errorMessage = "Sleep analysis is not available."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            todaySteps = try await fetchTodaySteps(for: stepType)
            todayStandingMinutes = try await fetchTodayStandingMinutes(for: standTimeType)
            todaySleepMinutes = try await fetchTodaySleepMinutes(for: sleepType)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func requestAuthorization(reading types: Set<HKObjectType>) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.requestAuthorization(toShare: [], read: types) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: HealthManagerError.authorizationDenied)
                }
            }
        }
    }

    private func fetchTodaySteps(for stepType: HKQuantityType) async throws -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                continuation.resume(returning: Int(steps))
            }

            healthStore.execute(query)
        }
    }

    private func fetchTodayStandingMinutes(for standTimeType: HKQuantityType) async throws -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: standTimeType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let standingMinutes = samples?.sumQuantity()?.doubleValue(for: .minute()) ?? 0
                continuation.resume(returning: Int(standingMinutes.rounded()))
            }

            healthStore.execute(query)
        }
    }

    private func fetchTodaySleepMinutes(for sleepType: HKCategoryType) async throws -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let now = Date()
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictEndDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let sleepMinutes = samples?
                    .compactMap { $0 as? HKCategorySample }
                    .filter { sample in
                        guard let value = HKCategoryValueSleepAnalysis(rawValue: sample.value) else {
                            return false
                        }

                        return HKCategoryValueSleepAnalysis.allAsleepValues.contains(value)
                    }
                    .reduce(0.0) { total, sample in
                        let startDate = max(sample.startDate, startOfDay)
                        let endDate = min(sample.endDate, now)
                        return total + max(0, endDate.timeIntervalSince(startDate) / 60)
                    } ?? 0

                continuation.resume(returning: Int(sleepMinutes.rounded()))
            }

            healthStore.execute(query)
        }
    }
}

enum HealthManagerError: LocalizedError {
    case authorizationDenied

    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            "Health permission was not granted."
        }
    }
}
