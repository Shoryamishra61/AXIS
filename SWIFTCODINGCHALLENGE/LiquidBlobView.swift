// LiquidBlobView.swift
// Axis - The Invisible Posture Companion
// Premium Liquid Visualizer for Swift Student Challenge 2026
//
// A stunning, mesmerizing visual that responds to head movement
// Designed to feel alive, organic, and deeply satisfying

import SwiftUI

// MARK: - Main Liquid Blob View
struct LiquidBlobView: View {
    // Motion input from sensors
    var pitch: Double
    var yaw: Double
    var isInTargetZone: Bool = false
    
    // Animation state
    @State private var breathPhase: CGFloat = 0
    @State private var morphPhase: CGFloat = 0
    @State private var glowPhase: CGFloat = 0
    @State private var particlePhase: CGFloat = 0
    @State private var rotationAngle: CGFloat = 0
    
    // Accessibility
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    // Computed states
    private var motionMagnitude: Double {
        sqrt(pitch * pitch + yaw * yaw)
    }
    
    private var normalizedError: Double {
        min(motionMagnitude / 45.0, 1.0)
    }
    
    private var stateColor: Color {
        if isInTargetZone {
            return AxisColor.success
        } else if normalizedError < 0.3 {
            return AxisColor.primary
        } else if normalizedError < 0.6 {
            return AxisColor.warning
        } else {
            return AxisColor.danger
        }
    }
    
    private var secondaryColor: Color {
        if isInTargetZone {
            return AxisColor.calm
        } else {
            return AxisColor.secondary
        }
    }
    
    // Brightness boost for visibility
    private var glowOpacity: Double {
        isInTargetZone ? 0.35 : 0.25
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            
            ZStack {
                // Layer 1: Deep ambient background glow
                ambientGlow(size: size)
                
                // Layer 2: Outer pulsing rings
                pulsingRings(size: size)
                
                // Layer 3: Floating particles
                if !reduceMotion {
                    floatingParticles(size: size)
                }
                
                // Layer 4: Main organic blob
                mainBlob(size: size)
                
                // Layer 5: Inner highlight/shine
                innerHighlight(size: size)
                
                // Layer 6: Success celebration overlay
                if isInTargetZone {
                    successOverlay(size: size)
                }
                
                // Layer 7: Motion-reactive energy field
                if motionMagnitude > 5 && !reduceMotion {
                    energyField(size: size)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .onAppear(perform: startAnimations)
        .accessibilityLabel(accessibilityDescription)
    }
    
    // MARK: - Layer 1: Ambient Glow
    private func ambientGlow(size: CGFloat) -> some View {
        ZStack {
            // Deep outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            stateColor.opacity(glowOpacity),
                            stateColor.opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: size * 0.1,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size * 1.4, height: size * 1.4)
                .blur(radius: 40)
                .scaleEffect(1.0 + 0.08 * sin(glowPhase))
            
            // Secondary pulsing glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            secondaryColor.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: size * 0.05,
                        endRadius: size * 0.45
                    )
                )
                .frame(width: size * 1.2, height: size * 1.2)
                .blur(radius: 30)
                .scaleEffect(1.0 + 0.05 * sin(glowPhase * 1.3 + .pi / 4))
        }
    }
    
    // MARK: - Layer 2: Pulsing Rings
    private func pulsingRings(size: CGFloat) -> some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(
                        stateColor.opacity(0.15 - Double(index) * 0.04),
                        lineWidth: 1.5
                    )
                    .frame(
                        width: size * (0.7 + CGFloat(index) * 0.15 + 0.05 * sin(breathPhase + CGFloat(index) * 0.8)),
                        height: size * (0.7 + CGFloat(index) * 0.15 + 0.05 * sin(breathPhase + CGFloat(index) * 0.8))
                    )
                    .opacity(reduceMotion ? 0.3 : 1.0)
            }
        }
    }
    
    // MARK: - Layer 3: Floating Particles
    private func floatingParticles(size: CGFloat) -> some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let particleCount = 24
            
            for i in 0..<particleCount {
                let angle = (CGFloat(i) / CGFloat(particleCount)) * .pi * 2 + particlePhase * 0.3
                let radiusVariation = sin(particlePhase * 0.5 + CGFloat(i) * 0.5) * 20
                let radius = size * 0.35 + radiusVariation + CGFloat(motionMagnitude) * 0.8
                
                let x = center.x + cos(angle) * radius
                let y = center.y + sin(angle) * radius
                
                let particleSize = 2.5 as CGFloat + 2.0 * sin(particlePhase + CGFloat(i))
                let particleRect = CGRect(
                    x: x - particleSize / 2,
                    y: y - particleSize / 2,
                    width: particleSize,
                    height: particleSize
                )
                
                // Particle glow
                context.addFilter(.blur(radius: 4))
                context.fill(
                    Path(ellipseIn: particleRect.insetBy(dx: -3, dy: -3)),
                    with: .color(stateColor.opacity(0.4))
                )
                
                // Particle core
                context.addFilter(.blur(radius: 0))
                context.fill(
                    Path(ellipseIn: particleRect),
                    with: .color(.white.opacity(0.8))
                )
            }
        }
        .allowsHitTesting(false)
    }
    
    // MARK: - Layer 4: Main Organic Blob
    private func mainBlob(size: CGFloat) -> some View {
        TimelineView(.animation(minimumInterval: 1/60)) { timeline in
            Canvas { context, canvasSize in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
                
                // Motion offset (blob follows head movement)
                let offsetX = CGFloat(yaw) * 1.2
                let offsetY = CGFloat(-pitch) * 1.2
                let blobCenter = CGPoint(x: center.x + offsetX, y: center.y + offsetY)
                
                // Breathing effect
                let breathScale = 1.0 + 0.06 * sin(CGFloat(time) * 0.8)
                let baseRadius = size * 0.28 * breathScale
                
                // Create organic blob path
                let blobPath = createOrganicBlobPath(
                    center: blobCenter,
                    baseRadius: baseRadius,
                    time: time,
                    motionMagnitude: motionMagnitude
                )
                
                // Multi-layer fill for depth
                // Layer A: Outer glow
                context.addFilter(.blur(radius: 25))
                context.fill(blobPath, with: .color(stateColor.opacity(0.5)))
                
                // Layer B: Mid glow
                context.addFilter(.blur(radius: 12))
                context.fill(blobPath, with: .color(stateColor.opacity(0.6)))
                
                // Layer C: Main fill with gradient
                context.addFilter(.blur(radius: 0))
                let gradient = Gradient(colors: [
                    stateColor.opacity(0.95),
                    secondaryColor.opacity(0.85),
                    stateColor.opacity(0.75)
                ])
                context.fill(blobPath, with: .radialGradient(
                    gradient,
                    center: CGPoint(x: blobCenter.x - baseRadius * 0.3, y: blobCenter.y - baseRadius * 0.3),
                    startRadius: 0,
                    endRadius: baseRadius * 1.3
                ))
                
                // Layer D: Edge definition
                context.stroke(
                    blobPath,
                    with: .linearGradient(
                        Gradient(colors: [
                            .white.opacity(0.4),
                            stateColor.opacity(0.3),
                            .white.opacity(0.2)
                        ]),
                        startPoint: CGPoint(x: blobCenter.x - baseRadius, y: blobCenter.y - baseRadius),
                        endPoint: CGPoint(x: blobCenter.x + baseRadius, y: blobCenter.y + baseRadius)
                    ),
                    lineWidth: 2.0
                )
            }
        }
        .allowsHitTesting(false)
    }
    
    // MARK: - Layer 5: Inner Highlight
    private func innerHighlight(size: CGFloat) -> some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let offsetX = CGFloat(yaw) * 1.2
            let offsetY = CGFloat(-pitch) * 1.2
            
            // Specular highlight (glass-like reflection)
            let highlightCenter = CGPoint(
                x: center.x + offsetX - size * 0.08,
                y: center.y + offsetY - size * 0.1
            )
            let highlightRadius = size * 0.12
            
            let highlightPath = Path(ellipseIn: CGRect(
                x: highlightCenter.x - highlightRadius,
                y: highlightCenter.y - highlightRadius * 0.6,
                width: highlightRadius * 2,
                height: highlightRadius * 1.2
            ))
            
            context.addFilter(.blur(radius: 8))
            context.fill(highlightPath, with: .color(.white.opacity(0.35)))
            
            // Secondary smaller highlight
            let smallHighlightCenter = CGPoint(
                x: center.x + offsetX + size * 0.06,
                y: center.y + offsetY + size * 0.08
            )
            let smallHighlightRadius = size * 0.04
            
            let smallHighlightPath = Path(ellipseIn: CGRect(
                x: smallHighlightCenter.x - smallHighlightRadius,
                y: smallHighlightCenter.y - smallHighlightRadius,
                width: smallHighlightRadius * 2,
                height: smallHighlightRadius * 2
            ))
            
            context.addFilter(.blur(radius: 4))
            context.fill(smallHighlightPath, with: .color(.white.opacity(0.25)))
        }
        .allowsHitTesting(false)
    }
    
    // MARK: - Layer 6: Success Overlay
    private func successOverlay(size: CGFloat) -> some View {
        ZStack {
            // Celebration pulse rings
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(
                        AxisColor.success.opacity(0.3 - Double(index) * 0.08),
                        lineWidth: 2
                    )
                    .frame(
                        width: size * (0.5 + CGFloat(index) * 0.12),
                        height: size * (0.5 + CGFloat(index) * 0.12)
                    )
                    .scaleEffect(1.0 + 0.15 * sin(glowPhase * 2 + CGFloat(index)))
            }
            
            // Success shimmer
            Circle()
                .fill(
                    AngularGradient(
                        colors: [
                            AxisColor.success.opacity(0.3),
                            Color.clear,
                            AxisColor.calm.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startAngle: .degrees(Double(rotationAngle) * 45.0),
                        endAngle: .degrees(Double(rotationAngle) * 45.0 + 360.0)
                    )
                )
                .frame(width: size * 0.7, height: size * 0.7)
                .blur(radius: 15)
        }
    }
    
    // MARK: - Layer 7: Energy Field
    private func energyField(size: CGFloat) -> some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let intensity = min(motionMagnitude / 30.0, 1.0)
            let fieldCount = 5
            
            for i in 0..<fieldCount {
                let angle = CGFloat(i) / CGFloat(fieldCount) * .pi * 2 + morphPhase
                let stretch = 1.0 + intensity * 0.5 // Double
                
                // Direction of motion
                let motionAngle = atan2(CGFloat(pitch), CGFloat(yaw)) // explicit CGFloat inputs
                let alignedAngle = angle + motionAngle
                
                let length = size * 0.3 * CGFloat(intensity) * CGFloat(stretch)
                let startRadius = size * 0.25
                
                let startX = center.x + cos(alignedAngle) * startRadius
                let startY = center.y + sin(alignedAngle) * startRadius
                let endX = startX + cos(alignedAngle) * length
                let endY = startY + sin(alignedAngle) * length
                
                var path = Path()
                path.move(to: CGPoint(x: startX, y: startY))
                path.addLine(to: CGPoint(x: endX, y: endY))
                
                context.stroke(
                    path,
                    with: .linearGradient(
                        Gradient(colors: [
                            stateColor.opacity(0.6),
                            stateColor.opacity(0.1)
                        ]),
                        startPoint: CGPoint(x: startX, y: startY),
                        endPoint: CGPoint(x: endX, y: endY)
                    ),
                    lineWidth: 2.5
                )
            }
        }
        .blur(radius: 2)
        .allowsHitTesting(false)
    }
    
    // MARK: - Organic Blob Path Generator
    private func createOrganicBlobPath(
        center: CGPoint,
        baseRadius: CGFloat,
        time: TimeInterval,
        motionMagnitude: Double
    ) -> Path {
        var path = Path()
        let pointCount = 64
        let motionInfluence = CGFloat(min(motionMagnitude / 30.0, 1.0))
        
        for i in 0...pointCount {
            let angle = CGFloat(i) / CGFloat(pointCount) * .pi * 2
            
            // Multi-frequency noise for organic deformation
            let noise1 = sin(angle * 3.0 + CGFloat(time) * 0.9) * 10.0
            let noise2 = cos(angle * 5.0 - CGFloat(time) * 0.6) * 7.0
            let noise3 = sin(angle * 7.0 + CGFloat(time) * 0.4) * 4.0
            let noise4 = cos(angle * 2.0 + CGFloat(time) * 1.1) * 6.0
            
            // Motion reactivity
            let motionNoise = sin(angle * 4.0 + CGFloat(time) * 2.0) * 5.0 * motionInfluence
            
            let totalNoise = noise1 + noise2 + noise3 + noise4 + motionNoise
            let radius = baseRadius + totalNoise
            
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.closeSubpath()
        return path
    }
    
    // MARK: - Animation Start
    private func startAnimations() {
        guard !reduceMotion else { return }
        
        withAnimation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true)) {
            breathPhase = .pi * 2
        }
        
        withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
            glowPhase = .pi * 2
        }
        
        withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
            morphPhase = .pi * 2
        }
        
        withAnimation(.linear(duration: 12.0).repeatForever(autoreverses: false)) {
            particlePhase = .pi * 4
        }
        
        withAnimation(.linear(duration: 20.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
    }
    
    // MARK: - Accessibility
    private var accessibilityDescription: String {
        if isInTargetZone {
            return "Alignment achieved. The visualization shows perfect posture."
        } else if normalizedError < 0.3 {
            return "Good alignment. Minor adjustment needed."
        } else if normalizedError < 0.6 {
            return "Moderate correction needed. Adjust your head position."
        } else {
            return "Significant correction needed. Follow the voice guidance."
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack {
            // Normal state
            LiquidBlobView(pitch: 5, yaw: 3, isInTargetZone: false)
                .frame(width: 300, height: 300)
            
            // Success state
            LiquidBlobView(pitch: 0, yaw: 0, isInTargetZone: true)
                .frame(width: 300, height: 300)
        }
    }
}
