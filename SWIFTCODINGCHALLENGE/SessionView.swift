// SessionView.swift
// Axis - The Invisible Posture Companion
// Premium Session Experience for Swift Student Challenge 2026

import SwiftUI

struct SessionView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @ObservedObject private var motion = MotionManager.shared
    @ObservedObject private var metrics = SessionMetrics.shared
    
    var selectedPosture: String
    var selectedDuration: Double
    
    // Session State
    @State private var routine: [Exercise] = []
    @State private var currentIndex: Int = 0
    @State private var isHolding: Bool = false
    @State private var isMuted: Bool = false
    @State private var showChrome: Bool = true
    @State private var isViewActive: Bool = false
    @State private var isCalibrating: Bool = true
    @State private var calibrationCountdown: Int = 3
    
    // Exercise Progress
    @State private var holdProgress: Double = 0.0
    @State private var holdTimer: Timer?
    @State private var currentAccuracy: Double = 0.0
    
    // Animation
    @State private var showSuccessFlash: Bool = false
    
    // Accessibility
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    // MARK: - Computed Properties
    
    var currentExercise: Exercise? {
        guard !routine.isEmpty, currentIndex < routine.count else { return nil }
        return routine[currentIndex]
    }
    
    var progressPercentage: Double {
        guard !routine.isEmpty else { return 0 }
        return Double(currentIndex) / Double(routine.count)
    }
    
    var currentSensorValue: Double {
        guard let exercise = currentExercise else { return 0 }
        switch exercise.targetAxis {
        case .pitch: return motion.pitch
        case .yaw: return motion.yaw
        case .roll: return motion.roll
        case .pitchYaw: return max(abs(motion.pitch), abs(motion.yaw))
        case .none: return 0
        }
    }
    
    var isAtTarget: Bool {
        guard let exercise = currentExercise else { return false }
        return exercise.checkTarget(currentValue: currentSensorValue)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background
            AxisColor.backgroundGradient.ignoresSafeArea()
            
            // Ambient glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            (isHolding ? AxisColor.success : AxisColor.primary).opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 400
                    )
                )
                .blur(radius: 50)
                .allowsHitTesting(false)
            
            if isCalibrating {
                calibrationView
            } else {
                sessionContent
            }
            
            // Success flash overlay
            if showSuccessFlash {
                successFlashOverlay
            }
        }
        .onAppear(perform: startSession)
        .onDisappear(perform: cleanup)
        .onChange(of: motion.pitch) { _ in checkProgress() }
        .onChange(of: motion.yaw) { _ in checkProgress() }
    }
    
    // MARK: - Calibration View
    
    private var calibrationView: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Calibration icon
            ZStack {
                Circle()
                    .stroke(AxisColor.primary.opacity(0.3), lineWidth: 4)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: CGFloat(3 - calibrationCountdown) / 3.0)
                    .stroke(AxisColor.primary, lineWidth: 4)
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                Text("\(calibrationCountdown)")
                    .font(.axisDisplay)
                    .foregroundStyle(AxisColor.primary)
            }
            
            VStack(spacing: 16) {
                Text("Calibrating")
                    .font(.axisTitle)
                    .foregroundStyle(.primary)
                
                Text("Look straight ahead comfortably")
                    .font(.axisInstruction)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                // Sensor source indicator
                HStack(spacing: 8) {
                    Image(systemName: motion.activeSource.contains("AirPods") ? "airpods.pro" : "iphone")
                        .foregroundStyle(AxisColor.primary)
                    Text(motion.activeSource)
                        .font(.axisTechnical)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
            }
            
            Spacer()
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Session Content
    
    private var sessionContent: some View {
        VStack(spacing: 0) {
            // Header
            if showChrome {
                headerView
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            Spacer()
            
            // Main visualizer
            ZStack {
                LiquidBlobView(
                    pitch: motion.pitch,
                    yaw: motion.yaw,
                    isInTargetZone: isHolding
                )
                .frame(width: 320, height: 320)
                
                // Progress ring when holding
                if isHolding, let exercise = currentExercise {
                    Circle()
                        .trim(from: 0, to: holdProgress)
                        .stroke(AxisColor.success, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 280, height: 280)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.1), value: holdProgress)
                }
                
                // Precision overlay (angle display)
                if !isHolding, let exercise = currentExercise, exercise.isTracked {
                    precisionOverlay
                }
            }
            
            Spacer()
            
            // Exercise info
            exerciseInfoView
                .padding(.bottom, 40)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                showChrome.toggle()
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack {
            // Exit button
            Button(action: exitSession) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .accessibilityLabel("Exit session")
            
            Spacer()
            
            // Progress indicator
            VStack(spacing: 4) {
                Text("\(currentIndex + 1) / \(routine.count)")
                    .font(.axisTechnical)
                    .foregroundStyle(.secondary)
                
                // Mini progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                        
                        Capsule()
                            .fill(AxisColor.primary)
                            .frame(width: geo.size.width * progressPercentage)
                    }
                }
                .frame(width: 60, height: 3)
            }
            
            Spacer()
            
            // Mute button
            Button {
                isMuted.toggle()
                if isMuted { SpeechManager.shared.stop() }
                AxisHaptic.tick()
            } label: {
                Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .foregroundStyle(isMuted ? AxisColor.danger : .white.opacity(0.7))
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .accessibilityLabel(isMuted ? "Unmute voice" : "Mute voice")
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Precision Overlay
    
    private var precisionOverlay: some View {
        VStack(spacing: 4) {
            // Current angle display
            Text(String(format: "%.0f°", abs(currentSensorValue)))
                .font(.axisTechnical)
                .foregroundStyle(isAtTarget ? AxisColor.success : AxisColor.textSecondary)
            
            if let exercise = currentExercise {
                Text("Target: \(String(format: "%.0f°", abs(exercise.targetValue)))")
                    .font(.axisCaption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .offset(y: 160)
    }
    
    // MARK: - Exercise Info View
    
    private var exerciseInfoView: some View {
        VStack(spacing: 20) {
            if let exercise = currentExercise {
                // Category badge
                HStack(spacing: 6) {
                    Image(systemName: exercise.category.icon)
                        .font(.caption)
                    Text(exercise.category.rawValue.uppercased())
                        .font(.axisTechnical)
                }
                .foregroundStyle(AxisColor.category(exercise.category))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AxisColor.category(exercise.category).opacity(0.15), in: Capsule())
                
                // Exercise name
                Text(exercise.name)
                    .font(.axisTitle)
                    .foregroundStyle(.primary)
                
                // Instruction
                Text(exercise.instruction)
                    .font(.axisInstruction)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineLimit(3)
                
                // Success indicator
                if isHolding {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AxisColor.success)
                        Text("PERFECT • HOLD")
                            .font(.axisTechnical)
                            .foregroundStyle(AxisColor.success)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(AxisColor.success.opacity(0.15), in: Capsule())
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHolding)
    }
    
    // MARK: - Success Flash Overlay
    
    private var successFlashOverlay: some View {
        Color.white
            .opacity(0.15)
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }
    
    // MARK: - Session Logic
    
    private func startSession() {
        isViewActive = true
        motion.startUpdates()
        
        // Generate routine
        routine = ProtocolEngine.shared.generateRoutine(
            posture: selectedPosture,
            durationMinutes: selectedDuration,
            isWheelchair: coordinator.isWheelchairUser
        )
        
        // Initialize metrics
        metrics.startSession(totalExerciseCount: routine.count)
        
        // Start calibration
        startCalibration()
    }
    
    private func startCalibration() {
        isCalibrating = true
        calibrationCountdown = 3
        
        // Countdown timer
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if calibrationCountdown > 1 {
                calibrationCountdown -= 1
                AxisHaptic.tick()
            } else {
                timer.invalidate()
                completeCalibration()
            }
        }
    }
    
    private func completeCalibration() {
        motion.calibrate()
        AxisHaptic.success()
        
        withAnimation(.easeOut(duration: 0.5)) {
            isCalibrating = false
        }
        
        // Announce first exercise
        announceCurrentExercise()
    }
    
    private func announceCurrentExercise() {
        guard !isMuted, let exercise = currentExercise else { return }
        SpeechManager.shared.speak(text: exercise.calmingInstruction)
    }
    
    private func checkProgress() {
        guard isViewActive, !isCalibrating, !isHolding else { return }
        guard let exercise = currentExercise else { return }
        
        // Calculate accuracy
        currentAccuracy = exercise.calculateAccuracy(currentValue: currentSensorValue)
        
        // Check if at target
        if exercise.isTracked {
            if isAtTarget {
                enterHoldState()
            } else {
                // Update haptic texture based on error
                let error = abs(currentSensorValue - exercise.targetValue)
                let intensity = Float(min(error / 45.0, 1.0))
                HapticManager.shared.updateGravelTexture(intensity: intensity, sharpness: intensity * 0.8)
            }
        }
    }
    
    private func enterHoldState() {
        guard !isHolding, let exercise = currentExercise else { return }
        
        isHolding = true
        holdProgress = 0.0
        
        // Success haptic
        HapticManager.shared.playSuccessThud()
        HapticManager.shared.updateGravelTexture(intensity: 0, sharpness: 0)
        
        // Track metrics
        metrics.enterTarget()
        
        // Start hold timer
        let holdDuration = exercise.holdDuration
        let updateInterval = 0.05
        var elapsed: TimeInterval = 0
        
        holdTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { timer in
            guard isViewActive else {
                timer.invalidate()
                return
            }
            
            elapsed += updateInterval
            holdProgress = min(elapsed / holdDuration, 1.0)
            
            // Check if still at target
            if !isAtTarget {
                // User moved away
                timer.invalidate()
                exitHoldState()
                return
            }
            
            if elapsed >= holdDuration {
                timer.invalidate()
                completeExercise()
            }
        }
    }
    
    private func exitHoldState() {
        isHolding = false
        holdProgress = 0.0
        metrics.exitTarget()
        AxisHaptic.warning()
    }
    
    private func completeExercise() {
        guard let exercise = currentExercise else { return }
        
        // Record metrics
        metrics.completeExercise(name: exercise.name, accuracy: currentAccuracy)
        
        // Success feedback
        showSuccessFlash = true
        AxisHaptic.success()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            showSuccessFlash = false
        }
        
        // Move to next exercise
        if currentIndex < routine.count - 1 {
            currentIndex += 1
            isHolding = false
            holdProgress = 0.0
            
            // Small delay before announcing next
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                announceCurrentExercise()
            }
        } else {
            // Session complete
            finishSession()
        }
    }
    
    private func finishSession() {
        metrics.endSession()
        cleanup()
        coordinator.completeSession()
    }
    
    private func exitSession() {
        cleanup()
        coordinator.returnHome()
    }
    
    private func cleanup() {
        isViewActive = false
        holdTimer?.invalidate()
        holdTimer = nil
        motion.stopUpdates()
        SpeechManager.shared.stop()
        HapticManager.shared.updateGravelTexture(intensity: 0, sharpness: 0)
    }
}

// MARK: - Preview
#Preview {
    SessionView(selectedPosture: "Sitting", selectedDuration: 3.0)
        .environmentObject(AppCoordinator())
}
