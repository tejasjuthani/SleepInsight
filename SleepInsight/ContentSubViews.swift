import SwiftUI

// MARK: - Authorization View
struct AuthorizationView: View {
    @EnvironmentObject var healthKitService: HealthKitService

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 90))
                .foregroundColor(.pink)
                .shadow(color: Color.pink.opacity(0.3), radius: 20, x: 0, y: 10)

            VStack(spacing: 12) {
                Text("Welcome to SleepInsight+")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)

                Text("Advanced sleep analytics powered by HealthKit")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
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
            .padding(20)
            .glassCardStyle(.secondary)

            Button {
                Task { await healthKitService.requestAuthorization() }
            } label: {
                Text("Connect to HealthKit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink.opacity(0.9))
                    .cornerRadius(20)
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
                .font(.system(size: 24))
                .foregroundColor(.pink)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.8)
                .tint(.white)

            Text("Analyzing your sleep data...")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)

            Text("Reading HealthKit sleep samples")
                .font(.callout)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(32)
        .glassCardStyle(.secondary)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    @EnvironmentObject var healthKitService: HealthKitService

    var body: some View {
        VStack(spacing: 28) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 70))
                .foregroundColor(.blue)
                .shadow(color: Color.blue.opacity(0.3), radius: 20, x: 0, y: 10)

            Text("No Sleep Data")
                .font(.system(size: 28, weight: .bold))
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
            .padding(.horizontal, 20)

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
                .padding(.vertical, 14)
                .background(Color.blue.opacity(0.9))
                .cornerRadius(20)
            }
        }
        .padding(28)
        .glassCardStyle(.primary)
    }
}
