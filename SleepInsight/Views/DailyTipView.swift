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
            HStack {
                Image(systemName: iconForCategory(tip.category))
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(colorForCategory(tip.category))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Tip")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)

                    Text(tip.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                }

                Spacer()
            }

            Text(tip.message)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)

                Text("Focus Area: \(tip.category.displayName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    private func iconForCategory(_ category: SleepComponent) -> String {
        switch category {
        case .duration: return "clock.fill"
        case .bedtime: return "moon.stars.fill"
        case .interruptions: return "bed.double.fill"
        }
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
            message: "Try going to bed 30 minutes earlier tonight. Set a bedtime reminder to help you wind down.",
            category: .duration
        )
    )
    .padding()
}
