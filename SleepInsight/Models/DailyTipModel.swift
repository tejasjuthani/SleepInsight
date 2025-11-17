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
    let category: SleepComponent

    static func generateTip(for component: SleepComponent) -> DailyTip {
        switch component {
        case .duration:
            let durationTips = [
                DailyTip(
                    title: "Extend Your Sleep Window",
                    message: "Try going to bed 30 minutes earlier tonight. Set a bedtime reminder to help you wind down.",
                    category: .duration
                ),
                DailyTip(
                    title: "Prioritize 7-9 Hours",
                    message: "Adults need 7-9 hours of sleep. Calculate your ideal bedtime based on your wake-up time.",
                    category: .duration
                ),
                DailyTip(
                    title: "Weekend Sleep Recovery",
                    message: "Avoid drastically different sleep schedules on weekends. Consistency helps your body rest better.",
                    category: .duration
                )
            ]
            return durationTips.randomElement() ?? durationTips[0]

        case .bedtime:
            let bedtimeTips = [
                DailyTip(
                    title: "Stick to a Schedule",
                    message: "Go to bed at the same time every night, even on weekends. Your body thrives on routine.",
                    category: .bedtime
                ),
                DailyTip(
                    title: "Create a Wind-Down Ritual",
                    message: "Start your bedtime routine 1 hour before sleep. Include calming activities like reading or stretching.",
                    category: .bedtime
                ),
                DailyTip(
                    title: "Set Bedtime Alarms",
                    message: "Use your phone's bedtime feature to remind you when to start winding down each evening.",
                    category: .bedtime
                )
            ]
            return bedtimeTips.randomElement() ?? bedtimeTips[0]

        case .interruptions:
            let interruptionTips = [
                DailyTip(
                    title: "Optimize Your Environment",
                    message: "Keep your bedroom cool (65-68°F), dark, and quiet. Consider blackout curtains or a white noise machine.",
                    category: .interruptions
                ),
                DailyTip(
                    title: "Limit Evening Fluids",
                    message: "Reduce water intake 2 hours before bed to minimize nighttime bathroom trips.",
                    category: .interruptions
                ),
                DailyTip(
                    title: "Reduce Screen Time",
                    message: "Avoid screens 1 hour before bed. Blue light disrupts your sleep cycle and can cause awakenings.",
                    category: .interruptions
                ),
                DailyTip(
                    title: "Check Your Mattress",
                    message: "Discomfort can cause you to wake up. Ensure your mattress and pillows provide proper support.",
                    category: .interruptions
                )
            ]
            return interruptionTips.randomElement() ?? interruptionTips[0]
        }
    }
}
