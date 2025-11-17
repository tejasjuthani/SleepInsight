//
//  HealthKitService.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import Foundation
import HealthKit

@MainActor
class HealthKitService: ObservableObject {
    private let healthStore = HKHealthStore()

    @Published var isAuthorized = false
    @Published var sleepScore: SleepScore?
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        checkAuthorizationStatus()
    }

    func checkAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "HealthKit is not available on this device"
            return
        }

        let sleepType = HKCategoryType(.sleepAnalysis)
        let authorizationStatus = healthStore.authorizationStatus(for: sleepType)

        isAuthorized = authorizationStatus == .sharingAuthorized
    }

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            await MainActor.run {
                errorMessage = "HealthKit is not available on this device"
            }
            return
        }

        let sleepType = HKCategoryType(.sleepAnalysis)
        let typesToRead: Set<HKObjectType> = [sleepType]

        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            await MainActor.run {
                isAuthorized = true
                errorMessage = nil
            }
            await fetchYesterdaySleepScore()
        } catch {
            await MainActor.run {
                errorMessage = "Failed to authorize HealthKit: \(error.localizedDescription)"
                isAuthorized = false
            }
        }
    }

    func fetchYesterdaySleepScore() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        let calendar = Calendar.current
        let now = Date()

        // Get yesterday's date range
        guard let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now)),
              let yesterdayEnd = calendar.date(byAdding: .day, value: 0, to: calendar.startOfDay(for: now)) else {
            await MainActor.run {
                errorMessage = "Failed to calculate yesterday's date"
                isLoading = false
            }
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: yesterdayStart, end: yesterdayEnd, options: .strictStartDate)
        let sleepType = HKCategoryType(.sleepAnalysis)

        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] _, samples, error in
            guard let self = self else { return }

            if let error = error {
                Task { @MainActor in
                    self.errorMessage = "Failed to fetch sleep data: \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }

            guard let sleepSamples = samples as? [HKCategorySample], !sleepSamples.isEmpty else {
                Task { @MainActor in
                    self.errorMessage = "No sleep data found for yesterday. Make sure you wore your Apple Watch to bed."
                    self.isLoading = false
                }
                return
            }

            // Calculate sleep score from samples
            let analyzer = SleepAnalyzer()
            let score = analyzer.analyzeSleepSamples(sleepSamples, for: yesterdayStart)

            Task { @MainActor in
                self.sleepScore = score
                self.isLoading = false
                self.errorMessage = nil
            }
        }

        healthStore.execute(query)
    }
}
