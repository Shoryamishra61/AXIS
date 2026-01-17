// ExerciseVisualizer.swift
// Axis - The Invisible Posture Companion
// Mode-Adaptive Exercise Visualization for Swift Student Challenge 2026

import SwiftUI

// MARK: - Exercise Visualizer (Mode-Adaptive)

struct ExerciseVisualizer: View {
    let mode: GuidanceMode
    let exercise: Exercise?
    let motion: MotionManager
    let isHolding: Bool
    let holdProgress: Double
    
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        switch mode {
        case .airpods:
            // Full blob visualization with motion tracking
            airpodsVisualizer
            
        case .audioOnly:
            // Simplified, calming visualization
            audioOnlyVisualizer
            
        case .camera:
            // Skeleton guide overlay style
            cameraVisualizer
        }
    }
    
    // MARK: - AirPods Mode Visualizer
    
    private var airpodsVisualizer: some View {
        ZStack {
            // Enhanced liquid blob
            LiquidBlobView(
                pitch: motion.pitch,
                yaw: motion.yaw,
                isInTargetZone: isHolding
            )
            .frame(width: 320, height: 320)
            
            // Progress ring when holding
            if isHolding {
                Circle()
                    .trim(from: 0, to: holdProgress)
                    .stroke(
                        LinearGradient(
                            colors: [AxisColor.success, AxisColor.calm],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: 280, height: 280)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: holdProgress)
                
                // Success pulse
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(AxisColor.success.opacity(0.3 - Double(i) * 0.1), lineWidth: 2)
                        .frame(width: 300 + CGFloat(i) * 20, height: 300 + CGFloat(i) * 20)
                        .scaleEffect(1.0 + holdProgress * 0.1)
                }
            }
            
            // Direction arrow when not at target
            if !isHolding, let exercise = exercise, exercise.isTracked {
                directionIndicator(for: exercise)
            }
        }
    }
    
    // MARK: - Audio Only Visualizer
    
    private var audioOnlyVisualizer: some View {
        ZStack {
            // Simple pulsing orb
            ForEach(0..<4, id: \.self) { i in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AxisColor.calm.opacity(0.4 - Double(i) * 0.08),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100 + CGFloat(i) * 30
                        )
                    )
                    .frame(width: 200 + CGFloat(i) * 60, height: 200 + CGFloat(i) * 60)
                    .blur(radius: CGFloat(i) * 5)
            }
            
            // Center circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [AxisColor.calm, AxisColor.primary.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
            
            // Audio wave icon
            Image(systemName: "waveform")
                .font(.system(size: 40, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
            
            // Progress ring
            if isHolding {
                Circle()
                    .trim(from: 0, to: holdProgress)
                    .stroke(AxisColor.success, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
            }
            
            // "Listen" badge
            VStack {
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "ear.fill")
                        .font(.system(size: 12))
                    Text("LISTEN & FOLLOW")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(AxisColor.calm)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(AxisColor.calm.opacity(0.15), in: Capsule())
            }
            .frame(height: 350)
        }
    }
    
    // MARK: - Camera Visualizer
    
    private var cameraVisualizer: some View {
        ZStack {
            // Skeleton silhouette
            GeometryReader { geo in
                // Head outline
                Circle()
                    .stroke(
                        isHolding ? AxisColor.success : AxisColor.secondary,
                        lineWidth: 3
                    )
                    .frame(width: 80, height: 80)
                    .position(x: geo.size.width / 2, y: 60)
                
                // Neck line
                Path { path in
                    path.move(to: CGPoint(x: geo.size.width / 2, y: 100))
                    path.addLine(to: CGPoint(x: geo.size.width / 2, y: 160))
                }
                .stroke(
                    isHolding ? AxisColor.success : AxisColor.secondary,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                
                // Shoulders
                Path { path in
                    path.move(to: CGPoint(x: geo.size.width / 2 - 80, y: 160))
                    path.addLine(to: CGPoint(x: geo.size.width / 2 + 80, y: 160))
                }
                .stroke(
                    isHolding ? AxisColor.success : AxisColor.secondary,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                
                // Alignment guides
                Path { path in
                    path.move(to: CGPoint(x: geo.size.width / 2, y: 20))
                    path.addLine(to: CGPoint(x: geo.size.width / 2, y: 200))
                }
                .stroke(
                    style: StrokeStyle(lineWidth: 1, dash: [8, 4])
                )
                .foregroundStyle(AxisColor.primary.opacity(0.4))
            }
            .frame(width: 280, height: 280)
            
            // Camera badge
            VStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    Text("POSE DETECTION")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AxisColor.secondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
                
                Spacer()
            }
            .frame(height: 350)
            
            // Progress overlay
            if isHolding {
                Circle()
                    .trim(from: 0, to: holdProgress)
                    .stroke(AxisColor.success, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 260, height: 260)
                    .rotationEffect(.degrees(-90))
            }
        }
    }
    
    // MARK: - Direction Indicator
    
    private func directionIndicator(for exercise: Exercise) -> some View {
        let currentValue = currentSensorValue(for: exercise)
        let targetValue = exercise.targetValue
        let diff = targetValue - currentValue
        
        return VStack {
            Spacer()
            
            HStack(spacing: 8) {
                // Arrow
                Image(systemName: arrowIcon(for: exercise, diff: diff))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AxisColor.deviation)
                
                // Text hint
                Text(directionText(for: exercise, diff: diff))
                    .font(.axisTechnical)
                    .foregroundColor(AxisColor.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
        }
        .frame(height: 400)
        .opacity(abs(diff) > exercise.tolerance ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.2), value: diff)
    }
    
    private func currentSensorValue(for exercise: Exercise) -> Double {
        switch exercise.targetAxis {
        case .pitch: return motion.pitch
        case .yaw: return motion.yaw
        case .roll: return motion.roll
        case .pitchYaw: return max(abs(motion.pitch), abs(motion.yaw))
        case .none: return 0
        }
    }
    
    private func arrowIcon(for exercise: Exercise, diff: Double) -> String {
        switch exercise.targetAxis {
        case .yaw:
            return diff > 0 ? "arrow.turn.up.left" : "arrow.turn.up.right"
        case .pitch:
            return diff > 0 ? "arrow.up" : "arrow.down"
        case .roll:
            return diff > 0 ? "arrow.counterclockwise" : "arrow.clockwise"
        default:
            return "arrow.up"
        }
    }
    
    private func directionText(for exercise: Exercise, diff: Double) -> String {
        switch exercise.targetAxis {
        case .yaw:
            return diff > 0 ? "Turn Left" : "Turn Right"
        case .pitch:
            return diff > 0 ? "Look Up" : "Look Down"
        case .roll:
            return diff > 0 ? "Tilt Left" : "Tilt Right"
        default:
            return "Adjust"
        }
    }
}

// MARK: - Compact Visualizer (for header/preview)

struct CompactExerciseVisualizer: View {
    let isActive: Bool
    let progress: Double
    let mode: GuidanceMode
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 3)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    mode.accentColor,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            // Mode icon
            Image(systemName: mode.icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isActive ? mode.accentColor : AxisColor.textTertiary)
        }
        .frame(width: 44, height: 44)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AxisColor.backgroundGradient.ignoresSafeArea()
        
        VStack(spacing: 40) {
            ExerciseVisualizer(
                mode: .airpods,
                exercise: nil,
                motion: MotionManager.shared,
                isHolding: false,
                holdProgress: 0.0
            )
            .frame(height: 350)
            
            ExerciseVisualizer(
                mode: .audioOnly,
                exercise: nil,
                motion: MotionManager.shared,
                isHolding: true,
                holdProgress: 0.6
            )
            .frame(height: 350)
        }
    }
}
