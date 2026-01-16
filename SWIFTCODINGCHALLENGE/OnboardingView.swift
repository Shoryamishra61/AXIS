// OnboardingView.swift
// Axis - The Invisible Posture Companion
// Distinguished Winner Onboarding for Swift Student Challenge 2026
//
// "The narrative behind your app carries more weight than code complexity."
// This onboarding tells our story in 3 screens: Problem → Solution → Promise

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var pageOffset: CGFloat = 0
    
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    // 3-Screen Narrative: Problem → Solution → Promise
    let stories: [OnboardingStory] = [
        // Screen 1: THE PROBLEM (Emotional hook)
        OnboardingStory(
            title: "Your Neck Carries Weight",
            subtitle: "Hours of screen time create invisible strain.",
            detail: "At 60° forward tilt, your cervical spine bears 27kg of pressure. We call this 'Tech Neck' — the silent cost of our digital lives.",
            icon: "figure.walk.motion",
            accentColor: AxisColor.critical
        ),
        // Screen 2: THE SOLUTION (Our approach)
        OnboardingStory(
            title: "Invisible Guidance",
            subtitle: "Using sensors in your AirPods, Axis provides gentle corrections.",
            detail: "No gym. No awkward stretches. Just micro-adjustments through haptics and spatial audio while you work.",
            icon: "airpods.pro",
            accentColor: AxisColor.primary
        ),
        // Screen 3: THE PROMISE (Trust & start)
        OnboardingStory(
            title: "Private by Design",
            subtitle: "All processing happens on your device.",
            detail: "Your biometric privacy is absolute. No cloud. No accounts. No tracking. No compromise.",
            icon: "lock.shield.fill",
            accentColor: AxisColor.aligned
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
            
            // Text content with proper hierarchy
            VStack(spacing: AxisSpacing.lg) {
                Text(story.title)
                    .font(.axisTitle)
                    .foregroundColor(AxisColor.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(story.subtitle)
                    .font(.axisHeadline)
                    .foregroundColor(AxisColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AxisSpacing.lg)
                
                Text(story.detail)
                    .font(.axisBody)
                    .foregroundColor(AxisColor.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AxisSpacing.xl)
                    .lineSpacing(4)
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
