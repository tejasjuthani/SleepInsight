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
        VStack(spacing: 16) {
            ForEach(insights) { insight in
                VStack(alignment: .leading, spacing: 12) {
                    // Title
                    Text(insight.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    // Explanation
                    Text(insight.explanation)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)

                    // Tonight's Plan
                    if insight.priority == 1 {
                        Divider()
                            .background(Color.white.opacity(0.2))

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "moon.stars.fill")
                                    .foregroundColor(.blue.opacity(0.8))
                                Text("TONIGHT'S PLAN")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                                    .fontWeight(.semibold)
                            }

                            Text(insight.tonightPlan)
                                .font(.body)
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
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.5))
                                    .fontWeight(.semibold)
                            }

                            Text("CDC, WHO, NIH")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    } else {
                        Text("No additional plan needed for this insight.")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.7))
                            .italic()
                    }

                    // Trend Note
                    if !insight.trendNote.isEmpty {
                        Text(insight.trendNote)
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(insight.priority == 1 ? 0.12 : 0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(insight.priority == 1 ? 0.3 : 0.15), lineWidth: insight.priority == 1 ? 1.5 : 1)
                )
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
