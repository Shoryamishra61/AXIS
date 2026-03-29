// CoachingCardView.swift

// The contextual coaching card displayed during a session.
// Features:
//   • Prominent countdown timer
//   • Coaching text with blur-replace transitions
//   • Exercise progress bar
//   • Accessibility labels and hints
//   • Glass-ready design (replaces opaque background)

import SwiftUI

struct CoachingCardView: View {

    var viewModel: SessionViewModel
    var isInGoodZone: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private var therapistSubtitle: String {
        switch viewModel.breathingPhase {
        case .setup:   return "Find your position — no rush."
        case .hold:    return "Small adjustments count."
        case .release: return "Let the breath do the work."
        }
    }

    var body: some View {
        VStack(spacing: DesignSystem.spacing12) {

            // ── Coaching Cue Text ────────────────────────
            VStack(spacing: DesignSystem.spacing4) {
                Text(viewModel.currentCueText)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .id(viewModel.currentCueText.prefix(20))
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.25), value: viewModel.currentCueText)

                Text(therapistSubtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .id(therapistSubtitle)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.35), value: therapistSubtitle)
            }

            Divider()
                .accessibilityHidden(true)

            // ── Exercise Info + Timer ────────────────────
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.currentExercise.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(viewModel.currentExercise.benefit)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(2)
                    Text("\(viewModel.currentExerciseIndex + 1) of \(viewModel.exercises.count)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Prominent countdown timer
                HStack(spacing: 4) {
                    if viewModel.exerciseTimeRemaining <= 5 {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.callout)
                            .foregroundStyle(timerColor)
                            .transition(.scale.combined(with: .opacity))
                    }
                    Text(formatTime(viewModel.exerciseTimeRemaining))
                        .font(.system(.title2, design: .serif).bold())
                        .foregroundStyle(timerColor)
                        .contentTransition(.numericText())
                        .monospacedDigit()
                        .animation(DesignSystem.springSnappy, value: viewModel.exerciseTimeRemaining)
                }
                .animation(DesignSystem.springSnappy, value: viewModel.exerciseTimeRemaining <= 5)
            }

            // ── Exercise Progress Bar ────────────────────
            GeometryReader { geo in
                let ex = viewModel.currentExercise
                let total = ex.durationSeconds
                let elapsed = total - viewModel.exerciseTimeRemaining
                let pct = total > 0 ? CGFloat(elapsed) / CGFloat(total) : 0

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: DesignSystem.exerciseProgressHeight / 2)
                        .fill(Color(UIColor.tertiarySystemFill))
                    RoundedRectangle(cornerRadius: DesignSystem.exerciseProgressHeight / 2)
                        .fill(isInGoodZone ? AXISTheme.success : AXISTheme.accent)
                        .frame(width: max(0, geo.size.width * pct))
                        .animation(.linear(duration: 1), value: pct)
                }
                .accessibilityRepresentation {
                    ProgressView(value: pct)
                        .accessibilityLabel("Exercise progress")
                        .accessibilityValue("\(Int(pct * 100)) percent")
                }
            }
            .frame(height: DesignSystem.exerciseProgressHeight)
        }
        .padding(DesignSystem.standardPadding)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.cardCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.cardCornerRadius, style: .continuous)
                .stroke(isInGoodZone ? AXISTheme.success.opacity(0.4) : Color.clear, lineWidth: 1.5)
                .animation(.easeInOut(duration: 0.5), value: isInGoodZone)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 16, y: 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Coaching card. \(viewModel.currentCueText). \(formatTime(viewModel.exerciseTimeRemaining)) remaining.")
        .accessibilityHint("Shows the current exercise coaching cue and countdown timer")
    }

    // MARK: - Timer Color (urgency feedback)

    private var timerColor: Color {
        if viewModel.exerciseTimeRemaining <= 5 {
            return AXISTheme.warning
        }
        return AXISTheme.accent
    }

    // MARK: - Helpers

    private func formatTime(_ s: Int) -> String {
        String(format: "%d:%02d", s / 60, s % 60)
    }
}
