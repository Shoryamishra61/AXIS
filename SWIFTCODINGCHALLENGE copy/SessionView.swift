import SwiftUI

struct SessionView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @ObservedObject private var motion = MotionManager.shared
    
    var selectedPosture: String
    var selectedDuration: Double
    
    @State private var routine: [ExerciseType] = []
    @State private var currentIndex: Int = 0
    @State private var isHolding: Bool = false
    @State private var isMuted: Bool = false
    @State private var showChrome: Bool = true
    @State private var isViewActive: Bool = false
    
    // Task 6 Tracking
    @State private var accuracyScores: [Double] = []
    
    var currentExercise: ExerciseType {
        routine.isEmpty ? .deepRest : routine[currentIndex]
    }
    
    var body: some View {
        ZStack {
            AxisColor.backgroundGradient.ignoresSafeArea()
            
            Circle()
                .fill(RadialGradient(colors: [Color.white.opacity(0.06), Color.clear], center: .center, startRadius: 20, endRadius: 420))
                .frame(width: 420, height: 420)
                .blur(radius: 24)
                .allowsHitTesting(false)
            
            VStack(spacing: 0) {
                if showChrome { headerView.transition(.opacity) }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(RadialGradient(colors: [Color.teal.opacity(0.18), Color.clear], center: .center, startRadius: 12, endRadius: 360))
                        .scaleEffect(isHolding ? 1.12 : 1.0)
                        .blur(radius: 36)
                        .opacity(0.9)
                        .animation(.easeInOut(duration: 1.0), value: isHolding)
                    
                    // Morphing, breathing blob without hard borders
                    LiquidBlobView(pitch: motion.pitch, yaw: motion.yaw)
                        // Breathing scale
                        .scaleEffect(1.0 + 0.035 * sin(Date().timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 10)) )
                        // Slight reactive scale on hold
                        .scaleEffect(isHolding ? 1.06 : 1.0)
                        // Colorful depth using overlay gradient
                        .overlay(
                            AngularGradient(colors: [
                                .teal.opacity(0.35),
                                .blue.opacity(0.25),
                                .purple.opacity(0.25),
                                .teal.opacity(0.35)
                            ], center: .center)
                            .blendMode(.softLight)
                            .opacity(0.9)
                        )
                        // Subtle glass tint without stroke
                        .background(
                            RoundedRectangle(cornerRadius: 44, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .shadow(color: Color.black.opacity(0.18), radius: 18, x: 0, y: 12)
                                .blur(radius: 0.5)
                                .opacity(0.65)
                        )
                        // Motion parallax/tilt
                        .offset(x: CGFloat(motion.yaw) * 0.6, y: CGFloat(-motion.pitch) * 0.6)
                        .rotation3DEffect(.degrees(Double(motion.pitch) * 0.05), axis: (x: 1, y: 0, z: 0))
                        .rotation3DEffect(.degrees(Double(motion.yaw) * 0.05), axis: (x: 0, y: 1, z: 0))
                        .saturation(1.06)
                        .brightness(0.01)
                        .animation(.spring(response: 0.9, dampingFraction: 0.85), value: isHolding)
                    
                    // Shader-like ripples via Canvas reacting to motion
                    Canvas { context, size in
                        let time = Date().timeIntervalSinceReferenceDate
                        let center = CGPoint(x: size.width/2, y: size.height/2)
                        let baseRadius = min(size.width, size.height) * 0.38
                        // Motion-driven ripple amplitude
                        let amp = CGFloat(min(max(abs(motion.pitch) + abs(motion.yaw), 0), 45)) / 45.0
                        let rippleCount = 3
                        for i in 0..<rippleCount {
                            let progress = CGFloat(i) / CGFloat(rippleCount)
                            let radius = baseRadius + progress * 70 + CGFloat(sin(time * 1.4 + Double(i))) * 6 * amp
                            let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
                            let alpha = (0.35 - progress * 0.28) * (0.6 + 0.4 * amp)
                            let gradient = Gradient(colors: [Color.white.opacity(alpha), Color.clear])
                            context.stroke(Path(ellipseIn: rect), with: .conicGradient(Gradient(colors: [Color.white.opacity(alpha), .clear]), center: center, angle: .degrees(0)), lineWidth: 1.0)
                        }
                    }
                    .blendMode(.plusLighter)
                    .opacity(0.9)
                    .allowsHitTesting(false)
                    
                    // Dynamic Island–style pulse when entering hold
                    if isHolding {
                        PulseRing()
                            .frame(width: 360, height: 360)
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal, 24)
                .saturation(1.04)
                .contrast(1.01)
                
                Spacer()
                
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text(currentExercise.rawValue.uppercased())
                            .font(.axisTechnical).foregroundStyle(.teal.opacity(0.6)).tracking(2)
                        
                        Text(currentExercise.instruction)
                            .font(.axisInstruction).foregroundStyle(.white)
                            .multilineTextAlignment(.center).padding(.horizontal, 50)
                    }
                    
                    if isHolding {
                        Text("PERFECT • HOLD")
                            .font(.axisTechnical).padding(.horizontal, 16).padding(.vertical, 8)
                            .background(Color.green.opacity(0.15), in: Capsule())
                            .overlay(Capsule().stroke(Color.green.opacity(0.5), lineWidth: 1))
                    }
                }
                .padding(.bottom, 80)
            }
        }
        .onAppear { setupSession() }
        .onTapGesture { withAnimation { showChrome.toggle() } }
        .onDisappear { forceExit() }
        .onChange(of: motion.pitch) { newValue in checkProgress(val: newValue) }
    }
    
    var headerView: some View {
        HStack {
            Button(action: forceExit) {
                Image(systemName: "xmark").font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6)).frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
            }
            Spacer()
            Button {
                isMuted.toggle()
                if isMuted { SpeechManager.shared.stop() }
            } label: {
                Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .foregroundStyle(isMuted ? .red : .white).frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
            }
        }
        .padding()
    }
    
    private func setupSession() {
        isViewActive = true
        motion.startUpdates()
        routine = ProtocolEngine.shared.generateRoutine(posture: selectedPosture, durationMinutes: selectedDuration, isWheelchair: coordinator.isWheelchairUser)
        if !isMuted { SpeechManager.shared.speak(text: currentExercise.instruction) }
    }
    
    private func checkProgress(val: Double) {
        guard isViewActive, !isHolding else { return }
        let error = max(abs(motion.pitch), abs(motion.yaw))
        
        if error <= 10 && error > 0 {
            isHolding = true
            HapticManager.shared.playSuccessThud()
            HapticManager.shared.updateGravelTexture(intensity: 0, sharpness: 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { nextExercise() }
        } else {
            let intensity = Float(min(abs(val) / 45.0, 1.0))
            HapticManager.shared.updateGravelTexture(intensity: intensity, sharpness: intensity)
        }
    }
    
    private func nextExercise() {
        guard isViewActive else { return }
        if currentIndex < routine.count - 1 {
            currentIndex += 1
            isHolding = false
            if !isMuted { SpeechManager.shared.speak(text: currentExercise.instruction) }
        } else {
            coordinator.completeSession()
        }
    }
    
    private func forceExit() {
        isViewActive = false
        motion.stopUpdates()
        SpeechManager.shared.stop()
        coordinator.returnHome()
    }
    
    // MARK: - Pulse Ring
    struct PulseRing: View {
        @State private var animate = false
        var body: some View {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.35), lineWidth: 2)
                    .scaleEffect(animate ? 1.2 : 0.8)
                    .opacity(animate ? 0.0 : 0.7)
                Circle()
                    .stroke(Color.teal.opacity(0.35), lineWidth: 3)
                    .scaleEffect(animate ? 1.35 : 0.9)
                    .opacity(animate ? 0.0 : 0.6)
                Circle()
                    .stroke(Color.teal.opacity(0.25), lineWidth: 4)
                    .scaleEffect(animate ? 1.55 : 1.0)
                    .opacity(animate ? 0.0 : 0.5)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 1.2).repeatForever(autoreverses: false)) {
                    animate = true
                }
            }
        }
    }
}

