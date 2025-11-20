//
//  DailyInsightsView.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import SwiftUI

struct DailyInsightsView: View {
    let insights: [InsightItem]

    var body: some View {
        VStack(spacing: 20) {
            ForEach(insights) { insight in
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    Text(insight.title)
                        .roundedFont(size: 22, weight: .bold)
                        .foregroundColor(.white)

                    // Explanation
                    Text(insight.explanation)
                        .proFont(size: 15, weight: .regular)
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)

                    // Tonight's Plan
                    if insight.priority == 1 {
                        Divider()
                            .background(Color.white.opacity(0.2))

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "moon.stars.fill")
                                    .foregroundColor(Color.purpleAccent.opacity(0.9))
                                Text("TONIGHT'S PLAN")
                                    .roundedFont(size: 12, weight: .semibold)
                                    .foregroundColor(Color.purpleAccent.opacity(0.9))
                            }

                            Text(insight.tonightPlan)
                                .proFont(size: 15, weight: .regular)
                                .foregroundColor(.white.opacity(0.9))
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Divider()
                            .background(Color.white.opacity(0.2))

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .foregroundColor(.white.opacity(0.5))
                                    .font(.caption2)
                                Text("SOURCES")
                                    .roundedFont(size: 11, weight: .semibold)
                                    .foregroundColor(.white.opacity(0.5))
                            }

                            Text("CDC, WHO, NIH")
                                .proFont(size: 11, weight: .regular)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    } else {
                        Text("No additional plan needed for this insight.")
                            .proFont(size: 15, weight: .regular)
                            .foregroundColor(.white.opacity(0.7))
                            .italic()
                    }

                    // Trend Note
                    if !insight.trendNote.isEmpty {
                        Text(insight.trendNote)
                            .proFont(size: 13, weight: .regular)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.top, 4)
                    }
                }
                .padding(20)
                .glassCardStyle(insight.priority == 1 ? .primary : .secondary)
            }
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(gradient: Gradient(colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.2, green: 0.1, blue: 0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

        ScrollView {
            DailyInsightsView(insights: [
                InsightItem(type: .shortDuration, title: "Short Sleep Duration Detected", explanation: "You slept 5h 30m, which is below the general wellness range of 7-9 hours.", tonightPlan: "Tonight, aim for an earlier bedtime.", priority: 1, trendNote: "Trend: This is the 3rd day with short duration."),
                InsightItem(type: .highDisruption, title: "Sleep Continuity Disrupted", explanation: "You experienced 8 interruptions during sleep.", tonightPlan: "No additional plan needed for this insight.", priority: 2, trendNote: "Trend: Interruptions increased compared to yesterday.")
            ])
            .padding()
        }
    }
}
