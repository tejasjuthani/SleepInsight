//
//  SleepScoreView.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import SwiftUI

struct SleepScoreView: View {
    let sleepScore: SleepScore

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Main Score Display
            VStack(spacing: 8) {
                Text("Sleep Score")
                    .font(.headline)
                    .foregroundColor(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(sleepScore.totalScore)")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(scoreColor(for: sleepScore.totalScore))

                    Text("/100")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)

            Divider()

            // Component Breakdown
            VStack(alignment: .leading, spacing: 16) {
                Text("Breakdown")
                    .font(.headline)
                    .padding(.bottom, 4)

                ComponentRow(
                    title: "Duration",
                    score: sleepScore.durationScore,
                    maxScore: 50,
                    explanation: sleepScore.durationExplanation,
                    isLowest: sleepScore.lowestComponent == .duration
                )

                ComponentRow(
                    title: "Bedtime Consistency",
                    score: sleepScore.bedtimeScore,
                    maxScore: 30,
                    explanation: sleepScore.bedtimeExplanation,
                    isLowest: sleepScore.lowestComponent == .bedtime
                )

                ComponentRow(
                    title: "Interruptions",
                    score: sleepScore.interruptionsScore,
                    maxScore: 20,
                    explanation: sleepScore.interruptionsExplanation,
                    isLowest: sleepScore.lowestComponent == .interruptions
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    private func scoreColor(for score: Int) -> Color {
        switch score {
        case 80...100: return .green
        case 60...79: return .blue
        case 40...59: return .orange
        default: return .red
        }
    }
}

struct ComponentRow: View {
    let title: String
    let score: Int
    let maxScore: Int
    let explanation: String
    let isLowest: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text("\(score)/\(maxScore)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(componentColor)

                if isLowest {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)

                    Rectangle()
                        .fill(componentColor)
                        .frame(width: geometry.size.width * CGFloat(score) / CGFloat(maxScore), height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)

            Text(explanation)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(isLowest ? Color.orange.opacity(0.1) : Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var componentColor: Color {
        let percentage = Double(score) / Double(maxScore)
        switch percentage {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .blue
        case 0.4..<0.6: return .orange
        default: return .red
        }
    }
}

#Preview {
    SleepScoreView(
        sleepScore: SleepScore(
            totalScore: 67,
            durationScore: 35,
            bedtimeScore: 20,
            interruptionsScore: 12,
            date: Date()
        )
    )
    .padding()
}
