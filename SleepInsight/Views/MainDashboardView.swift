//
//  MainDashboardView.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import SwiftUI

struct MainDashboardView: View {
    let sleepScore: SleepScore

    private let insightEngine = InsightEngine()
    private let tipEngine = TipEngine()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Section
                VStack(spacing: 8) {
                    Text("Yesterday's Sleep")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .textCase(.uppercase)

                    Text(formattedDate)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.top, 8)

                // 1. Yesterday's Sleep Scores (Dual Display)
                SleepScoreView(sleepScore: sleepScore)

                // 2. Component Breakdown already in SleepScoreView

                // 3. What Helped / What Hurt
                InsightBreakdownView(
                    insights: insightEngine.generateInsights(from: sleepScore)
                )

                // 4. Readiness for Today
                ReadinessView(
                    readiness: ReadinessScore(
                        score: ReadinessScore.calculate(from: sleepScore.sleepInsightScore),
                        date: Date()
                    )
                )

                // 5. Daily Action Tip
                DailyTipView(
                    tip: tipEngine.generateDailyTip(from: sleepScore)
                )

                // Bottom spacing
                Spacer(minLength: 40)
            }
            .padding()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.2, green: 0.1, blue: 0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: sleepScore.date)
    }
}

#Preview {
    MainDashboardView(
        sleepScore: SleepScore(
            appleDurationScore: 48,
            appleBedtimeScore: 22,
            appleInterruptionsScore: 14,
            appleTotalScore: 84,
            sleepInsightScore: 78,
            date: Date().addingTimeInterval(-86400),
            totalSleepHours: 8.25,
            bedtimeHour: 22,
            bedtimeMinute: 30,
            interruptionCount: 3
        )
    )
}
