//
//  GlassCardStyle.swift
//  SleepInsight
//
//  Created by TJ Technologies
//

import SwiftUI

// MARK: - Purple Accent Color

extension Color {
    static let purpleAccent = Color(hex: "#A26BFF")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Glass Level Elevation

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

// MARK: - Liquid Glass A2 Card Modifier

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
                    .background(.ultraThinMaterial)
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

// MARK: - Hybrid Typography Helpers

extension View {
    /// SF Rounded style for titles, headers, and score numbers
    func roundedFont(size: CGFloat, weight: Font.Weight = .regular) -> some View {
        self.font(.system(size: size, weight: weight, design: .rounded))
            .minimumScaleFactor(0.85)
            .dynamicTypeSize(.medium ... .xxLarge)
    }

    /// SF Pro style for body text, explanations, and details
    func proFont(size: CGFloat, weight: Font.Weight = .regular) -> some View {
        self.font(.system(size: size, weight: weight, design: .default))
            .minimumScaleFactor(0.85)
            .dynamicTypeSize(.medium ... .xxLarge)
    }
}
