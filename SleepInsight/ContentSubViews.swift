import SwiftUI

// MARK: - Authorization View
struct AuthorizationView: View {
    @EnvironmentObject var healthKitService: HealthKitService

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 80))
                .foregroundColor(.pink)

            VStack(spacing: 12) {
                Text("Welcome to SleepInsight")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Advanced sleep analytics powered by HealthKit")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(
                    icon: "chart.bar.fill",
                    title: "Dual Sleep Scoring",
                    description: "See both Apple and SleepInsight adjusted scores"
                )
                FeatureRow(
                    icon: "exclamationmark.bubble.fill",
                    title: "Behavioral Insights",
                    description: "Understand what helped and hurt your sleep"
                )
                FeatureRow(
                    icon: "bolt.fill",
                    title: "Daily Action Plans",
                    description: "Get specific, actionable tips to improve"
                )
                FeatureRow(
                    icon: "gauge.high",
                    title: "Morning Readiness",
                    description: "Know your energy level for the day"
                )
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(16)

            Button {
                Task { await healthKitService.requestAuthorization() }
            } label: {
                Text("Connect to HealthKit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink)
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
    }
}

// Feature Row Component
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

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)

            Text("Analyzing your sleep data...")
                .font(.headline)
                .foregroundColor(.white)

            Text("Reading HealthKit sleep samples")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

// MARK: - Empty State View
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

            VStack(spacing: 12) {
                Text("We couldn't find sleep data for this date.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)

                Text("Make sure you're wearing your Apple Watch to bed and Sleep tracking is enabled in the Health app.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)

            Button {
                Task { await healthKitService.fetchYesterdaySleepScore() }
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
