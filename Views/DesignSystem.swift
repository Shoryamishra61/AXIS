// DesignSystem.swift

// Centralized definitions for UI metrics, physics, and shared constants.
// Eliminates magic numbers across the application.
// Follows the 8-Point Grid system and Apple HIG specifications.

import SwiftUI

enum DesignSystem {
    // MARK: - 8-Point Grid Spacing
    static let spacing4:  CGFloat = 4
    static let spacing8:  CGFloat = 8
    static let spacing12: CGFloat = 12
    static let spacing16: CGFloat = 16
    static let spacing20: CGFloat = 20
    static let spacing24: CGFloat = 24
    static let spacing32: CGFloat = 32
    static let spacing40: CGFloat = 40
    static let spacing48: CGFloat = 48

    // MARK: - Layout
    static let standardPadding: CGFloat = 20
    static let cardCornerRadius: CGFloat = 20
    static let buttonCornerRadius: CGFloat = 16
    static let maxReadableWidth: CGFloat = 600 // For iPad formatting

    // MARK: - Touch Targets (Fitts's Law — HIG minimum 44×44pt)
    static let minTouchTarget: CGFloat = 44

    // MARK: - Progress Bars
    static let sessionProgressHeight: CGFloat = 5
    static let exerciseProgressHeight: CGFloat = 6

    // MARK: - Physics & Animation
    static let springResponse: Double = 0.5
    static let springDamping: Double = 0.85

    // iOS 26 Spring Presets (Apple HIG recommended values)
    static let springSnappy = Animation.spring(response: 0.35, dampingFraction: 0.82)
    static let springSmooth = Animation.spring(response: 0.5, dampingFraction: 0.85)
    static let springBouncy = Animation.spring(response: 0.4, dampingFraction: 0.6)
    static let springGentle = Animation.spring(response: 0.6, dampingFraction: 0.9)

    // MARK: - Animation Durations (HIG Timing)
    static let durationQuick: Double = 0.15    // Button press feedback
    static let durationMedium: Double = 0.3    // Content appearance
    static let durationSlow: Double = 0.6      // Navigation transitions

    // MARK: - Timing
    static let defaultDelay: Double = 0.15

    // MARK: - Session UX
    static let countdownDuration: Int = 3             // 3-2-1 countdown
    static let uiRetreatThreshold: Int = 5            // Seconds in zone before UI retreats
    static let exerciseTransitionDuration: Double = 2.0  // Pause between exercises
}

// MARK: - iOS 26 Liquid Glass Button Helpers
// Deployment target is iOS 26.0, so these APIs are always available.

extension View {
    /// Primary CTA: Liquid Glass `.glassProminent` button style.
    func prominentButtonStyle() -> some View {
        self.buttonStyle(.glassProminent)
            .controlSize(.large)
    }

    /// Secondary action: Liquid Glass `.glass` button style.
    func secondaryButtonStyle() -> some View {
        self.buttonStyle(.glass)
    }
}
