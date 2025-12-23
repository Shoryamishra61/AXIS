import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    
    let stories = [
        OnboardingStory(title: "The 27kg Burden", 
                        sub: "The average head weighs 5kg. At a 60° tilt—standard for texting—your spine bears 27kg. We call this 'Tech Neck'.", 
                        icon: "figure.piloc"),
        OnboardingStory(title: "Invisible Correction", 
                        sub: "No public gym exercises. Axis uses AirPods sensors to guide you through subtle micro-movements that fix alignment in real-time.", 
                        icon: "airpods.pro"),
        OnboardingStory(title: "Privacy as a Core", 
                        sub: "Military-grade on-device processing. No cameras recorded. No data leaves this iPhone. Your health is your own.", 
                        icon: "shield.checkered")
    ]
    
    var body: some View {
        ZStack {
            AxisColor.backgroundGradient.ignoresSafeArea()
            
            VStack(spacing: 40) {
                TabView(selection: $currentPage) {
                    ForEach(0..<stories.count, id: \.self) { index in
                        VStack(spacing: 24) {
                            Image(systemName: stories[index].icon)
                                .font(.system(size: 80))
                                .foregroundStyle(.teal)
                            
                            Text(stories[index].title)
                                .font(.axisTitle)
                                .multilineTextAlignment(.center)
                            
                            Text(stories[index].sub)
                                .font(.axisInstruction)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                
                Button {
                    if currentPage < stories.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        hasCompletedOnboarding = true
                    }
                } label: {
                    Text(currentPage == stories.count - 1 ? "Begin" : "Next")
                        .font(.axisTechnical)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.teal, in: Capsule())
                        .foregroundStyle(.black)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingStory {
    let title: String
    let sub: String
    let icon: String
}