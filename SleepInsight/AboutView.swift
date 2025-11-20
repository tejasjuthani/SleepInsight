//
//  AboutView.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // App Description
                VStack(alignment: .leading, spacing: 12) {
                    Text("About SleepInsight+")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("SleepInsight+ is a general wellness application that helps you track and understand your sleep patterns using data from Apple HealthKit. The app provides insights based on sleep duration, bedtime consistency, and sleep interruptions.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, 8)

                Divider()
                    .background(Color.white.opacity(0.3))

                // Medical Disclaimer
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.yellow)
                        Text("Medical Disclaimer")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }

                    Text("SleepInsight+ is a general wellness app and does not provide medical advice, diagnosis, or treatment. Always consult a qualified healthcare professional for medical concerns.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.yellow.opacity(0.2))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                        )

                    Text("The information provided by this app is for educational and informational purposes only. It should not be used as a substitute for professional medical advice, diagnosis, or treatment. If you have concerns about your sleep or health, please consult with a qualified healthcare provider.")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, 8)

                Divider()
                    .background(Color.white.opacity(0.3))

                // Citations and Sources
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.blue)
                        Text("Citations & Sources")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }

                    Text("SleepInsight+'s insights and recommendations are informed by established sleep health guidelines from reputable health organizations:")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)

                    // CDC Citation
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Centers for Disease Control and Prevention (CDC)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        Link("Sleep and Sleep Disorders", destination: URL(string: "https://www.cdc.gov/sleep/about/")!)
                            .font(.caption)
                            .foregroundColor(.blue.opacity(0.8))

                        Text("The CDC provides comprehensive data on sleep duration recommendations and the importance of sleep for overall health.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                    )

                    // NIH Citation
                    VStack(alignment: .leading, spacing: 6) {
                        Text("National Heart, Lung, and Blood Institute (NIH)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        Link("Healthy Sleep", destination: URL(string: "https://www.nhlbi.nih.gov/health/sleep")!)
                            .font(.caption)
                            .foregroundColor(.blue.opacity(0.8))

                        Text("The NHLBI provides research-based information on sleep health, sleep deficiency, and the importance of quality sleep.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                    )

                    // WHO Citation
                    VStack(alignment: .leading, spacing: 6) {
                        Text("World Health Organization (WHO)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        Link("Physical Activity & Sleep", destination: URL(string: "https://www.who.int/news-room/fact-sheets/detail/physical-activity")!)
                            .font(.caption)
                            .foregroundColor(.blue.opacity(0.8))

                        Text("The WHO provides guidelines on the relationship between physical activity, rest, and overall wellness.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                    )
                }
                .padding(.bottom, 8)

                Divider()
                    .background(Color.white.opacity(0.3))

                // Privacy & Data
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.green)
                        Text("Privacy & Data")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }

                    Text("Your sleep data is stored locally on your device and accessed only through Apple HealthKit. SleepInsight+ does not collect, store, or transmit your personal health information to any external servers.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, 8)

                // Version Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Version 1.0")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))

                    Text("© 2025 TJ Technologies. All rights reserved.")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.top, 16)

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
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        AboutView()
    }
}
