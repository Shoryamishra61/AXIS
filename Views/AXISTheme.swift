// AXISTheme.swift

// Semantic, High-Contrast Color System following "Architecture of Calm" principles.
// De-saturated sage, teal, and warm earth tones to suppress cortisol and reduce heart rates.
// Resolves dynamically for Light, Dark, and high-contrast accessibility modes.
// Supports iOS 26 Reduce Transparency fallbacks.

import SwiftUI

enum AXISTheme {
    // MARK: - Primary Colors

    // Calm Blue: De-saturated from system blue toward a serene, clinical tone.
    static let accent = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.40, green: 0.62, blue: 0.85, alpha: 1.0) // Soft sky blue
            : UIColor(red: 0.22, green: 0.47, blue: 0.72, alpha: 1.0) // Calm steel blue
    })

    // De-saturated Teal/Sage: The report mandates sage greens and de-saturated teals.
    static let secondaryAccent = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.35, green: 0.68, blue: 0.62, alpha: 1.0) // Sage teal
            : UIColor(red: 0.20, green: 0.52, blue: 0.48, alpha: 1.0) // Deep sage
    })

    // Soft Sage Green: Replaces systemGreen with a calming, de-saturated sage.
    static let success = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.40, green: 0.72, blue: 0.55, alpha: 1.0) // Mint sage
            : UIColor(red: 0.25, green: 0.58, blue: 0.42, alpha: 1.0) // Deep sage green
    })

    // Warm Amber: Replaces systemOrange with a softer, less alarming tone.
    static let warning = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.88, green: 0.72, blue: 0.40, alpha: 1.0) // Warm gold
            : UIColor(red: 0.75, green: 0.58, blue: 0.28, alpha: 1.0) // Earth amber
    })

    // Soft Coral: Replaces aggressive systemRed with a firm but non-alarming alert.
    static let danger = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.85, green: 0.45, blue: 0.42, alpha: 1.0) // Soft coral
            : UIColor(red: 0.72, green: 0.32, blue: 0.30, alpha: 1.0) // Muted brick
    })

    // MARK: - Dynamic Background Gradients (Session Atmosphere)

    /// In-zone gradient — calm, sage/teal tones
    static let zoneGoodGradientColors: [Color] = [
        Color(red: 0.08, green: 0.12, blue: 0.14),
        Color(red: 0.10, green: 0.18, blue: 0.20),
        Color(red: 0.06, green: 0.14, blue: 0.16)
    ]

    /// Out-of-zone gradient — warm, neutral tones
    static let zoneAdjustGradientColors: [Color] = [
        Color(red: 0.12, green: 0.10, blue: 0.08),
        Color(red: 0.16, green: 0.12, blue: 0.10),
        Color(red: 0.10, green: 0.10, blue: 0.10)
    ]

    /// Light mode in-zone gradient
    static let zoneGoodGradientColorsLight: [Color] = [
        Color(red: 0.92, green: 0.96, blue: 0.95),
        Color(red: 0.88, green: 0.94, blue: 0.92),
        Color(red: 0.94, green: 0.97, blue: 0.96)
    ]

    /// Light mode out-of-zone gradient
    static let zoneAdjustGradientColorsLight: [Color] = [
        Color(red: 0.96, green: 0.95, blue: 0.93),
        Color(red: 0.95, green: 0.93, blue: 0.90),
        Color(red: 0.96, green: 0.96, blue: 0.95)
    ]

    // MARK: - Accessibility Helpers

    /// Returns the right ShapeStyle for floating card backgrounds.
    /// Respects the Reduce Transparency accessibility setting.
    static func cardBackground(reduceTransparency: Bool) -> AnyShapeStyle {
        if reduceTransparency {
            return AnyShapeStyle(Color(UIColor.secondarySystemGroupedBackground))
        }
        return AnyShapeStyle(.ultraThinMaterial)
    }

    /// Returns a solid opaque background when Reduce Transparency is on.
    static func adaptiveCardBackground(reduceTransparency: Bool) -> Color {
        Color(UIColor.secondarySystemGroupedBackground)
    }

    /// Returns full-opacity color variant for high contrast contexts
    static func highContrastVariant(of color: Color) -> Color {
        color.opacity(1.0)
    }
}
