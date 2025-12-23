import SwiftUI

struct CameraView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // 1. The Fake Camera Feed (Black Background)
            Color.black.ignoresSafeArea()
            
            // 2. The "Video" (Just a placeholder face)
            VStack {
                Spacer()
                Image(systemName: "face.smiling")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .foregroundStyle(.gray)
                    .opacity(0.5)
                Spacer()
            }
            
            // 3. The "Augmented Reality" Overlay
            VStack {
                Spacer()
                // Fake Alignment Line
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 2, height: 300)
                    .overlay(
                        Text("Perfectly Aligned")
                            .font(.caption)
                            .foregroundStyle(.green)
                            .offset(x: 60)
                    )
                Spacer()
            }
            
            // 4. UI Controls
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    Text("Posture Snapshot")
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(.ultraThinMaterial, in: Capsule())
                    Spacer()
                    // Fake Camera Flip Button
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundStyle(.white)
                }
                .padding()
                
                Spacer()
                
                // "Snap" Button
                Button {
                    // Just dismiss for the demo
                    dismiss()
                } label: {
                    Circle()
                        .strokeBorder(.white, lineWidth: 4)
                        .frame(width: 70, height: 70)
                        .background(Circle().fill(.white.opacity(0.2)))
                }
                .padding(.bottom, 40)
            }
        }
    }
}
