// AXISLaunchAnimation.swift
// AXIS — Premium Launch Animation
// A sleek, minimalist "breathing orb" that expands and morphs into the
// AXIS wordmark, accompanied by a subtle haptic pulse. This creates a
// calm, premium, and modern health-tech vibe (similar to Apple Breathe).
// Uses modern Swift 6 structured concurrency (Task.sleep) instead of
// legacy DispatchQueue.main.asyncAfter.

import SwiftUI
import UIKit

struct AXISLaunchAnimation: View {

    let onFinished: () -> Void

    // ── Animation state ──────────────────────────────────────
    @State private var orbScale: CGFloat = 0.1
    @State private var orbOpacity: Double = 0.0
    @State private var showWordmark = false
    @State private var showTagline = false
    @State private var dismissing = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    // ── Breathing Orb ────────────────────────────
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AXISTheme.accent, AXISTheme.secondaryAccent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .blur(radius: showWordmark ? 40 : 10)
                        .scaleEffect(orbScale)
                        .opacity(orbOpacity)

                    // ── AXIS Wordmark ────────────────────────────
                    VStack(spacing: 8) {
                        Text("AXIS")
                            .font(.system(.largeTitle, design: .serif).bold())
                            .tracking(6)
                            .foregroundStyle(.primary)

                        Text("Cervical Alignment System")
                            .font(.subheadline.weight(.medium))
                            .tracking(3)
                            .foregroundStyle(.secondary)
                            .opacity(showTagline ? 1 : 0)
                            .offset(y: showTagline ? 0 : 10)
                    }
                    .opacity(showWordmark ? 1 : 0)
                    .scaleEffect(showWordmark ? 1.0 : 0.9)
                }

                Spacer()
            }
            .opacity(dismissing ? 0 : 1)
            .scaleEffect(dismissing ? 1.05 : 1.0)
        }
        .accessibilityLabel("AXIS Cervical Alignment System")
        .onAppear {
            if reduceMotion {
                onFinished()
                return
            }
            Task { @MainActor in
                await startSequence()
            }
        }
    }

    // ── Animation sequence (structured concurrency) ──────────
    @MainActor
    private func startSequence() async {
        // Phase 1: Orb fades in and expands (inhale)
        withAnimation(.easeOut(duration: 0.8)) {
            orbOpacity = 0.8
            orbScale = 1.0
        }

        // Trigger ghost haptic + primary pulse at peak
        try? await Task.sleep(for: .seconds(0.6))
        UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.3)
        try? await Task.sleep(for: .milliseconds(50))
        UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.8)

        // Phase 2: Orb diffuses, Wordmark appears
        try? await Task.sleep(for: .milliseconds(140))
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            orbScale = 2.5
            orbOpacity = 0.15
            showWordmark = true
        }
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()

        // Phase 3: Tagline slides up
        try? await Task.sleep(for: .milliseconds(300))
        withAnimation(.easeOut(duration: 0.4)) {
            showTagline = true
        }

        // Phase 4: Dismiss and transition to app
        try? await Task.sleep(for: .seconds(0.8))
        withAnimation(.easeInOut(duration: 0.4)) {
            dismissing = true
        }
        try? await Task.sleep(for: .milliseconds(400))
        onFinished()
    }
}
