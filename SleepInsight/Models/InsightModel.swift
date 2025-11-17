//
//  InsightModel.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import Foundation

struct SleepInsights: Identifiable {
    let id = UUID()
    let helpedFactors: [InsightFactor]
    let hurtFactors: [InsightFactor]
    let scoreDifference: Int  // Difference between Apple and Adjusted scores

    var hasPositiveFactors: Bool {
        !helpedFactors.isEmpty
    }

    var hasNegativeFactors: Bool {
        !hurtFactors.isEmpty
    }

    var adjustmentExplanation: String {
        if scoreDifference > 0 {
            return "SleepInsight weighted your sleep quality \(scoreDifference) points higher based on consistency patterns."
        } else if scoreDifference < 0 {
            return "SleepInsight adjusted your score \(abs(scoreDifference)) points lower to account for sleep timing irregularities."
        } else {
            return "Both scores align — your sleep quality and timing were balanced."
        }
    }
}

struct InsightFactor: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let component: SleepComponent
    let impact: ImpactLevel

    enum ImpactLevel {
        case high
        case medium
        case low

        var displayText: String {
            switch self {
            case .high: return "Major factor"
            case .medium: return "Moderate factor"
            case .low: return "Minor factor"
            }
        }

        var color: String {
            switch self {
            case .high: return "red"
            case .medium: return "orange"
            case .low: return "yellow"
            }
        }
    }
}
