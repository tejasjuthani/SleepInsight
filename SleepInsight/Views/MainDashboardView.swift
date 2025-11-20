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
            VStack(spacing: 24) {
                // App Title
                HStack {
                    Text("SleepInsight+")
                        .roundedFont(size: 38, weight: .bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top, 24)

                // Day Selector
                DaySelectorView(
                    selectedDate: $selectedDate,
                    availableDates: availableDates,
                    onDateSelected: onDateSelected
                )

                // Header Section
                VStack(spacing: 8) {
                    Text(headerText)
                        .roundedFont(size: 12, weight: .semibold)
                        .foregroundColor(Color.purpleAccent.opacity(0.9))
                        .textCase(.uppercase)

                    Text(formattedDate)
                        .roundedFont(size: 20, weight: .semibold)
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
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.yellow)
                            .font(.body)
                        Text("Medical Disclaimer")
                            .roundedFont(size: 15, weight: .semibold)
                            .foregroundColor(.white)
                    }

                    Text("SleepInsight+ is a general wellness app and does not provide medical advice, diagnosis, or treatment. Always consult a qualified healthcare professional for medical concerns.")
                        .proFont(size: 14, weight: .regular)
                        .foregroundColor(.white.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .glassCardStyle(.tertiary, cornerRadius: 16)

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
                HStack(spacing: 16) {
                    NavigationLink(destination: WeeklyOverviewView()) {
                        Image(systemName: "chart.bar")
                            .imageScale(.large)
                    }
                    NavigationLink(destination: AboutView()) {
                        Image(systemName: "info.circle")
                            .imageScale(.large)
                    }
                }
                .foregroundColor(.white)
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
                    .roundedFont(size: 11, weight: .semibold)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))

                Text(dayNumber)
                    .roundedFont(size: 20, weight: .bold)
                    .foregroundColor(.white)

                Text(monthLabel)
                    .roundedFont(size: 10, weight: .medium)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            }
            .frame(width: 70, height: 80)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.purpleAccent.opacity(0.12))
                        )
                } else {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.1))
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(isSelected ? Color.purpleAccent.opacity(0.6) : Color.white.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(
                color: isSelected ? Color.purpleAccent.opacity(0.3) : Color.clear,
                radius: isSelected ? 12 : 0,
                x: 0,
                y: isSelected ? 6 : 0
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
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
