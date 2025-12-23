import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    // Animation States
    @State private var showCheck = false
    @State private var showText = false
    
    var body: some View {
        ZStack {
            // 1. Consistent Deep Background
            RadialGradient(
                gradient: Gradient(colors: [Color(hex: "1A2A3A"), Color.black]),
                center: .center,
                startRadius: 5,
                endRadius: 500
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // 2. Success Animation
                ZStack {
                    // Glowing Ring
                    Circle()
                        .stroke(Color.teal.opacity(0.3), lineWidth: 2)
                        .frame(width: 120, height: 120)
                        .scaleEffect(showCheck ? 1.0 : 0.5)
                        .opacity(showCheck ? 1.0 : 0.0)
                    
                    // The Checkmark
                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundStyle(.white)
                        .scaleEffect(showCheck ? 1.0 : 0.1)
                        .opacity(showCheck ? 1.0 : 0.0)
                }
                
                // 3. Editorial Text
                VStack(spacing: 16) {
                    Text("Session Complete")
                        .font(.system(size: 32, weight: .medium, design: .serif)) // High-end look
                        .foregroundStyle(.white)
                        .opacity(showText ? 1.0 : 0.0)
                        .offset(y: showText ? 0 : 20)
                    
                    Text("You spent \(Int(coordinator.selectedDuration)) minutes restoring your \(coordinator.selectedPosture.lowercased()) alignment.")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(showText ? 1.0 : 0.0)
                        .offset(y: showText ? 0 : 20)
                }
                
                Spacer()
                
                // 4. "Done" Action
                Button {
                    // This calls the Coordinator to safely reset the state
                    coordinator.returnHome()
                } label: {
                    Text("Return Home")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
                .opacity(showText ? 1.0 : 0.0)
            }
        }
        .onAppear {
            // Staggered Animations for a "Premium" feel
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                showCheck = true
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                showText = true
            }
        }
    }
}
