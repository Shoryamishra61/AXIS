import SwiftUI

struct LiquidBlobView: View {
    var pitch: Double
    var yaw: Double
    
    @State private var breathing: CGFloat = 0
    @State private var lastOffset: CGPoint = .zero
    @State private var pulsePhase: CGFloat = 0
    @State private var particlePhase: CGFloat = 0
    @State private var rotationPhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            // MARK: Full Screen Background - NO BORDERS
            RadialGradient(
                colors: [
                    Color(red: 0.0, green: 0.35, blue: 0.45),
                    Color(red: 0.0, green: 0.25, blue: 0.35),
                    Color(red: 0.0, green: 0.15, blue: 0.25),
                    Color(red: 0.0, green: 0.08, blue: 0.15),
                    Color.black
                ],
                center: .center,
                startRadius: 50,
                endRadius: 700
            )
            .edgesIgnoringSafeArea(.all)
            
            TimelineView(.animation) { timeline in
                GeometryReader { geo in
                    Canvas { context, size in
                        
                        let centerPoint = CGPoint(
                            x: size.width / 2,
                            y: size.height / 2
                        )
                        
                        // MARK: Accuracy States
                        let error = max(abs(pitch), abs(yaw))
                        let calm = error < 8
                        let curious = error < 18
                        
                        // MARK: ENHANCED Position Tracking with Smoothing
                        let radius = min(size.width, size.height) * 0.42
                        let nx = CGFloat(yaw) / 40
                        let ny = CGFloat(-pitch) / 40
                        
                        var offset = CGPoint(x: nx * radius,
                                             y: ny * radius)
                        
                        let dist = hypot(offset.x, offset.y)
                        if dist > radius {
                            offset.x *= radius / dist
                            offset.y *= radius / dist
                        }
                        
                        // MARK: Velocity & Motion Response
                        let velocity = hypot(
                            offset.x - lastOffset.x,
                            offset.y - lastOffset.y
                        )
                        
                        let moveAngle = atan2(
                            offset.y - lastOffset.y,
                            offset.x - lastOffset.x
                        )
                        
                        lastOffset = offset
                        
                        // MARK: Dynamic Squash & Stretch
                        let stretchAmount = min(velocity * 0.008, 0.35)
                        let sx = 1 + stretchAmount * abs(cos(moveAngle))
                        let sy = 1 + stretchAmount * abs(sin(moveAngle))
                        
                        // MARK: Multi-Phase Animation
                        let breathe = 1 + 0.09 * sin(breathing)
                        let pulse = 1 + 0.05 * sin(pulsePhase * 1.8)
                        let base = min(size.width, size.height) * 0.45 * breathe * pulse
                        
                        let rect = CGRect(
                            x: centerPoint.x - base/2 + offset.x,
                            y: centerPoint.y - base/2 + offset.y,
                            width: base * sx,
                            height: base * sy
                        )
                        
                        // MARK: Dynamic Blob Shape
                        let blob = blobPath(
                            rect: rect,
                            phase: breathing,
                            velocity: velocity,
                            rotation: rotationPhase
                        )
                        
                        // MARK: State-Based Colors
                        let primary = calm ?
                            Color(red: 0.1, green: 0.95, blue: 0.85) :
                            curious ?
                            Color(red: 0.0, green: 0.85, blue: 0.95) :
                            Color(red: 1.0, green: 0.65, blue: 0.3)
                        
                        let secondary = calm ?
                            Color(red: 0.0, green: 0.75, blue: 0.9) :
                            curious ?
                            Color(red: 0.2, green: 0.5, blue: 1.0) :
                            Color(red: 1.0, green: 0.35, blue: 0.45)
                        
                        // MARK: Massive Outer Glow (Multiple Layers)
                        context.addFilter(.blur(radius: 120))
                        context.fill(blob, with: .color(primary.opacity(0.4)))
                        
                        context.addFilter(.blur(radius: 80))
                        context.fill(blob, with: .color(primary.opacity(0.35)))
                        
                        context.addFilter(.blur(radius: 50))
                        context.fill(blob, with: .color(secondary.opacity(0.3)))
                        
                        // MARK: Motion Trail
                        if velocity > 1.0 {
                            for i in 1...3 {
                                let trailOffset = CGFloat(i) * 15
                                let trailBlob = blobPath(
                                    rect: CGRect(
                                        x: rect.midX - base/2 - cos(moveAngle) * trailOffset,
                                        y: rect.midY - base/2 - sin(moveAngle) * trailOffset,
                                        width: base * 0.85,
                                        height: base * 0.85
                                    ),
                                    phase: breathing - CGFloat(i) * 0.3,
                                    velocity: 0,
                                    rotation: rotationPhase
                                )
                                context.fill(trailBlob, with: .color(
                                    primary.opacity(0.15 / CGFloat(i))
                                ))
                            }
                        }
                        
                        // MARK: Main Gradient Fill
                        let gradientCenter = CGPoint(
                            x: rect.midX - offset.x * 0.2,
                            y: rect.midY - offset.y * 0.2
                        )
                        
                        context.fill(blob, with: .radialGradient(
                            Gradient(colors: [
                                primary.opacity(1.0),
                                primary.opacity(0.95),
                                secondary.opacity(0.9),
                                secondary.opacity(0.7)
                            ]),
                            center: gradientCenter,
                            startRadius: 5,
                            endRadius: base * 0.9
                        ))
                        
                        // MARK: Inner Glow Enhancement
                        context.addFilter(.blur(radius: 30))
                        context.fill(blob, with: .color(primary.opacity(0.5)))
                        
                        // MARK: Specular Highlight
                        let highlightSize = base * 0.4
                        let highlightPath = blobPath(
                            rect: CGRect(
                                x: rect.minX + base * 0.2,
                                y: rect.minY + base * 0.15,
                                width: highlightSize,
                                height: highlightSize
                            ),
                            phase: breathing * 0.6,
                            velocity: 0,
                            rotation: 0
                        )
                        context.addFilter(.blur(radius: 15))
                        context.fill(highlightPath, with: .color(.white.opacity(0.35)))
                        
                        // MARK: Edge Definition
                        context.stroke(blob,
                                       with: .linearGradient(
                                        Gradient(colors: [
                                            .white.opacity(0.4),
                                            primary.opacity(0.3),
                                            .white.opacity(0.4)
                                        ]),
                                        startPoint: gradientCenter,
                                        endPoint: CGPoint(x: rect.maxX, y: rect.maxY)
                                       ),
                                       lineWidth: 2.5)
                        
                        // MARK: Particle System
                        drawParticles(
                            context: &context,
                            center: CGPoint(x: rect.midX, y: rect.midY),
                            phase: particlePhase,
                            calm: calm,
                            velocity: velocity,
                            primary: primary
                        )
                        
                        // MARK: Ripple Rings
                        drawRipples(
                            context: &context,
                            center: CGPoint(x: rect.midX, y: rect.midY),
                            phase: breathing,
                            radius: base * 0.6,
                            color: primary
                        )
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .allowsHitTesting(false)
            
            // MARK: Ambient Light Effects
            lightSweepOverlay
            lightSweepOverlay2
            radialLightPulse
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 5.0)
                .repeatForever(autoreverses: true)
            ) {
                breathing = .pi * 2
            }
            
            withAnimation(
                .easeInOut(duration: 3.5)
                .repeatForever(autoreverses: true)
            ) {
                pulsePhase = .pi * 2
            }
            
            withAnimation(
                .linear(duration: 10.0)
                .repeatForever(autoreverses: false)
            ) {
                particlePhase = .pi * 4
            }
            
            withAnimation(
                .linear(duration: 20.0)
                .repeatForever(autoreverses: false)
            ) {
                rotationPhase = .pi * 2
            }
        }
    }
}


// MARK: Ultra Organic Blob Path
func blobPath(rect: CGRect, phase: CGFloat, velocity: CGFloat, rotation: CGFloat) -> Path {
    var path = Path()
    let points = 18
    let r = rect.width / 2
    let cx = rect.midX
    let cy = rect.midY
    
    for i in 0...points {
        let baseAngle = CGFloat(i) / CGFloat(points) * .pi * 2
        let angle = baseAngle + rotation * 0.1
        
        // Complex multi-frequency noise for organic motion
        let noise = sin(angle * 3 + phase) * 16 +
                    cos(angle * 5 - phase * 0.7) * 10 +
                    sin(angle * 7 + phase * 0.5) * 6 +
                    cos(angle * 2 + phase * 1.2) * 8 +
                    sin(velocity * 15 + angle) * 4
        
        let x = cx + cos(angle) * (r + noise)
        let y = cy + sin(angle) * (r + noise)
        
        if i == 0 {
            path.move(to: CGPoint(x: x, y: y))
        } else {
            path.addLine(to: CGPoint(x: x, y: y))
        }
    }
    
    path.closeSubpath()
    return path
}


// MARK: Enhanced Particle System with Motion
func drawParticles(
    context: inout GraphicsContext,
    center: CGPoint,
    phase: CGFloat,
    calm: Bool,
    velocity: CGFloat,
    primary: Color
) {
    let particleCount = calm ? 16 : 20
    let baseRadius: CGFloat = calm ? 170 : 190
    
    for i in 0..<particleCount {
        let t = CGFloat(i) * (.pi * 2 / CGFloat(particleCount)) + phase * 0.4
        let orbitVariation = sin(t * 4 + phase) * 25
        let radius = baseRadius + orbitVariation + velocity * 5
        
        let x = center.x + cos(t) * radius
        let y = center.y + sin(t) * radius
        
        // Dynamic particle size
        let baseSize = CGFloat.random(in: 2.5...6)
        let r = baseSize * (1 + 0.4 * sin(phase * 1.5 + t))
        
        let rect = CGRect(x: x - r/2, y: y - r/2, width: r, height: r)
        
        // Particle glow
        context.addFilter(.blur(radius: 6))
        context.fill(
            Path(ellipseIn: rect),
            with: .color(primary.opacity(0.7))
        )
        
        // Particle core
        context.fill(
            Path(ellipseIn: rect),
            with: .color(.white.opacity(0.9))
        )
    }
}


// MARK: Ripple Effect
func drawRipples(
    context: inout GraphicsContext,
    center: CGPoint,
    phase: CGFloat,
    radius: CGFloat,
    color: Color
) {
    for i in 0..<3 {
        let rippleRadius = radius * 1.2 + CGFloat(i) * 40 + sin(phase + CGFloat(i)) * 15
        let opacity = 0.2 - CGFloat(i) * 0.05
        
        let ripplePath = Path(ellipseIn: CGRect(
            x: center.x - rippleRadius,
            y: center.y - rippleRadius,
            width: rippleRadius * 2,
            height: rippleRadius * 2
        ))
        
        context.stroke(
            ripplePath,
            with: .color(color.opacity(opacity)),
            lineWidth: 1.5
        )
    }
}


// MARK: Light Sweep Effects
var lightSweepOverlay: some View {
    LinearGradient(
        colors: [
            .clear,
            Color.cyan.opacity(0.12),
            .clear
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    .rotationEffect(.degrees(30))
    .blendMode(.screen)
    .edgesIgnoringSafeArea(.all)
    .allowsHitTesting(false)
}

var lightSweepOverlay2: some View {
    LinearGradient(
        colors: [
            .clear,
            Color(red: 0.0, green: 0.95, blue: 0.85).opacity(0.08),
            .clear
        ],
        startPoint: .bottomLeading,
        endPoint: .topTrailing
    )
    .rotationEffect(.degrees(-40))
    .blendMode(.screen)
    .edgesIgnoringSafeArea(.all)
    .allowsHitTesting(false)
}

var radialLightPulse: some View {
    RadialGradient(
        colors: [
            Color.cyan.opacity(0.06),
            .clear
        ],
        center: .center,
        startRadius: 100,
        endRadius: 400
    )
    .blendMode(.screen)
    .edgesIgnoringSafeArea(.all)
    .allowsHitTesting(false)
}
