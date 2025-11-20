//
//  WeeklyOverviewView.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import SwiftUI

struct WeeklyOverviewView: View {
    @EnvironmentObject var healthKitService: HealthKitService

    private let goalHours: Double = 7.0

    var body: some View {
        let history = healthKitService.weeklyHistory.sorted { $0.date < $1.date }
        let weekData = Array(history.suffix(7))

        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Title
                Text("Weekly Overview")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(.white)

                Text("Last 7 nights based on your SleepInsight+ score.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))

                if weekData.isEmpty {
                    // Not enough data state
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Not enough data yet")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        Text("Wear your Apple Watch to bed for a few nights so SleepInsight+ can show your weekly trends.")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(20)
                    .glassCardStyle(.secondary)
                } else {
                    // Aggregate stats and sections
                    WeeklyStatsSummaryView(weekData: weekData, goalHours: goalHours)

                    // Score trend chart
                    if weekData.count >= 2 {
                        WeeklyScoreTrendView(scores: weekData)
                    }

                    WeeklyNightsListView(weekData: weekData)
                }

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
}

// MARK: - Weekly Stats Summary View

struct WeeklyStatsSummaryView: View {
    let weekData: [SleepScore]
    let goalHours: Double

    var body: some View {
        let avgScore = weekData.map { Double($0.sleepInsightScore) }.reduce(0, +) / Double(weekData.count)
        let avgDuration = weekData.map { $0.totalSleepHours }.reduce(0, +) / Double(weekData.count)
        let avgInterruptions = weekData.map { Double($0.interruptionCount) }.reduce(0, +) / Double(weekData.count)
        let goalNightsMet = weekData.filter { $0.totalSleepHours >= goalHours }.count

        let bestNight = weekData.max(by: { $0.sleepInsightScore < $1.sleepInsightScore })
        let toughestNight = weekData.min(by: { $0.sleepInsightScore < $1.sleepInsightScore })

        VStack(alignment: .leading, spacing: 16) {
            Text("This Week at a Glance")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Avg SleepInsight+ Score")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(Int(avgScore.rounded())) / 100")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Avg Sleep Duration")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text(String(format: "%.1f h", avgDuration))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Avg Interruptions")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text(String(format: "%.1f per night", avgInterruptions))
                        .font(.subheadline)
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Goal Progress")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("Goal: \(Int(goalHours))h • \(goalNightsMet) of \(weekData.count) nights met")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }

            if let best = bestNight {
                Text("Best night: \(formattedDay(best.date)) • \(best.sleepInsightScore)/100, \(String(format: "%.1f h", best.totalSleepHours))")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }

            if let toughest = toughestNight {
                Text("Toughest night: \(formattedDay(toughest.date)) • \(toughest.sleepInsightScore)/100, \(String(format: "%.1f h", toughest.totalSleepHours))")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(20)
        .glassCardStyle(.primary)
    }

    private func formattedDay(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE d MMM"
        return f.string(from: date)
    }
}

// MARK: - Weekly Score Trend View

struct WeeklyScoreTrendView: View {
    let scores: [SleepScore]

    @State private var selectedIndex: Int?

    private let goalScore: Double = 70.0
    private let maxScore: Double = 100.0
    private let minBarHeight: CGFloat = 8.0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text("Score Trend")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("SleepInsight+ score for each of the last 7 nights.")
                .font(.body)
                .foregroundColor(.white.opacity(0.7))

            // Chart
            GeometryReader { geometry in
                let chartHeight: CGFloat = 180
                let chartWidth = geometry.size.width
                let barSpacing: CGFloat = 8
                let barWidth = (chartWidth - (CGFloat(scores.count - 1) * barSpacing)) / CGFloat(scores.count)

                ZStack(alignment: .bottom) {
                    // Goal line
                    let goalLineY = chartHeight * (1 - CGFloat(goalScore / maxScore))

                    // Goal line with label
                    HStack {
                        Rectangle()
                            .fill(Color.yellow.opacity(0.5))
                            .frame(height: 1)

                        Text("Goal 70")
                            .font(.caption2)
                            .foregroundColor(.yellow.opacity(0.8))
                            .padding(.leading, 4)
                    }
                    .offset(y: -goalLineY)

                    // Bars
                    HStack(alignment: .bottom, spacing: barSpacing) {
                        ForEach(Array(scores.enumerated()), id: \.element.date) { index, score in
                            VStack(spacing: 4) {
                                // Bar
                                let scoreValue = Double(score.sleepInsightScore)
                                let barHeight = max(chartHeight * CGFloat(scoreValue / maxScore), minBarHeight)

                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.blue.opacity(0.8),
                                                Color.purple.opacity(0.6)
                                            ]),
                                            startPoint: .bottom,
                                            endPoint: .top
                                        )
                                    )
                                    .frame(width: barWidth, height: barHeight)
                                    .scaleEffect(y: selectedIndex == index ? 1.07 : 1.0, anchor: .bottom)
                                    .animation(.spring(response: 0.28, dampingFraction: 0.75), value: selectedIndex)

                                // Day label
                                Text(formattedWeekday(score.date))
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(width: barWidth)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedIndex = index
                            }
                        }
                    }
                }
                .frame(height: chartHeight + 20)
            }
            .frame(height: 220)

            // Detail line
            if let index = selectedIndex, index < scores.count {
                let score = scores[index]
                let formattedDate = formattedDetailDate(score.date)
                let formattedHours = String(format: "%.1f", score.totalSleepHours)

                Text("\(formattedDate) – \(score.sleepInsightScore) / 100, \(formattedHours) h, \(score.interruptionCount) interruptions")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 8)
            } else {
                Text("Tap a bar to see that night's details.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 8)
            }
        }
        .padding(20)
        .glassCardStyle(.secondary)
    }

    private func formattedWeekday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    private func formattedDetailDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d MMM"
        return formatter.string(from: date)
    }
}

// MARK: - Weekly Nights List View

struct WeeklyNightsListView: View {
    let weekData: [SleepScore]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Night-by-Night View")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            ForEach(weekData.sorted(by: { $0.date < $1.date }), id: \.date) { score in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formattedDay(score.date))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        Text("Score: \(score.sleepInsightScore)/100 • \(String(format: "%.1f h", score.totalSleepHours)) • \(score.interruptionCount) interruptions")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }

                    Spacer()
                }
                .padding(16)
                .glassCardStyle(.tertiary, cornerRadius: 16)
            }
        }
    }

    private func formattedDay(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE d MMM"
        return f.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        WeeklyOverviewView()
            .environmentObject({
                let service = HealthKitService()
                // Mock weekly history with sample data
                service.weeklyHistory = [
                    SleepScore(
                        appleDurationScore: 45,
                        appleBedtimeScore: 20,
                        appleInterruptionsScore: 15,
                        sleepInsightScore: 80,
                        date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!,
                        totalSleepHours: 7.5,
                        bedtimeHour: 22,
                        bedtimeMinute: 30,
                        interruptionCount: 2
                    ),
                    SleepScore(
                        appleDurationScore: 40,
                        appleBedtimeScore: 18,
                        appleInterruptionsScore: 12,
                        sleepInsightScore: 70,
                        date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
                        totalSleepHours: 6.5,
                        bedtimeHour: 23,
                        bedtimeMinute: 0,
                        interruptionCount: 4
                    ),
                    SleepScore(
                        appleDurationScore: 48,
                        appleBedtimeScore: 22,
                        appleInterruptionsScore: 16,
                        sleepInsightScore: 86,
                        date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
                        totalSleepHours: 8.0,
                        bedtimeHour: 22,
                        bedtimeMinute: 0,
                        interruptionCount: 1
                    )
                ]
                return service
            }())
    }
}
