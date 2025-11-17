//
//  AppleScoreExplanationView.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import SwiftUI

struct AppleScoreExplanationView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // SECTION 1: Why the score may look different
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Why the score may look different")
                            .font(.headline)
                            .fontWeight(.semibold)

                        Text("Apple does not provide their official Sleep Score through HealthKit. Third-party apps can only access raw sleep metrics — duration, consistency, interruptions — and must recreate Apple's score using Apple's known methodology. Because Apple Health may use additional private signals, the score shown here may differ slightly.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Divider()

                    // SECTION 2: How this score is calculated
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How this score is calculated")
                            .font(.headline)
                            .fontWeight(.semibold)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 6))
                                    .foregroundColor(.secondary)
                                Text("Duration: 0–50 points")
                                    .font(.body)
                            }

                            HStack(spacing: 8) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 6))
                                    .foregroundColor(.secondary)
                                Text("Bedtime consistency: 0–30 points")
                                    .font(.body)
                            }

                            HStack(spacing: 8) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 6))
                                    .foregroundColor(.secondary)
                                Text("Interruptions: 0–20 points")
                                    .font(.body)
                            }
                        }

                        Text("Your Apple Score here is a simple sum of these components, which is the closest possible match to Apple Health's scoring system.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 8)
                    }

                    Divider()

                    // SECTION 3: How SleepInsight Score is different
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How SleepInsight Score is different")
                            .font(.headline)
                            .fontWeight(.semibold)

                        Text("SleepInsight uses a weighted scoring model to provide deeper behavioral insights.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 6))
                                    .foregroundColor(.secondary)
                                Text("Duration: 50%")
                                    .font(.body)
                            }

                            HStack(spacing: 8) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 6))
                                    .foregroundColor(.secondary)
                                Text("Bedtime consistency: 30%")
                                    .font(.body)
                            }

                            HStack(spacing: 8) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 6))
                                    .foregroundColor(.secondary)
                                Text("Interruptions: 20%")
                                    .font(.body)
                            }
                        }

                        Text("This offers a more actionable score focused on habits, not just totals.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 8)
                    }

                    // Footer
                    Text("If Apple exposes the official Sleep Score in future HealthKit updates, SleepInsight will switch to the real score automatically.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 16)
                }
                .padding()
            }
            .navigationTitle("About Apple Sleep Score")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AppleScoreExplanationView()
}
