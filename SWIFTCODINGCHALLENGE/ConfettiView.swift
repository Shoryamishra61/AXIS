// ConfettiView.swift
// Axis - The Invisible Posture Companion
// Celebration Effects for Swift Student Challenge 2026

import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var isAnimating = false
    
    let colors: [Color] = [
        AxisColor.primary,
        AxisColor.secondary,
        AxisColor.success,
        AxisColor.calm,
        .white
    ]
    
    var body: some View {
        Canvas { context, size in
            for particle in particles {
                let rect = CGRect(
                    x: particle.x,
                    y: particle.y,
                    width: particle.size,
                    height: particle.size * 1.5
                )
                
                context.rotate(by: .degrees(particle.rotation))
                context.fill(
                    RoundedRectangle(cornerRadius: 2).path(in: rect),
                    with: .color(particle.color.opacity(particle.opacity))
                )
                context.rotate(by: .degrees(-particle.rotation))
            }
        }
        .onAppear {
            createParticles()
            animateParticles()
        }
        .allowsHitTesting(false)
    }
    
    private func createParticles() {
        for _ in 0..<50 {
            particles.append(ConfettiParticle(
                x: CGFloat.random(in: 50...350),
                y: -20,
                size: CGFloat.random(in: 6...12),
                color: colors.randomElement() ?? AxisColor.primary,
                rotation: Double.random(in: 0...360),
                opacity: 1.0,
                velocityX: CGFloat.random(in: -3...3),
                velocityY: CGFloat.random(in: 4...8),
                rotationSpeed: Double.random(in: -10...10)
            ))
        }
    }
    
    private func animateParticles() {
        withAnimation(.linear(duration: 3.0)) {
            for i in particles.indices {
                particles[i].y += 800
                particles[i].x += particles[i].velocityX * 100
                particles[i].rotation += particles[i].rotationSpeed * 30
                particles[i].opacity = 0
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
    var rotation: Double
    var opacity: Double
    var velocityX: CGFloat
    var velocityY: CGFloat
    var rotationSpeed: Double
}

// MARK: - Success Burst Effect

struct SuccessBurstView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // Expanding ring 1
            Circle()
                .stroke(AxisColor.success.opacity(0.5), lineWidth: 4)
                .scaleEffect(scale)
                .opacity(opacity)
            
            // Expanding ring 2
            Circle()
                .stroke(AxisColor.calm.opacity(0.3), lineWidth: 2)
                .scaleEffect(scale * 0.7)
                .opacity(opacity)
            
            // Center flash
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white.opacity(0.8), AxisColor.success.opacity(0.4), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 50
                    )
                )
                .frame(width: 100, height: 100)
                .scaleEffect(scale * 0.5)
                .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                scale = 2.5
                opacity = 0
            }
        }
    }
}

// MARK: - Pulse Ring

struct PulseRingView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.8
    
    let color: Color
    let delay: Double
    
    var body: some View {
        Circle()
            .stroke(color, lineWidth: 2)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 1.5)
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    scale = 1.5
                    opacity = 0
                }
            }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ConfettiView()
    }
}
