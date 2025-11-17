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
        VStack(alignment: .leading, spacing: 20) {
            // What Helped Section
            if insights.hasPositiveFactors {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)

                        Text("What Helped Your Score")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }

                    ForEach(insights.helpedFactors) { factor in
                        InsightFactorCard(factor: factor, isPositive: true)
                    }
                }
            }

            // What Hurt Section
            if insights.hasNegativeFactors {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.title3)

                        Text("What Hurt Your Score")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }

                    ForEach(insights.hurtFactors) { factor in
                        InsightFactorCard(factor: factor, isPositive: false)
                    }
                }
            }

            // Score Adjustment Explanation
            if insights.scoreDifference != 0 {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)

                        Text("Score Adjustment")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    Text(insights.adjustmentExplanation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct InsightFactorCard: View {
    let factor: InsightFactor
    let isPositive: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            Image(systemName: factor.component.icon)
                .font(.title3)
                .foregroundColor(isPositive ? .green : .orange)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 6) {
                // Title
                Text(factor.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                // Description
                Text(factor.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
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
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isPositive ? Color.green.opacity(0.05) : Color.orange.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isPositive ? Color.green.opacity(0.2) : Color.orange.opacity(0.2), lineWidth: 1)
        )
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
