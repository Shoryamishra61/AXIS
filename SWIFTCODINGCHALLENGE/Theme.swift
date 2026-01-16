// Theme.swift
// Axis - The Invisible Posture Companion
// Apple-Grade Design System for Swift Student Challenge 2026

import SwiftUI

// MARK: - Typography System
extension Font {
    /// Hero titles - SF Pro Rounded Bold 34pt (warm, friendly)
    static let axisTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    
    /// Exercise names - SF Mono Medium 14pt (technical precision)
    static let axisTechnical = Font.system(.caption, design: .monospaced).weight(.medium)
    
    /// Instructions - New York Regular 18pt (readability during movement)
    static let axisInstruction = Font.system(.title3, design: .serif)
    
    /// Small labels - SF Pro Text Regular 13pt (system consistency)
    static let axisCaption = Font.system(.caption2, design: .default)
    
    /// Large display numbers
    static let axisDisplay = Font.system(size: 48, weight: .bold, design: .rounded)
    
    /// Button text
    static let axisButton = Font.system(.body, design: .rounded).weight(.semibold)
}

// MARK: - Color System
struct AxisColor {
    /// Primary brand color - Teal
    static let primary = Color(red: 0.0, green: 0.75, blue: 0.72)
    
    /// Secondary accent - Blue
    static let secondary = Color(red: 0.2, green: 0.5, blue: 0.95)
    
    /// Success state - Green
    static let success = Color(red: 0.2, green: 0.85, blue: 0.5)
    
    /// Warning state - Amber/Orange
    static let warning = Color(red: 1.0, green: 0.7, blue: 0.3)
    
    /// Error/Danger state - Coral Red
    static let danger = Color(red: 1.0, green: 0.4, blue: 0.4)
    
    /// Calm state - Mint
    static let calm = Color(red: 0.6, green: 0.95, blue: 0.85)
    
    /// Deep dark background
    static let backgroundDark = Color(red: 0.1, green: 0.12, blue: 0.18)
    
    static func semantic(for angle: Double) -> Color {
        let absoluteAngle = abs(angle)
        if absoluteAngle <= 10 { return success }
        if absoluteAngle <= 20 { return warning }
        return danger
    }
    
    /// Returns color based on accuracy (0.0 to 1.0)
    static func accuracy(_ value: Double) -> Color {
        switch value {
        case 0.85...: return success
        case 0.65..<0.85: return warning
        default: return danger
        }
    }
    
    static let backgroundGradient = RadialGradient(
        colors: [
            Color(red: 0.1, green: 0.16, blue: 0.22),
            Color(red: 0.06, green: 0.08, blue: 0.12),
            Color.black
        ],
        center: .center,
        startRadius: 50,
        endRadius: 600
    )
    
    /// Hero orb gradient
    static let orbGradient = LinearGradient(
        colors: [primary, secondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Success celebration gradient
    static let successGradient = LinearGradient(
        colors: [success, calm],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// Button gradient
    static let buttonGradient = LinearGradient(
        colors: [primary, secondary.opacity(0.9)],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    /// Calm ambient gradient
    static let ambientGradient = RadialGradient(
        colors: [
            primary.opacity(0.15),
            Color.clear
        ],
        center: .center,
        startRadius: 50,
        endRadius: 300
    )
    
    // MARK: Category Colors
    
    /// Get color for exercise category
    static func category(_ category: ExerciseCategory) -> Color {
        switch category {
        case .neckMobility: return primary
        case .isometric: return warning
        case .shoulderBack: return secondary
        case .eyeVestibular: return Color.purple
        case .breathwork: return calm
        case .yogaStretch: return Color.indigo
        case .wheelchair: return Color.cyan
        case .rest: return Color.gray
        }
    }
}

// MARK: - Accessibility Support
extension AxisColor {
    /// High contrast text on dark backgrounds (WCAG AAA compliant)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.5)
    
    /// Minimum contrast colors for accessibility
    static func accessibleForeground(on background: Color) -> Color {
        // On dark backgrounds, use white
        return .white
    }
}

// MARK: - Animation Durations
struct AxisAnimation {
    /// Quick feedback (haptic response, button press)
    static let quick = Animation.easeOut(duration: 0.15)
    
    /// Standard transitions
    static let standard = Animation.easeInOut(duration: 0.3)
    
    /// Smooth page transitions
    static let page = Animation.spring(response: 0.5, dampingFraction: 0.85)
    
    /// Breathing orb animation
    static let breathing = Animation.easeInOut(duration: 4.0).repeatForever(autoreverses: true)
    
    /// Success celebration
    static let celebration = Animation.spring(response: 0.4, dampingFraction: 0.6)
    
    /// Reduced motion alternative
    static let reduced = Animation.linear(duration: 0.01)
}

// MARK: - Reduce Motion Support
struct ReduceMotionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let animation: Animation
    let reducedAnimation: Animation
    
    func body(content: Content) -> some View {
        content.animation(reduceMotion ? reducedAnimation : animation)
    }
}

extension View {
    func axisAnimation(_ animation: Animation) -> some View {
        modifier(ReduceMotionModifier(
            animation: animation,
            reducedAnimation: AxisAnimation.reduced
        ))
    }
}

// MARK: - Haptic Patterns
struct AxisHaptic {
    /// Light tick for navigation
    static func tick() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Medium impact for button press
    static func tap() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// Heavy thud for success
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// Warning feedback
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}

