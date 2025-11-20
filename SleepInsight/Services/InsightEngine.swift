//
//  InsightEngine.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import Foundation

// MARK: - Insight Types

enum InsightType {
    case shortDuration
    case longDuration
    case highDisruption
    case excellentContinuity
    case irregularBedtime
    case strongConsistency
    case earlierBedtime
    case laterBedtime
    case betterThanBaseline
    case worseThanBaseline
    case weekdayWeekendShift
    case highRecovery
    case noData
}

// MARK: - Plan Types

enum PlanType {
    case durationFocus
    case continuityFocus
    case consistencyFocus
    case recovery
    case maintenance
}

// MARK: - Individual Insight Item

struct InsightItem: Identifiable {
    let id = UUID()
    let type: InsightType
    let title: String
    let explanation: String
    let tonightPlan: String
    let priority: Int
    let trendNote: String
}

// MARK: - Weekly Baseline

struct WeeklyBaseline {
    let avgDuration: Double
    let medianBedtime: Double
    let avgInterruptions: Double
}

// MARK: - Insight Engine

class InsightEngine {

    // MARK: - Micro-Variation Templates

    private let shortDurationTemplates = [
        "You slept %@, which is below the general wellness range of 7-9 hours. This pattern often aligns with reduced recovery time.",
        "Your sleep duration of %@ falls short of the typical 7-9 hour range. This may align with increased sleep debt or schedule pressures.",
        "You got %@ of sleep, below the wellness guideline of 7-9 hours. This pattern can impact your daytime energy and recovery capacity."
    ]

    private let longDurationTemplates = [
        "You slept %@, which exceeds the typical 7-9 hour range. This pattern can indicate sleep debt recovery or may align with your body's natural sleep need.",
        "Your sleep duration of %@ is above the standard 7-9 hour guideline. This might reflect your individual sleep requirement or a recovery period.",
        "You got %@ of sleep, more than the typical 7-9 hour range. This pattern may signal recovery from accumulated sleep debt."
    ]

    private let highDisruptionTemplates = [
        "You experienced %d %@ during sleep. This pattern often aligns with environmental factors, temperature, or evening routines that affect sleep architecture.",
        "Your sleep showed %d %@, which can relate to room temperature, noise levels, or pre-sleep habits impacting continuity.",
        "You had %d %@ throughout the night. This pattern may align with environmental conditions or lifestyle factors affecting sleep quality."
    ]

    private let excellentContinuityTemplates = [
        "You had only %d %@ during sleep, indicating strong sleep continuity. This pattern supports effective recovery and restorative sleep cycles.",
        "Your sleep showed minimal disruption with just %d %@. This continuity supports deep, restorative sleep phases.",
        "You experienced only %d %@, reflecting excellent sleep quality and uninterrupted rest patterns."
    ]

    private let irregularBedtimeTemplates = [
        "Your bedtime at %@ shows significant variation (approximately %d minutes from your typical schedule). This pattern often aligns with disrupted circadian rhythm patterns.",
        "You went to bed at %@, differing by about %d minutes from your usual routine. This inconsistency can affect your body's internal clock alignment.",
        "Your bedtime of %@ varies by roughly %d minutes from your baseline. This pattern may relate to schedule irregularities or shifting routines."
    ]

    private let strongConsistencyTemplates = [
        "Your bedtime at %@ closely aligns with your typical schedule. This consistency supports healthy circadian rhythm alignment and sleep quality.",
        "You maintained a consistent bedtime of %@, matching your regular pattern. This stability promotes optimal sleep-wake cycle regulation.",
        "Your bedtime at %@ shows strong consistency with your routine. This predictability supports your body's natural sleep timing."
    ]

    // MARK: - Multi-Insight Generation

    func generateMultipleInsights(from score: SleepScore, weeklyHistory: [SleepScore]) -> [InsightItem] {
        let baseline = calculateWeeklyBaseline(weeklyHistory)
        let patterns = detectAllPatterns(score: score, weeklyHistory: weeklyHistory, baseline: baseline)

        if patterns.isEmpty {
            return [InsightItem(type: .noData, title: "Not Enough Data", explanation: "We don't have sufficient sleep data for this date to generate insights.", tonightPlan: "Wear your Apple Watch to bed to track tonight's sleep patterns.", priority: 1, trendNote: "")]
        }

        let topPatterns = patterns.sorted { $0.strength > $1.strength }.prefix(3)
        var insights: [InsightItem] = []

        for (index, pattern) in topPatterns.enumerated() {
            let insight = generateInsightForPattern(pattern.type, score: score, baseline: baseline, weeklyHistory: weeklyHistory, priority: index + 1)
            insights.append(insight)
        }

        return insights
    }

    // MARK: - Pattern Detection

    private struct PatternMatch {
        let type: InsightType
        let strength: Double
    }

    private func detectAllPatterns(score: SleepScore, weeklyHistory: [SleepScore], baseline: WeeklyBaseline) -> [PatternMatch] {
        var patterns: [PatternMatch] = []
        let duration = score.totalSleepHours
        let interruptions = score.interruptionCount
        let bedtimeHour = Double(score.bedtimeHour) + Double(score.bedtimeMinute) / 60.0

        // 1. Short Sleep Duration (< 5.5h)
        if duration < 5.5 {
            let severity = (5.5 - duration) * 15
            patterns.append(PatternMatch(type: .shortDuration, strength: min(90, 60 + severity)))
        }

        // 2. Long Sleep Duration (> 9h)
        if duration > 9.0 {
            let severity = (duration - 9.0) * 10
            patterns.append(PatternMatch(type: .longDuration, strength: min(85, 50 + severity)))
        }

        // 3. Sleep Continuity Disruption (≥ 7 interruptions)
        if interruptions >= 7 {
            let severity = Double(interruptions - 7) * 5
            patterns.append(PatternMatch(type: .highDisruption, strength: min(95, 70 + severity)))
        }

        // 4. High Sleep Continuity (≤ 2 interruptions)
        if interruptions <= 2 {
            let quality = Double(2 - interruptions) * 15
            patterns.append(PatternMatch(type: .excellentContinuity, strength: min(75, 50 + quality)))
        }

        // 5. Irregular Bedtime (variance > 45 min)
        let bedtimeVariance = calculateBedtimeVariance(bedtimeHour: bedtimeHour, baseline: baseline)
        if bedtimeVariance > 45 {
            let severity = (bedtimeVariance - 45) * 0.5
            patterns.append(PatternMatch(type: .irregularBedtime, strength: min(80, 55 + severity)))
        }

        // 6. Strong Bedtime Consistency (variance ≤ 15 min)
        if bedtimeVariance <= 15 {
            let consistency = (15 - bedtimeVariance) * 2
            patterns.append(PatternMatch(type: .strongConsistency, strength: min(70, 40 + consistency)))
        }

        // 7. Earlier Than Usual (> 40 min earlier)
        let bedtimeShift = calculateBedtimeShift(bedtimeHour: bedtimeHour, baseline: baseline)
        if bedtimeShift > 40 {
            let magnitude = (bedtimeShift - 40) * 0.4
            patterns.append(PatternMatch(type: .earlierBedtime, strength: min(65, 45 + magnitude)))
        }

        // 8. Later Than Usual (> 40 min later)
        if bedtimeShift < -40 {
            let magnitude = (abs(bedtimeShift) - 40) * 0.4
            patterns.append(PatternMatch(type: .laterBedtime, strength: min(75, 50 + magnitude)))
        }

        // 9. Better Than 7-Day Baseline (> avg + 40 min)
        let durationDiff = (duration - baseline.avgDuration) * 60
        if durationDiff > 40 {
            let improvement = (durationDiff - 40) * 0.3
            patterns.append(PatternMatch(type: .betterThanBaseline, strength: min(70, 45 + improvement)))
        }

        // 10. Worse Than 7-Day Baseline (< avg - 40 min)
        if durationDiff < -40 {
            let decline = (abs(durationDiff) - 40) * 0.3
            patterns.append(PatternMatch(type: .worseThanBaseline, strength: min(80, 55 + decline)))
        }

        // 11. Weekday vs Weekend Shift (> 60 min difference)
        if let weekdayWeekendShift = detectWeekdayWeekendShift(weeklyHistory: weeklyHistory, currentScore: score) {
            patterns.append(PatternMatch(type: .weekdayWeekendShift, strength: weekdayWeekendShift))
        }

        // 12. High Recovery Night (≥ 7.5h AND ≤ 3 interruptions)
        if duration >= 7.5 && interruptions <= 3 {
            let quality = (duration - 7.5) * 10 + Double(3 - interruptions) * 5
            patterns.append(PatternMatch(type: .highRecovery, strength: min(85, 60 + quality)))
        }

        return patterns
    }

    private func calculateBedtimeVariance(bedtimeHour: Double, baseline: WeeklyBaseline) -> Double {
        let rawDiff = bedtimeHour - baseline.medianBedtime
        var adjustedDiff = rawDiff
        if rawDiff > 12 {
            adjustedDiff = rawDiff - 24
        } else if rawDiff < -12 {
            adjustedDiff = rawDiff + 24
        }
        return abs(adjustedDiff) * 60
    }

    private func calculateBedtimeShift(bedtimeHour: Double, baseline: WeeklyBaseline) -> Double {
        let rawDiff = baseline.medianBedtime - bedtimeHour
        var adjustedDiff = rawDiff
        if rawDiff > 12 {
            adjustedDiff = rawDiff - 24
        } else if rawDiff < -12 {
            adjustedDiff = rawDiff + 24
        }
        return adjustedDiff * 60
    }

    private func detectWeekdayWeekendShift(weeklyHistory: [SleepScore], currentScore: SleepScore) -> Double? {
        guard weeklyHistory.count >= 5 else { return nil }
        let calendar = Calendar.current
        var weekdayDurations: [Double] = []
        var weekendDurations: [Double] = []

        for score in weeklyHistory {
            let weekday = calendar.component(.weekday, from: score.date)
            if weekday >= 2 && weekday <= 6 {
                weekdayDurations.append(score.totalSleepHours)
            } else if weekday == 1 || weekday == 7 {
                weekendDurations.append(score.totalSleepHours)
            }
        }

        guard !weekdayDurations.isEmpty && !weekendDurations.isEmpty else { return nil }
        let weekdayAvg = weekdayDurations.reduce(0, +) / Double(weekdayDurations.count)
        let weekendAvg = weekendDurations.reduce(0, +) / Double(weekendDurations.count)
        let difference = abs(weekendAvg - weekdayAvg) * 60

        if difference > 60 {
            return min(70, 40 + (difference - 60) * 0.2)
        }
        return nil
    }

    // MARK: - Trend Note Generation

    private func generateTrendNote(type: InsightType, score: SleepScore, weeklyHistory: [SleepScore]) -> String {
        guard weeklyHistory.count >= 2 else {
            return "Trend: Not enough historical data yet."
        }

        let duration = score.totalSleepHours
        let interruptions = score.interruptionCount

        // Count consecutive days with similar pattern
        var consecutiveDays = 1
        if weeklyHistory.count >= 2 {
            let yesterday = weeklyHistory[weeklyHistory.count - 2]
            switch type {
            case .shortDuration:
                if yesterday.totalSleepHours < 5.5 {
                    consecutiveDays += 1
                    if weeklyHistory.count >= 3 && weeklyHistory[weeklyHistory.count - 3].totalSleepHours < 5.5 {
                        consecutiveDays += 1
                    }
                }
            case .highDisruption:
                if yesterday.interruptionCount >= 7 {
                    consecutiveDays += 1
                    if weeklyHistory.count >= 3 && weeklyHistory[weeklyHistory.count - 3].interruptionCount >= 7 {
                        consecutiveDays += 1
                    }
                }
            default:
                break
            }
        }

        // Generate trend based on type
        switch type {
        case .shortDuration:
            if consecutiveDays >= 3 {
                return "Trend: This is the \(consecutiveDays == 3 ? "3rd" : "\(consecutiveDays)th") day with short duration."
            } else if weeklyHistory.count >= 2 {
                let avgLast3 = weeklyHistory.suffix(3).reduce(0.0) { $0 + $1.totalSleepHours } / Double(min(3, weeklyHistory.count))
                if duration < avgLast3 {
                    return "Trend: Duration decreased compared to your recent average."
                } else {
                    return "Trend: Duration stabilized vs. your recent pattern."
                }
            }

        case .longDuration:
            if weeklyHistory.count >= 2 {
                let avgLast3 = weeklyHistory.suffix(3).reduce(0.0) { $0 + $1.totalSleepHours } / Double(min(3, weeklyHistory.count))
                if duration > avgLast3 {
                    return "Trend: Duration increased compared to your recent average."
                } else {
                    return "Trend: Duration consistent with your recent pattern."
                }
            }

        case .highDisruption:
            if consecutiveDays >= 3 {
                return "Trend: This is the \(consecutiveDays == 3 ? "3rd" : "\(consecutiveDays)th") day with high disruption."
            } else if weeklyHistory.count >= 2 {
                let yesterday = weeklyHistory[weeklyHistory.count - 2]
                let diff = interruptions - yesterday.interruptionCount
                if diff > 0 {
                    return "Trend: Interruptions increased compared to yesterday."
                } else if diff < 0 {
                    return "Trend: Interruptions decreased compared to yesterday."
                } else {
                    return "Trend: Interruption count similar to yesterday."
                }
            }

        case .excellentContinuity:
            if weeklyHistory.count >= 2 {
                let yesterday = weeklyHistory[weeklyHistory.count - 2]
                if interruptions <= yesterday.interruptionCount {
                    return "Trend: Sleep continuity improving or stable."
                } else {
                    return "Trend: Sleep quality remains strong overall."
                }
            }

        case .irregularBedtime, .laterBedtime, .earlierBedtime:
            return "Trend: Bedtime pattern shows variation from your baseline."

        case .strongConsistency:
            return "Trend: You're maintaining consistent sleep timing."

        case .betterThanBaseline:
            return "Trend: Duration improved vs. your weekly baseline."

        case .worseThanBaseline:
            return "Trend: Duration below your weekly baseline."

        case .weekdayWeekendShift:
            return "Trend: Sleep patterns differ between weekdays and weekends."

        case .highRecovery:
            return "Trend: Excellent recovery pattern maintained."

        case .noData:
            return ""
        }

        return "Trend: Pattern consistent with recent observations."
    }

    // MARK: - Insight Generation

    private func generateInsightForPattern(_ type: InsightType, score: SleepScore, baseline: WeeklyBaseline, weeklyHistory: [SleepScore], priority: Int) -> InsightItem {
        let duration = score.totalSleepHours
        let interruptions = score.interruptionCount
        let bedtime = score.formattedBedtime
        let durationDiff = (duration - baseline.avgDuration) * 60
        let interruptionDiff = interruptions - Int(baseline.avgInterruptions)
        let baselineContext = generateBaselineContext(durationDiff: durationDiff, interruptionDiff: interruptionDiff)
        let plan = priority == 1 ? generatePlan(for: type) : "No additional plan needed for this insight."
        let trendNote = generateTrendNote(type: type, score: score, weeklyHistory: weeklyHistory)

        switch type {
        case .shortDuration:
            let template = shortDurationTemplates.randomElement() ?? shortDurationTemplates[0]
            let explanation = String(format: template, formatHours(duration)) + " \(baselineContext)"
            return InsightItem(type: type, title: "Short Sleep Duration Detected", explanation: explanation, tonightPlan: plan, priority: priority, trendNote: trendNote)

        case .longDuration:
            let template = longDurationTemplates.randomElement() ?? longDurationTemplates[0]
            let explanation = String(format: template, formatHours(duration)) + " \(baselineContext)"
            return InsightItem(type: type, title: "Extended Sleep Duration Noted", explanation: explanation, tonightPlan: plan, priority: priority, trendNote: trendNote)

        case .highDisruption:
            let word = interruptions == 1 ? "interruption" : "interruptions"
            let template = highDisruptionTemplates.randomElement() ?? highDisruptionTemplates[0]
            let explanation = String(format: template, interruptions, word) + " \(baselineContext)"
            return InsightItem(type: type, title: "Sleep Continuity Disrupted", explanation: explanation, tonightPlan: plan, priority: priority, trendNote: trendNote)

        case .excellentContinuity:
            let word = interruptions == 1 ? "interruption" : "interruptions"
            let template = excellentContinuityTemplates.randomElement() ?? excellentContinuityTemplates[0]
            let explanation = String(format: template, interruptions, word) + " \(baselineContext)"
            return InsightItem(type: type, title: "Excellent Sleep Continuity", explanation: explanation, tonightPlan: plan, priority: priority, trendNote: trendNote)

        case .irregularBedtime:
            let bedtimeHour = Double(score.bedtimeHour) + Double(score.bedtimeMinute) / 60.0
            let variance = calculateBedtimeVariance(bedtimeHour: bedtimeHour, baseline: baseline)
            let template = irregularBedtimeTemplates.randomElement() ?? irregularBedtimeTemplates[0]
            let explanation = String(format: template, bedtime, Int(variance)) + " \(baselineContext)"
            return InsightItem(type: type, title: "Bedtime Inconsistency Detected", explanation: explanation, tonightPlan: plan, priority: priority, trendNote: trendNote)

        case .strongConsistency:
            let template = strongConsistencyTemplates.randomElement() ?? strongConsistencyTemplates[0]
            let explanation = String(format: template, bedtime) + " \(baselineContext)"
            return InsightItem(type: type, title: "Strong Bedtime Consistency", explanation: explanation, tonightPlan: plan, priority: priority, trendNote: trendNote)

        case .earlierBedtime:
            let bedtimeHour = Double(score.bedtimeHour) + Double(score.bedtimeMinute) / 60.0
            let shift = calculateBedtimeShift(bedtimeHour: bedtimeHour, baseline: baseline)
            return InsightItem(type: type, title: "Earlier Bedtime Pattern", explanation: "You went to bed approximately \(Int(shift)) minutes earlier than your typical schedule. This shift may align with changes in your daily routine or sleep need. \(baselineContext)", tonightPlan: plan, priority: priority, trendNote: trendNote)

        case .laterBedtime:
            let bedtimeHour = Double(score.bedtimeHour) + Double(score.bedtimeMinute) / 60.0
            let shift = abs(calculateBedtimeShift(bedtimeHour: bedtimeHour, baseline: baseline))
            return InsightItem(type: type, title: "Later Bedtime Pattern", explanation: "You went to bed approximately \(Int(shift)) minutes later than your typical schedule. This pattern often aligns with evening activities or schedule variations. \(baselineContext)", tonightPlan: plan, priority: priority, trendNote: trendNote)

        case .betterThanBaseline:
            return InsightItem(type: type, title: "Above Your Weekly Baseline", explanation: "You slept \(formatHours(duration)), which is above your 7-day average. This pattern indicates positive improvement in sleep duration alignment with wellness ranges. \(baselineContext)", tonightPlan: plan, priority: priority, trendNote: trendNote)

        case .worseThanBaseline:
            return InsightItem(type: type, title: "Below Your Weekly Baseline", explanation: "You slept \(formatHours(duration)), which is below your 7-day average. This pattern may align with schedule changes or sleep opportunity variations. \(baselineContext)", tonightPlan: plan, priority: priority, trendNote: trendNote)

        case .weekdayWeekendShift:
            return InsightItem(type: type, title: "Weekday-Weekend Sleep Pattern", explanation: "Your sleep duration shows notable differences between weekdays and weekends. This pattern often aligns with schedule variations and may indicate weekday sleep opportunity limitations. \(baselineContext)", tonightPlan: plan, priority: priority, trendNote: trendNote)

        case .highRecovery:
            let word = interruptions == 1 ? "interruption" : "interruptions"
            return InsightItem(type: type, title: "High-Quality Recovery Night", explanation: "You slept \(formatHours(duration)) with only \(interruptions) \(word). This combination supports optimal recovery and aligns with general wellness sleep recommendations. \(baselineContext)", tonightPlan: plan, priority: priority, trendNote: trendNote)

        case .noData:
            return InsightItem(type: type, title: "Not Enough Data", explanation: "We don't have sufficient sleep data for this date to generate insights.", tonightPlan: "Wear your Apple Watch to bed to track tonight's sleep patterns.", priority: priority, trendNote: "")
        }
    }

    // MARK: - Plan Generation

    private func generatePlan(for type: InsightType) -> String {
        switch type {
        case .shortDuration, .worseThanBaseline:
            return "Tonight, aim for an earlier bedtime to support adequate sleep duration. Consider reducing evening screen time after 9 PM, avoiding stimulants after 2 PM, and creating a wind-down routine 30 minutes before sleep."

        case .highDisruption:
            return "Tonight, optimize your sleep environment to support continuity. Keep your bedroom cool (65-68°F), minimize noise and light exposure, avoid heavy meals 3 hours before bed, and limit fluid intake after 8 PM."

        case .irregularBedtime, .earlierBedtime, .laterBedtime, .weekdayWeekendShift:
            return "Tonight, return to your regular sleep schedule to support circadian rhythm alignment. Set a consistent bedtime alarm, start your wind-down routine at the same time, and expose yourself to bright light in the morning."

        case .longDuration:
            return "Tonight, prioritize sleep quality over duration. Keep your bedtime consistent, ensure your room is cool and dark, and consider limiting daytime naps to support nighttime sleep efficiency."

        case .excellentContinuity, .strongConsistency, .betterThanBaseline, .highRecovery:
            return "Tonight, maintain your current routine that's supporting good sleep patterns. Keep consistent sleep and wake times, continue your wind-down practices, and avoid late-day stimulants or schedule disruptions."

        case .noData:
            return "Wear your Apple Watch to bed to track tonight's sleep patterns."
        }
    }

    // MARK: - Weekly Baseline Calculation

    private func calculateWeeklyBaseline(_ history: [SleepScore]) -> WeeklyBaseline {
        guard !history.isEmpty else {
            return WeeklyBaseline(avgDuration: 7.5, medianBedtime: 22.5, avgInterruptions: 3.0)
        }

        let avgDuration = history.reduce(0.0) { $0 + $1.totalSleepHours } / Double(history.count)
        let avgInterruptions = Double(history.reduce(0) { $0 + $1.interruptionCount }) / Double(history.count)
        let bedtimeHours = history.map { Double($0.bedtimeHour) + Double($0.bedtimeMinute) / 60.0 }.sorted()
        let medianBedtime: Double

        if bedtimeHours.count % 2 == 0 {
            let mid = bedtimeHours.count / 2
            medianBedtime = (bedtimeHours[mid - 1] + bedtimeHours[mid]) / 2.0
        } else {
            medianBedtime = bedtimeHours[bedtimeHours.count / 2]
        }

        return WeeklyBaseline(avgDuration: avgDuration, medianBedtime: medianBedtime, avgInterruptions: avgInterruptions)
    }

    // MARK: - Baseline Context Generation

    private func generateBaselineContext(durationDiff: Double, interruptionDiff: Int) -> String {
        var parts: [String] = []

        if abs(durationDiff) >= 15 {
            if durationDiff > 0 {
                parts.append("you slept \(Int(abs(durationDiff))) minutes more than your weekly average")
            } else {
                parts.append("you slept \(Int(abs(durationDiff))) minutes less than your weekly average")
            }
        }

        if abs(interruptionDiff) >= 2 {
            if interruptionDiff > 0 {
                parts.append("interruptions were \(abs(interruptionDiff)) higher than your baseline")
            } else {
                parts.append("interruptions were \(abs(interruptionDiff)) lower than your baseline")
            }
        }

        if parts.isEmpty {
            return "This aligns closely with your 7-day baseline patterns."
        } else {
            return "Compared to your 7-day baseline: " + parts.joined(separator: ", ") + "."
        }
    }

    // MARK: - Original Insights (Preserved for Component Breakdown)

    func generateInsights(from sleepScore: SleepScore) -> SleepInsights {
        var helpedFactors: [InsightFactor] = []
        var hurtFactors: [InsightFactor] = []

        analyzeDuration(score: sleepScore.appleDurationScore, percentage: sleepScore.durationPercentage, totalHours: sleepScore.totalSleepHours, helped: &helpedFactors, hurt: &hurtFactors)
        analyzeBedtime(score: sleepScore.appleBedtimeScore, percentage: sleepScore.bedtimePercentage, bedtime: sleepScore.formattedBedtime, hour: sleepScore.bedtimeHour, helped: &helpedFactors, hurt: &hurtFactors)
        analyzeInterruptions(score: sleepScore.appleInterruptionsScore, percentage: sleepScore.interruptionsPercentage, count: sleepScore.interruptionCount, helped: &helpedFactors, hurt: &hurtFactors)

        let difference = sleepScore.sleepInsightScore - sleepScore.appleTotalScore
        return SleepInsights(helpedFactors: helpedFactors, hurtFactors: hurtFactors, scoreDifference: difference)
    }

    private func analyzeDuration(score: Int, percentage: Double, totalHours: Double, helped: inout [InsightFactor], hurt: inout [InsightFactor]) {
        if percentage >= 0.9 {
            helped.append(InsightFactor(title: "Excellent Sleep Duration", description: "You slept for \(formatHours(totalHours)), which is in the optimal 7-9 hour range.", component: .duration, impact: .high))
        } else if percentage >= 0.7 {
            helped.append(InsightFactor(title: "Good Sleep Duration", description: "You got \(formatHours(totalHours)) of sleep, which is decent but could be improved.", component: .duration, impact: .medium))
        } else if percentage < 0.5 {
            hurt.append(InsightFactor(title: "Insufficient Sleep Duration", description: "You only slept \(formatHours(totalHours)). You lost \(50 - score) points due to short sleep duration.", component: .duration, impact: percentage < 0.3 ? .high : .medium))
        }
    }

    private func analyzeBedtime(score: Int, percentage: Double, bedtime: String, hour: Int, helped: inout [InsightFactor], hurt: inout [InsightFactor]) {
        if percentage >= 0.8 {
            helped.append(InsightFactor(title: "Consistent Bedtime", description: "You went to bed at \(bedtime), which is within the ideal window (9-11 PM).", component: .bedtime, impact: .high))
        } else if percentage < 0.5 {
            let explanation: String
            if hour >= 0 && hour < 6 {
                explanation = "You went to bed at \(bedtime), which is very late. You lost \(30 - score) points due to irregular bedtime."
            } else if hour >= 6 && hour < 20 {
                explanation = "You went to bed at \(bedtime), which is unusually early. This affected your consistency score by \(30 - score) points."
            } else {
                explanation = "Your bedtime of \(bedtime) is outside the optimal window. You lost \(30 - score) points."
            }
            hurt.append(InsightFactor(title: "Irregular Bedtime", description: explanation, component: .bedtime, impact: percentage < 0.3 ? .high : .medium))
        }
    }

    private func analyzeInterruptions(score: Int, percentage: Double, count: Int, helped: inout [InsightFactor], hurt: inout [InsightFactor]) {
        if percentage >= 0.9 {
            helped.append(InsightFactor(title: "Minimal Sleep Interruptions", description: count <= 1 ? "You had excellent sleep continuity with minimal waking." : "Very few interruptions detected — great sleep quality.", component: .interruptions, impact: .high))
        } else if percentage >= 0.7 {
            helped.append(InsightFactor(title: "Good Sleep Continuity", description: "You had \(count) interruption\(count == 1 ? "" : "s"), which is manageable.", component: .interruptions, impact: .medium))
        } else if percentage < 0.6 {
            hurt.append(InsightFactor(title: "Frequent Sleep Interruptions", description: "You woke up \(count) times during the night. This cost you \(20 - score) points and reduced sleep quality.", component: .interruptions, impact: percentage < 0.4 ? .high : .medium))
        }
    }

    private func formatHours(_ hours: Double) -> String {
        let h = Int(hours)
        let m = Int((hours - Double(h)) * 60)
        return "\(h)h \(m)m"
    }
}
