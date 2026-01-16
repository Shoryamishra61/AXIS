// OnboardingView.swift
// Axis - The Invisible Posture Companion
// Emotional Narrative Onboarding for Swift Student Challenge 2026

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var pageOffset: CGFloat = 0
    
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    let stories: [OnboardingStory] = [
        OnboardingStory(
            title: "The 27kg Burden",
            subtitle: "At a 60° tilt, your cervical spine bears 27kg of pressure.",
            detail: "We call this 'Tech Neck' — the silent cost of our digital lives.",
            icon: "figure.walk.motion",
            accentColor: .orange
        ),
        OnboardingStory(
            title: "Zero-Context Correction",
            subtitle: "Invisible micro-adjustments while you work.",
            detail: "No gym. No awkward stretches in the library. Just gentle guidance through sound and touch.",
            icon: "airpods.pro",
            accentColor: AxisColor.primary
        ),
        OnboardingStory(
            title: "Privacy First",
            subtitle: "All motion data is processed on-device.",
            detail: "Your biometric privacy is absolute. No cloud. No tracking. No compromise.",
            icon: "lock.shield.fill",
            accentColor: .green
        ),
        OnboardingStory(
            title: "Ready When You Are",
            subtitle: "2 minutes or 10 — you choose.",
            detail: "Sitting, standing, or lying down. Axis adapts to your context and respects your time.",
            icon: "clock.badge.checkmark.fill",
            accentColor: AxisColor.secondary
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            AxisColor.backgroundGradient.ignoresSafeArea()
            
            // Ambient glow based on current page
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            stories[currentPage].accentColor.opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 400
                    )
                )
                .blur(radius: 80)
                .offset(y: -100)
                .animation(.easeInOut(duration: 0.5), value: currentPage)
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button {
                        completeOnboarding()
                    } label: {
                        Text("Skip")
                            .font(.axisTechnical)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<stories.count, id: \.self) { index in
                        storyPage(stories[index], index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)
                
                // Custom page indicator
                pageIndicator
                    .padding(.bottom, 24)
                
                // Action button
                actionButton
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
            }
        }
    }
    
    // MARK: - Story Page
    
    private func storyPage(_ story: OnboardingStory, index: Int) -> some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon with animated ring
            ZStack {
                // Outer ring
                Circle()
                    .stroke(story.accentColor.opacity(0.2), lineWidth: 2)
                    .frame(width: 160, height: 160)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: currentPage == index ? 1.0 : 0.0)
                    .stroke(
                        story.accentColor.opacity(0.5),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.8), value: currentPage)
                
                // Icon background
                Circle()
                    .fill(story.accentColor.opacity(0.15))
                    .frame(width: 120, height: 120)
                
                // Icon
                Image(systemName: story.icon)
                    .font(.system(size: 48))
                    .foregroundStyle(story.accentColor)
                    .symbolEffect(.bounce, value: currentPage == index)
            }
            
            // Text content
            VStack(spacing: 20) {
                Text(story.title)
                    .font(.axisTitle)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                
                Text(story.subtitle)
                    .font(.axisInstruction)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                Text(story.detail)
                    .font(.axisCaption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineLimit(3)
            }
            
            Spacer()
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(story.title). \(story.subtitle). \(story.detail)")
    }
    
    // MARK: - Page Indicator
    
    private var pageIndicator: some View {
        HStack(spacing: 10) {
            ForEach(0..<stories.count, id: \.self) { index in
                Capsule()
                    .fill(currentPage == index ? stories[currentPage].accentColor : Color.white.opacity(0.3))
                    .frame(width: currentPage == index ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
    }
    
    // MARK: - Action Button
    
    private var actionButton: some View {
        Button {
            if currentPage < stories.count - 1 {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentPage += 1
                }
                AxisHaptic.tick()
            } else {
                completeOnboarding()
            }
        } label: {
            HStack(spacing: 8) {
                Text(currentPage == stories.count - 1 ? "Get Started" : "Continue")
                    .font(.axisButton)
                
                if currentPage < stories.count - 1 {
                    Image(systemName: "arrow.right")
                        .font(.caption.weight(.bold))
                }
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                currentPage == stories.count - 1
                    ? AxisColor.buttonGradient
                    : LinearGradient(colors: [stories[currentPage].accentColor], startPoint: .leading, endPoint: .trailing),
                in: Capsule()
            )
            .shadow(color: stories[currentPage].accentColor.opacity(0.4), radius: 15, y: 8)
        }
        .animation(.easeInOut(duration: 0.3), value: currentPage)
    }
    
    // MARK: - Complete Onboarding
    
    private func completeOnboarding() {
        AxisHaptic.success()
        withAnimation(.easeOut(duration: 0.3)) {
            hasCompletedOnboarding = true
        }
    }
}

// MARK: - Onboarding Story Model

struct OnboardingStory {
    let title: String
    let subtitle: String
    let detail: String
    let icon: String
    let accentColor: Color
}

// MARK: - Preview

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
