import SwiftUI

struct LiquidView: View {
    var pitch: Double
    var yaw: Double
    var isHolding: Bool
    
    // Animation State
    @State private var time: Double = 0.0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = timeline.date.timeIntervalSinceReferenceDate
                let angle = now
                
                // Calculate "Distortion" based on head movement
                // The more you move off-center, the more the blob stretches
                let stretchX = yaw * 2.0
                let stretchY = pitch * 2.0
                
                // Draw the fluid blob
                let center = CGPoint(x: size.width / 2 + stretchX, y: size.height / 2 + stretchY)
                let baseRadius = size.width / 3
                
                var path = Path()
                
                // Create a morphing blob shape using cosine waves
                for i in stride(from: 0, to: 361, by: 1) {
                    let rad = Double(i) * .pi / 180
                    
                    // The "Wobble" math
                    let wobble = cos(rad * 5 + angle * 2) * 10
                    let distance = baseRadius + wobble
                    
                    let x = center.x + cos(rad) * distance
                    let y = center.y + sin(rad) * distance
                    
                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                path.closeSubpath()
                
                // Color Logic: Teal (Neutral) -> Green (Holding/Success)
                let color = isHolding ? Color.green : Color.teal
                
                // Fill with Gradient
                context.fill(
                    path,
                    with: .linearGradient(
                        Gradient(colors: [color.opacity(0.8), color.opacity(0.3)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                // Add a glowing stroke
                context.stroke(
                    path,
                    with: .color(color),
                    lineWidth: 3
                )
                
            }
        }
        .frame(width: 300, height: 300)
    }
}
