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
    var isLoading = false
    var errorMessage: String?

    private let healthStore = HKHealthStore()

    func requestAuthorizationAndFetchSteps() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "Health data is not available on this device."
            return
        }

        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            errorMessage = "Step count is not available."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await requestAuthorization(reading: [stepType])
            todaySteps = try await fetchTodaySteps(for: stepType)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refreshTodaySteps() async {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            errorMessage = "Step count is not available."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            todaySteps = try await fetchTodaySteps(for: stepType)
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

