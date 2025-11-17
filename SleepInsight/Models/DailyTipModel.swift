//
//  DailyTipModel.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import Foundation

struct DailyTip: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let actionItem: String
    let category: SleepComponent
    let priority: TipPriority

    enum TipPriority {
        case critical
        case high
        case medium

        var displayText: String {
            switch self {
            case .critical: return "🔴 Critical"
            case .high: return "🟠 High Priority"
            case .medium: return "🟡 Medium Priority"
            }
        }
    }
}
