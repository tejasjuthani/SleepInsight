//
//  SleepInsightApp.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import SwiftUI

@main
struct SleepInsightApp: App {
    @StateObject private var healthKitService = HealthKitService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthKitService)
        }
    }
}
