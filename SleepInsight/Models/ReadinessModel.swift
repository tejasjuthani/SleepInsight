//
//  ReadinessModel.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import Foundation

struct ReadinessScore: Identifiable {
    let id = UUID()
    let score: Int // 1-10
    let date: Date

    var emoji: String {
        switch score {
        case 9...10: return "🚀"
        case 7...8: return "💪"
        case 5...6: return "😊"
        case 3...4: return "😐"
        default: return "😴"
        }
    }

    var description: String {
        switch score {
        case 9...10:
            return "You're at peak performance today! Take on your biggest challenges."
        case 7...8:
            return "You're ready for a productive day. Your energy levels are solid."
        case 5...6:
            return "You're moderately ready. Pace yourself and prioritize important tasks."
        case 3...4:
            return "Your energy is low. Consider light activities and early rest tonight."
        default:
            return "You need recovery. Take it easy today and prioritize sleep tonight."
        }
    }

    var category: String {
        switch score {
        case 9...10: return "Peak Performance"
        case 7...8: return "High Readiness"
        case 5...6: return "Moderate Readiness"
        case 3...4: return "Low Energy"
        default: return "Recovery Needed"
        }
    }

    static func calculate(from sleepScore: Int) -> Int {
        let readiness = Int(round(Double(sleepScore) / 10.0))
        return max(1, min(10, readiness)) // Clamp between 1-10
    }
}
