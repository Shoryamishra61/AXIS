// SplashScreenView.swift
// Axis - The Invisible Posture Companion
// Premium Animated Splash for Swift Student Challenge 2026
//
// First impression matters - this creates instant "wow" factor

import SwiftUI

struct SplashScreenView: View {
    var onComplete: () -> Void
    
    // Animation States
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0
    @State private var letterReveal: Int = 0
    @State private var glowIntensity: Double = 0
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 0
    @State private var taglineOpacity: Double = 0
    @State private var particlesActive: Bool = false
    @State private var backgroundPulse: Double = 0
    
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    private let logoText = "AXIS"
    
    var body: some View {
        ZStack {
            // Background
            backgroundLayer
            
            // Content
            VStack(spacing: 30) {
                Spacer()
                
                // Logo container
                ZStack {
                    // Outer rings
                    outerRings
                    
                    // Particle burst
                    if particlesActive && !reduceMotion {
                        ParticleBurstView()
                    }
                    
                    // Glow orb
                    glowOrb
                    
                    // Logo text with reveal
                    logoTextView
                }
                .frame(height: 200)
                
                // Tagline
                Text("Invisible Posture Guidance")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AxisColor.textSecondary, AxisColor.primary.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(taglineOpacity)
                
                Spacer()
                
                // Powered by badge
                poweredByBadge
                    .opacity(taglineOpacity)
                    .padding(.bottom, 60)
            }
        }
        .onAppear(perform: startAnimation)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Axis. Invisible Posture Guidance. Loading.")
    }
    
    // MARK: - Background Layer
    
    private var backgroundLayer: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.05),
                    Color(red: 0.05, green: 0.08, blue: 0.12),
                    Color(red: 0.02, green: 0.02, blue: 0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Ambient pulse
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AxisColor.primary.opacity(0.15 + backgroundPulse * 0.1),
                            AxisColor.secondary.opacity(0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 400
                    )
                )
                .blur(radius: 60)
                .offset(y: -50)
        }
    }
    
    // MARK: - Outer Rings
    
    private var outerRings: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                AxisColor.primary.opacity(0.3 - Double(index) * 0.08),
                                AxisColor.secondary.opacity(0.2 - Double(index) * 0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .frame(
                        width: 180 + CGFloat(index) * 50,
                        height: 180 + CGFloat(index) * 50
                    )
                    .scaleEffect(ringScale + CGFloat(index) * 0.05)
                    .opacity(ringOpacity - Double(index) * 0.15)
            }
        }
    }
    
    // MARK: - Glow Orb
    
    private var glowOrb: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AxisColor.primary.opacity(0.4 * glowIntensity),
                            AxisColor.secondary.opacity(0.2 * glowIntensity),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
                .blur(radius: 40)
            
            // Core glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AxisColor.primary.opacity(0.6 * glowIntensity),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
                .blur(radius: 20)
        }
    }
    
    // MARK: - Logo Text
    
    private var logoTextView: some View {
        HStack(spacing: 4) {
            ForEach(Array(logoText.enumerated()), id: \.offset) { index, character in
                Text(String(character))
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, AxisColor.primary],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(index < letterReveal ? 1 : 0)
                    .scaleEffect(index < letterReveal ? 1 : 0.5)
                    .offset(y: index < letterReveal ? 0 : 20)
                    .animation(
                        reduceMotion ? .none :
                            .spring(response: 0.5, dampingFraction: 0.7)
                            .delay(Double(index) * 0.08),
                        value: letterReveal
                    )
            }
        }
        .scaleEffect(logoScale)
        .opacity(logoOpacity)
    }
    
    // MARK: - Powered By Badge
    
    private var poweredByBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "applelogo")
                .font(.system(size: 14))
            Text("Swift Student Challenge 2026")
                .font(.system(size: 13, weight: .medium, design: .rounded))
        }
        .foregroundColor(AxisColor.textTertiary)
    }
    
    // MARK: - Animation Sequence
    
    private func startAnimation() {
        if reduceMotion {
            // Instant show for reduced motion
            logoScale = 1.0
            logoOpacity = 1.0
            letterReveal = logoText.count
            glowIntensity = 1.0
            ringScale = 1.0
            ringOpacity = 1.0
            taglineOpacity = 1.0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onComplete()
            }
            return
        }
        
        // Phase 1: Glow appears (0-0.3s)
        withAnimation(.easeOut(duration: 0.4)) {
            glowIntensity = 1.0
            backgroundPulse = 1.0
        }
        
        // Phase 2: Logo scales in (0.2-0.6s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
        
        // Phase 3: Letters reveal (0.4-0.8s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            letterReveal = logoText.count
            particlesActive = true
        }
        
        // Phase 4: Rings expand (0.5-1.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                ringScale = 1.0
                ringOpacity = 1.0
            }
        }
        
        // Phase 5: Tagline fades in (0.8-1.2s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.easeOut(duration: 0.4)) {
                taglineOpacity = 1.0
            }
        }
        
        // Phase 6: Transition out (2.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            AxisHaptic.success()
            onComplete()
        }
    }
}

// MARK: - Particle Burst View

struct ParticleBurstView: View {
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var scale: CGFloat
        var opacity: Double
        let color: Color
    }
    
    var body: some View {
        Canvas { context, size in
            for particle in particles {
                let rect = CGRect(
                    x: size.width / 2 + particle.x - 3,
                    y: size.height / 2 + particle.y - 3,
                    width: 6 * particle.scale,
                    height: 6 * particle.scale
                )
                
                context.addFilter(.blur(radius: 2))
                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(particle.color.opacity(particle.opacity))
                )
            }
        }
        .onAppear {
            createParticles()
            animateParticles()
        }
    }
    
    private func createParticles() {
        let colors: [Color] = [AxisColor.primary, AxisColor.secondary, .white, AxisColor.calm]
        
        for _ in 0..<24 {
            particles.append(Particle(
                x: 0,
                y: 0,
                scale: CGFloat.random(in: 0.5...1.5),
                opacity: 1.0,
                color: colors.randomElement() ?? AxisColor.primary
            ))
        }
    }
    
    private func animateParticles() {
        for i in particles.indices {
            let angle = CGFloat.random(in: 0...(.pi * 2))
            let distance = CGFloat.random(in: 80...160)
            
            withAnimation(.easeOut(duration: 1.2).delay(Double(i) * 0.02)) {
                particles[i].x = cos(angle) * distance
                particles[i].y = sin(angle) * distance
                particles[i].opacity = 0
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SplashScreenView(onComplete: {})
}
