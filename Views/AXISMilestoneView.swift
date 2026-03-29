// AXISMilestoneView.swift

// "Flame" Milestone Shape
// Adapts the Liquid Glass aesthetic into a minimalist milestone visualization
// that replaces the forbidden "Activity Rings", changing size & glow based on cumulative time.
// Accessibility: reduce motion support, descriptive label.

import SwiftUI

struct AXISMilestoneView: View {
    // 0 to 1+
    var progress: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if reduceMotion {
                // Static milestone for reduce motion: simple progress ring
                staticMilestone
            } else {
                // Animated organic shape
                animatedMilestone
            }
        }
        .accessibilityLabel("Milestone progress: \(Int(min(progress, 1.0) * 100)) percent")
    }

    // MARK: - Static Milestone (Reduce Motion)

    private var staticMilestone: some View {
        ZStack {
            Circle()
                .stroke(AXISTheme.success.opacity(0.2), lineWidth: 8)
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(AXISTheme.success, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Image(systemName: "flame.fill")
                .font(.title)
                .foregroundStyle(AXISTheme.success)
        }
    }

    // MARK: - Animated Milestone

    private var animatedMilestone: some View {
        TimelineView(.animation(minimumInterval: 0.02)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let cx = size.width / 2
                let cy = size.height / 2
                let baseRadius = size.width * 0.25

                let growth = CGFloat(min(1.0, progress)) * baseRadius * 0.4
                let activeRadius = baseRadius + growth

                var path = Path()

                let points = 8
                let angleStep = (2.0 * .pi) / Double(points)
                for i in 0..<points {
                    let theta = Double(i) * angleStep

                    let w1 = sin(t * 1.5 + theta * 3) * (activeRadius * 0.08)
                    let w2 = cos(t * 0.8 + theta * 2) * (activeRadius * 0.05)
                    let r = activeRadius + w1 + w2

                    let x = cx + CGFloat(cos(theta)) * r
                    let y = cy + CGFloat(sin(theta)) * r
                    let p = CGPoint(x: x, y: y)

                    if i == 0 {
                        path.move(to: p)
                    } else {
                        path.addLine(to: p)
                    }
                }
                path.closeSubpath()

                let smoothPath = path.smoothed()

                context.fill(
                    smoothPath,
                    with: .linearGradient(
                        Gradient(colors: [
                            AXISTheme.success.opacity(0.8),
                            AXISTheme.success.opacity(0.3)
                        ]),
                        startPoint: CGPoint(x: cx, y: cy - activeRadius),
                        endPoint: CGPoint(x: cx, y: cy + activeRadius)
                    )
                )

                context.stroke(
                    smoothPath,
                    with: .color(AXISTheme.success.opacity(0.9)),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                )
            }
        }
        .drawingGroup()
    }
}

// Extension to smooth paths organically across points
private extension Path {
    func smoothed() -> Path {
        var path = Path()
        var current: CGPoint?
        var first: CGPoint?

        cgPath.applyWithBlock { element in
            let points = element.pointee.points
            switch element.pointee.type {
            case .moveToPoint:
                current = points[0]
                first = points[0]
                path.move(to: points[0])
            case .addLineToPoint:
                let next = points[0]
                if let curr = current {
                    let midX = (curr.x + next.x) / 2
                    let midY = (curr.y + next.y) / 2
                    path.addQuadCurve(to: next, control: CGPoint(x: midX, y: midY))
                }
                current = next
            case .closeSubpath:
                if let curr = current, let f = first {
                    let midX = (curr.x + f.x) / 2
                    let midY = (curr.y + f.y) / 2
                    path.addQuadCurve(to: f, control: CGPoint(x: midX, y: midY))
                }
                path.closeSubpath()
            default: break
            }
        }
        return path
    }
}
