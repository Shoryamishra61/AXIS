// AXISCoreFlowView.swift
//
// Root State Machine. Manages transitions between the major phases
// of the application: Onboarding → Picker → Session → Summary.
//
// Improvements over previous version:
//   • matchedGeometryEffect on the spine visualiser (onboarding ↔ session)
//   • Declarative .sensoryFeedback modifiers (SwiftUI 5+) replacing imperative UIImpactFeedbackGenerator
//   • .navigationTransition for iOS 18 morphing flow instead of push/pop

import SwiftUI
import SwiftData

struct AXISCoreFlowView: View {

    enum FlowStep {
        case onboarding(page: Int)
        case pickPosition
        case prepSession(UserPosition)
        case session(UserPosition, Int) // position, duration in minutes
        case summary(SessionSummary)
    }

    @State private var step: FlowStep = .onboarding(page: 0)
    @State private var motion = MotionManager()

    @Environment(\.modelContext) private var modelContext
    @Query private var userProgresses: [UserProgress]
    @State private var showJudgeMilestone = false

    // ── Matched Geometry Namespace ────────────────────────────
    @Namespace private var flowNamespace

    // ── Sensory Feedback Triggers (declarative SwiftUI haptics) ────
    @State private var didExitToSummary = false
    @State private var didStartSession = false
    @State private var didReturnToMenu = false

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            NavigationStack {
                Group {
                    switch step {
                    case .onboarding(let page):
                        OnboardingView(
                            page: page,
                            onNext: { nextStep in
                                withAnimation(DesignSystem.springSmooth) {
                                    step = nextStep
                                }
                            },
                            spineNamespace: flowNamespace
                        )

                    case .pickPosition:
                        PositionPickerView { pos in
                            didStartSession = true
                            withAnimation(DesignSystem.springSmooth) {
                                step = .prepSession(pos)
                            }
                        }
                        .transition(.move(edge: .trailing).combined(with: .opacity))

                    case .prepSession(let pos):
                        SessionPrepView(position: pos) { duration in
                            withAnimation(DesignSystem.springSmooth) {
                                step = .session(pos, duration)
                            }
                        }
                        .transition(.move(edge: .trailing).combined(with: .opacity))

                    case .session(let pos, let duration):
                        AXISSessionView(
                            viewModel: SessionViewModel(position: pos, motionManager: motion, duration: duration),
                            motionManager: motion,
                            onComplete: { summary in
                                let goodSeconds = (summary.alignmentScore * summary.totalSeconds) / 100

                                let progress: UserProgress
                                if let existing = userProgresses.first {
                                    progress = existing
                                } else {
                                    progress = UserProgress()
                                    modelContext.insert(progress)
                                }

                                progress.totalSecondsInZone += goodSeconds

                                if progress.totalSecondsInZone >= 60 && !progress.reachedFirstMilestone {
                                    progress.reachedFirstMilestone = true
                                    showJudgeMilestone = true
                                }

                                try? modelContext.save()

                                didExitToSummary = true
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    step = .summary(summary)
                                }
                            },
                            onExit: {
                                didReturnToMenu = true
                                withAnimation(DesignSystem.springSmooth) {
                                    step = .pickPosition
                                }
                            },
                            spineNamespace: flowNamespace
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))

                    case .summary(let summary):
                        SessionSummaryView(
                            summary: summary,
                            cumulativeSeconds: userProgresses.first?.totalSecondsInZone ?? 0,
                            onDone: {
                                didReturnToMenu = true
                                withAnimation(DesignSystem.springSmooth) {
                                    step = .pickPosition
                                }
                            }
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            }
        }
        // ── Declarative Haptic Feedback ─────────────────────────────
        .sensoryFeedback(.impact(weight: .medium), trigger: didStartSession)
        .sensoryFeedback(.success, trigger: didExitToSummary)
        .sensoryFeedback(.impact(weight: .light), trigger: didReturnToMenu)

        // ── Milestone Sheet ──────────────────────────────────────────
        .sheet(isPresented: $showJudgeMilestone) {
            MilestoneSheetView()
        }
    }
}
