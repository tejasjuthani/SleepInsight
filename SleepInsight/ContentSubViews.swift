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
                    .roundedFont(size: 36, weight: .bold)
                    .foregroundColor(.white)

                Text("Sleep insights powered by data from the Health app.")
                    .proFont(size: 17, weight: .regular)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(
                    icon: "chart.bar.fill",
                    title: "Daily Sleep Score",
                    description: "Your duration, bedtime patterns, and interruptions combined into a simple nightly score."
                )
                FeatureRow(
                    icon: "lightbulb.fill",
                    title: "Behavior-Based Insights",
                    description: "Clear explanations of what helped and what impacted your sleep."
                )
                FeatureRow(
                    icon: "moon.stars.fill",
                    title: "Tonight's Plan",
                    description: "Simple, actionable suggestions based on your recent sleep patterns."
                )
                FeatureRow(
                    icon: "calendar.badge.clock",
                    title: "Weekly Overview",
                    description: "Track trends, goals, and your best and toughest nights at a glance."
                )
            }
            .padding(20)
            .glassCardStyle(.secondary)

            Button {
                Task { await healthKitService.requestAuthorization() }
            } label: {
                Text("Connect to Health")
                    .roundedFont(size: 17, weight: .bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purpleAccent)
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
                    .roundedFont(size: 15, weight: .semibold)
                    .foregroundColor(.white)

                Text(description)
                    .proFont(size: 13, weight: .regular)
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
                .roundedFont(size: 20, weight: .semibold)
                .foregroundColor(.white)

            Text("Reading Health sleep samples")
                .proFont(size: 15, weight: .regular)
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
                .roundedFont(size: 28, weight: .bold)
                .foregroundColor(.white)

            VStack(spacing: 12) {
                Text("We couldn't find sleep data for this date.")
                    .proFont(size: 17, weight: .regular)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)

                Text("Make sure you're wearing your Apple Watch to bed and Sleep tracking is enabled in the Health app.")
                    .proFont(size: 13, weight: .regular)
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
                .roundedFont(size: 17, weight: .semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(Color.purpleAccent)
                .cornerRadius(20)
            }
        }
        .padding(28)
        .glassCardStyle(.primary)
    }
}
