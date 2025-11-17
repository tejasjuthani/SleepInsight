//
//  SleepScoreModel.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import Foundation

struct SleepScore: Identifiable {
    let id = UUID()

    // Apple Health Score Components (calculated using Apple's methodology)
    // Note: HealthKit does not expose Apple's actual sleep score via API
    // These are calculated to match Apple's algorithm as closely as possible
    let appleDurationScore: Int         // Apple's duration score (0-50)
    let appleBedtimeScore: Int          // Apple's bedtime consistency score (0-30)
    let appleInterruptionsScore: Int    // Apple's interruptions score (0-20)
    let appleTotalScore: Int            // Apple-style total (sum of above, 0-100)

    // SleepInsight Weighted Score (our custom algorithm)
    let sleepInsightScore: Int          // Weighted score (0-100)

    let date: Date

    // Raw sleep metrics
    let totalSleepHours: Double
    let bedtimeHour: Int
    let bedtimeMinute: Int
    let interruptionCount: Int

    var lowestComponent: SleepComponent {
        let components = [
            (SleepComponent.duration, Double(appleDurationScore) / 50.0),
            (SleepComponent.bedtime, Double(appleBedtimeScore) / 30.0),
            (SleepComponent.interruptions, Double(appleInterruptionsScore) / 20.0)
        ]
        return components.min(by: { $0.1 < $1.1 })?.0 ?? .duration
    }

    var highestComponent: SleepComponent {
        let components = [
            (SleepComponent.duration, Double(appleDurationScore) / 50.0),
            (SleepComponent.bedtime, Double(appleBedtimeScore) / 30.0),
            (SleepComponent.interruptions, Double(appleInterruptionsScore) / 20.0)
        ]
        return components.max(by: { $0.1 < $1.1 })?.0 ?? .duration
    }

    var durationPercentage: Double {
        Double(appleDurationScore) / 50.0
    }

    var bedtimePercentage: Double {
        Double(appleBedtimeScore) / 30.0
    }

    var interruptionsPercentage: Double {
        Double(appleInterruptionsScore) / 20.0
    }

    var formattedBedtime: String {
        let period = bedtimeHour < 12 ? "AM" : "PM"
        let displayHour = bedtimeHour == 0 ? 12 : (bedtimeHour > 12 ? bedtimeHour - 12 : bedtimeHour)
        return String(format: "%d:%02d %@", displayHour, bedtimeMinute, period)
    }

    var formattedSleepDuration: String {
        let hours = Int(totalSleepHours)
        let minutes = Int((totalSleepHours - Double(hours)) * 60)
        return "\(hours)h \(minutes)m"
    }
}

enum SleepComponent: CaseIterable {
    case duration
    case bedtime
    case interruptions

    var displayName: String {
        switch self {
        case .duration: return "Duration"
        case .bedtime: return "Bedtime Consistency"
        case .interruptions: return "Sleep Interruptions"
        }
    }

    var icon: String {
        switch self {
        case .duration: return "clock.fill"
        case .bedtime: return "moon.stars.fill"
        case .interruptions: return "bed.double.fill"
        }
    }

    var maxScore: Int {
        switch self {
        case .duration: return 50
        case .bedtime: return 30
        case .interruptions: return 20
        }
    }
}
