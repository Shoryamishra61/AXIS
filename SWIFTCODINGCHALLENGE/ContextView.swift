// ContextView.swift
// Axis - The Invisible Posture Companion
// Context Selection with Auto-Detection for Swift Student Challenge 2026

import SwiftUI

struct ContextView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var activity = ActivityManager()
    
    @State private var selectedPosition = "Sitting"
    @State private var selectedDuration = 3.0
    @State private var showDurationPicker = false
    
    let positions = [
        ContextOption(name: "Sitting", icon: "chair.lounge.fill", description: "Desk, couch, or transit"),
        ContextOption(name: "Standing", icon: "figure.stand", description: "Alignment and balance"),
        ContextOption(name: "Lying Down", icon: "bed.double.fill", description: "Deep decompression")
    ]
    
    let durations: [Double] = [2, 3, 5, 7, 10]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AxisColor.backgroundGradient.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        // Auto-detection banner
                        detectionBanner
                        
                        // Guidance mode selection (NEW)
                        GuidanceModeSelector(selectedMode: $coordinator.selectedGuidanceMode)
                        
                        // Position selection
                        positionSection
                        
                        // Duration selection
                        durationSection
                        
                        // Wheelchair mode toggle
                        wheelchairToggle
                        
                        // Session preview
                        sessionPreview
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                // Bottom action button
                VStack {
                    Spacer()
                    startButton
                        .padding(.horizontal, 20)
                        .padding(.bottom, 34)
                        .background(
                            LinearGradient(
                                colors: [Color.clear, AxisColor.backgroundDark],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 120)
                            .allowsHitTesting(false),
                            alignment: .bottom
                        )
                }
            }
            .navigationTitle("Set Context")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        coordinator.returnHome()
                    }
                    .font(.axisButton)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .onAppear {
            activity.startActivityDetection()
            selectedPosition = activity.detectedContext
        }
        .onDisappear {
            activity.stopActivityDetection()
        }
    }
    
    // MARK: - Detection Banner
    
    private var detectionBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundStyle(AxisColor.primary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Auto-Detected")
                    .font(.axisCaption)
                    .foregroundStyle(.secondary)
                Text(activity.detectedContext.uppercased())
                    .font(.axisTechnical)
                    .foregroundStyle(AxisColor.primary)
            }
            
            Spacer()
            
            Button {
                selectedPosition = activity.detectedContext
                AxisHaptic.tick()
            } label: {
                Text("Use")
                    .font(.axisTechnical)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
        .padding(16)
        .background(AxisColor.primary.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AxisColor.primary.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Position Section
    
    private var positionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("CURRENT POSITION")
                .font(.axisCaption)
                .foregroundStyle(.secondary)
                .tracking(1)
            
            VStack(spacing: 10) {
                ForEach(positions, id: \.name) { option in
                    PositionCard(
                        option: option,
                        isSelected: selectedPosition == option.name
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedPosition = option.name
                        }
                        AxisHaptic.tick()
                    }
                }
            }
        }
    }
    
    // MARK: - Duration Section
    
    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("SESSION LENGTH")
                    .font(.axisCaption)
                    .foregroundStyle(.secondary)
                    .tracking(1)
                
                Spacer()
                
                Text("\(Int(selectedDuration)) min")
                    .font(.axisTitle)
                    .foregroundStyle(AxisColor.primary)
            }
            
            // Duration chips
            HStack(spacing: 10) {
                ForEach(durations, id: \.self) { duration in
                    DurationChip(
                        duration: duration,
                        isSelected: selectedDuration == duration
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedDuration = duration
                        }
                        AxisHaptic.tick()
                    }
                }
            }
            
            // Slider for fine control
            Slider(value: $selectedDuration, in: 2...10, step: 1)
                .tint(AxisColor.primary)
                .padding(.top, 4)
        }
    }
    
    // MARK: - Wheelchair Toggle
    
    private var wheelchairToggle: some View {
        HStack(spacing: 16) {
            Image(systemName: "figure.roll")
                .font(.title2)
                .foregroundStyle(coordinator.isWheelchairUser ? AxisColor.primary : .secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Wheelchair Mode")
                    .font(.axisButton)
                    .foregroundStyle(.primary)
                Text("Optimizes calibration and exercises for seated mobility.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $coordinator.isWheelchairUser)
                .tint(AxisColor.primary)
                .labelsHidden()
        }
        .padding(16)
        .background(Color.white.opacity(0.03), in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Wheelchair Mode. \(coordinator.isWheelchairUser ? "On" : "Off")")
    }
    
    // MARK: - Session Preview
    
    private var sessionPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SESSION PREVIEW")
                .font(.axisCaption)
                .foregroundStyle(.secondary)
                .tracking(1)
            
            let routine = ProtocolEngine.shared.generateRoutine(
                posture: selectedPosition,
                durationMinutes: selectedDuration,
                isWheelchair: coordinator.isWheelchairUser
            )
            
            HStack(spacing: 20) {
                PreviewStat(icon: "list.bullet", value: "\(routine.count)", label: "Exercises")
                PreviewStat(icon: "timer", value: "\(Int(selectedDuration))", label: "Minutes")
                PreviewStat(icon: "waveform", value: "\(routine.filter { $0.isTracked }.count)", label: "Tracked")
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - Start Button
    
    private var startButton: some View {
        Button {
            coordinator.startSession(posture: selectedPosition, duration: selectedDuration)
            AxisHaptic.tap()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "play.fill")
                    .font(.title3)
                Text("Begin Movement")
                    .font(.axisButton)
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(AxisColor.buttonGradient, in: Capsule())
            .shadow(color: AxisColor.primary.opacity(0.4), radius: 20, y: 10)
        }
        .accessibilityLabel("Begin \(Int(selectedDuration)) minute \(selectedPosition) session")
    }
}

// MARK: - Context Option Model

struct ContextOption {
    let name: String
    let icon: String
    let description: String
}

// MARK: - Position Card

struct PositionCard: View {
    let option: ContextOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: option.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? AxisColor.primary : .secondary)
                    .frame(width: 40)
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.name)
                        .font(.axisButton)
                        .foregroundStyle(isSelected ? .primary : .secondary)
                    Text(option.description)
                        .font(.axisCaption)
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? AxisColor.primary : Color.secondary.opacity(0.3))
                    .font(.title3)
            }
            .padding(16)
            .background(
                isSelected ? AxisColor.primary.opacity(0.1) : Color.white.opacity(0.03),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? AxisColor.primary.opacity(0.5) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Duration Chip

struct DurationChip: View {
    let duration: Double
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(Int(duration))")
                .font(.axisTechnical)
                .foregroundStyle(isSelected ? .black : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    isSelected ? AxisColor.primary : Color.white.opacity(0.05),
                    in: RoundedRectangle(cornerRadius: 12)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview Stat

struct PreviewStat: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AxisColor.primary)
            Text(label)
                .font(.axisCaption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    ContextView()
        .environmentObject(AppCoordinator())
}
