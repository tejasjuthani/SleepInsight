//
//  SleepScoreModel.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import Foundation

struct SleepScore: Identifiable {
    let id = UUID()
    let totalScore: Int
    let durationScore: Int
    let bedtimeScore: Int
    let interruptionsScore: Int
    let date: Date

    var durationExplanation: String {
        if durationScore >= 40 {
            return "Excellent sleep duration - you got the rest you needed."
        } else if durationScore >= 30 {
            return "Good sleep duration, but there's room for improvement."
        } else if durationScore >= 20 {
            return "Below average sleep duration - try to get more hours."
        } else {
            return "Poor sleep duration - prioritize getting more sleep."
        }
    }

    var bedtimeExplanation: String {
        if bedtimeScore >= 24 {
            return "Great bedtime consistency - your body knows when to sleep."
        } else if bedtimeScore >= 18 {
            return "Good bedtime routine, slight variations noticed."
        } else if bedtimeScore >= 12 {
            return "Inconsistent bedtime - try to stick to a schedule."
        } else {
            return "Poor bedtime consistency - establish a regular schedule."
        }
    }

    var interruptionsExplanation: String {
        if interruptionsScore >= 16 {
            return "Minimal sleep interruptions - excellent sleep quality."
        } else if interruptionsScore >= 12 {
            return "Few interruptions - generally good sleep quality."
        } else if interruptionsScore >= 8 {
            return "Some interruptions detected - consider sleep hygiene."
        } else {
            return "Frequent interruptions - optimize your sleep environment."
        }
    }

    var lowestComponent: SleepComponent {
        let components = [
            (SleepComponent.duration, Double(durationScore) / 50.0),
            (SleepComponent.bedtime, Double(bedtimeScore) / 30.0),
            (SleepComponent.interruptions, Double(interruptionsScore) / 20.0)
        ]
        return components.min(by: { $0.1 < $1.1 })?.0 ?? .duration
    }
}

enum SleepComponent {
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
}
