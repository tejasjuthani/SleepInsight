//
//  TipEngine.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import Foundation

class TipEngine {

    func generateDailyTip(from sleepScore: SleepScore) -> DailyTip {
        let lowestComponent = sleepScore.lowestComponent
        let lowestPercentage = getPercentage(for: lowestComponent, from: sleepScore)

        // Determine priority based on severity
        let priority: DailyTip.TipPriority
        if lowestPercentage < 0.4 {
            priority = .critical
        } else if lowestPercentage < 0.7 {
            priority = .high
        } else {
            priority = .medium
        }

        // Generate specific tip based on component
        return generateTip(for: lowestComponent, sleepScore: sleepScore, priority: priority)
    }

    // MARK: - Component-Specific Tips

    private func generateTip(
        for component: SleepComponent,
        sleepScore: SleepScore,
        priority: DailyTip.TipPriority
    ) -> DailyTip {
        switch component {
        case .duration:
            return generateDurationTip(sleepScore: sleepScore, priority: priority)
        case .bedtime:
            return generateBedtimeTip(sleepScore: sleepScore, priority: priority)
        case .interruptions:
            return generateInterruptionsTip(sleepScore: sleepScore, priority: priority)
        }
    }

    private func generateDurationTip(sleepScore: SleepScore, priority: DailyTip.TipPriority) -> DailyTip {
        let targetHours: Double = 7.5
        let currentHours = sleepScore.totalSleepHours
        let difference = targetHours - currentHours

        if difference > 0 {
            let additionalMinutes = Int(difference * 60)
            return DailyTip(
                title: "Extend Your Sleep Window",
                message: "You slept \(sleepScore.formattedSleepDuration) last night, which is below the recommended 7-9 hours.",
                actionItem: "Go to bed \(additionalMinutes) minutes earlier tonight to reach \(Int(targetHours))h 30m.",
                category: .duration,
                priority: priority
            )
        } else {
            return DailyTip(
                title: "Maintain Your Sleep Duration",
                message: "You're getting good sleep duration at \(sleepScore.formattedSleepDuration).",
                actionItem: "Keep your current sleep schedule consistent to maintain this healthy pattern.",
                category: .duration,
                priority: priority
            )
        }
    }

    private func generateBedtimeTip(sleepScore: SleepScore, priority: DailyTip.TipPriority) -> DailyTip {
        let bedtimeHour = sleepScore.bedtimeHour

        if bedtimeHour >= 23 || bedtimeHour < 6 {
            // Too late
            let targetTime = "10:00 PM"
            return DailyTip(
                title: "Stick to a Consistent Bedtime",
                message: "You went to bed at \(sleepScore.formattedBedtime), which is later than optimal.",
                actionItem: "Set a wind-down alarm for 9:30 PM and aim to be in bed by \(targetTime).",
                category: .bedtime,
                priority: priority
            )
        } else if bedtimeHour >= 6 && bedtimeHour < 20 {
            // Too early
            return DailyTip(
                title: "Adjust Your Sleep Schedule",
                message: "Your bedtime of \(sleepScore.formattedBedtime) is unusually early, which may disrupt your rhythm.",
                actionItem: "Gradually shift your bedtime later by 15-30 minutes to align with natural circadian rhythms.",
                category: .bedtime,
                priority: priority
            )
        } else {
            // Good range
            return DailyTip(
                title: "Maintain Bedtime Consistency",
                message: "Your bedtime of \(sleepScore.formattedBedtime) is in a good range.",
                actionItem: "Keep going to bed at the same time each night, even on weekends, to strengthen your sleep routine.",
                category: .bedtime,
                priority: priority
            )
        }
    }

    private func generateInterruptionsTip(sleepScore: SleepScore, priority: DailyTip.TipPriority) -> DailyTip {
        let interruptionCount = sleepScore.interruptionCount

        if interruptionCount <= 1 {
            return DailyTip(
                title: "Excellent Sleep Continuity",
                message: "You had minimal interruptions last night — great sleep quality!",
                actionItem: "Keep your current sleep environment and habits. Whatever you're doing is working.",
                category: .interruptions,
                priority: priority
            )
        } else if interruptionCount <= 3 {
            return DailyTip(
                title: "Reduce Sleep Interruptions",
                message: "You woke up \(interruptionCount) times last night, which affected your sleep quality.",
                actionItem: "Limit fluids 2 hours before bed and reduce screen time 30 minutes before sleep.",
                category: .interruptions,
                priority: priority
            )
        } else {
            return DailyTip(
                title: "Optimize Your Sleep Environment",
                message: "You had \(interruptionCount) interruptions last night, significantly impacting sleep quality.",
                actionItem: "Keep bedroom cool (65-68°F), dark, and quiet. Consider blackout curtains or white noise.",
                category: .interruptions,
                priority: priority
            )
        }
    }

    // MARK: - Helpers

    private func getPercentage(for component: SleepComponent, from sleepScore: SleepScore) -> Double {
        switch component {
        case .duration:
            return sleepScore.durationPercentage
        case .bedtime:
            return sleepScore.bedtimePercentage
        case .interruptions:
            return sleepScore.interruptionsPercentage
        }
    }
}
