//
//  SleepAnalyzer.swift
//  SleepInsight
//
//  Created by TJ Technologies
//
//  Analyzes HealthKit sleep data following Apple's official documentation

import Foundation
import HealthKit

class SleepAnalyzer {

    /// Analyze sleep samples from HealthKit and compute Apple-aligned scores
    /// - Parameters:
    ///   - samples: HKCategorySample array from HKCategoryType(.sleepAnalysis)
    ///   - date: The date for this sleep session
    ///   - baselineBedtimes: Array of bedtimes from previous 7 days for consistency scoring
    /// - Returns: Computed SleepScore with all metrics
    func analyzeSleepSamples(
        _ samples: [HKCategorySample],
        for date: Date,
        baselineBedtimes: [Date]
    ) -> SleepScore {

        // Sort samples by start date (Apple may return unsorted)
        let sortedSamples = samples.sorted { $0.startDate < $1.startDate }

        // Extract sleep metrics from HealthKit data
        let totalSleepDuration = calculateTotalSleepDuration(sortedSamples)
        let bedtime = extractBedtime(sortedSamples)
        let interruptions = countSleepInterruptions(sortedSamples)

        // Calculate component scores (Apple-aligned)
        let durationScore = calculateDurationScore(totalSleepDuration)
        let bedtimeScore = calculateBedtimeConsistencyScore(bedtime, baseline: baselineBedtimes)
        let interruptionsScore = calculateInterruptionsScore(interruptions)

        // Calculate weighted final score
        let weightedSum = (Double(durationScore) * 0.5) +
                         (Double(bedtimeScore) * 0.3) +
                         (Double(interruptionsScore) * 0.2)

        // Normalize to 0-100 scale
        let maxPossible = (50.0 * 0.5) + (30.0 * 0.3) + (20.0 * 0.2)
        let normalizedScore = Int((weightedSum / maxPossible) * 100.0)
        let sleepInsightScore = max(0, min(normalizedScore, 100))

        // Extract bedtime hour and minute
        let calendar = Calendar.current
        let bedtimeComponents = calendar.dateComponents([.hour, .minute], from: bedtime)

        return SleepScore(
            appleDurationScore: durationScore,
            appleBedtimeScore: bedtimeScore,
            appleInterruptionsScore: interruptionsScore,
            sleepInsightScore: sleepInsightScore,
            date: date,
            totalSleepHours: totalSleepDuration / 3600.0,
            bedtimeHour: bedtimeComponents.hour ?? 0,
            bedtimeMinute: bedtimeComponents.minute ?? 0,
            interruptionCount: interruptions
        )
    }

    // MARK: - Sleep Metrics Extraction (Following Apple HealthKit Documentation)

    /// Calculate total sleep duration from asleep stages only
    /// Uses: asleepCore, asleepDeep, asleepREM, asleepUnspecified
    /// Per Apple docs: These represent actual sleep time
    private func calculateTotalSleepDuration(_ samples: [HKCategorySample]) -> TimeInterval {
        let asleepSamples = samples.filter { isAsleepStage($0) }

        return asleepSamples.reduce(0.0) { total, sample in
            total + sample.endDate.timeIntervalSince(sample.startDate)
        }
    }

    /// Extract bedtime using first non-awake sleep stage
    /// Per Apple docs: Bedtime is when sleep actually begins, not when user went to bed
    private func extractBedtime(_ samples: [HKCategorySample]) -> Date {
        // Find first asleep stage (not inBed, not awake)
        for sample in samples {
            if isAsleepStage(sample) {
                return sample.startDate
            }
        }

        // Fallback: use first sample if no asleep stage found
        return samples.first?.startDate ?? Date()
    }

    /// Count sleep interruptions as state transitions from asleep → awake
    /// Per Apple docs: Track when user transitions from sleeping to awake state
    private func countSleepInterruptions(_ samples: [HKCategorySample]) -> Int {
        var interruptionCount = 0
        var previousWasAsleep = false

        for sample in samples {
            let currentIsAsleep = isAsleepStage(sample)
            let currentIsAwake = (sample.value == HKCategoryValueSleepAnalysis.awake.rawValue)

            // Count transition: asleep → awake
            if previousWasAsleep && currentIsAwake {
                interruptionCount += 1
            }

            // Update state for next iteration
            previousWasAsleep = currentIsAsleep
        }

        return interruptionCount
    }

    /// Check if sample represents an asleep stage
    /// Returns true for: asleepCore, asleepDeep, asleepREM, asleepUnspecified
    private func isAsleepStage(_ sample: HKCategorySample) -> Bool {
        if #available(iOS 16.0, *) {
            return sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                   sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                   sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue ||
                   sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue
        } else {
            // iOS 15 and below: use generic asleep value
            return sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue
        }
    }

    // MARK: - Score Calculations (Apple-Aligned)

    /// Duration Score: 0-50 points
    /// Based on total sleep duration compared to optimal range
    /// - 7-9 hours: 45-50 points (optimal)
    /// - 6-7 or 9-10 hours: 30-44 points (good)
    /// - <6 or >10 hours: 0-29 points (poor)
    private func calculateDurationScore(_ duration: TimeInterval) -> Int {
        let hours = duration / 3600.0

        if hours >= 7.0 && hours <= 9.0 {
            // Optimal range: 7-9 hours → 45-50 points
            // Peak at 8 hours = 50 points
            let deviationFrom8 = abs(hours - 8.0)
            let score = 50 - Int(deviationFrom8 * 5.0)
            return max(45, min(50, score))
        } else if hours >= 6.0 && hours < 7.0 {
            // Good range: 6-7 hours → 30-44 points
            let progress = hours - 6.0
            return 30 + Int(progress * 14.0)
        } else if hours > 9.0 && hours <= 10.0 {
            // Good range: 9-10 hours → 30-44 points
            let progress = 10.0 - hours
            return 30 + Int(progress * 14.0)
        } else if hours < 6.0 {
            // Poor range: <6 hours → 0-29 points
            return Int(hours * 5.0)
        } else {
            // Poor range: >10 hours → 0-29 points
            let excess = hours - 10.0
            return max(0, 25 - Int(excess * 5.0))
        }
    }

    /// Interruptions Score: 0-20 points
    /// Based on number of wake interruptions during sleep
    /// Formula: 0→20, 1→18, 2→16, 3→14, 4→12, 5→10, >5→10-2*(count-5)
    private func calculateInterruptionsScore(_ count: Int) -> Int {
        switch count {
        case 0: return 20
        case 1: return 18
        case 2: return 16
        case 3: return 14
        case 4: return 12
        case 5: return 10
        default: return max(0, 10 - ((count - 5) * 2))
        }
    }

    /// Bedtime Consistency Score: 0-30 points
    /// Based on 7-day rolling median bedtime comparison
    /// - ≤30 min difference: 30 points
    /// - 31-60 min: 25 points
    /// - 61-120 min: 20 points
    /// - >120 min: 10 points
    private func calculateBedtimeConsistencyScore(_ bedtime: Date, baseline: [Date]) -> Int {
        // If no baseline data, give full points
        guard baseline.count >= 1 else { return 30 }

        let calendar = Calendar.current

        // Calculate median bedtime from baseline (in minutes from midnight)
        let baselineMinutes = baseline.map { date -> Int in
            let components = calendar.dateComponents([.hour, .minute], from: date)
            return (components.hour ?? 0) * 60 + (components.minute ?? 0)
        }.sorted()

        // Calculate median
        let medianMinutes: Int
        if baselineMinutes.count % 2 == 0 {
            let mid = baselineMinutes.count / 2
            medianMinutes = (baselineMinutes[mid - 1] + baselineMinutes[mid]) / 2
        } else {
            medianMinutes = baselineMinutes[baselineMinutes.count / 2]
        }

        // Calculate current bedtime in minutes from midnight
        let bedtimeComponents = calendar.dateComponents([.hour, .minute], from: bedtime)
        let currentMinutes = (bedtimeComponents.hour ?? 0) * 60 + (bedtimeComponents.minute ?? 0)

        // Calculate absolute difference in minutes
        let difference = abs(currentMinutes - medianMinutes)

        // Score based on difference thresholds
        if difference <= 30 {
            return 30
        } else if difference <= 60 {
            return 25
        } else if difference <= 120 {
            return 20
        } else {
            return 10
        }
    }
}
