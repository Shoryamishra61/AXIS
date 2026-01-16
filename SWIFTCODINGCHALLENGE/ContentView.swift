// ContentView.swift
// Axis - The Invisible Posture Companion
// Premium Home Dashboard for Swift Student Challenge 2026

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @ObservedObject private var motion = MotionManager.shared
    
    @State private var showAbout = false
    @State private var orbScale: CGFloat = 1.0
    @State private var orbRotation: Double = 0
    @State private var showSensorInfo = false
    
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        ZStack {
            // Background
            AxisColor.backgroundGradient.ignoresSafeArea()
            
            // Ambient background glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AxisColor.primary.opacity(0.12),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 400
                    )
                )
                .blur(radius: 60)
                .offset(y: -100)
                .allowsHitTesting(false)
            
            VStack(spacing: 0) {
                // Header with info button
                headerBar
                
                Spacer()
                
                // Central hero section
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
            startAnimations()
        }
    }
    
    // MARK: - Header Bar
    
    private var headerBar: some View {
        HStack {
            // Sensor status (subtle)
            if motion.isConnected {
                Button {
                    showSensorInfo.toggle()
                } label: {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(motion.connectionQuality == .excellent ? AxisColor.success : AxisColor.warning)
                            .frame(width: 6, height: 6)
                        
                        Text(motion.activeSource)
                            .font(.axisCaption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                }
                .popover(isPresented: $showSensorInfo) {
                    sensorInfoPopover
                }
            }
            
            Spacer()
            
            // About button
            Button {
                showAbout = true
                AxisHaptic.tick()
            } label: {
                Image(systemName: "info.circle")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .padding(12)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .accessibilityLabel("About Axis")
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(spacing: 32) {
            // Animated orb
            ZStack {
                // Outer glow rings
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(
                            AxisColor.primary.opacity(0.15 - Double(index) * 0.04),
                            lineWidth: 1.5
                        )
                        .frame(
                            width: 220 + CGFloat(index) * 30,
                            height: 220 + CGFloat(index) * 30
                        )
                        .scaleEffect(reduceMotion ? 1.0 : orbScale - CGFloat(index) * 0.02)
                }
                
                // Main glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AxisColor.primary.opacity(0.5),
                                AxisColor.secondary.opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .blur(radius: 30)
                    .scaleEffect(reduceMotion ? 1.0 : orbScale)
                
                // Center content
                VStack(spacing: 12) {
                    Text("Axis")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text("Zero-context mobility.")
                        .font(.axisInstruction)
                        .foregroundStyle(.secondary)
                }
            }
            .onTapGesture {
                coordinator.startSetup()
                AxisHaptic.tap()
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Axis. Zero-context mobility. Tap to start session")
            .accessibilityAddTraits(.isButton)
            
            // Tagline
            Text("Relieve neck stiffness in minutes")
                .font(.axisCaption)
                .foregroundStyle(.tertiary)
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            // Primary: Start Session
            Button {
                coordinator.startSetup()
                AxisHaptic.tap()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "airpods.pro")
                        .font(.title3)
                    Text("Start Session")
                        .font(.axisButton)
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(AxisColor.buttonGradient, in: Capsule())
                .shadow(color: AxisColor.primary.opacity(0.4), radius: 20, y: 10)
            }
            .accessibilityLabel("Start Mobility Session")
            
            // Secondary: Check Alignment
            Button {
                coordinator.appState = .alignmentCheck
                AxisHaptic.tick()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "camera.viewfinder")
                    Text("Check Alignment")
                }
                .font(.axisButton)
                .foregroundStyle(.primary)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial, in: Capsule())
            }
            .accessibilityLabel("Open Camera Mirror to check posture alignment")
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 50)
    }
    
    // MARK: - Sensor Info Popover
    
    private var sensorInfoPopover: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sensor Status")
                .font(.axisButton)
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "Source", value: motion.activeSource)
                InfoRow(label: "Quality", value: motion.connectionQuality.rawValue)
                InfoRow(label: "Calibrated", value: motion.isCalibrated ? "Yes" : "No")
            }
            
            Divider()
            
            Text("AirPods Pro/Max provide the most accurate head tracking.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(width: 250)
        .presentationCompactAdaptation(.popover)
    }
    
    // MARK: - Animations
    
    private func startAnimations() {
        guard !reduceMotion else { return }
        
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            orbScale = 1.08
        }
        
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            orbRotation = 360
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
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.axisTechnical)
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(AppCoordinator())
}
