// AxisSplineVisualizer.swift
// AXIS — Guided Visceral Spine Visualizer
// An abstract, Apple-premium visualizer for cervical alignment.
// Represents the spine as a stack of glowing vertebrae (glass-styled rounded rectangles).
// Mechanics:
//   • Pitch/Roll/Yaw exercises → Top of the spine bends in the direction of deviation.
//   • When inside the target zone, the spine perfectly stacks, turns teal/mint, and breathes gently.
//   • When highly deviated, the spine bends significantly and glows orange/amber warning colors.
//   • A subtle "ghost" spine represents perfect alignment, giving contextual significance.
//   • Progressive zone glow intensifies with sustained time in zone.
// Follows "Liquid Glass" principles.

import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: - Public API
// ─────────────────────────────────────────────────────────────

struct AxisSplineVisualizer: View {

    /// –1 … +1 normalised deviation from the exercise target.
    var deviation: Double

    /// True when the user is inside the tolerance zone.
    var isInGoodZone: Bool

    /// Current coaching phase — controls the spine's breathing pattern.
    var breathingPhase: BreathingPhase = .setup

    /// 0→1 overall session progress (calms the breathing over time).
    var sessionProgress: Double

    /// Which motion axis drives the orb direction.
    var motionAxis: MotionAxis = .pitch

    /// 0→1 progressive glow intensity based on sustained zone time.
    var zoneIntensity: Double = 0

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.016)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            GuidedOrbCanvas(
                deviation: deviation,
                isInGoodZone: isInGoodZone,
                breathingPhase: breathingPhase,
                sessionProgress: sessionProgress,
                motionAxis: motionAxis,
                zoneIntensity: zoneIntensity,
                time: t
            )
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.72), value: deviation)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isInGoodZone)
        .animation(.easeInOut(duration: 0.8), value: breathingPhase)
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Canvas Renderer
// ─────────────────────────────────────────────────────────────

private struct GuidedOrbCanvas: View {

    let deviation: Double
    let isInGoodZone: Bool
    let breathingPhase: BreathingPhase
    let sessionProgress: Double
    let motionAxis: MotionAxis
    let zoneIntensity: Double
    let time: Double

    // ── Derived colours ──────────────────────────────────────

    private var orbColor: Color {
        if isInGoodZone              { return AXISTheme.success }
        if abs(deviation) < 0.35     { return AXISTheme.accent }
        return AXISTheme.warning
    }

    var body: some View {
        Canvas { context, size in
            let cx = size.width  / 2

            // ── 1. Calculate overall curvature based on deviation ──
            let clamped = max(-1, min(1, deviation))
            let maxCurve: CGFloat = size.width * 0.35
            let curveOffset = CGFloat(clamped) * maxCurve

            // ── 2. Determine Spine Stack Parameters ──────────────────
            let numBlocks = 7
            let maxStackHeight = size.height * 0.75
            let blockHeight: CGFloat = (maxStackHeight * 0.6) / CGFloat(numBlocks)
            let blockWidth: CGFloat = size.width * 0.22
            let startY = size.height * 0.88 // Bottom of the stack

            // Target (Ghost) Spine Bezier Control Points (perfectly neutral)
            let n1 = CGPoint(x: cx, y: startY)
            let n2 = CGPoint(x: cx, y: size.height * 0.65)
            let n3 = CGPoint(x: cx, y: size.height * 0.4)
            let n4 = CGPoint(x: cx, y: size.height * 0.15)

            // Current Spine Bezier Control Points
            let p1 = n1
            var p2 = n2
            var p3 = n3
            var p4 = n4

            // Adjust X/Y curvature based on the active motion axis
            switch motionAxis {
            case .pitch:
                p2.x += curveOffset * 0.1
                p3.x += curveOffset * 0.6
                p4.x += curveOffset
            case .yaw, .roll:
                p2.x += curveOffset * 0.2
                p3.x += curveOffset * 0.7
                p4.x += curveOffset * 1.2
                p4.y += abs(curveOffset) * 0.2
            }

            var targetSpinePath = Path()
            targetSpinePath.move(to: n1)
            targetSpinePath.addCurve(to: n4, control1: n2, control2: n3)

            var spinePath = Path()
            spinePath.move(to: p1)
            spinePath.addCurve(to: p4, control1: p2, control2: p3)

            // ── 3. Draw Ghost Target Spine ───────────────────────────
            context.stroke(
                targetSpinePath,
                with: .color(Color(UIColor.tertiaryLabel).opacity(0.3)),
                style: StrokeStyle(lineWidth: blockWidth * 0.4, lineCap: .round, lineJoin: .round)
            )

            context.stroke(
                spinePath,
                with: .color(orbColor.opacity(0.12)),
                style: StrokeStyle(lineWidth: 6, lineCap: .round)
            )

            // ── 4. Draw Breathing Vertebrae Blocks (Liquid Glass) ────

            let breathAmp: Double
            let breathFreq: Double
            switch breathingPhase {
            case .setup:
                breathAmp = 0.04 * (1.0 - sessionProgress * 0.3)
                breathFreq = 1.8
            case .hold:
                breathAmp = 0.005
                breathFreq = 0.5
            case .release:
                breathAmp = 0.10
                breathFreq = 1.2
            }
            let breathe = 1.0 + sin(time * breathFreq) * breathAmp

            // Rolling Specular Highlight for the liquid effect
            let rollingHighlight = (sin(time * 1.8) + 1.0) / 2.0

            for i in 0..<numBlocks {
                let t = CGFloat(i) / CGFloat(numBlocks - 1)

                let centerPoint = calculateBezierPoint(t: t, p1: p1, p2: p2, p3: p3, p4: p4)

                let scaleW = 1.0 - (t * 0.35)
                let rectW = blockWidth * CGFloat(breathe) * scaleW
                let rectH = blockHeight * CGFloat(breathe)

                let blockRect = CGRect(x: centerPoint.x - rectW/2, y: centerPoint.y - rectH/2, width: rectW, height: rectH)
                let cornerRadius: CGFloat = rectH * 0.45

                let path = Path(roundedRect: blockRect, cornerRadius: cornerRadius)

                // --- Liquid Glass Layering ---

                // 1. Ambient Glow (Outer diffused light)
                let glowRect = blockRect.insetBy(dx: -8, dy: -8)
                let glowPath = Path(roundedRect: glowRect, cornerRadius: cornerRadius * 1.5)
                context.fill(glowPath, with: .color(orbColor.opacity(0.18)))

                // 2. Base Fill (Solid yet transparent glass block)
                context.fill(path, with: .color(orbColor.opacity(0.75)))

                // 3. Inner Volume (Soft gradient simulating depth)
                let gradient = Gradient(colors: [
                    Color.white.opacity(0.2),
                    Color.clear,
                    Color.black.opacity(0.15)
                ])
                context.fill(
                    path,
                    with: .linearGradient(
                        gradient,
                        startPoint: CGPoint(x: blockRect.minX, y: blockRect.minY),
                        endPoint: CGPoint(x: blockRect.maxX, y: blockRect.maxY)
                    )
                )

                // 4. Tight Specular Highlight
                let specWidth = rectW * 0.8
                let specHeight = rectH * 0.4
                let specRect = CGRect(
                    x: centerPoint.x - specWidth/2,
                    y: blockRect.minY + 1,
                    width: specWidth,
                    height: specHeight
                )
                let specPath = Path(roundedRect: specRect, cornerRadius: cornerRadius * 0.7)
                context.fill(specPath, with: .color(Color.white.opacity(0.45)))

                // Rolling Specular
                let rollOpacity = max(0, 1.0 - abs(rollingHighlight - Double(1.0 - t)) * 3.0)
                if rollOpacity > 0.05 {
                    context.fill(specPath, with: .color(Color.white.opacity(rollOpacity * 0.6)))
                }

                // 5. Crisp Glass Edge
                context.stroke(path, with: .color(Color.white.opacity(0.6)), lineWidth: 1.5)

                // 6. Progressive Zone Glow (intensifies with sustained zone time)
                if isInGoodZone {
                    let baseGlowStrength: Double
                    let glowSize: CGFloat

                    switch breathingPhase {
                    case .hold:
                        let pulse = 1.0 + sin(time * 0.5 - t * .pi * 0.5) * 0.08
                        baseGlowStrength = 0.08 * max(0.3, zoneIntensity) * max(0, (1.2 - pulse))
                        glowSize = 8 * CGFloat(max(1, pulse))
                    case .release:
                        let pulse = 1.0 + sin(time * 1.2 - t * .pi * 0.5) * 0.30
                        baseGlowStrength = 0.14 * max(0.3, zoneIntensity) * max(0, (1.3 - pulse))
                        glowSize = 20 * CGFloat(max(1, pulse))
                    case .setup:
                        let pulse = 1.0 + sin(time * 3.0 - t * .pi * 0.5) * 0.15
                        baseGlowStrength = 0.10 * max(0.3, zoneIntensity) * max(0, (1.2 - pulse))
                        glowSize = 12 * CGFloat(max(1, pulse))
                    }

                    if baseGlowStrength > 0.01 {
                        let activeGlowRect = blockRect.insetBy(dx: -glowSize, dy: -glowSize)
                        let activeGlowPath = Path(roundedRect: activeGlowRect, cornerRadius: cornerRadius * 2)
                        context.fill(activeGlowPath, with: .color(orbColor.opacity(baseGlowStrength)))
                    }

                    // Extra shimmer layer at high zone intensity
                    if zoneIntensity > 0.7 {
                        let shimmer = sin(time * 4.0 - t * .pi) * 0.5 + 0.5
                        if shimmer > 0.6 {
                            let shimmerOpacity = (shimmer - 0.6) * 0.3 * zoneIntensity
                            context.fill(specPath, with: .color(Color.white.opacity(shimmerOpacity)))
                        }
                    }
                }
            }
        }
    }

    // Evaluate 2D cubic bezier curve at parameter t (0...1)
    private func calculateBezierPoint(t: CGFloat, p1: CGPoint, p2: CGPoint, p3: CGPoint, p4: CGPoint) -> CGPoint {
        let u = 1.0 - t
        let tt = t * t
        let uu = u * u
        let uuu = uu * u
        let ttt = tt * t

        var x = uuu * p1.x
        x += 3 * uu * t * p2.x
        x += 3 * u * tt * p3.x
        x += ttt * p4.x

        var y = uuu * p1.y
        y += 3 * uu * t * p2.y
        y += 3 * u * tt * p3.y
        y += ttt * p4.y

        return CGPoint(x: x, y: y)
    }
}
