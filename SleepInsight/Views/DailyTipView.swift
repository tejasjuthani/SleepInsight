//
//  DailyTipView.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import SwiftUI

struct DailyTipView: View {
    let tip: DailyTip

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(colorForCategory(tip.category))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Today's Action Plan")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)

                        Spacer()

                        Text(tip.priority.displayText)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }

                    Text(tip.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }

            Divider()

            // Why Section
            VStack(alignment: .leading, spacing: 6) {
                Label("Why", systemImage: "questionmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)

                Text(tip.message)
                    .font(.body)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Action Section
            VStack(alignment: .leading, spacing: 6) {
                Label("What To Do", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)

                Text(tip.actionItem)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(colorForCategory(tip.category).opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(colorForCategory(tip.category).opacity(0.3), lineWidth: 1)
                    )
            }

            // Focus Area
            HStack {
                Image(systemName: tip.category.icon)
                    .font(.caption)
                    .foregroundColor(colorForCategory(tip.category))

                Text("Focus: \(tip.category.displayName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    private func colorForCategory(_ category: SleepComponent) -> Color {
        switch category {
        case .duration: return .blue
        case .bedtime: return .purple
        case .interruptions: return .indigo
        }
    }
}

#Preview {
    DailyTipView(
        tip: DailyTip(
            title: "Extend Your Sleep Window",
            message: "You slept 6h 30m last night, which is below the recommended 7-9 hours.",
            actionItem: "Go to bed 60 minutes earlier tonight to reach 7h 30m.",
            category: .duration,
            priority: .high
        )
    )
    .padding()
}
