// ContentView.swift
// Axis - The Invisible Posture Companion
// Distinguished Winner Home Dashboard for Swift Student Challenge 2026
//
// First impression is everything. This screen must immediately convey:
// 1. What the app does (neck posture)
// 2. How it works (AirPods)
// 3. Why it's special (invisible guidance)

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @ObservedObject private var motion = MotionManager.shared
    
    @State private var showAbout = false
    @State private var orbScale: CGFloat = 1.0
    @State private var showSensorInfo = false
    @State private var isHeroPressed = false
    
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        ZStack {
            // Background
            AxisColor.backgroundGradient.ignoresSafeArea()
            
            // Ambient background glow
            ambientGlow
            
            VStack(spacing: 0) {
                // Header with sensor status and info
                headerBar
                
                Spacer()
                
                // Central hero section with live alignment
                heroSection
                
                Spacer()
                
                // Action buttons
                actionButtons
            }
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
        .onAppear {
            motion.startUpdates()
            motion.startConnectionMonitoring()
            startAnimations()
        }
        .onDisappear {
            motion.stopConnectionMonitoring()
        }
    }
    
    // MARK: - Ambient Glow
    
    private var ambientGlow: some View {
        Circle()
            .fill(AxisColor.ambientGradient)
            .blur(radius: 60)
            .offset(y: -100)
            .allowsHitTesting(false)
    }
    
    // MARK: - Header Bar
    
    private var headerBar: some View {
        HStack {
            // Sensor status indicator
            sensorStatusBadge
            
            Spacer()
            
            // About button
            Button {
                showAbout = true
                AxisHaptic.tick()
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(AxisColor.textSecondary)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
            .accessibilityLabel("About Axis")
            .accessibilityHint("Opens information about the app")
        }
        .padding(.horizontal, AxisSpacing.md)
        .padding(.top, AxisSpacing.lg)
    }
    
    // MARK: - Sensor Status Badge
    
    @ViewBuilder
    private var sensorStatusBadge: some View {
        if motion.isConnected {
            Button {
                showSensorInfo.toggle()
                AxisHaptic.selection()
            } label: {
                HStack(spacing: AxisSpacing.sm) {
                    // Status dot
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    
                    // Source name
                    Text(motion.activeSource)
                        .font(.axisTechnical)
                        .foregroundColor(AxisColor.textSecondary)
                    
                    // Quality indicator (optional)
                    if motion.connectionQuality == .excellent {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AxisColor.aligned)
                    }
                }
                .padding(.horizontal, AxisSpacing.md)
                .padding(.vertical, AxisSpacing.sm)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
            .popover(isPresented: $showSensorInfo) {
                sensorInfoPopover
            }
            .accessibilityLabel("Sensor status: \(motion.activeSource), quality \(motion.connectionQuality.rawValue)")
        } else {
            // No sensor connected hint
            HStack(spacing: AxisSpacing.sm) {
                Image(systemName: "airpods.pro")
                    .font(.system(size: 14))
                Text("Connect AirPods")
                    .font(.axisTechnical)
            }
            .foregroundColor(AxisColor.textTertiary)
            .padding(.horizontal, AxisSpacing.md)
            .padding(.vertical, AxisSpacing.sm)
            .background(.ultraThinMaterial, in: Capsule())
        }
    }
    
    private var statusColor: Color {
        switch motion.connectionQuality {
        case .excellent: return AxisColor.aligned
        case .good: return AxisColor.aligned.opacity(0.8)
        case .fair: return AxisColor.deviation
        case .poor: return AxisColor.critical
        case .unknown: return AxisColor.textTertiary
        }
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(spacing: AxisSpacing.xl) {
            // Dynamic hero orb (shows live alignment when connected)
            ZStack {
                // Outer breathing rings
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(
                            AxisColor.primary.opacity(0.12 - Double(index) * 0.03),
                            lineWidth: 1.5
                        )
                        .frame(
                            width: 220 + CGFloat(index) * 35,
                            height: 220 + CGFloat(index) * 35
                        )
                        .scaleEffect(reduceMotion ? 1.0 : orbScale - CGFloat(index) * 0.02)
                }
                
                // Main glow orb
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                currentOrbColor.opacity(0.5),
                                currentOrbColor.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 130
                        )
                    )
                    .frame(width: 260, height: 260)
                    .blur(radius: 35)
                    .scaleEffect(reduceMotion ? 1.0 : orbScale)
                
                // Inner orb with glass effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                currentOrbColor.opacity(0.2),
                                currentOrbColor.opacity(0.05),
                                Color.clear
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 140, height: 140)
                    .overlay(
                        Circle()
                            .stroke(currentOrbColor.opacity(0.3), lineWidth: 2)
                    )
                    .overlay(
                        // Specular highlight
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.white.opacity(0.4), Color.clear],
                                    center: .topLeading,
                                    startRadius: 0,
                                    endRadius: 50
                                )
                            )
                            .frame(width: 60, height: 60)
                            .offset(x: -25, y: -25)
                    )
                    // Subtle tilt based on current head position
                    .rotation3DEffect(
                        .degrees(reduceMotion ? 0 : motion.pitch * 0.2),
                        axis: (x: 1, y: 0, z: 0)
                    )
                    .rotation3DEffect(
                        .degrees(reduceMotion ? 0 : motion.yaw * 0.2),
                        axis: (x: 0, y: 1, z: 0)
                    )
                
                // Center content
                VStack(spacing: AxisSpacing.sm) {
                    Text("Axis")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(AxisColor.textPrimary)
                    
                    Text("Invisible posture guidance")
                        .font(.axisBody)
                        .foregroundColor(AxisColor.textSecondary)
                }
            }
            .scaleEffect(isHeroPressed ? 0.97 : 1.0)
            .animation(reduceMotion ? nil : AxisAnimation.quick, value: isHeroPressed)
            .onTapGesture {
                coordinator.startSetup()
                AxisHaptic.tap()
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isHeroPressed = true }
                    .onEnded { _ in isHeroPressed = false }
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Axis. Invisible posture guidance.")
            .accessibilityHint("Tap to start a mobility session")
            .accessibilityAddTraits(.isButton)
            
            // Live alignment preview (when connected)
            if motion.isConnected && motion.isCalibrated {
                CompactAlignmentIndicator(motion: motion)
                    .transition(.opacity.combined(with: .scale))
            }
            
            // Tagline
            Text("Relieve neck tension in minutes")
                .font(.axisCaption)
                .foregroundColor(AxisColor.textTertiary)
        }
    }
    
    private var currentOrbColor: Color {
        if motion.isConnected && motion.isCalibrated {
            // Show alignment state color when connected
            let deviation = max(abs(motion.pitch), abs(motion.yaw))
            return AxisColor.semantic(for: deviation)
        }
        return AxisColor.primary
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: AxisSpacing.md) {
            // Primary: Start Session
            AxisButton("Start Session", icon: "airpods.pro", style: .primary) {
                coordinator.startSetup()
            }
            .accessibilityHint("Begins guided posture exercises using your AirPods")
            
            // Secondary: Check Alignment
            AxisButton("Check Alignment", icon: "camera.viewfinder", style: .secondary) {
                coordinator.appState = .alignmentCheck
            }
            .accessibilityHint("Opens camera mirror to visually check your posture")
        }
        .padding(.horizontal, AxisSpacing.xl)
        .padding(.bottom, 50)
    }
    
    // MARK: - Sensor Info Popover
    
    private var sensorInfoPopover: some View {
        VStack(alignment: .leading, spacing: AxisSpacing.md) {
            // Header
            Text("Sensor Status")
                .font(.axisHeadline)
                .foregroundColor(AxisColor.textPrimary)
            
            Divider()
            
            // Details
            VStack(spacing: AxisSpacing.sm) {
                InfoRow(label: "Source", value: motion.activeSource)
                InfoRow(label: "Quality", value: motion.connectionQuality.rawValue)
                InfoRow(label: "Calibrated", value: motion.isCalibrated ? "Yes" : "No")
            }
            
            Divider()
            
            // Tip
            HStack(spacing: AxisSpacing.sm) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(AxisColor.deviation)
                Text("AirPods Pro or Max provide the most accurate head tracking.")
                    .font(.axisCaption)
                    .foregroundColor(AxisColor.textSecondary)
            }
        }
        .padding(AxisSpacing.lg)
        .frame(width: 280)
        .presentationCompactAdaptation(.popover)
    }
    
    // MARK: - Animations
    
    private func startAnimations() {
        guard !reduceMotion else { return }
        
        withAnimation(AxisAnimation.breathing) {
            orbScale = 1.06
        }
    }
}

// MARK: - Info Row Component

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.axisCaption)
                .foregroundColor(AxisColor.textSecondary)
            Spacer()
            Text(value)
                .font(.axisTechnical)
                .foregroundColor(AxisColor.textPrimary)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(AppCoordinator())
}
