import SwiftUI

struct SessionView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var motion = MotionManager()
    
    var body: some View {
        ZStack {
            // Background
            Color(uiColor: .systemBackground).ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Header
                HStack {
                    Button {
                        motion.stopUpdates()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(motion.activeSource)
                        .font(.caption)
                        .padding(6)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                .padding()
                
                Spacer()
                
                // The Orb (Visual Feedback)
                ZStack {
                    // Center Anchor
                    Circle()
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        .frame(width: 250, height: 250)
                    
                    // The Moving Cursor
                    Circle()
                        .fill(Color.blue.gradient)
                        .frame(width: 60, height: 60)
                        .shadow(radius: 10)
                        // This connects the Sensor Data to the UI Position
                        .offset(
                            x: CGFloat(motion.yaw * 2),  // Turning head moves X
                            y: CGFloat(motion.pitch * 2) // Tilting head moves Y
                        )
                }
                
                Spacer()
                
                // Instruction
                Text("Gently rotate your head.")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                
                // Debug Data (Remove before final submission)
                VStack {
                    Text("Yaw: \(Int(motion.yaw))°")
                    Text("Pitch: \(Int(motion.pitch))°")
                }
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.bottom)
            }
        }
        .onAppear {
            motion.startUpdates()
        }
        .onDisappear {
            motion.stopUpdates()
        }
    }
}
