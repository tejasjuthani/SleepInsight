//
//  ContentView.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var healthKitService: HealthKitService

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.2, green: 0.1, blue: 0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if !healthKitService.isAuthorized {
                    AuthorizationView()
                } else if healthKitService.isLoading {
                    LoadingView()
                } else if let errorMessage = healthKitService.errorMessage {
                    ErrorView(message: errorMessage)
                } else if let sleepScore = healthKitService.sleepScore {
                    MainContentView(sleepScore: sleepScore)
                } else {
                    EmptyStateView()
                }
            }
            .navigationTitle("SleepInsight")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if healthKitService.isAuthorized && healthKitService.sleepScore != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            Task {
                                await healthKitService.fetchYesterdaySleepScore()
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
        }
    }
}

struct AuthorizationView: View {
    @EnvironmentObject var healthKitService: HealthKitService

    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 80))
                .foregroundColor(.pink)

            VStack(spacing: 12) {
                Text("Welcome to SleepInsight")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Unlock personalized sleep insights")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
            }

            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "bed.double.fill", title: "Sleep Score Decoder", description: "Understand your Apple Sleep Score components")
                FeatureRow(icon: "lightbulb.fill", title: "Daily Tips", description: "Get actionable advice to improve your sleep")
                FeatureRow(icon: "gauge.high", title: "Morning Readiness", description: "Know your energy level for the day ahead")
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(16)

            Button {
                Task {
                    await healthKitService.requestAuthorization()
                }
            } label: {
                Text("Connect to HealthKit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink)
                    .cornerRadius(12)
            }
            .padding(.top)
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.pink)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)

            Text("Analyzing your sleep data...")
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}

struct ErrorView: View {
    let message: String
    @EnvironmentObject var healthKitService: HealthKitService

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("Oops!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(message)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                Task {
                    await healthKitService.fetchYesterdaySleepScore()
                }
            } label: {
                Text("Try Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}

struct EmptyStateView: View {
    @EnvironmentObject var healthKitService: HealthKitService

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("No Sleep Data")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("We couldn't find sleep data for yesterday. Make sure you're wearing your Apple Watch to bed.")
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                Task {
                    await healthKitService.fetchYesterdaySleepScore()
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Refresh")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(12)
            }
        }
        .padding()
    }
}

struct MainContentView: View {
    let sleepScore: SleepScore

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Readiness Score at top
                ReadinessView(
                    readiness: ReadinessScore(
                        score: ReadinessScore.calculate(from: sleepScore.totalScore),
                        date: sleepScore.date
                    )
                )

                // Sleep Score breakdown
                SleepScoreView(sleepScore: sleepScore)

                // Daily Tip based on lowest component
                DailyTipView(
                    tip: DailyTip.generateTip(for: sleepScore.lowestComponent)
                )

                Spacer(minLength: 40)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(HealthKitService())
}
