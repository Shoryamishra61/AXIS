// PositionPickerView.swift

// Let the user pick their orientation (sitting, standing, lying down).
// Fogg B=MAT triggers present time-aware dynamic messaging.
// Accessibility: reduce motion, accessibility hints, structured concurrency.

import SwiftUI
import SwiftData

struct PositionPickerView: View {

    let onSelect: (UserPosition) -> Void

    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: \SessionData.date, order: .reverse) private var sessions: [SessionData]
    @Query private var userProgresses: [UserProgress]

    private var timeAwareMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "Good morning. Your neck carried you through the night. Let's give it some care."
        } else if hour < 17 {
            return "Your neck has worked hard today. Let's give it 2 minutes of care."
        } else {
            return "Wind down with your spine. A gentle reset now helps you sleep better tonight."
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.spacing24) {

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: DesignSystem.spacing8) {
                        Text("Choose Position")
                            .font(.system(.largeTitle, design: .serif).bold())
                            .foregroundStyle(.primary)
                            .accessibilityAddTraits(.isHeader)
                        Text(timeAwareMessage)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    }
                    Spacer()
                }
                .padding(.top, 60)

                VStack(spacing: DesignSystem.spacing12) {
                    ForEach(Array(UserPosition.allCases.enumerated()), id: \.element.id) { index, pos in
                        PositionRow(position: pos) { onSelect(pos) }
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : (reduceMotion ? 0 : 20))
                            .animation(
                                reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.08),
                                value: appeared
                            )
                    }
                }

                HStack(spacing: DesignSystem.spacing12) {
                    Image(systemName: "airpodspro")
                        .font(.title3)
                        .foregroundStyle(AXISTheme.accent)
                    Text("AirPods Pro enable real-time head tracking. Without them, AXIS guides you through every movement with audio coaching — you'll still get the full benefit.")
                        .font(.callout)
                        .foregroundStyle(.primary.opacity(0.7))
                }
                .padding(DesignSystem.spacing16)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .accessibilityElement(children: .combine)
                .accessibilityLabel("AirPods information. AirPods Pro enable real-time head tracking. Without them, AXIS guides you with audio coaching.")

                // My Progress (#7)
                if !sessions.isEmpty {
                    VStack(alignment: .leading, spacing: DesignSystem.spacing12) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.callout)
                                .foregroundStyle(AXISTheme.success)
                            Text("My Progress")
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(.primary)
                        }

                        HStack(spacing: DesignSystem.spacing16) {
                            ProgressStatItem(
                                value: "\(sessions.first?.completionRate.formatted(.number.precision(.fractionLength(0))) ?? "0")%",
                                label: "Last Score",
                                color: AXISTheme.accent
                            )
                            ProgressStatItem(
                                value: "\(sessions.count)",
                                label: sessions.count == 1 ? "Session" : "Sessions",
                                color: AXISTheme.secondaryAccent
                            )
                            ProgressStatItem(
                                value: formatCumulativeTime(userProgresses.first?.totalSecondsInZone ?? 0),
                                label: "In Zone",
                                color: AXISTheme.success
                            )
                        }
                    }
                    .padding(DesignSystem.spacing16)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("My Progress. \(sessions.count) sessions completed.")
                }

                Spacer(minLength: DesignSystem.spacing40)
            }
            .padding(.horizontal, DesignSystem.standardPadding)
        }
        .onAppear {
            if reduceMotion {
                appeared = true
            } else {
                withAnimation(DesignSystem.springSmooth) {
                    appeared = true
                }
            }
            // Ghost haptic cascade
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(150))
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(300))
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }
        }
    }

    private func formatCumulativeTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return m > 0 ? "\(m)m \(s)s" : "\(s)s"
    }
}

struct PositionRow: View {

    let position: UserPosition
    let action: () -> Void

    private var posColor: Color {
        switch position {
        case .sitting:  return AXISTheme.accent
        case .standing: return AXISTheme.secondaryAccent
        case .lying:    return AXISTheme.warning
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.spacing16) {
                Image(systemName: position.sfSymbol)
                    .font(.title3)
                    .foregroundStyle(posColor)
                    .frame(width: DesignSystem.minTouchTarget, height: DesignSystem.minTouchTarget)
                    .background(posColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .symbolEffect(.breathe, options: position == .sitting ? .repeating : .nonRepeating, value: position == .sitting)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: DesignSystem.spacing8) {
                        Text(position.rawValue)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.primary)
                        if position == .sitting {
                            Text("Recommended")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AXISTheme.success)
                                .padding(.horizontal, DesignSystem.spacing8)
                                .padding(.vertical, 2)
                                .background(AXISTheme.success.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                    Text("\(position.sessionTitle) · 2–10 min")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
                    .accessibilityHidden(true)
            }
            .padding(DesignSystem.spacing16)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.buttonCornerRadius, style: .continuous))
        }
        .buttonStyle(PremiumCardButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(position.rawValue), \(position.sessionTitle)")
        .accessibilityHint("Opens the \(position.sessionTitle.lowercased()) exercise session setup")
    }
}

struct PremiumCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

private struct ProgressStatItem: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
