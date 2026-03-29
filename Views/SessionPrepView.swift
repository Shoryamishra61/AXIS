// SessionPrepView.swift
// Pre-session preparation screen with duration picker.
// Previews exercises for the selected duration and position.

import SwiftUI

struct SessionPrepView: View {

    let position: UserPosition
    let onBegin: (Int) -> Void // passes selected duration in minutes

    @State private var selectedDuration: Int = 2
    @State private var appeared = false
    @State private var showExercises = false
    @State private var pulse = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let availableDurations = [2, 4, 6, 8, 10]

    private var exercises: [Exercise] {
        SessionLibrary.exercises(for: position, duration: selectedDuration)
    }

    var body: some View {
        VStack(spacing: 0) {

            Spacer()

            // Header
            VStack(spacing: DesignSystem.spacing8) {
                Image(systemName: position.sfSymbol)
                    .font(.largeTitle)
                    .foregroundStyle(AXISTheme.accent)
                    .symbolEffect(.breathe, options: .repeating, value: pulse)

                Text(position.sessionTitle)
                    .font(.system(.title2, design: .serif).bold())
                    .foregroundStyle(.primary)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : (reduceMotion ? 0 : 15))
            .padding(.bottom, DesignSystem.spacing24)

            // Duration Picker
            VStack(spacing: DesignSystem.spacing8) {
                Text("Session Length")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.secondary)

                HStack(spacing: DesignSystem.spacing8) {
                    ForEach(availableDurations, id: \.self) { duration in
                        Button {
                            withAnimation(DesignSystem.springSnappy) {
                                selectedDuration = duration
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            VStack(spacing: 2) {
                                Text("\(duration)")
                                    .font(.title3.weight(.bold))
                                Text("min")
                                    .font(.caption2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DesignSystem.spacing8)
                            .background(
                                selectedDuration == duration
                                    ? AXISTheme.accent
                                    : Color(UIColor.tertiarySystemFill)
                            )
                            .foregroundStyle(
                                selectedDuration == duration ? .white : .primary
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .accessibilityLabel("\(duration) minutes")
                        .accessibilityAddTraits(selectedDuration == duration ? .isSelected : [])
                    }
                }
                .padding(.horizontal, DesignSystem.spacing24)

                Text("\(exercises.count) exercises · \(selectedDuration) min")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .contentTransition(.numericText())
            }
            .opacity(appeared ? 1 : 0)
            .padding(.bottom, DesignSystem.spacing24)

            // Exercise Preview List
            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignSystem.spacing4) {
                    ForEach(Array(exercises.enumerated()), id: \.offset) { index, exercise in
                        HStack(spacing: DesignSystem.spacing12) {
                            Text("\(index + 1)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(width: 24, height: 24)
                                .background(AXISTheme.accent.opacity(0.8))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(exercise.name)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.primary)
                                Text(exercise.benefit)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Text("\(exercise.durationSeconds)s")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, DesignSystem.spacing16)
                        .padding(.vertical, DesignSystem.spacing8)
                    }
                }
                .padding(.vertical, DesignSystem.spacing8)
            }
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, DesignSystem.spacing24)
            .frame(maxHeight: 240)
            .opacity(showExercises ? 1 : 0)

            Spacer()

            // Motivational prompt
            Text("Find a comfortable spot. We'll guide you through each movement.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.spacing32)
                .opacity(showExercises ? 1 : 0)

            // Begin Button
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onBegin(selectedDuration)
            } label: {
                Label("Begin Session", systemImage: "play.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: DesignSystem.minTouchTarget)
            }
            .prominentButtonStyle()
            .padding(.horizontal, DesignSystem.spacing24)
            .padding(.top, DesignSystem.spacing16)
            .padding(.bottom, DesignSystem.spacing48)
            .opacity(showExercises ? 1 : 0)
            .scaleEffect(showExercises ? 1.0 : (reduceMotion ? 1.0 : 0.95))
            .accessibilityHint("Starts the \(position.sessionTitle) session for \(selectedDuration) minutes")
        }
        .onAppear {
            pulse = true

            if reduceMotion {
                appeared = true
                showExercises = true
            } else {
                withAnimation(.easeOut(duration: 0.5)) {
                    appeared = true
                }
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(400))
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                        showExercises = true
                    }
                }
            }

            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }
}
