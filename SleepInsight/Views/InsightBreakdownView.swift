//
//  InsightBreakdownView.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import SwiftUI

struct InsightBreakdownView: View {
    let insights: SleepInsights

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // What Helped Section
            if insights.hasPositiveFactors {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)

                        Text("What Helped Your Score")
                            .roundedFont(size: 20, weight: .bold)
                            .foregroundColor(.white)
                    }

                    ForEach(insights.helpedFactors) { factor in
                        InsightFactorCard(factor: factor, isPositive: true)
                    }
                }
            }

            // What Hurt Section
            if insights.hasNegativeFactors {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.title2)

                        Text("What Hurt Your Score")
                            .roundedFont(size: 20, weight: .bold)
                            .foregroundColor(.white)
                    }

                    ForEach(insights.hurtFactors) { factor in
                        InsightFactorCard(factor: factor, isPositive: false)
                    }
                }
            }

            // Score Adjustment Explanation
            if insights.scoreDifference != 0 {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title3)

                        Text("Score Adjustment")
                            .roundedFont(size: 17, weight: .semibold)
                            .foregroundColor(.white)
                    }

                    Text(insights.adjustmentExplanation)
                        .proFont(size: 15, weight: .regular)
                        .foregroundColor(.white.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .glassCardStyle(.tertiary, cornerRadius: 16)
            }
        }
        .padding(20)
        .glassCardStyle(.primary)
    }
}

struct InsightFactorCard: View {
    let factor: InsightFactor
    let isPositive: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            Image(systemName: factor.component.icon)
                .font(.title2)
                .foregroundColor(isPositive ? .green : .orange)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(factor.title)
                    .roundedFont(size: 17, weight: .semibold)
                    .foregroundColor(.white)

                // Description
                Text(factor.description)
                    .proFont(size: 14, weight: .regular)
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)

                // Impact badge
                Text(factor.impact.displayText)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(impactColor(for: factor.impact))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(impactColor(for: factor.impact).opacity(0.15))
                    )
            }

            Spacer()
        }
        .padding(16)
        .glassCardStyle(.tertiary, cornerRadius: 16)
    }

    private func impactColor(for impact: InsightFactor.ImpactLevel) -> Color {
        switch impact {
        case .high: return .red
        case .medium: return .orange
        case .low: return .yellow
        }
    }
}

#Preview {
    InsightBreakdownView(
        insights: SleepInsights(
            helpedFactors: [
                InsightFactor(
                    title: "Excellent Sleep Duration",
                    description: "You slept for 8h 15m, which is in the optimal 7-9 hour range.",
                    component: .duration,
                    impact: .high
                )
            ],
            hurtFactors: [
                InsightFactor(
                    title: "Irregular Bedtime",
                    description: "You went to bed at 11:47 PM, which is later than optimal. You lost 8 points due to irregular bedtime.",
                    component: .bedtime,
                    impact: .medium
                )
            ],
            scoreDifference: -5
        )
    )
    .padding()
}
