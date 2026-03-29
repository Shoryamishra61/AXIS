// AXISSessionView.swift

// The core exercise orchestration view — where the user spends the most time.
// Features:
//   • 3-2-1 countdown ceremony before session starts
//   • Dynamic MeshGradient background that responds to zone state
//   • Exercise dot indicators showing overall progress
//   • Segmented session progress bar
//   • Live "In Zone" timer counter for gamification
//   • Directional guidance text when out of zone
//   • Exercise transition checkpoint between exercises
//   • Selective UI retreat that keeps timer visible
//   • iPad-adaptive spine scaling

import SwiftUI

struct AXISSessionView: View {

    @State var viewModel: SessionViewModel
    var motionManager: MotionManager
    var onComplete: (SessionSummary) -> Void
    var onExit: () -> Void

    /// Shared namespace from AXISCoreFlowView for the spine matchedGeometryEffect transition.
    var spineNamespace: Namespace.ID?

    @State private var timeInZone: Int = 0
    @State private var uiVisible: Bool = true
    @State private var visualizerAppeared = false
    @State private var wasInGoodZone = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme

    let zoneTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var deviation: Double {
        let ex = viewModel.currentExercise
        let angle = motionManager.angle(for: ex.motionAxis)

        switch ex.motionAxis {
        case .yaw, .roll:
            return max(-1, min(1, angle / 30.0))
        case .pitch:
            return max(-1, min(1, (angle - ex.targetDeg) / 40.0))
        }
    }

    private var isInGoodZone: Bool {
        let ex = viewModel.currentExercise
        let angle = motionManager.angle(for: ex.motionAxis)
        return abs(angle - ex.targetDeg) <= ex.toleranceDeg
    }

    var body: some View {
        GeometryReader { geometry in
            let spineSize = min(geometry.size.width * 0.65, 320.0)

            ZStack {
                // ── Dynamic Atmospheric Background ──────────────
                sessionBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    // ── Exercise Dot Indicators ─────────────────
                    exerciseDotIndicators
                        .padding(.top, DesignSystem.spacing8)
                        .opacity(uiVisible ? 1.0 : 0.3)
                        .animation(.easeInOut(duration: 0.8), value: uiVisible)

                    // ── Session Progress Bar (Segmented) ────────
                    sessionProgressBar(width: geometry.size.width)
                        .padding(.top, DesignSystem.spacing8)
                        .opacity(uiVisible ? 1.0 : 0.4)
                        .animation(.easeInOut(duration: 0.8), value: uiVisible)

                    Spacer()

                    // ── Main Content Area ────────────────────────
                    ZStack {
                        // Countdown Overlay
                        if case .countdown(let count) = viewModel.sessionPhase {
                            countdownOverlay(count: count)
                                .transition(.scale(scale: 0.5).combined(with: .opacity))
                        }

                        // Transition Checkpoint Overlay
                        if case .transition(let completed, let next) = viewModel.sessionPhase {
                            transitionOverlay(completed: completed, next: next)
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }

                        // Active Exercise View
                        if viewModel.sessionPhase == .exercising {
                            VStack(spacing: 0) {
                                // The matchedGeometryEffect destination — morphs from Onboarding spine
                                let spineVisualizer = AxisSplineVisualizer(
                                    deviation: deviation,
                                    isInGoodZone: isInGoodZone,
                                    breathingPhase: viewModel.breathingPhase,
                                    sessionProgress: viewModel.sessionProgress,
                                    motionAxis: viewModel.currentExercise.motionAxis,
                                    zoneIntensity: zoneGlowIntensity
                                )
                                .frame(width: spineSize, height: spineSize)
                                .scaleEffect(visualizerAppeared ? 1.0 : 0.8)
                                .opacity(visualizerAppeared ? 1.0 : 0.0)
                                .accessibilityLabel("Posture guide visualizer")
                                .accessibilityValue(isInGoodZone ? "Aligned correctly" : "Adjust your position")

                                if let ns = spineNamespace, !reduceMotion {
                                    spineVisualizer
                                        .matchedGeometryEffect(id: "axisSpine", in: ns, isSource: false)
                                } else {
                                    spineVisualizer
                                }

                                // ── Zone Status Badge ───────────────
                                zoneStatusBadge
                                    .padding(.top, DesignSystem.spacing12)
                            }
                            .transition(.opacity)
                        }
                    }
                    .animation(reduceMotion ? .none : DesignSystem.springSmooth, value: viewModel.sessionPhase)

                    Spacer()

                    // ── Coaching Card ────────────────────────────
                    if viewModel.sessionPhase == .exercising {
                        CoachingCardView(viewModel: viewModel, isInGoodZone: isInGoodZone)
                            .padding(.horizontal, DesignSystem.spacing16)
                            .padding(.bottom, DesignSystem.spacing24)
                            .opacity(uiVisible ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 1.0), value: uiVisible)
                    }

                    // ── Persistent Timer (visible during UI retreat) ──
                    if viewModel.sessionPhase == .exercising && !uiVisible {
                        persistentTimer
                            .padding(.bottom, DesignSystem.spacing32)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    viewModel.stopSession()
                    onExit()
                } label: {
                    Label("Take a Break", systemImage: "leaf.fill")
                }
                .accessibilityHint("Ends the current session and returns to the position picker")
                .opacity(uiVisible ? 1.0 : 0.4)
                .animation(.easeInOut(duration: 1.0), value: uiVisible)
            }
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(viewModel.currentExercise.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    if viewModel.isLastExercise {
                        Text("Final Exercise")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AXISTheme.success)
                    } else {
                        Text("\(viewModel.currentExerciseIndex + 1)/\(viewModel.exercises.count)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .opacity(uiVisible ? 1.0 : 0.4)
                .animation(.easeInOut(duration: 1.0), value: uiVisible)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "airpodspro")
                    .font(.callout)
                    .foregroundStyle(
                        motionManager.isConnected ? AXISTheme.success :
                        Color(UIColor.tertiaryLabel)
                    )
                    .accessibilityLabel(motionManager.isConnected ? "AirPods connected" : "AirPods not connected")
                    .accessibilityHint("Shows whether AirPods are providing live motion data")
                    .opacity(uiVisible ? 1.0 : 0.4)
                    .animation(.easeInOut(duration: 1.0), value: uiVisible)
            }
        }
        .onAppear {
            viewModel.startSession()
            if reduceMotion {
                visualizerAppeared = true
            } else {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
                    visualizerAppeared = true
                }
            }
        }
        .onDisappear {
            viewModel.stopSession()
            zoneTimer.upstream.connect().cancel()
        }
        .onChange(of: viewModel.summary) { _, s in
            if let s { onComplete(s) }
        }
        .onChange(of: isInGoodZone) { _, inZone in
            // Enhanced haptic feedback on zone transitions (operant conditioning)
            if inZone && !wasInGoodZone {
                // Double-tap pattern for zone entry — more perceptible
                UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.4)
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(50))
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.7)
                }
            } else if !inZone && wasInGoodZone {
                UISelectionFeedbackGenerator().selectionChanged()
            }
            wasInGoodZone = inZone
        }
        .onReceive(zoneTimer) { _ in
            guard viewModel.sessionPhase == .exercising else { return }
            if isInGoodZone {
                timeInZone += 1
                if timeInZone >= DesignSystem.uiRetreatThreshold && uiVisible {
                    withAnimation(reduceMotion ? .none : .easeInOut(duration: 1.0)) {
                        uiVisible = false
                    }
                }
            } else {
                timeInZone = 0
                if !uiVisible {
                    withAnimation(reduceMotion ? .none : DesignSystem.springSmooth) {
                        uiVisible = true
                    }
                }
            }
        }
    }

    // MARK: - Dynamic Background

    @ViewBuilder
    private var sessionBackground: some View {
        if reduceTransparency {
            Color(UIColor.systemBackground)
        } else {
            let isGood = isInGoodZone && viewModel.sessionPhase == .exercising
            let colors = colorScheme == .dark
                ? (isGood ? AXISTheme.zoneGoodGradientColors : AXISTheme.zoneAdjustGradientColors)
                : (isGood ? AXISTheme.zoneGoodGradientColorsLight : AXISTheme.zoneAdjustGradientColorsLight)

            // Use a radial gradient as ambient atmospheric canvas
            ZStack {
                // Base atmospheric layer
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Soft radial vignette for depth
                RadialGradient(
                    colors: [
                        (isGood ? AXISTheme.success : AXISTheme.accent).opacity(0.06),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 50,
                    endRadius: 400
                )
            }
            .animation(.easeInOut(duration: 1.5), value: isGood)
        }
    }

    // MARK: - Countdown Overlay

    @ViewBuilder
    private func countdownOverlay(count: Int) -> some View {
        VStack(spacing: DesignSystem.spacing16) {
            Text("\(count)")
                .font(.system(.largeTitle, design: .serif).bold())
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
                .animation(DesignSystem.springSnappy, value: count)

            Text("Get Ready")
                .font(.title3.weight(.medium))
                .foregroundStyle(.secondary)

            // Preview the upcoming exercise so user can prepare
            VStack(spacing: DesignSystem.spacing4) {
                Text(viewModel.currentExercise.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(viewModel.currentExercise.setupCue)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.horizontal, DesignSystem.spacing24)
            .padding(.top, DesignSystem.spacing8)
        }
        .accessibilityLabel("Session starting in \(count). First exercise: \(viewModel.currentExercise.name). \(viewModel.currentExercise.setupCue)")
    }

    // MARK: - Transition Overlay

    @ViewBuilder
    private func transitionOverlay(completed: String, next: String) -> some View {
        VStack(spacing: DesignSystem.spacing24) {
            // Celebration
            Image(systemName: "checkmark.circle.fill")
                .font(.title)
                .foregroundStyle(AXISTheme.success)
                .symbolEffect(.bounce, value: completed)
                .accessibilityHidden(true)

            VStack(spacing: DesignSystem.spacing8) {
                Text(completed)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("Complete")
                    .font(.body)
                    .foregroundStyle(AXISTheme.success)
            }

            // Separator
            RoundedRectangle(cornerRadius: 1)
                .fill(Color(UIColor.separator))
                .frame(width: 40, height: 2)
                .accessibilityHidden(true)

            // Next exercise preview
            VStack(spacing: DesignSystem.spacing4) {
                Text("Next")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.secondary)
                Text(next)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
            }
        }
        .padding(DesignSystem.spacing32)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(completed) complete. Next exercise: \(next)")
    }

    // MARK: - Exercise Dot Indicators

    private var exerciseDotIndicators: some View {
        HStack(spacing: DesignSystem.spacing8) {
            ForEach(0..<viewModel.exercises.count, id: \.self) { i in
                Circle()
                    .fill(dotColor(for: i))
                    .frame(width: 8, height: 8)
                    .scaleEffect(i == viewModel.currentExerciseIndex ? 1.3 : 1.0)
                    .animation(DesignSystem.springSnappy, value: viewModel.currentExerciseIndex)
            }
        }
        .accessibilityLabel("Exercise \(viewModel.currentExerciseIndex + 1) of \(viewModel.exercises.count)")
    }

    private func dotColor(for index: Int) -> Color {
        if index < viewModel.currentExerciseIndex {
            return AXISTheme.success
        } else if index == viewModel.currentExerciseIndex {
            return AXISTheme.accent
        }
        return Color(UIColor.tertiarySystemFill)
    }

    // MARK: - Session Progress Bar (Segmented)

    @ViewBuilder
    private func sessionProgressBar(width: CGFloat) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: DesignSystem.sessionProgressHeight / 2)
                    .fill(Color(UIColor.tertiarySystemFill))
                RoundedRectangle(cornerRadius: DesignSystem.sessionProgressHeight / 2)
                    .fill(AXISTheme.accent)
                    .frame(width: max(0, geo.size.width * viewModel.sessionProgress))
                    .animation(.linear(duration: 1), value: viewModel.sessionProgress)
            }
        }
        .frame(height: DesignSystem.sessionProgressHeight)
        .padding(.horizontal, DesignSystem.standardPadding)
        .accessibilityRepresentation {
            ProgressView(value: viewModel.sessionProgress)
                .accessibilityLabel("Session progress")
                .accessibilityValue("\(Int(viewModel.sessionProgress * 100)) percent complete")
        }
    }

    // MARK: - Zone Status Badge

    @ViewBuilder
    private var zoneStatusBadge: some View {
        if viewModel.sessionPhase == .exercising {
            if isInGoodZone {
                HStack(spacing: DesignSystem.spacing8) {
                    Label("In Zone", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .foregroundStyle(AXISTheme.success)
                }
                .transition(.scale(scale: 0.8).combined(with: .opacity))
                .accessibilityLabel("In Zone")
                .opacity(uiVisible ? 1.0 : 0.6)
                .animation(.easeInOut(duration: 0.8), value: uiVisible)
            } else {
                // Directional guidance when out of zone
                if !viewModel.guidanceText.isEmpty {
                    HStack(spacing: DesignSystem.spacing4) {
                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                            .font(.callout)
                            .foregroundStyle(AXISTheme.warning)
                        Text(viewModel.guidanceText)
                            .font(.callout.weight(.medium))
                            .foregroundStyle(AXISTheme.warning)
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.guidanceText)
                    .accessibilityLabel("Guidance: \(viewModel.guidanceText)")
                } else {
                    Text(viewModel.currentExercise.motionAxis.label)
                        .font(.callout)
                        .foregroundStyle(.tertiary)
                        .accessibilityLabel("Motion axis: \(viewModel.currentExercise.motionAxis.label)")
                }
            }
        }
    }

    // MARK: - Persistent Timer (during UI Retreat)

    private var persistentTimer: some View {
        VStack(spacing: DesignSystem.spacing4) {
            Text(formatTime(viewModel.exerciseTimeRemaining))
                .font(.system(.title2, design: .serif).bold())
                .foregroundStyle(.primary.opacity(0.6))
                .contentTransition(.numericText())
                .monospacedDigit()
        }
        .accessibilityLabel("Time remaining: \(formatTime(viewModel.exerciseTimeRemaining))")
    }

    // MARK: - Progressive Zone Glow

    private var zoneGlowIntensity: Double {
        if !isInGoodZone { return 0 }
        // Ramp up glow intensity based on sustained zone time
        let t = Double(viewModel.inZoneSeconds)
        if t < 3 { return 0.3 }
        if t < 6 { return 0.5 }
        if t < 10 { return 0.7 }
        return 1.0
    }

    // MARK: - Helpers

    private func formatTime(_ s: Int) -> String {
        String(format: "%d:%02d", s / 60, s % 60)
    }
}
