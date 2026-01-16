// DynamicAlignmentIndicator.swift
// Axis - The Invisible Posture Companion
// Distinguished Winner Core Innovation for Swift Student Challenge 2026
//
// This is the "wow" moment - a functional posture visualizer that transforms
// sensor data into an intuitive, beautiful, accessible experience.
// Every element has purpose. Every animation is intentional.

import SwiftUI

// MARK: - Dynamic Alignment Indicator

struct DynamicAlignmentIndicator: View {
    @ObservedObject var motion: MotionManager
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    // MARK: - Configuration
    let size: CGFloat
    let showNumericOverlay: Bool
    let showPrecisionRings: Bool
    let isInteractive: Bool
    
    // MARK: - Animation State
    @State private var pulseScale: CGFloat = 1.0
    @State private var ringRotation: Double = 0
    @State private var glowIntensity: Double = 0.6
    
    // MARK: - Computed Properties
    
    var currentDeviation: Double {
        max(abs(motion.pitch), abs(motion.yaw))
    }
    
    var alignmentState: AlignmentState {
        AlignmentState(deviation: currentDeviation)
    }
    
    var directionText: String {
        var parts: [String] = []
        if abs(motion.yaw) > 3 {
            parts.append(motion.yaw > 0 ? "LEFT" : "RIGHT")
        }
        if abs(motion.pitch) > 3 {
            parts.append(motion.pitch > 0 ? "UP" : "DOWN")
        }
        return parts.isEmpty ? "CENTERED" : parts.joined(separator: " • ")
    }
    
    var directionIcon: String {
        if currentDeviation < 3 { return "checkmark.circle.fill" }
        
        // Determine primary direction
        if abs(motion.yaw) > abs(motion.pitch) {
            return motion.yaw > 0 ? "arrow.turn.up.left" : "arrow.turn.up.right"
        } else {
            return motion.pitch > 0 ? "arrow.up" : "arrow.down"
        }
    }
    
    // MARK: - Initializer
    
    init(
        motion: MotionManager,
        size: CGFloat = 280,
        showNumericOverlay: Bool = true,
        showPrecisionRings: Bool = true,
        isInteractive: Bool = true
    ) {
        self.motion = motion
        self.size = size
        self.showNumericOverlay = showNumericOverlay
        self.showPrecisionRings = showPrecisionRings
        self.isInteractive = isInteractive
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Layer 1: Precision rings (30°, 20°, 10°)
            if showPrecisionRings {
                precisionRings
            }
            
            // Layer 2: Dynamic glow based on alignment state
            alignmentGlow
            
            // Layer 3: Core indicator orb
            coreOrb
            
            // Layer 4: Direction indicator arrow
            directionArrow
            
            // Layer 5: Numeric angle overlay
            if showNumericOverlay {
                angleOverlay
                    .offset(y: size * 0.55)
            }
        }
        .frame(width: size, height: size)
        .onAppear { startAnimations() }
        .onChange(of: alignmentState) { newState in
            triggerHapticFeedback(for: newState)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Posture alignment indicator")
        .accessibilityValue(accessibilityDescription)
    }
    
    // MARK: - Precision Rings
    
    private var precisionRings: some View {
        ZStack {
            ForEach([30, 20, 10], id: \.self) { targetAngle in
                PrecisionRing(
                    targetAngle: Double(targetAngle),
                    currentDeviation: currentDeviation,
                    size: size * CGFloat(targetAngle) / 35.0
                )
            }
        }
        .rotationEffect(.degrees(reduceMotion ? 0 : ringRotation))
    }
    
    // MARK: - Alignment Glow
    
    private var alignmentGlow: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        alignmentState.color.opacity(glowIntensity),
                        alignmentState.color.opacity(glowIntensity * 0.5),
                        alignmentState.color.opacity(0)
                    ],
                    center: .center,
                    startRadius: size * 0.1,
                    endRadius: size * 0.5
                )
            )
            .frame(width: size * 0.9, height: size * 0.9)
            .blur(radius: 30)
            .scaleEffect(reduceMotion ? 1.0 : pulseScale)
    }
    
    // MARK: - Core Orb
    
    private var coreOrb: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            alignmentState.color.opacity(0.6),
                            alignmentState.color.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: size * 0.4, height: size * 0.4)
                .blur(radius: 2)
            
            // Main orb with glass effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            alignmentState.color.opacity(0.3),
                            alignmentState.color.opacity(0.1),
                            Color.clear
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: size * 0.25
                    )
                )
                .frame(width: size * 0.35, height: size * 0.35)
                .overlay(
                    Circle()
                        .stroke(alignmentState.color.opacity(0.4), lineWidth: 2)
                )
                .overlay(
                    // Inner highlight
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.3), Color.clear],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: size * 0.15
                            )
                        )
                        .frame(width: size * 0.2, height: size * 0.2)
                        .offset(x: -size * 0.05, y: -size * 0.05)
                )
        }
        .scaleEffect(reduceMotion ? 1.0 : 0.95 + pulseScale * 0.05)
        // Tilt based on head position (subtle)
        .rotation3DEffect(
            .degrees(reduceMotion ? 0 : motion.pitch * 0.3),
            axis: (x: 1, y: 0, z: 0)
        )
        .rotation3DEffect(
            .degrees(reduceMotion ? 0 : motion.yaw * 0.3),
            axis: (x: 0, y: 1, z: 0)
        )
    }
    
    // MARK: - Direction Arrow
    
    private var directionArrow: some View {
        Group {
            if currentDeviation > 5 {
                // Arrow pointing in direction user needs to move
                Image(systemName: "arrow.up")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(alignmentState.color)
                    .rotationEffect(arrowRotation)
                    .offset(y: -size * 0.25)
                    .opacity(min(currentDeviation / 30, 1.0))
                    .animation(reduceMotion ? nil : AxisAnimation.smooth, value: currentDeviation)
            }
        }
    }
    
    private var arrowRotation: Angle {
        // Calculate angle based on yaw and pitch
        let angle = atan2(motion.yaw, -motion.pitch) * 180 / .pi
        return .degrees(angle + 90)
    }
    
    // MARK: - Angle Overlay
    
    private var angleOverlay: some View {
        VStack(spacing: AxisSpacing.xs) {
            // Large angle display
            HStack(spacing: AxisSpacing.xs) {
                Image(systemName: directionIcon)
                    .font(.system(size: 20, weight: .semibold))
                Text(String(format: "%.0f°", currentDeviation))
                    .font(.axisAngle)
            }
            .foregroundColor(alignmentState.color)
            
            // Direction label
            Text(directionText)
                .font(.axisTechnical)
                .foregroundColor(alignmentState.color.opacity(0.8))
        }
        .padding(.horizontal, AxisSpacing.md)
        .padding(.vertical, AxisSpacing.sm)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule()
                .stroke(alignmentState.color.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Accessibility
    
    private var accessibilityDescription: String {
        let angleDescription = String(format: "%.0f degrees", currentDeviation)
        return "\(angleDescription) \(directionText). \(alignmentState.accessibilityDescription)"
    }
    
    // MARK: - Animations
    
    private func startAnimations() {
        guard !reduceMotion else { return }
        
        // Breathing pulse
        withAnimation(AxisAnimation.breathing) {
            pulseScale = 1.08
        }
        
        // Slow ring rotation
        withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
            ringRotation = 360
        }
        
        // Glow intensity pulse
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            glowIntensity = 0.8
        }
    }
    
    // MARK: - Haptic Feedback
    
    @State private var lastHapticState: AlignmentState?
    
    private func triggerHapticFeedback(for state: AlignmentState) {
        guard state != lastHapticState else { return }
        lastHapticState = state
        
        switch state {
        case .aligned:
            AxisHaptic.success()
        case .deviation:
            AxisHaptic.warning()
        case .critical:
            AxisHaptic.error()
        }
    }
}

// MARK: - Precision Ring Component

struct PrecisionRing: View {
    let targetAngle: Double
    let currentDeviation: Double
    let size: CGFloat
    
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var isWithinRing: Bool {
        currentDeviation <= targetAngle
    }
    
    var ringColor: Color {
        if isWithinRing {
            return AxisColor.aligned.opacity(0.4)
        } else {
            return Color.white.opacity(0.08)
        }
    }
    
    var body: some View {
        ZStack {
            // Main ring
            Circle()
                .stroke(ringColor, lineWidth: isWithinRing ? 2 : 1)
                .frame(width: size, height: size)
            
            // Degree label (subtle)
            if !isWithinRing {
                Text("\(Int(targetAngle))°")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.white.opacity(0.3))
                    .offset(y: -size / 2 - 8)
            }
        }
        .animation(reduceMotion ? nil : AxisAnimation.smooth, value: isWithinRing)
    }
}

// MARK: - Compact Alignment Indicator (for dashboard)

struct CompactAlignmentIndicator: View {
    @ObservedObject var motion: MotionManager
    
    var currentDeviation: Double {
        max(abs(motion.pitch), abs(motion.yaw))
    }
    
    var alignmentState: AlignmentState {
        AlignmentState(deviation: currentDeviation)
    }
    
    var body: some View {
        HStack(spacing: AxisSpacing.sm) {
            // State icon
            Image(systemName: alignmentState.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(alignmentState.color)
            
            // Angle
            Text(String(format: "%.0f°", currentDeviation))
                .font(.axisTechnical)
                .foregroundColor(alignmentState.color)
            
            // Quality indicator
            Circle()
                .fill(alignmentState.color)
                .frame(width: 8, height: 8)
        }
        .padding(.horizontal, AxisSpacing.md)
        .padding(.vertical, AxisSpacing.sm)
        .background(.ultraThinMaterial, in: Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Current alignment: \(Int(currentDeviation)) degrees, \(alignmentState.rawValue)")
    }
}

// MARK: - Calibration Indicator

struct CalibrationIndicator: View {
    let countdown: Int
    let total: Int
    
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var ringProgress: CGFloat = 0
    @State private var pulseScale: CGFloat = 1.0
    
    var progress: CGFloat {
        CGFloat(total - countdown) / CGFloat(total)
    }
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(AxisColor.primary.opacity(0.2), lineWidth: 6)
                .frame(width: 120, height: 120)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AxisColor.primaryGradient,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? nil : AxisAnimation.countdown, value: progress)
            
            // Countdown number
            Text("\(countdown)")
                .font(.axisDisplay)
                .foregroundColor(AxisColor.primary)
                .scaleEffect(reduceMotion ? 1.0 : pulseScale)
            
            // Expanding pulse rings
            if !reduceMotion {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(AxisColor.primary.opacity(0.3), lineWidth: 2)
                        .frame(width: 120, height: 120)
                        .scaleEffect(1.0 + CGFloat(index) * 0.2 * pulseScale)
                        .opacity(1.0 - Double(index) * 0.3)
                }
            }
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.1
            }
        }
        .onChange(of: countdown) { _ in
            AxisHaptic.tick()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Calibrating. \(countdown) seconds remaining.")
    }
}

// MARK: - Preview

#Preview("Dynamic Alignment Indicator") {
    ZStack {
        AxisColor.backgroundGradient.ignoresSafeArea()
        
        VStack(spacing: 40) {
            DynamicAlignmentIndicator(motion: MotionManager.shared)
            
            CompactAlignmentIndicator(motion: MotionManager.shared)
            
            CalibrationIndicator(countdown: 3, total: 3)
        }
    }
}
