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
        VStack(alignment: .leading, spacing: 24) {
            // SleepInsight Score Display
            VStack(spacing: 8) {
                Text("SleepInsight Score")
                    .font(.headline)
                    .foregroundColor(.primary)

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(sleepScore.sleepInsightScore)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(scoreColor(for: sleepScore.sleepInsightScore))

                    Text("/100")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }

                Text("SleepInsight scores your sleep independently using Apple Health data.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)

            // Component Breakdown
            VStack(alignment: .leading, spacing: 16) {
                Text("Component Breakdown")
                    .font(.headline)
                    .padding(.bottom, 4)

                ComponentRow(
                    title: "Duration",
                    subtitle: sleepScore.formattedSleepDuration,
                    score: sleepScore.appleDurationScore,
                    maxScore: 50,
                    percentage: sleepScore.durationPercentage,
                    icon: "clock.fill",
                    isLowest: sleepScore.lowestComponent == .duration,
                    isHighest: sleepScore.highestComponent == .duration
                )

                ComponentRow(
                    title: "Bedtime Consistency",
                    subtitle: "Bedtime: \(sleepScore.formattedBedtime)",
                    score: sleepScore.appleBedtimeScore,
                    maxScore: 30,
                    percentage: sleepScore.bedtimePercentage,
                    icon: "moon.stars.fill",
                    isLowest: sleepScore.lowestComponent == .bedtime,
                    isHighest: sleepScore.highestComponent == .bedtime
                )

                ComponentRow(
                    title: "Sleep Continuity",
                    subtitle: "\(sleepScore.interruptionCount) interruption\(sleepScore.interruptionCount == 1 ? "" : "s")",
                    score: sleepScore.appleInterruptionsScore,
                    maxScore: 20,
                    percentage: sleepScore.interruptionsPercentage,
                    icon: "bed.double.fill",
                    isLowest: sleepScore.lowestComponent == .interruptions,
                    isHighest: sleepScore.highestComponent == .interruptions
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
    let subtitle: String
    let score: Int
    let maxScore: Int
    let percentage: Double
    let icon: String
    let isLowest: Bool
    let isHighest: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(componentColor)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("\(score)/\(maxScore)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(componentColor)

                if isLowest {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.body)
                        .foregroundColor(.orange)
                } else if isHighest {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.body)
                        .foregroundColor(.green)
                }
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [componentColor.opacity(0.7), componentColor]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(percentage), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isLowest ? Color.orange.opacity(0.1) : Color(.secondarySystemBackground))
        )
    }

    private var componentColor: Color {
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
            appleDurationScore: 48,
            appleBedtimeScore: 22,
            appleInterruptionsScore: 14,
            sleepInsightScore: 78,
            date: Date(),
            totalSleepHours: 8.25,
            bedtimeHour: 22,
            bedtimeMinute: 30,
            interruptionCount: 3
        )
    )
    .padding()
}
