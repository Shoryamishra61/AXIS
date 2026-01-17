// RootView.swift
// Axis - The Invisible Posture Companion
// Navigation Root with Onboarding for Swift Student Challenge 2026

import SwiftUI

struct RootView: View {
    @StateObject private var coordinator = AppCoordinator()
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var showSplash: Bool = true
    
    var body: some View {
        ZStack {
            // Global dark background (prevents white flashes)
            AxisColor.backgroundDark.ignoresSafeArea()
            
            // Check splash and onboarding status
            if showSplash {
                SplashScreenView(onComplete: {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showSplash = false
                    }
                })
                .transition(.opacity)
            } else if !coordinator.hasCompletedOnboarding {
                OnboardingView(hasCompletedOnboarding: $coordinator.hasCompletedOnboarding)
                    .transition(.opacity)
            } else {
                // Main app navigation
                mainContent
            }
        }
        .environmentObject(coordinator)
        .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.8), value: coordinator.appState)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.3), value: coordinator.hasCompletedOnboarding)
    }
    
    // MARK: - Main Content Switchboard
    
    @ViewBuilder
    private var mainContent: some View {
        switch coordinator.appState {
        case .idle:
            ContentView()
                .transition(.opacity)
            
        case .setup:
            ContextView()
                .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
            
        case .alignmentCheck:
            CameraView()
                .transition(.opacity)
            
        case .sessionRunning:
            SessionView(
                selectedPosture: coordinator.selectedPosture,
                selectedDuration: coordinator.selectedDuration
            )
            .transition(.opacity)
            
        case .summary:
            SummaryView()
                .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
        }
    }
}
