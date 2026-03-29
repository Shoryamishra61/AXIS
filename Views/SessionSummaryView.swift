// SessionSummaryView.swift

// Post-session completion screen based on the Peak-End Rule.
// Displays the AI Health Digest and haptic celebrations.
// Accessibility: reduce motion, hints, semantic fonts, 44pt touch targets.

import SwiftUI

struct SessionSummaryView: View {

    let summary: SessionSummary
    let cumulativeSeconds: Int
    let onDone: () -> Void

    // 3-stage reveal cascade (Peak-End Rule)
    @State private var showHeader = false
    @State private var showScore = false
    @State private var showContent = false

    @State private var dailyDigest: String?
    @State private var sealPop = false
    @State private var selectedMood: SessionMood?

    // Completion Popup States
    @State private var showCompletionPopup = false
    @State private var completionMessage = ""

    /// First session: cumulative time is very low (less than one full session)
    private var isFirstSession: Bool {
        cumulativeSeconds < summary.totalSeconds + 10
    }

    enum SessionMood: String, CaseIterable {
        case easy = "😌 Easy"
        case justRight = "😐 Just Right"
        case tooHard = "😣 Too Hard"
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private var scoreColor: Color {
        if summary.alignmentScore >= 80 { return AXISTheme.success }
        if summary.alignmentScore >= 55 { return AXISTheme.accent }
        return AXISTheme.warning
    }

    private var gradeLabel: String {
        if isFirstSession {
            if summary.alignmentScore >= 70 { return "Natural Talent" }
            if summary.alignmentScore >= 40 { return "Strong First Session" }
            return "Great Start — Your Baseline"
        }
        if summary.alignmentScore >= 90 { return "Outstanding" }
        if summary.alignmentScore >= 80 { return "Excellent" }
        if summary.alignmentScore >= 65 { return "Good Effort" }
        if summary.alignmentScore >= 50 { return "Keep Practicing" }
        return "Getting Started"
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        Spacer(minLength: DesignSystem.spacing32)

                        Image(systemName: "checkmark.seal.fill")
                            .font(.title)
                            .foregroundStyle(scoreColor)
                            .padding(.bottom, DesignSystem.spacing8)
                            .opacity(showHeader ? 1 : 0)
                            .scaleEffect(sealPop ? 1.2 : (showHeader ? 1.0 : 0.5))
                            .animation(reduceMotion ? .none : .bouncy(duration: 0.6).delay(0.3), value: sealPop)
                            .symbolEffect(.bounce, value: sealPop)
                            .accessibilityHidden(true)

                        Text("Protocol Complete")
                            .font(.system(.largeTitle, design: .serif).bold())
                            .foregroundStyle(.primary)
                            .accessibilityAddTraits(.isHeader)
                            .padding(.bottom, DesignSystem.spacing4)
                            .opacity(showHeader ? 1 : 0)
                            .offset(y: showHeader ? 0 : (reduceMotion ? 0 : 10))

                        Text(gradeLabel)
                            .font(.headline)
                            .foregroundStyle(scoreColor)
                            .opacity(showHeader ? 1 : 0)

                        // First-session encouragement
                        if isFirstSession {
                            Text("First sessions average 30–40%. Your muscles are learning a new pattern.")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, DesignSystem.spacing32)
                                .opacity(showHeader ? 1 : 0)
                        }

                        Spacer().frame(height: DesignSystem.spacing32)

                        // Score Ring
                        ZStack {
                            if summary.alignmentScore >= 80 {
                                AXISMilestoneView(progress: Double(summary.alignmentScore) / 100.0)
                                    .frame(width: 220, height: 220)
                                    .opacity(showScore ? 0.35 : 0)
                                    .animation(reduceMotion ? .none : .easeOut(duration: 1.5).delay(0.5), value: showScore)
                            }

                            Circle()
                                .stroke(Color(UIColor.tertiarySystemFill), lineWidth: 14)
                                .frame(width: 180, height: 180)

                            Circle()
                                .trim(from: 0, to: showScore ? Double(summary.alignmentScore) / 100.0 : 0)
                                .stroke(
                                    scoreColor,
                                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 180, height: 180)
                                .animation(
                                    reduceMotion ? .none : .spring(response: 1.2, dampingFraction: 0.7).delay(0.3),
                                    value: showScore
                                )

                            VStack(spacing: 2) {
                                Text("\(summary.alignmentScore)")
                                    .font(.system(.largeTitle, design: .serif).bold())
                                    .foregroundStyle(.primary)
                                    .contentTransition(.numericText())
                                Text("Alignment Score")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Alignment Score: \(summary.alignmentScore) percent, \(gradeLabel)")
                        .padding(.bottom, DesignSystem.spacing32)
                        .opacity(showScore ? 1 : 0)
                        .scaleEffect(showScore ? 1.0 : (reduceMotion ? 1.0 : 0.9))

                        // Stat Cards
                        HStack(spacing: DesignSystem.spacing16) {
                            CompletionStatCard(
                                icon: "clock.fill",
                                color: AXISTheme.accent,
                                value: formatDuration(summary.totalSeconds),
                                label: "Duration",
                                delay: 0.0
                            )
                            CompletionStatCard(
                                icon: "figure.walk",
                                color: AXISTheme.secondaryAccent,
                                value: "\(SessionLibrary.exercises(for: summary.position).count)",
                                label: "Exercises",
                                delay: 0.08
                            )
                            CompletionStatCard(
                                icon: "chart.line.uptrend.xyaxis",
                                color: AXISTheme.success,
                                value: formatDuration(cumulativeSeconds),
                                label: "Total",
                                delay: 0.16
                            )
                        }
                        .padding(.horizontal, DesignSystem.spacing24)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : (reduceMotion ? 0 : 20))

                        // Daily Health Digest
                        VStack(alignment: .leading, spacing: DesignSystem.spacing12) {
                            HStack {
                                Image(systemName: "apple.intelligence")
                                    .foregroundStyle(AXISTheme.accent)
                                Text("Daily Health Digest")
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }

                            if let digest = dailyDigest {
                                Text(digest)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                    .lineSpacing(4)
                                    .transition(.opacity.combined(with: .blurReplace))
                            } else {
                                HStack {
                                    ProgressView()
                                        .accessibilityLabel("Loading")
                                        .controlSize(.small)
                                    Text("Analyzing session patterns...")
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, DesignSystem.spacing4)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(DesignSystem.standardPadding)
                        .background(AXISTheme.cardBackground(reduceTransparency: reduceTransparency))
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.buttonCornerRadius, style: .continuous))
                        .padding(.horizontal, DesignSystem.spacing24)
                        .padding(.top, DesignSystem.spacing24)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : (reduceMotion ? 0 : 15))
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Daily Health Digest. \(dailyDigest ?? "Analyzing session patterns")")

                        // Position badge
                        HStack(spacing: DesignSystem.spacing8) {
                            Image(systemName: summary.position.sfSymbol)
                                .font(.callout)
                            Text(summary.position.rawValue)
                                .font(.callout.weight(.medium))
                        }
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, DesignSystem.spacing16)
                        .padding(.vertical, DesignSystem.spacing8)
                        .background(Color(UIColor.tertiarySystemFill))
                        .clipShape(Capsule())
                        .padding(.top, DesignSystem.spacing24)
                        .opacity(showContent ? 1 : 0)

                        // Mood Picker
                        VStack(spacing: DesignSystem.spacing8) {
                            Text("How did that feel?")
                                .font(.callout.weight(.medium))
                                .foregroundStyle(.secondary)
                            HStack(spacing: DesignSystem.spacing12) {
                                ForEach(SessionMood.allCases, id: \.self) { mood in
                                    Button {
                                        guard !showCompletionPopup else { return }

                                        withAnimation(DesignSystem.springSnappy) {
                                            selectedMood = mood
                                        }
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()

                                        switch mood {
                                        case .easy: completionMessage = "We'll step it up next time."
                                        case .justRight: completionMessage = "Perfect balance."
                                        case .tooHard: completionMessage = "We'll take it easier next time."
                                        }

                                        Task { @MainActor in
                                            try? await Task.sleep(for: .milliseconds(150))
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                                showCompletionPopup = true
                                            }
                                            UINotificationFeedbackGenerator().notificationOccurred(.success)

                                            try? await Task.sleep(for: .seconds(1.8))
                                            onDone()
                                        }
                                    } label: {
                                        Text(mood.rawValue)
                                            .font(.subheadline.weight(.medium))
                                            .padding(.horizontal, DesignSystem.spacing12)
                                            .padding(.vertical, DesignSystem.spacing8)
                                            .background(
                                                selectedMood == mood
                                                    ? AXISTheme.accent.opacity(0.15)
                                                    : Color(UIColor.tertiarySystemFill)
                                            )
                                            .foregroundStyle(selectedMood == mood ? AXISTheme.accent : .primary)
                                            .clipShape(Capsule())
                                    }
                                    .accessibilityLabel(mood.rawValue)
                                    .accessibilityAddTraits(selectedMood == mood ? .isSelected : [])
                                }
                            }
                        }
                        .padding(.top, DesignSystem.spacing24)
                        .opacity(showContent ? 1 : 0)

                        // Post-Session Tip
                        HStack(spacing: DesignSystem.spacing8) {
                            Image(systemName: "drop.fill")
                                .font(.callout)
                                .foregroundStyle(AXISTheme.secondaryAccent)
                            Text("Drink water. Roll your shoulders gently. Move again in 2 hours.")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        .padding(DesignSystem.spacing16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .padding(.horizontal, DesignSystem.spacing24)
                        .padding(.top, DesignSystem.spacing16)
                        .opacity(showContent ? 1 : 0)

                        Spacer(minLength: DesignSystem.spacing40)
                    }
                    .frame(minHeight: geometry.size.height)
                }

                // Completion Popup Overlay
                if showCompletionPopup {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()

                    VStack(spacing: DesignSystem.spacing16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(AXISTheme.success)
                            .symbolEffect(.bounce, value: showCompletionPopup)

                        Text("Session Logged")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.primary)

                        Text(completionMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(DesignSystem.spacing32)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .shadow(color: .black.opacity(0.15), radius: 30, y: 15)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                    .zIndex(100)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onDone()
                }
                .font(.body.weight(.semibold))
                .accessibilityHint("Returns to the main screen")
                .disabled(showCompletionPopup)
            }
        }
        .onAppear {
            // 3-Stage Haptic Cascade
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(150))
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(300))
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                sealPop = true
            }

            if reduceMotion {
                showHeader = true
                showScore = true
                showContent = true
            } else {
                withAnimation(.easeOut(duration: 0.4)) {
                    showHeader = true
                }
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(400))
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showScore = true
                    }
                }
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(800))
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                        showContent = true
                    }
                }
            }

            Task {
                await IntelligenceAgent.shared.prewarm()
                let digest = await IntelligenceAgent.shared.generateDigest(
                    score: summary.alignmentScore,
                    sessionTime: summary.totalSeconds,
                    positionTitle: summary.position.sessionTitle
                )
                withAnimation(DesignSystem.springSmooth) {
                    self.dailyDigest = digest
                }
            }
        }
    }

    private func formatDuration(_ s: Int) -> String {
        let m = s / 60
        let sec = s % 60
        return m > 0 ? "\(m)m \(sec)s" : "\(sec)s"
    }
}

struct CompletionStatCard: View {
    let icon: String
    let color: Color
    let value: String
    let label: String
    var delay: Double = 0

    var body: some View {
        VStack(spacing: DesignSystem.spacing8) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.12))
                .clipShape(Circle())

            Text(value)
                .font(.headline)
                .foregroundStyle(.primary)
            Text(label)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.spacing16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.buttonCornerRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}
