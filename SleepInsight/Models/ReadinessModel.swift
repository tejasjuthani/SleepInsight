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
            return "Peak performance day — great for hard workouts and challenging tasks."
        case 7...8:
            return "High readiness — your energy levels are solid for a productive day."
        case 5...6:
            return "Moderate readiness — pace yourself and prioritize important tasks."
        case 3...4:
            return "Low energy — consider light activities and prioritize rest tonight."
        default:
            return "Recovery needed — take it easy today and focus on sleep tonight."
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

    var adviceType: String {
        switch score {
        case 9...10: return "Go for it!"
        case 7...8: return "Strong day ahead"
        case 5...6: return "Balanced approach"
        case 3...4: return "Take it easier"
        default: return "Prioritize recovery"
        }
    }

    static func calculate(from sleepScore: Int) -> Int {
        let readiness = Int(round(Double(sleepScore) / 10.0))
        return max(1, min(10, readiness))
    }
}
