// GuidanceMode.swift
// Axis - The Invisible Posture Companion
// Guidance Mode Selection for Swift Student Challenge 2026

import SwiftUI

// MARK: - Guidance Mode Enum

enum GuidanceMode: String, CaseIterable, Codable {
    case audioOnly = "Audio Guided"
    case camera = "Camera Guided"
    case airpods = "AirPods Motion"
    
    var icon: String {
        switch self {
        case .audioOnly: return "waveform"
        case .camera: return "camera.viewfinder"
        case .airpods: return "airpodspro"
        }
    }
    
    var description: String {
        switch self {
        case .audioOnly:
            return "Voice instructions only. Perfect when sensors aren't available."
        case .camera:
            return "Visual pose detection using camera. See your alignment in real-time."
        case .airpods:
            return "Precise head tracking with AirPods Pro or Max. Most accurate."
        }
    }
    
    var shortDescription: String {
        switch self {
        case .audioOnly: return "Listen & follow"
        case .camera: return "See & correct"
        case .airpods: return "Sense & feel"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .audioOnly: return AxisColor.calm
        case .camera: return AxisColor.secondary
        case .airpods: return AxisColor.primary
        }
    }
    
    var requiresSensor: Bool {
        switch self {
        case .audioOnly: return false
        case .camera: return false
        case .airpods: return true
        }
    }
}

// MARK: - Guidance Mode Selector

struct GuidanceModeSelector: View {
    @Binding var selectedMode: GuidanceMode
    @ObservedObject var motion: MotionManager = .shared
    
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        VStack(alignment: .leading, spacing: AxisSpacing.md) {
            // Section header
            HStack(spacing: AxisSpacing.sm) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AxisColor.primary)
                Text("GUIDANCE MODE")
                    .font(.axisTechnical)
                    .foregroundColor(AxisColor.textSecondary)
            }
            
            // Mode cards
            VStack(spacing: AxisSpacing.sm) {
                ForEach(GuidanceMode.allCases, id: \.self) { mode in
                    modeCard(mode)
                }
            }
        }
    }
    
    // MARK: - Mode Card
    
    private func modeCard(_ mode: GuidanceMode) -> some View {
        let isSelected = selectedMode == mode
        // Use HONEST AirPods detection - only show as available if actually connected
        let isAirPodsAvailable = motion.isAirPodsActuallyConnected
        let isAvailable = !mode.requiresSensor || isAirPodsAvailable
        
        return Button {
            guard isAvailable else { return }
            selectedMode = mode
            AxisHaptic.selection()
        } label: {
            HStack(spacing: AxisSpacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(mode.accentColor.opacity(isSelected ? 0.2 : 0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: mode.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isSelected ? mode.accentColor : AxisColor.textSecondary)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: AxisSpacing.xs) {
                        Text(mode.rawValue)
                            .font(.axisButton)
                            .foregroundColor(isSelected ? AxisColor.textPrimary : AxisColor.textSecondary)
                        
                        // Recommended badge - ONLY show if AirPods actually connected
                        if mode == .airpods && isAirPodsAvailable {
                            Text("BEST")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AxisColor.primary, in: Capsule())
                        }
                        
                        // Unavailable indicator - honest status
                        if mode.requiresSensor && !isAirPodsAvailable {
                            Text("CONNECT AIRPODS")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(AxisColor.textTertiary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.1), in: Capsule())
                        }
                    }
                    
                    Text(mode.shortDescription)
                        .font(.axisCaption)
                        .foregroundColor(AxisColor.textTertiary)
                }
                
                Spacer()
                
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? mode.accentColor : Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    
                    if isSelected {
                        Circle()
                            .fill(mode.accentColor)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(AxisSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AxisRadius.lg)
                    .fill(Color.white.opacity(isSelected ? 0.08 : 0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: AxisRadius.lg)
                            .stroke(
                                isSelected ? mode.accentColor.opacity(0.5) : Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
            )
            .opacity(isAvailable ? 1.0 : 0.5)
        }
        .buttonStyle(.plain)
        .disabled(!isAvailable)
        .animation(reduceMotion ? nil : AxisAnimation.quick, value: isSelected)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(mode.rawValue). \(mode.shortDescription)")
        .accessibilityValue(isSelected ? "Selected" : "")
        .accessibilityHint(isAvailable ? "Double tap to select" : "Connect AirPods to enable")
    }
}

// MARK: - Compact Mode Indicator

struct CompactModeIndicator: View {
    let mode: GuidanceMode
    
    var body: some View {
        HStack(spacing: AxisSpacing.xs) {
            Image(systemName: mode.icon)
                .font(.system(size: 12))
            Text(mode.rawValue.uppercased())
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundColor(mode.accentColor)
        .padding(.horizontal, AxisSpacing.sm)
        .padding(.vertical, AxisSpacing.xs)
        .background(mode.accentColor.opacity(0.15), in: Capsule())
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AxisColor.backgroundGradient.ignoresSafeArea()
        
        VStack {
            GuidanceModeSelector(selectedMode: .constant(.airpods))
                .padding()
            
            HStack(spacing: 16) {
                CompactModeIndicator(mode: .audioOnly)
                CompactModeIndicator(mode: .camera)
                CompactModeIndicator(mode: .airpods)
            }
        }
    }
}
