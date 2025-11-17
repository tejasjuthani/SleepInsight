//
//  AppleScoreExplanationView.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import SwiftUI

struct AppleScoreExplanationView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {

                    Text("How Apple Calculates Sleep Score")
                        .font(.title2.bold())

                    Text("""
Apple does not expose the actual Sleep Score through HealthKit. However, Apple states that the Sleep Score is based on three components:

• Sleep Duration (0–50)
• Bedtime Consistency (0–30)
• Sleep Continuity – interruptions (0–20)

Apple's daily score is simply the sum of these three values.

SleepInsight uses the same formula for displaying the Apple Score so it matches your Apple Sleep app as closely as possible.
""")

                    Divider()

                    Text("Why Scores May Differ")
                        .font(.title3.bold())

                    Text("""
Apple sometimes applies additional weekly normalization or streak adjustments which are NOT exposed to developers.

Since Apple does not provide these adjustments through HealthKit, third-party apps cannot replicate them.

SleepInsight therefore calculates the Apple Score using the official component weighting system only.
""")

                    Divider()

                    Text("SleepInsight Adjusted Score")
                        .font(.title3.bold())

                    Text("""
SleepInsight provides an additional score using a weighted formula to better reflect:
• Sleep quality
• Sleep timing habits
• Fragmentation impact

This score is separate from the Apple Score.
""")
                }
                .padding()
            }
            .navigationTitle("Apple Score Info")
        }
    }
}

#Preview {
    AppleScoreExplanationView()
}
