//
//  ReadinessView.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import SwiftUI

struct ReadinessView: View {
    let readiness: ReadinessScore

    var body: some View {
        VStack(spacing: 20) {
            // Emoji and Score
            VStack(spacing: 12) {
                Text(readiness.emoji)
                    .font(.system(size: 70))

                Text("Readiness Score")
                    .font(.headline)
                    .foregroundColor(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(readiness.score)")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(readinessColor)

                    Text("/10")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }

                Text(readiness.category)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(readinessColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(readinessColor.opacity(0.15))
                    )
            }

            Divider()
                .padding(.horizontal)

            // Description
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "quote.bubble.fill")
                        .foregroundColor(.blue)

                    Text("Your Day Ahead")
                        .font(.headline)
                }

                Text(readiness.description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)

            // Visual Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    ForEach(1...10, id: \.self) { index in
                        Rectangle()
                            .fill(index <= readiness.score ? readinessColor : Color.gray.opacity(0.2))
                            .frame(height: 8)
                            .cornerRadius(4)
                    }
                }

                HStack {
                    Text("Low")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("High")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    private var readinessColor: Color {
        switch readiness.score {
        case 9...10: return .green
        case 7...8: return .blue
        case 5...6: return .orange
        case 3...4: return .red
        default: return .gray
        }
    }
}

#Preview {
    ReadinessView(
        readiness: ReadinessScore(
            score: 7,
            date: Date()
        )
    )
    .padding()
}
