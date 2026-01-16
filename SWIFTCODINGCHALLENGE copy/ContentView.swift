import SwiftUI

struct ContentView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var showAbout = false
    @State private var orbScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // 1. Cinematic Background
            AxisColor.backgroundGradient.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 2. Glassmorphic Header
                HStack {
                    Spacer()
                    Button {
                        showAbout = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .padding(12)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
                
                // 3. Dynamic Alignment Indicator (Report 1)
                // Replacing the static orb with a functional spinal visualizer preview
                VStack(spacing: 24) {
                    ZStack {
                        // Shadow Glow
                        Circle()
                            .fill(LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 220, height: 220)
                            .blur(radius: 40)
                            .opacity(0.4)
                            .scaleEffect(orbScale)
                        
                        VStack(spacing: 8) {
                            Text("Axis")
                                .font(.axisTitle) // SF Pro Rounded
                                .foregroundStyle(.primary)
                            Text("Zero-context mobility.")
                                .font(.axisInstruction) // New York
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onTapGesture {
                        // Quick 5-second check logic (Report 1)
                        coordinator.startSetup()
                    }
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                        orbScale = 1.12
                    }
                }
                
                Spacer()
                
                // 4. Primary Actions (Von Restorff Effect)
                VStack(spacing: 20) {
                    // Start Session (Main Action)
                    Button {
                        coordinator.startSetup()
                    } label: {
                        HStack {
                            Image(systemName: "airpods.pro")
                            Text("Start Session")
                        }
                        .font(.axisTechnical) // SF Mono
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(colors: [.teal, .blue], startPoint: .leading, endPoint: .trailing))
                        .clipShape(Capsule())
                        .shadow(color: .teal.opacity(0.4), radius: 15, y: 8)
                    }
                    .accessibilityLabel("Start Mobility Session")
                    
                    // Alignment Check (Secondary)
                    Button {
                        coordinator.appState = .alignmentCheck
                    } label: {
                        HStack {
                            Image(systemName: "camera.viewfinder")
                            Text("Check Alignment")
                        }
                        .font(.axisTechnical)
                        .foregroundStyle(.primary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                    .accessibilityLabel("Open Camera Mirror")
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
    }
}
