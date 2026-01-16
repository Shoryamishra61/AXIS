import SwiftUI

struct ContextView: View {
    // 1. Connect to the Coordinator and Activity Logic
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var activity = ActivityManager()
    
    // 2. Local selection state for manual override
    @State private var selectedPosition = "Sitting"
    @State private var selectedDuration = 3.0
    let positions = ["Sitting", "Standing", "Lying Down"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AxisColor.backgroundGradient.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 30) {
                    // Title in SF Pro Rounded
                    Text("Set Context")
                        .font(.axisTitle)
                        .padding(.top, 20)
                    
                    // Intelligent Environment Detection Banner
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Detected: \(activity.detectedContext.uppercased())")
                            .font(.axisTechnical)
                    }
                    .padding()
                    .background(.teal.opacity(0.1), in: Capsule())
                    .overlay(Capsule().stroke(.teal.opacity(0.3), lineWidth: 1))
                    
                    // Posture Selection Stack (Fitts's Law Optimized)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Current Environment")
                            .font(.axisTechnical)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 12) {
                            ForEach(positions, id: \.self) { position in
                                Button {
                                    selectedPosition = position
                                } label: {
                                    VStack {
                                        Image(systemName: iconFor(position))
                                            .font(.title2)
                                        Text(position)
                                            .font(.axisTechnical)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(selectedPosition == position ? .teal.opacity(0.2) : .white.opacity(0.05))
                                    .foregroundStyle(selectedPosition == position ? .teal : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(selectedPosition == position ? .teal : .clear, lineWidth: 2)
                                    )
                                }
                            }
                        }
                    }
                    
                    // Duration Logic (Miller's Law: Predictive Presets)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Session Duration")
                                .font(.axisTechnical)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(Int(selectedDuration)) min").font(.axisTitle)
                        }
                        
                        Slider(value: $selectedDuration, in: 2...10, step: 1)
                            .tint(.teal)
                    }
                    
                    // Wheelchair Mode Toggle (Task 5 Inclusivity)
                    Toggle(isOn: $coordinator.isWheelchairUser) {
                        VStack(alignment: .leading) {
                            Text("Wheelchair Mode").font(.axisTechnical)
                            Text("Optimizes calibration for seated mobility.").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .tint(.teal)
                    .padding()
                    .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
                    
                    Spacer()
                    
                    // Start Action (Von Restorff Effect)
                    Button {
                        coordinator.startSession(posture: selectedPosition, duration: selectedDuration)
                    } label: {
                        Text("Begin Movement")
                            .font(.axisTechnical)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.teal)
                            .foregroundStyle(.black)
                            .clipShape(Capsule())
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        coordinator.returnHome() // Fixes 'cancelSetup' error
                    }
                    .font(.axisTechnical)
                    .foregroundStyle(.primary)
                }
            }
        }
        .onAppear {
            activity.startActivityDetection() // Trigger auto-sensing
            selectedPosition = activity.detectedContext
        }
        .onDisappear {
            activity.stopActivityDetection()
        }
    }
    
    func iconFor(_ name: String) -> String {
        switch name {
        case "Sitting": return "chair.lounge"
        case "Standing": return "figure.stand"
        default: return "bed.double"
        }
    }
}
