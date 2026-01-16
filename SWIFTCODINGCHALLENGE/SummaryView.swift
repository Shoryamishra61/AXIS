// SummaryView.swift
// Axis - The Invisible Posture Companion
// Distinguished Winner Session Summary for Swift Student Challenge 2026
//
// "End the session on a high note with celebration and actionable insight."
// Every metric tells a story. Make the user feel accomplished.

import SwiftUI
struct SummaryView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @ObservedObject private var metrics = SessionMetrics.shared
    
    @State private var showContent = false
    @State private var animateProgress = false
    @State private var celebrateComplete = false
    
    private var summary: SessionSummary {
        metrics.getSummary()
    }
    
    var body: some View {
        ZStack {
            // Background
            AxisColor.backgroundGradient.ignoresSafeArea()
            
            // Celebration particles
            if celebrateComplete {
                celebrationParticles
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Success header
                    headerSection
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    
                    // Performance level
                    performanceBadge
                        .opacity(showContent ? 1 : 0)
                        .scaleEffect(showContent ? 1 : 0.8)
                    
                    // Metrics cards
                    metricsGrid
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 30)
                    
                    // Challenging exercises (if any)
                    if !summary.challengingExercises.isEmpty {
                        challengingSection
                            .opacity(showContent ? 1 : 0)
                    }
                    
                    // Done button
                    doneButton
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 40)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                showContent = true
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
                animateProgress = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                celebrateComplete = true
                AxisHaptic.success()
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: AxisSpacing.md) {
            // Sparkle icon with animation
            ZStack {
                Circle()
                    .fill(AxisColor.aligned.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundColor(AxisColor.aligned)
                    .symbolEffect(.bounce, value: showContent)
            }
            
            Text("Session Complete")
                .font(.axisTitle)
                .foregroundColor(AxisColor.textPrimary)
            
            Text(summary.performanceLevel.message)
                .font(.axisHeadline)
                .foregroundColor(AxisColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AxisSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Session complete. \(summary.performanceLevel.message)")
    }
    
    // MARK: - Performance Badge
    
    private var performanceBadge: some View {
        HStack(spacing: AxisSpacing.md) {
            Text(summary.performanceLevel.emoji)
                .font(.system(size: 32))
            
            VStack(alignment: .leading, spacing: AxisSpacing.xs) {
                Text(summary.performanceLevel.rawValue)
                    .font(.axisButton)
                    .foregroundColor(AxisColor.textPrimary)
                
                // Accuracy ring
                HStack(spacing: AxisSpacing.sm) {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 4)
                            .frame(width: 40, height: 40)
                        
                        Circle()
                            .trim(from: 0, to: animateProgress ? summary.averageAccuracy : 0)
                            .stroke(
                                AxisColor.accuracy(summary.averageAccuracy),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .frame(width: 40, height: 40)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeOut(duration: 1.0), value: animateProgress)
                        
                        Text(summary.formattedAccuracy)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(AxisColor.accuracy(summary.averageAccuracy))
                    }
                    
                    Text("Accuracy")
                        .font(.axisCaption)
                        .foregroundColor(AxisColor.textSecondary)
                }
            }
        }
        .padding(.horizontal, AxisSpacing.lg)
        .padding(.vertical, AxisSpacing.md)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AxisRadius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: AxisRadius.xl)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(summary.performanceLevel.rawValue). \(summary.formattedAccuracy) accuracy.")
    }
    
    // MARK: - Metrics Grid
    
    private var metricsGrid: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                MetricCard(
                    icon: "figure.walk",
                    title: "Exercises",
                    value: "\(summary.totalExercises)",
                    color: AxisColor.primary
                )
                
                MetricCard(
                    icon: "target",
                    title: "Time in Target",
                    value: summary.formattedTimeInTarget,
                    color: AxisColor.success
                )
            }
            
            HStack(spacing: 16) {
                MetricCard(
                    icon: "clock",
                    title: "Duration",
                    value: summary.formattedDuration,
                    color: AxisColor.secondary
                )
                
                MetricCard(
                    icon: "flame",
                    title: "Most Challenging",
                    value: truncate(summary.mostChallenging, to: 12),
                    color: AxisColor.warning,
                    isSmallText: true
                )
            }
        }
    }
    
    // MARK: - Challenging Section
    
    private var challengingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Areas to Focus")
                .font(.axisTechnical)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                ForEach(summary.challengingExercises, id: \.self) { exercise in
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundStyle(AxisColor.warning)
                            .font(.caption)
                        
                        Text(exercise)
                            .font(.axisInstruction)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Text("Practice more")
                            .font(.axisCaption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(AxisColor.warning.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Done Button
    
    private var doneButton: some View {
        Button {
            AxisHaptic.tap()
            coordinator.returnHome()
        } label: {
            Text("Done")
                .font(.axisButton)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.white, in: Capsule())
                .shadow(color: Color.white.opacity(0.3), radius: 15, y: 5)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Celebration Particles
    
    private var celebrationParticles: some View {
        GeometryReader { geo in
            ForEach(0..<20, id: \.self) { index in
                Circle()
                    .fill(
                        [AxisColor.success, AxisColor.primary, AxisColor.calm, AxisColor.secondary][index % 4]
                    )
                    .frame(width: CGFloat.random(in: 4...8))
                    .position(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: CGFloat.random(in: -50...geo.size.height * 0.3)
                    )
                    .opacity(0.6)
                    .animation(
                        .easeOut(duration: Double.random(in: 1.5...3.0))
                        .delay(Double(index) * 0.05),
                        value: celebrateComplete
                    )
            }
        }
        .allowsHitTesting(false)
    }
    
    // MARK: - Helpers
    
    private func truncate(_ text: String, to length: Int) -> String {
        if text.count <= length { return text }
        return String(text.prefix(length - 3)) + "..."
    }
}

// MARK: - Metric Card Component

struct MetricCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    var isSmallText: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(isSmallText ? .axisTechnical : .system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(title)
                .font(.axisCaption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Preview

#Preview {
    SummaryView()
        .environmentObject(AppCoordinator())
}
