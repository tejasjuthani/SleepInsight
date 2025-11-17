//
//  SleepAnalyzer.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import Foundation
import HealthKit

class SleepAnalyzer {

    func analyzeSleepSamples(_ samples: [HKCategorySample], for date: Date) -> SleepScore {
        // Extract raw metrics from HealthKit samples
        let totalDuration = calculateTotalSleepDuration(samples)
        let bedtime = extractBedtime(samples)
        let interruptionCount = calculateInterruptions(samples)
        let bedtimeConsistency = calculateBedtimeConsistency(samples)

        // Calculate component scores using Apple's methodology
        let durationScore = calculateDurationScore(totalDuration)       // 0–50
        let bedtimeScore = calculateBedtimeScore(bedtimeConsistency)   // 0–30
        let interruptionsScore = calculateInterruptionsScore(interruptionCount) // 0–20

        // APPLE DAILY SCORE — EXACT SAME AS APPLE HEALTH
        let appleDurationScore = durationScore       // already scaled 0–50
        let appleBedtimeScore = bedtimeScore         // already scaled 0–30
        let appleInterruptionsScore = interruptionsScore // already scaled 0–20

        // SLEEPINSIGHT WEIGHTED SCORE
        // Weighted raw score using the 50/30/20 model
        let rawWeightedScore =
            (Double(appleDurationScore) * 0.50) +
            (Double(appleBedtimeScore) * 0.30) +
            (Double(appleInterruptionsScore) * 0.20)

        // Normalize raw weighted score to 0–100 range
        // Max possible raw weighted value = 38.0
        let normalizedScore = Int((rawWeightedScore / 38.0) * 100.0)

        // Final SleepInsight Score (bounded within 0–100)
        let sleepInsightScore = max(0, min(normalizedScore, 100))

        let calendar = Calendar.current
        let bedtimeComponents = calendar.dateComponents([.hour, .minute], from: bedtime)

        return SleepScore(
            appleDurationScore: appleDurationScore,
            appleBedtimeScore: appleBedtimeScore,
            appleInterruptionsScore: appleInterruptionsScore,
            sleepInsightScore: sleepInsightScore,
            date: date,
            totalSleepHours: totalDuration / 3600.0,
            bedtimeHour: bedtimeComponents.hour ?? 0,
            bedtimeMinute: bedtimeComponents.minute ?? 0,
            interruptionCount: interruptionCount
        )
    }

    // MARK: - Sleep Metrics Calculation

    private func calculateTotalSleepDuration(_ samples: [HKCategorySample]) -> TimeInterval {
        let asleepSamples = samples.filter { sample in
            if #available(iOS 16.0, *) {
                return sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                       sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                       sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue ||
                       sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue
            } else {
                return sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue
            }
        }

        return asleepSamples.reduce(0.0) { total, sample in
            total + sample.endDate.timeIntervalSince(sample.startDate)
        }
    }

    private func extractBedtime(_ samples: [HKCategorySample]) -> Date {
        guard let firstSample = samples.min(by: { $0.startDate < $1.startDate }) else {
            return Date()
        }
        return firstSample.startDate
    }

    private func calculateBedtimeConsistency(_ samples: [HKCategorySample]) -> Double {
        guard let firstSample = samples.min(by: { $0.startDate < $1.startDate }) else {
            return 0
        }

        let calendar = Calendar.current
        let bedtimeHour = calendar.component(.hour, from: firstSample.startDate)

        // Ideal bedtime: 21:00-23:00 (9 PM - 11 PM)
        if bedtimeHour >= 21 && bedtimeHour <= 23 {
            return 1.0  // Perfect
        } else if bedtimeHour >= 20 && bedtimeHour < 21 {
            return 0.8  // Very Good
        } else if bedtimeHour == 0 {
            return 0.7  // Good (midnight)
        } else if (bedtimeHour >= 19 && bedtimeHour < 20) || (bedtimeHour >= 1 && bedtimeHour <= 2) {
            return 0.5  // Fair
        } else {
            return 0.3  // Poor
        }
    }

    private func calculateInterruptions(_ samples: [HKCategorySample]) -> Int {
        let sortedSamples = samples.sorted { $0.startDate < $1.startDate }
        var interruptionCount = 0
        var wasAsleep = false

        for sample in sortedSamples {
            let isAsleep: Bool
            if #available(iOS 16.0, *) {
                isAsleep = sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                          sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                          sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue ||
                          sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue
            } else {
                isAsleep = sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue
            }

            if wasAsleep && !isAsleep {
                interruptionCount += 1
            }

            wasAsleep = isAsleep
        }

        return interruptionCount
    }

    // MARK: - Component Scoring

    private func calculateDurationScore(_ duration: TimeInterval) -> Int {
        let hours = duration / 3600.0

        // Optimal: 7-9 hours → 45-50 points
        if hours >= 7.0 && hours <= 9.0 {
            let idealHours: Double = 8.0
            let deviation = abs(hours - idealHours)
            return 50 - Int(deviation * 5.0)  // Small penalty for deviation from 8h
        }
        // Good: 6-7 or 9-10 hours → 30-44 points
        else if (hours >= 6.0 && hours < 7.0) || (hours > 9.0 && hours <= 10.0) {
            if hours < 7.0 {
                return 30 + Int((hours - 6.0) * 14.0)
            } else {
                return 30 + Int((10.0 - hours) * 14.0)
            }
        }
        // Poor: <6 or >10 hours → 0-29 points
        else if hours < 6.0 {
            return Int(hours * 5.0)
        } else {
            return max(0, 25 - Int((hours - 10.0) * 5.0))
        }
    }

    private func calculateBedtimeScore(_ consistency: Double) -> Int {
        return Int(consistency * 30.0)
    }

    private func calculateInterruptionsScore(_ interruptions: Int) -> Int {
        switch interruptions {
        case 0:
            return 20
        case 1:
            return 18
        case 2:
            return 16
        case 3:
            return 14
        case 4:
            return 12
        case 5:
            return 10
        default:
            return max(0, 10 - (interruptions - 5) * 2)
        }
    }
}
