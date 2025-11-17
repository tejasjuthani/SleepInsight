//
//  InsightEngine.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import Foundation

class InsightEngine {

    func generateInsights(from sleepScore: SleepScore) -> SleepInsights {
        var helpedFactors: [InsightFactor] = []
        var hurtFactors: [InsightFactor] = []

        // Analyze Duration
        analyzeDuration(
            score: sleepScore.durationScore,
            percentage: sleepScore.durationPercentage,
            totalHours: sleepScore.totalSleepHours,
            helped: &helpedFactors,
            hurt: &hurtFactors
        )

        // Analyze Bedtime
        analyzeBedtime(
            score: sleepScore.bedtimeScore,
            percentage: sleepScore.bedtimePercentage,
            bedtime: sleepScore.formattedBedtime,
            hour: sleepScore.bedtimeHour,
            helped: &helpedFactors,
            hurt: &hurtFactors
        )

        // Analyze Interruptions
        analyzeInterruptions(
            score: sleepScore.interruptionsScore,
            percentage: sleepScore.interruptionsPercentage,
            count: sleepScore.interruptionCount,
            helped: &helpedFactors,
            hurt: &hurtFactors
        )

        let scoreDifference = sleepScore.sleepInsightScore - sleepScore.appleTotalScore

        return SleepInsights(
            helpedFactors: helpedFactors,
            hurtFactors: hurtFactors,
            scoreDifference: scoreDifference
        )
    }

    // MARK: - Component Analysis

    private func analyzeDuration(
        score: Int,
        percentage: Double,
        totalHours: Double,
        helped: inout [InsightFactor],
        hurt: inout [InsightFactor]
    ) {
        if percentage >= 0.9 {
            // Excellent duration
            helped.append(InsightFactor(
                title: "Excellent Sleep Duration",
                description: "You slept for \(formatHours(totalHours)), which is in the optimal 7-9 hour range.",
                component: .duration,
                impact: .high
            ))
        } else if percentage >= 0.7 {
            // Good duration
            helped.append(InsightFactor(
                title: "Good Sleep Duration",
                description: "You got \(formatHours(totalHours)) of sleep, which is decent but could be improved.",
                component: .duration,
                impact: .medium
            ))
        } else if percentage < 0.5 {
            // Poor duration
            hurt.append(InsightFactor(
                title: "Insufficient Sleep Duration",
                description: "You only slept \(formatHours(totalHours)). You lost \(50 - score) points due to short sleep duration.",
                component: .duration,
                impact: percentage < 0.3 ? .high : .medium
            ))
        }
    }

    private func analyzeBedtime(
        score: Int,
        percentage: Double,
        bedtime: String,
        hour: Int,
        helped: inout [InsightFactor],
        hurt: inout [InsightFactor]
    ) {
        if percentage >= 0.8 {
            // Excellent bedtime
            helped.append(InsightFactor(
                title: "Consistent Bedtime",
                description: "You went to bed at \(bedtime), which is within the ideal window (9-11 PM).",
                component: .bedtime,
                impact: .high
            ))
        } else if percentage < 0.5 {
            // Poor bedtime
            let explanation: String
            if hour >= 0 && hour < 6 {
                explanation = "You went to bed at \(bedtime), which is very late. You lost \(30 - score) points due to irregular bedtime."
            } else if hour >= 6 && hour < 20 {
                explanation = "You went to bed at \(bedtime), which is unusually early. This affected your consistency score by \(30 - score) points."
            } else {
                explanation = "Your bedtime of \(bedtime) is outside the optimal window. You lost \(30 - score) points."
            }

            hurt.append(InsightFactor(
                title: "Irregular Bedtime",
                description: explanation,
                component: .bedtime,
                impact: percentage < 0.3 ? .high : .medium
            ))
        }
    }

    private func analyzeInterruptions(
        score: Int,
        percentage: Double,
        count: Int,
        helped: inout [InsightFactor],
        hurt: inout [InsightFactor]
    ) {
        if percentage >= 0.9 {
            // Excellent - minimal interruptions
            helped.append(InsightFactor(
                title: "Minimal Sleep Interruptions",
                description: count <= 1 ? "You had excellent sleep continuity with minimal waking." : "Very few interruptions detected — great sleep quality.",
                component: .interruptions,
                impact: .high
            ))
        } else if percentage >= 0.7 {
            // Good - few interruptions
            helped.append(InsightFactor(
                title: "Good Sleep Continuity",
                description: "You had \(count) interruption\(count == 1 ? "" : "s"), which is manageable.",
                component: .interruptions,
                impact: .medium
            ))
        } else if percentage < 0.6 {
            // Poor - many interruptions
            hurt.append(InsightFactor(
                title: "Frequent Sleep Interruptions",
                description: "You woke up \(count) times during the night. This cost you \(20 - score) points and reduced sleep quality.",
                component: .interruptions,
                impact: percentage < 0.4 ? .high : .medium
            ))
        }
    }

    // MARK: - Helpers

    private func formatHours(_ hours: Double) -> String {
        let h = Int(hours)
        let m = Int((hours - Double(h)) * 60)
        return "\(h)h \(m)m"
    }
}
