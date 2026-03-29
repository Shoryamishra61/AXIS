// MilestoneSheetView.swift

// Displayed when a user reaches a significant lifetime engagement milestone.
// Uses gamification to boost retention.
// Accessibility: labels, hints, reduce motion, 44pt touch target.

import SwiftUI

struct MilestoneSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        VStack(spacing: DesignSystem.spacing32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(reduceTransparency ? AXISTheme.success.opacity(0.3) : AXISTheme.success.opacity(0.1))
                    .frame(width: 160, height: 160)

                AXISMilestoneView(progress: 1.0)
                    .frame(width: 140, height: 140)
            }
            .padding(.bottom, DesignSystem.spacing24)
            .accessibilityLabel("Milestone achievement visualization, fully complete")

            VStack(spacing: DesignSystem.spacing16) {
                Text("First Milestone Reached!")
                    .font(.system(.title2, design: .serif).weight(.bold))
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text("1 Minute of glorious space between your vertebrae. Consistency builds resilience.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.spacing32)
                    .accessibilityLabel("You have reached one cumulative minute of correct alignment. Consistency builds resilience.")
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Continue Journey")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: DesignSystem.minTouchTarget)
            }
            .prominentButtonStyle()
            .padding(.horizontal, DesignSystem.spacing32)
            .padding(.bottom, DesignSystem.spacing48)
            .accessibilityHint("Dismisses the milestone celebration and returns to the session")
        }
        .presentationDetents([.medium])
        .presentationCornerRadius(DesignSystem.spacing32)
    }
}
