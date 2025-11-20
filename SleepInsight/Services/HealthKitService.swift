//
//  HealthKitService.swift
//  SleepInsight
//
//  Created by TJ Technologies
//
//  HealthKit service following Apple's official documentation
//  Reference: https://developer.apple.com/documentation/healthkit

import Foundation
import HealthKit

@MainActor
class HealthKitService: ObservableObject {
    private let healthStore = HKHealthStore()

    @Published var isAuthorized = false
    @Published var sleepScore: SleepScore?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var dailyInsightItems: [InsightItem] = []
    @Published var weeklyHistory: [SleepScore] = []

    init() {
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    /// Check if HealthKit is available and authorized for sleep data
    func checkAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "HealthKit is not available on this device"
            return
        }

        let sleepType = HKCategoryType(.sleepAnalysis)
        let authorizationStatus = healthStore.authorizationStatus(for: sleepType)

        isAuthorized = authorizationStatus == .sharingAuthorized
    }

    /// Request authorization to read sleep data from HealthKit
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

    // MARK: - Sleep Data Fetching

    /// Fetch and analyze yesterday's sleep data
    /// Per Apple docs: Sleep sessions use 12:00 p.m. (noon) as day boundary
    /// Fetch sleep score for a specific date
    func fetchSleepScore(for targetDate: Date) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        let calendar = Calendar.current

        // Apple's sleep day boundary: target date at noon → next day at noon
        guard let targetNoon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: targetDate),
              let nextDayNoon = calendar.date(byAdding: .day, value: 1, to: targetNoon) else {
            await MainActor.run {
                errorMessage = "Failed to calculate sleep window"
                isLoading = false
            }
            return
        }

        // Fetch 7 days of historical data for bedtime baseline
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: targetNoon) else {
            await MainActor.run {
                errorMessage = "Failed to calculate baseline window"
                isLoading = false
            }
            return
        }

        // Create predicate for HKSampleQuery
        let predicate = HKQuery.predicateForSamples(
            withStart: sevenDaysAgo,
            end: nextDayNoon,
            options: .strictStartDate
        )

        // Query HKCategoryType.sleepAnalysis
        let sleepType = HKCategoryType(.sleepAnalysis)

        // Create HKSampleQuery with sort descriptors
        let query = HKSampleQuery(
            sampleType: sleepType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
        ) { [weak self] _, samples, error in
            guard let self = self else { return }

            if let error = error {
                Task { @MainActor in
                    self.errorMessage = "Failed to fetch sleep data: \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }

            guard let allSamples = samples as? [HKCategorySample] else {
                Task { @MainActor in
                    self.errorMessage = "Invalid sleep data format"
                    self.isLoading = false
                }
                return
            }

            // Filter samples for target date's sleep session (noon-to-noon)
            let targetSamples = allSamples.filter { sample in
                sample.startDate >= targetNoon && sample.startDate < nextDayNoon
            }

            if targetSamples.isEmpty {
                Task { @MainActor in
                    self.dailyInsightItems = [
                        InsightItem(
                            type: .noData,
                            title: "Not Enough Data",
                            explanation: "We don't have sufficient sleep data for this date to generate insights.",
                            tonightPlan: "Wear your Apple Watch to bed to track tonight's sleep patterns.",
                            priority: 1,
                            trendNote: ""
                        )
                    ]
                    self.sleepScore = nil
                    self.weeklyHistory = []
                    self.isLoading = false
                    self.errorMessage = nil
                }
                return
            }

            // Extract baseline bedtimes from last 7 days
            let baselineBedtimes = self.extractDailyBedtimes(
                from: allSamples,
                startDate: sevenDaysAgo,
                endDate: targetNoon,
                calendar: calendar
            )

            // Analyze sleep data using SleepAnalyzer
            let analyzer = SleepAnalyzer()
            let score = analyzer.analyzeSleepSamples(
                targetSamples,
                for: targetNoon,
                baselineBedtimes: baselineBedtimes
            )

            // Generate weekly sleep scores for history
            let weeklyScores = self.generateWeeklyScores(
                from: allSamples,
                startDate: sevenDaysAgo,
                endDate: targetNoon,
                calendar: calendar
            )

            // Generate daily insights using multi-insight engine
            let insightEngine = InsightEngine()
            let insightItems = insightEngine.generateMultipleInsights(
                from: score,
                weeklyHistory: weeklyScores
            )

            Task { @MainActor in
                self.sleepScore = score
                self.weeklyHistory = weeklyScores
                self.dailyInsightItems = insightItems
                self.isLoading = false
                self.errorMessage = nil
            }
        }

        // Execute query
        healthStore.execute(query)
    }

    func fetchYesterdaySleepScore() async {
        let calendar = Calendar.current

        // Calculate yesterday's date
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) else {
            await MainActor.run {
                errorMessage = "Failed to calculate yesterday's date"
                isLoading = false
            }
            return
        }

        // Use the new fetchSleepScore method
        await fetchSleepScore(for: yesterday)
    }

    // MARK: - Baseline Calculation

    /// Extract daily bedtimes from sleep samples for 7-day baseline
    /// Per Apple docs: Group samples by day using noon-to-noon boundaries
    nonisolated private func extractDailyBedtimes(
        from samples: [HKCategorySample],
        startDate: Date,
        endDate: Date,
        calendar: Calendar
    ) -> [Date] {
        var bedtimesByDay: [Date: Date] = [:]

        for sample in samples {
            // Only consider asleep stages for bedtime calculation
            let isAsleep: Bool
            if #available(iOS 16.0, *) {
                isAsleep = (
                    sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                    sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                    sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue ||
                    sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue
                )
            } else {
                isAsleep = sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue
            }

            // Filter to date range and asleep stages only
            if isAsleep && sample.startDate >= startDate && sample.startDate < endDate {
                // Group by wake-up date (endDate) to match Apple Health display
                let dayKey = calendar.startOfDay(for: sample.endDate)

                // Keep earliest bedtime for each day
                if let existingBedtime = bedtimesByDay[dayKey] {
                    if sample.startDate < existingBedtime {
                        bedtimesByDay[dayKey] = sample.startDate
                    }
                } else {
                    bedtimesByDay[dayKey] = sample.startDate
                }
            }
        }

        return Array(bedtimesByDay.values).sorted()
    }

    /// Generate weekly sleep scores from samples
    /// Groups samples by day and analyzes each day's sleep
    nonisolated private func generateWeeklyScores(
        from samples: [HKCategorySample],
        startDate: Date,
        endDate: Date,
        calendar: Calendar
    ) -> [SleepScore] {
        var scoresByDay: [Date: [HKCategorySample]] = [:]

        // Group samples by day using wake-up date (endDate)
        for sample in samples {
            if sample.startDate >= startDate && sample.startDate < endDate {
                // Use endDate (wake-up time) for day grouping to match Apple Health display
                let day = calendar.startOfDay(for: sample.endDate)

                if scoresByDay[day] == nil {
                    scoresByDay[day] = []
                }
                scoresByDay[day]?.append(sample)
            }
        }

        // Generate scores for each day
        let analyzer = SleepAnalyzer()
        var weeklyScores: [SleepScore] = []

        for (day, daySamples) in scoresByDay.sorted(by: { $0.key < $1.key }) {
            if !daySamples.isEmpty {
                // For weekly history, we don't need baseline (use empty array)
                let score = analyzer.analyzeSleepSamples(daySamples, for: day, baselineBedtimes: [])
                weeklyScores.append(score)
            }
        }

        return weeklyScores
    }
}
