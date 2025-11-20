import SwiftUI

struct ContentView: View {
    @EnvironmentObject var healthKitService: HealthKitService

    // Controls whether splash animation is showing
    @State private var showLaunchAnimation = true

    // Date selection state
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var availableDates: [Date] = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: today)
        }
    }()

    var body: some View {
        ZStack {
            if showLaunchAnimation {
                LaunchAnimationView {
                    // Animation finished → show actual app
                    showLaunchAnimation = false
                }
            } else {
                mainAppContent
            }
        }
    }

    // MARK: - Main App Content
    private var mainAppContent: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.2, green: 0.1, blue: 0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Flow control after splash
                if !healthKitService.isAuthorized {
                    AuthorizationView()
                } else if healthKitService.isLoading {
                    LoadingView()
                } else if let sleepScore = healthKitService.sleepScore {
                    MainDashboardView(
                        sleepScore: sleepScore,
                        insights: healthKitService.dailyInsightItems,
                        selectedDate: $selectedDate,
                        availableDates: availableDates,
                        onDateSelected: { date in
                            Task {
                                await healthKitService.fetchSleepScore(for: date)
                            }
                        }
                    )
                } else if healthKitService.checkedForData {
                    EmptyStateView()
                }
            }
            .navigationTitle("SleepInsight")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task {
                // Always fetch TODAY on first launch
                await healthKitService.fetchSleepScore(for: selectedDate)
            }
            .onAppear {
                // Always reset to today when screen appears
                selectedDate = Calendar.current.startOfDay(for: Date())
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(HealthKitService())
}
