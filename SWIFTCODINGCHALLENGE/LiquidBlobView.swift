import SwiftUI

struct LiquidBlobView: View {
    var pitch: Double // Forward/Backward
    var yaw: Double   // Left/Right
    @State private var appearancePhase: CGFloat = 0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let midX = size.width / 2
                let midY = size.height / 2
                
                // 1. Calculate Deformation based on Motion
                // We normalize the sensor data to a 0.0 - 1.0 stretch factor
                let stretchX = CGFloat(yaw) / 30.0
                let stretchY = CGFloat(pitch) / 30.0
                
                // 2. Determine State Colors
                let error = max(abs(pitch), abs(yaw))
                let baseColor = AxisColor.semantic(for: error)
                
                // 3. Draw the "Liquid" Shape
                // We use a simplified metaball approach: an ellipse that warps
                let baseRadius: CGFloat = 100 + (sin(appearancePhase) * 5) // "Breathing" pulse
                let width = baseRadius * (1 + abs(stretchX) * 0.6)
                let height = baseRadius * (1 - abs(stretchY) * 0.3)
                
                let rect = CGRect(
                    x: midX - (width / 2) + (stretchX * 40),
                    y: midY - (height / 2) - (stretchY * 40),
                    width: width,
                    height: height
                )
                
                let blobPath = Path(ellipseIn: rect)
                
                // 4. Multi-Layered Glow (Cinematic Depth)
                context.addFilter(.blur(radius: error > 15 ? 30 : 15)) // Turbulent blur
                context.fill(blobPath, with: .color(baseColor.opacity(0.3)))
                
                context.addFilter(.blur(radius: 0))
                context.fill(
                    blobPath,
                    with: .radialGradient(
                        Gradient(colors: [baseColor, baseColor.opacity(0.8)]),
                        center: CGPoint(x: rect.midX, y: rect.midY),
                        startRadius: 0,
                        endRadius: baseRadius
                    )
                )
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                appearancePhase = .pi * 2
            }
        }
    }
}