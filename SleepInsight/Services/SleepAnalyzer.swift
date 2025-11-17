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
        // Calculate total sleep duration
        let totalDuration = calculateTotalSleepDuration(samples)

        // Calculate bedtime consistency (using start time)
        let bedtimeConsistency = calculateBedtimeConsistency(samples)

        // Calculate interruptions
        let interruptions = calculateInterruptions(samples)

        // Calculate component scores
        let durationScore = calculateDurationScore(totalDuration)
        let bedtimeScore = calculateBedtimeScore(bedtimeConsistency)
        let interruptionsScore = calculateInterruptionsScore(interruptions)

        let totalScore = durationScore + bedtimeScore + interruptionsScore

        return SleepScore(
            totalScore: totalScore,
            durationScore: durationScore,
            bedtimeScore: bedtimeScore,
            interruptionsScore: interruptionsScore,
            date: date
        )
    }

    private func calculateTotalSleepDuration(_ samples: [HKCategorySample]) -> TimeInterval {
        // Filter for asleep periods only (not awake in bed)
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

        let totalDuration = asleepSamples.reduce(0.0) { total, sample in
            total + sample.endDate.timeIntervalSince(sample.startDate)
        }

        return totalDuration
    }

    private func calculateBedtimeConsistency(_ samples: [HKCategorySample]) -> TimeInterval {
        // For MVP, we'll use a simpler approach
        // In a real implementation, we'd compare against historical bedtimes
        // For now, we'll check if bedtime is within ideal range (9pm - 11pm)

        guard let firstSample = samples.min(by: { $0.startDate < $1.startDate }) else {
            return 0
        }

        let calendar = Calendar.current
        let bedtimeHour = calendar.component(.hour, from: firstSample.startDate)

        // Ideal bedtime is between 21:00 (9pm) and 23:00 (11pm)
        // Return a value between 0 and 1 based on how close to ideal
        if bedtimeHour >= 21 && bedtimeHour <= 23 {
            return 1.0 // Perfect
        } else if bedtimeHour >= 20 && bedtimeHour <= 24 {
            return 0.7 // Good
        } else if (bedtimeHour >= 19 && bedtimeHour <= 20) || bedtimeHour == 0 {
            return 0.5 // Fair
        } else {
            return 0.3 // Poor
        }
    }

    private func calculateInterruptions(_ samples: [HKCategorySample]) -> Int {
        // Count transitions from asleep to awake
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

    // Duration Score: 0-50 points
    // 7-9 hours = 45-50 points
    // 6-7 or 9-10 hours = 35-44 points
    // <6 or >10 hours = 0-34 points
    private func calculateDurationScore(_ duration: TimeInterval) -> Int {
        let hours = duration / 3600.0

        if hours >= 7.0 && hours <= 9.0 {
            return 45 + Int((9.0 - abs(hours - 8.0)) * 2.5) // 45-50
        } else if (hours >= 6.0 && hours < 7.0) || (hours > 9.0 && hours <= 10.0) {
            if hours < 7.0 {
                return 35 + Int((hours - 6.0) * 10.0) // 35-44
            } else {
                return 35 + Int((10.0 - hours) * 10.0) // 35-44
            }
        } else if hours < 6.0 {
            return Int(hours * 5.0) // 0-30
        } else {
            return max(0, 30 - Int((hours - 10.0) * 5.0)) // Decreasing score for oversleep
        }
    }

    // Bedtime Score: 0-30 points
    // Based on consistency value (0-1)
    private func calculateBedtimeScore(_ consistency: TimeInterval) -> Int {
        return Int(consistency * 30.0)
    }

    // Interruptions Score: 0-20 points
    // 0-1 interruptions = 18-20 points
    // 2-3 interruptions = 14-17 points
    // 4-5 interruptions = 10-13 points
    // >5 interruptions = 0-9 points
    private func calculateInterruptionsScore(_ interruptions: Int) -> Int {
        switch interruptions {
        case 0...1:
            return 20 - interruptions
        case 2...3:
            return 17 - (interruptions - 2)
        case 4...5:
            return 13 - (interruptions - 4)
        default:
            return max(0, 9 - (interruptions - 6))
        }
    }
}
