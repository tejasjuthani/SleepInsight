//
//  GlassCardStyle.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import SwiftUI

enum GlassLevel {
    case primary
    case secondary
    case tertiary

    var shadowRadius: CGFloat {
        switch self {
        case .primary: return 30
        case .secondary: return 20
        case .tertiary: return 12
        }
    }

    var shadowY: CGFloat {
        switch self {
        case .primary: return 20
        case .secondary: return 12
        case .tertiary: return 6
        }
    }

    var shadowOpacity: Double {
        switch self {
        case .primary: return 0.35
        case .secondary: return 0.25
        case .tertiary: return 0.15
        }
    }
}

struct GlassCard: ViewModifier {
    let level: GlassLevel
    let cornerRadius: CGFloat

    init(level: GlassLevel = .secondary, cornerRadius: CGFloat = 24) {
        self.level = level
        self.cornerRadius = cornerRadius
    }

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(
                color: Color.black.opacity(level.shadowOpacity),
                radius: level.shadowRadius,
                x: 0,
                y: level.shadowY
            )
    }
}

extension View {
    func glassCardStyle(_ level: GlassLevel = .secondary, cornerRadius: CGFloat = 24) -> some View {
        self.modifier(GlassCard(level: level, cornerRadius: cornerRadius))
    }
}
