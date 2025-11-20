//
//  MainDashboardView.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import SwiftUI

struct MainDashboardView: View {
    let sleepScore: SleepScore
    let insights: [InsightItem]
    @Binding var selectedDate: Date
    let availableDates: [Date]
    let onDateSelected: (Date) -> Void

    private let insightEngine = InsightEngine()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Day Selector
                DaySelectorView(
                    selectedDate: $selectedDate,
                    availableDates: availableDates,
                    onDateSelected: onDateSelected
                )

                // Header Section
                VStack(spacing: 8) {
                    Text(headerText)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .textCase(.uppercase)

                    Text(formattedDate)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.top, 8)

                // 1. Sleep Scores (Dual Display)
                SleepScoreView(sleepScore: sleepScore)

                // 2. Component Breakdown (What Helped / What Hurt)
                InsightBreakdownView(
                    insights: insightEngine.generateInsights(from: sleepScore)
                )

                // 3. Today's Insights (Multi-Insight Display)
                if !insights.isEmpty {
                    DailyInsightsView(insights: insights)
                }

                // Medical Disclaimer
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("Medical Disclaimer")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.8))
                    }

                    Text("SleepInsight is a general wellness app and does not provide medical advice, diagnosis, or treatment. Always consult a qualified healthcare professional for medical concerns.")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.yellow.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AboutView()) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.white)
                }
            }
        }
    }

    private var headerText: String {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())

        if let yesterday = yesterday, calendar.isDate(selectedDate, inSameDayAs: yesterday) {
            return "Yesterday's Sleep"
        } else {
            return "Sleep Summary"
        }
    }

    private var formattedDate: String {
        let normalized = Calendar.current.startOfDay(for: selectedDate)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = .current
        return formatter.string(from: normalized)
    }
}

// MARK: - Day Selector View

struct DaySelectorView: View {
    @Binding var selectedDate: Date
    let availableDates: [Date]
    let onDateSelected: (Date) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(availableDates.reversed(), id: \.self) { date in
                    DayButton(
                        date: date,
                        isSelected: Calendar.current.isDate(selectedDate, inSameDayAs: date),
                        onTap: {
                            selectedDate = date
                            onDateSelected(date)
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct DayButton: View {
    let date: Date
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(dayLabel)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))

                Text(dayNumber)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(monthLabel)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            }
            .frame(width: 70, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.3) : Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.white.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
    }

    private var dayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private var monthLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date).uppercased()
    }
}

#Preview {
    @Previewable @State var selectedDate = Calendar.current.startOfDay(for: Date())

    MainDashboardView(
        sleepScore: SleepScore(
            appleDurationScore: 48,
            appleBedtimeScore: 22,
            appleInterruptionsScore: 14,
            sleepInsightScore: 78,
            date: Date().addingTimeInterval(-86400),
            totalSleepHours: 8.25,
            bedtimeHour: 22,
            bedtimeMinute: 30,
            interruptionCount: 3
        ),
        insights: [
            InsightItem(
                type: .highRecovery,
                title: "High-Quality Recovery Night",
                explanation: "You slept 8h 15m with only 3 interruptions.",
                tonightPlan: "Tonight, maintain your current routine.",
                priority: 1,
                trendNote: "Trend: Excellent recovery pattern maintained."
            )
        ],
        selectedDate: $selectedDate,
        availableDates: (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: -$0, to: Calendar.current.startOfDay(for: Date())) },
        onDateSelected: { _ in }
    )
}
