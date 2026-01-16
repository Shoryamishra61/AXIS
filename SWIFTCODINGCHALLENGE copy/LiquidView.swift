import SwiftUI

struct LiquidView: View {
    var pitch: Double
    var yaw: Double
    var isHolding: Bool
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                // 1. Get time inside the drawing context
                let now = timeline.date.timeIntervalSinceReferenceDate
                let angle = now
                
                // 2. Calculate Movement Stretch
                let stretchX = CGFloat(yaw * 2.0)
                let stretchY = CGFloat(pitch * 2.0)
                
                // 3. Geometry Setup
                let center = CGPoint(x: size.width / 2 + stretchX, y: size.height / 2 + stretchY)
                let baseRadius = size.width / 3
                
                // 4. Blob Parameters
                let wobbleFrequency: Double = 5
                let wobbleSpeed: Double = 2
                let wobbleAmplitude: CGFloat = 10
                
                // 5. Build the Path
                var path = Path()
                
                for i in stride(from: 0, through: 360, by: 1) {
                    let rad = Double(i) * .pi / 180
                    
                    // Create organic wobble using Cosine waves
                    let wobbleValue = cos(rad * wobbleFrequency + angle * wobbleSpeed)
                    let wobble = CGFloat(wobbleValue) * wobbleAmplitude
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
                
                // 6. Draw Gradient Fill
                let baseColor: Color = isHolding ? .green : .teal
                
                context.fill(
                    path,
                    with: .linearGradient(
                        Gradient(colors: [baseColor.opacity(0.8), baseColor.opacity(0.3)]),
                        startPoint: .zero,
                        endPoint: CGPoint(x: size.width, y: size.height)
                    )
                )
                
                // 7. Draw Glowing Stroke
                context.stroke(
                    path,
                    with: .color(baseColor),
                    lineWidth: 3
                )
            }
            .frame(width: 300, height: 300)
        }
    }
}
