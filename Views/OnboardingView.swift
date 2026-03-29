// OnboardingView.swift

// 3-page illustrated introduction to the application.
// Smart Skip enables returning users to bypass this automatically.
// Supports swipe gesture for iOS muscle memory (HIG compliance).
// Accessibility: reduce motion, accessibility hints, 44pt touch targets.

import SwiftUI

struct OnboardingView: View {

    let page: Int
    let onNext: (AXISCoreFlowView.FlowStep) -> Void

    /// Optional namespace from AXISCoreFlowView for matchedGeometryEffect spine transition.
    var spineNamespace: Namespace.ID?

    @State private var demoDeviation: Double = -0.6
    @State private var appeared = false
    @State private var dragOffset: CGFloat = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private struct PageContent {
        let icon: String
        let accent: Color
        let title: String
        let subtitle: String
        let figures: [String]
    }

    private let pages: [PageContent] = [
        PageContent(
            icon: "person.fill",
            accent: AXISTheme.warning,
            title: "Tech Neck\nis a Modern Epidemic",
            subtitle: "Looking at a screen pushes your head forward, adding up to 60 lbs of strain on your cervical spine. This causes chronic pain, headaches, and nerve compression.",
            figures: ["iphone", "desktopcomputer", "laptopcomputer"]
        ),
        PageContent(
            icon: "airpodspro",
            accent: AXISTheme.accent,
            title: "Clinical Head Tracking\nwith AirPods",
            subtitle: "AXIS reads the motion sensors built into your AirPods Pro to measure head position — pitch, yaw, and roll — with clinical-grade precision.",
            figures: ["gyroscope", "waveform.path.ecg", "sensor.fill"]
        ),
        PageContent(
            icon: "figure.mind.and.body",
            accent: AXISTheme.success,
            title: "Guided Exercises.\nReal-Time Feedback.",
            subtitle: "Follow evidence-based cervical protocols. An animated spine tracks your movements and coaches you through every rep.",
            figures: ["timer", "checkmark.circle.fill", "chart.line.uptrend.xyaxis"]
        )
    ]

    // MARK: - Spine Preview (page 0)
    // A computed property is required here because SwiftUI ViewBuilder blocks
    // don't support `let` bindings that are then conditionally modified.

    @ViewBuilder
    private var spinePreview: some View {
        let base = AxisSplineVisualizer(
            deviation: demoDeviation,
            isInGoodZone: abs(demoDeviation) < 0.25,
            breathingPhase: .setup,
            sessionProgress: 0.0,
            motionAxis: .pitch,
            zoneIntensity: abs(demoDeviation) < 0.25 ? 0.5 : 0
        )
        .frame(width: 160, height: 160)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(
                .easeInOut(duration: 2.5).repeatForever(autoreverses: true)
            ) {
                demoDeviation = 0.6
            }
        }

        if let ns = spineNamespace, !reduceMotion {
            base.matchedGeometryEffect(id: "axisSpine", in: ns, isSource: true)
        } else {
            base
        }
    }

    var body: some View {
        let p = pages[page]

        VStack(spacing: 0) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .shadow(color: Color.black.opacity(0.04), radius: 20, y: 8)

                VStack(spacing: DesignSystem.spacing20) {

                    if page == 0 {
                        spinePreview
                    } else {
                        Image(systemName: p.icon)
                            .font(.largeTitle)
                            .foregroundStyle(p.accent)
                            .symbolEffect(.pulse, options: reduceMotion ? .nonRepeating : .repeating)
                            .accessibilityHidden(true)
                    }

                    HStack(spacing: DesignSystem.spacing24) {
                        ForEach(p.figures, id: \.self) { fig in
                            Image(systemName: fig)
                                .font(.title3)
                                .foregroundStyle(p.accent.opacity(0.7))
                                .frame(width: DesignSystem.minTouchTarget, height: DesignSystem.minTouchTarget)
                                .background(p.accent.opacity(0.1))
                                .clipShape(Circle())
                                .accessibilityHidden(true)
                        }
                    }
                }
                .padding(.vertical, DesignSystem.spacing32)
            }
            .frame(minHeight: 260)
            .padding(.horizontal, DesignSystem.spacing24)
            .scaleEffect(appeared ? 1.0 : (reduceMotion ? 1.0 : 0.92))
            .opacity(appeared ? 1.0 : 0.0)
            .offset(x: reduceMotion ? 0 : dragOffset)

            Spacer().frame(height: DesignSystem.spacing32)

            VStack(spacing: DesignSystem.spacing12) {
                Text(p.title)
                    .font(.system(.title2, design: .serif).bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .accessibilityAddTraits(.isHeader)
                    .id("title-\(page)")
                    .transition(.opacity.combined(with: .move(edge: .trailing)))

                Text(p.subtitle)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .id("sub-\(page)")
                    .transition(.opacity)
            }
            .padding(.horizontal, DesignSystem.spacing32)
            .animation(reduceMotion ? .none : .easeInOut(duration: 0.35), value: page)
            .offset(x: reduceMotion ? 0 : dragOffset * 0.5)

            Spacer()

            // Page indicators
            HStack(spacing: DesignSystem.spacing8) {
                ForEach(0..<pages.count, id: \.self) { i in
                    Capsule()
                        .fill(i == page ? AXISTheme.accent : Color(UIColor.tertiarySystemFill))
                        .frame(width: i == page ? 22 : 8, height: 8)
                        .animation(reduceMotion ? .none : .spring(response: 0.3), value: page)
                }
            }
            .accessibilityLabel("Page \(page + 1) of \(pages.count)")
            .padding(.bottom, DesignSystem.spacing20)

            // Primary CTA
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                if page < pages.count - 1 {
                    onNext(.onboarding(page: page + 1))
                } else {
                    onNext(.pickPosition)
                }
            } label: {
                Text(page < pages.count - 1 ? "Continue" : "Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: DesignSystem.minTouchTarget)
            }
            .prominentButtonStyle()
            .padding(.horizontal, DesignSystem.spacing24)
            .padding(.bottom, DesignSystem.spacing24)
            .accessibilityHint(page < pages.count - 1 ? "Advances to the next introduction page" : "Begins exercise selection")

            // Skip button with proper touch target
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onNext(.pickPosition)
            } label: {
                Text("Skip")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(minWidth: DesignSystem.minTouchTarget, minHeight: DesignSystem.minTouchTarget)
            }
            .secondaryButtonStyle()
        }
        .gesture(
            DragGesture(minimumDistance: 30, coordinateSpace: .local)
                .onChanged { value in
                    guard !reduceMotion else { return }
                    dragOffset = value.translation.width * 0.4
                }
                .onEnded { value in
                    let threshold: CGFloat = 60
                    if !reduceMotion {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            dragOffset = 0
                        }
                    }
                    if value.translation.width < -threshold {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        if page < pages.count - 1 {
                            onNext(.onboarding(page: page + 1))
                        } else {
                            onNext(.pickPosition)
                        }
                    } else if value.translation.width > threshold && page > 0 {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        onNext(.onboarding(page: page - 1))
                    }
                }
        )
        .onAppear {
            if reduceMotion {
                appeared = true
            } else {
                withAnimation(DesignSystem.springSmooth) {
                    appeared = true
                }
            }
        }
        .onChange(of: page) { _, _ in
            if reduceMotion {
                appeared = true
            } else {
                appeared = false
                withAnimation(DesignSystem.springSmooth) {
                    appeared = true
                }
            }
        }
    }
}
