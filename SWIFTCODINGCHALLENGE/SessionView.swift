// SessionView.swift
// Axis - The Invisible Posture Companion
// Distinguished Winner Session Experience for Swift Student Challenge 2026
//
// The session is the core product experience. Every interaction must be:
// - Immediately understandable
// - Visually delightful
// - Fully accessible

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
    @State private var showConfetti: Bool = false
    @State private var showSuccessBurst: Bool = false
    
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
            
            // Confetti celebration
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
            
            // Success burst effect
            if showSuccessBurst {
                SuccessBurstView()
                    .frame(width: 300, height: 300)
            }
        }
        .onAppear(perform: startSession)
        .onDisappear(perform: cleanup)
        .onChange(of: motion.pitch) { _ in checkProgress() }
        .onChange(of: motion.yaw) { _ in checkProgress() }
    }
    
    // MARK: - Calibration View
    
    private var calibrationView: some View {
        VStack(spacing: AxisSpacing.xxl) {
            Spacer()
            
            // Use the polished CalibrationIndicator component
            CalibrationIndicator(countdown: calibrationCountdown, total: 3)
            
            VStack(spacing: AxisSpacing.md) {
                Text("Calibrating")
                    .font(.axisTitle)
                    .foregroundColor(AxisColor.textPrimary)
                
                Text("Look straight ahead comfortably")
                    .font(.axisHeadline)
                    .foregroundColor(AxisColor.textSecondary)
                    .multilineTextAlignment(.center)
                
                // Sensor source indicator
                HStack(spacing: AxisSpacing.sm) {
                    Image(systemName: motion.activeSource.contains("AirPods") ? "airpods.pro" : "iphone")
                        .font(.system(size: 16))
                        .foregroundColor(AxisColor.primary)
                    Text(motion.activeSource)
                        .font(.axisTechnical)
                        .foregroundColor(AxisColor.textSecondary)
                }
                .padding(.horizontal, AxisSpacing.md)
                .padding(.vertical, AxisSpacing.sm)
                .background(.ultraThinMaterial, in: Capsule())
            }
            
            Spacer()
            Spacer()
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Calibrating. \(calibrationCountdown) seconds remaining. Look straight ahead.")
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
            
            // Main visualizer (Mode-Adaptive)
            ZStack {
                ExerciseVisualizer(
                    mode: coordinator.selectedGuidanceMode,
                    exercise: currentExercise,
                    motion: motion,
                    isHolding: isHolding,
                    holdProgress: holdProgress
                )
                .frame(width: 320, height: 350)
                
                // Precision overlay (angle display) for AirPods mode
                if coordinator.selectedGuidanceMode == .airpods,
                   !isHolding,
                   let exercise = currentExercise,
                   exercise.isTracked {
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
            
            // Progress indicator with mode badge
            VStack(spacing: 4) {
                // Mode indicator
                CompactModeIndicator(mode: coordinator.selectedGuidanceMode)
                
                Text("\(currentIndex + 1) / \(routine.count)")
                    .font(.axisTechnical)
                    .foregroundStyle(.secondary)
                
                // Mini progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                        
                        Capsule()
                            .fill(coordinator.selectedGuidanceMode.accentColor)
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
    
    // MARK: - Enhanced Precision Overlay
    
    private var precisionOverlay: some View {
        VStack(spacing: AxisSpacing.xs) {
            // Current angle with direction icon
            HStack(spacing: AxisSpacing.xs) {
                Image(systemName: directionIcon)
                    .font(.system(size: 18, weight: .semibold))
                Text(String(format: "%.0f°", abs(currentSensorValue)))
                    .font(.axisAngle)
            }
            .foregroundColor(precisionColor)
            
            // Direction label
            Text(directionLabel)
                .font(.axisTechnical)
                .foregroundColor(precisionColor.opacity(0.8))
            
            // Target hint
            if let exercise = currentExercise {
                Text("Target: \(String(format: "%.0f°", abs(exercise.targetValue)))")
                    .font(.axisCaption)
                    .foregroundColor(AxisColor.textTertiary)
            }
        }
        .padding(.horizontal, AxisSpacing.md)
        .padding(.vertical, AxisSpacing.sm)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AxisRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: AxisRadius.md)
                .stroke(precisionColor.opacity(0.3), lineWidth: 1)
        )
        .offset(y: 160)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Current angle: \(Int(abs(currentSensorValue))) degrees \(directionLabel)")
    }
    
    private var directionIcon: String {
        guard let exercise = currentExercise else { return "circle" }
        switch exercise.targetAxis {
        case .yaw:
            return currentSensorValue > 0 ? "arrow.turn.up.left" : "arrow.turn.up.right"
        case .pitch:
            return currentSensorValue > 0 ? "arrow.up" : "arrow.down"
        case .roll:
            return currentSensorValue > 0 ? "arrow.counterclockwise" : "arrow.clockwise"
        default:
            return "circle"
        }
    }
    
    private var directionLabel: String {
        guard let exercise = currentExercise, exercise.isTracked else { return "" }
        
        switch exercise.targetAxis {
        case .yaw:
            return currentSensorValue > 0 ? "TURN LEFT" : "TURN RIGHT"
        case .pitch:
            return currentSensorValue > 0 ? "LOOK UP" : "LOOK DOWN"
        case .roll:
            return currentSensorValue > 0 ? "TILT LEFT" : "TILT RIGHT"
        default:
            return "CENTERED"
        }
    }
    
    private var precisionColor: Color {
        guard let exercise = currentExercise else { return AxisColor.textSecondary }
        let error = abs(currentSensorValue - exercise.targetValue)
        if error <= exercise.tolerance {
            return AxisColor.aligned
        } else if error <= exercise.tolerance * 2 {
            return AxisColor.deviation
        }
        return AxisColor.textSecondary
    }
    
    // MARK: - Exercise Info View
    
    private var exerciseInfoView: some View {
        VStack(spacing: 16) {
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
                    .lineLimit(2)
                
                // Success indicator OR next up preview
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
                } else if currentIndex < routine.count - 1 {
                    // Next up preview
                    nextUpPreview
                }
                
                // Skip button for demos (small, subtle)
                if showChrome {
                    Button {
                        skipExercise()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 10))
                            Text("Skip")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(AxisColor.textTertiary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                    .padding(.top, 8)
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHolding)
    }
    
    // MARK: - Next Up Preview
    
    private var nextUpPreview: some View {
        let nextIndex = currentIndex + 1
        guard nextIndex < routine.count else { return AnyView(EmptyView()) }
        let nextExercise = routine[nextIndex]
        
        return AnyView(
            HStack(spacing: 8) {
                Text("NEXT:")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(AxisColor.textTertiary)
                
                Image(systemName: nextExercise.category.icon)
                    .font(.system(size: 12))
                    .foregroundColor(AxisColor.category(nextExercise.category))
                
                Text(nextExercise.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AxisColor.textSecondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .opacity(0.8)
        )
    }
    
    // MARK: - Skip Exercise
    
    private func skipExercise() {
        AxisHaptic.tick()
        
        // Move to next exercise
        if currentIndex < routine.count - 1 {
            currentIndex += 1
            isHolding = false
            holdProgress = 0.0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                announceCurrentExercise()
            }
        } else {
            // Session complete
            showConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                finishSession()
            }
        }
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
        // Use calmingInstruction for premium, sensory guidance
        // This solves User Point 14 (Robot Voice) and 26 (Bad Text)
        SpeechManager.shared.speakCoaching(exercise.calmingInstruction)
        
        // Also ensure simple instruction is shown on screen via binding (handled by visualizer)
    }
    
    private func checkProgress() {
        guard isViewActive, !isCalibrating, !isHolding else { return }
        guard let exercise = currentExercise else { return }
        
        // Mode-Adaptive Logic (Fixes Point 10 & 23)
        // Camera & Audio modes act as "Timed/Guided" sessions without strict sensor gating
        if coordinator.selectedGuidanceMode == .camera || coordinator.selectedGuidanceMode == .audioOnly {
            currentAccuracy = 1.0 // Assume user is following along
            enterHoldState()      // Immediately start the timer
            return
        }
        
        // AirPods Mode: Strict Sensor Logic (Premium Feature)
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
        
        // Success feedback with burst effect
        showSuccessFlash = true
        showSuccessBurst = true
        AxisHaptic.success()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            showSuccessFlash = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            showSuccessBurst = false
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
            // Session complete - show confetti!
            showConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                finishSession()
            }
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
