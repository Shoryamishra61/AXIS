import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    
    let stories = [
        OnboardingStory(title: "The 27kg Burden", sub: "At a 60° tilt, your cervical spine bears 27kg of pressure. We call this 'Tech Neck'.", icon: "figure.piloc"),
        OnboardingStory(title: "Zero-Context Correction", sub: "Axis uses AirPods to guide you through invisible micro-adjustments while you work.", icon: "airpods.pro"),
        OnboardingStory(title: "Privacy First", sub: "All motion data is processed on-device. Your biometric privacy is absolute.", icon: "shield.checkered")
    ]
    
    var body: some View {
        ZStack {
            AxisColor.backgroundGradient.ignoresSafeArea()
            VStack(spacing: 40) {
                TabView(selection: $currentPage) {
                    ForEach(0..<stories.count, id: \.self) { index in
                        VStack(spacing: 24) {
                            Image(systemName: stories[index].icon).font(.system(size: 80)).foregroundStyle(.teal)
                            Text(stories[index].title).font(.axisTitle).multilineTextAlignment(.center)
                            Text(stories[index].sub).font(.axisInstruction).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal, 40)
                        }.tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                
                Button(action: { if currentPage < stories.count - 1 { withAnimation { currentPage += 1 } } else { hasCompletedOnboarding = true } }) {
                    Text(currentPage == stories.count - 1 ? "Begin" : "Next").font(.axisTechnical).frame(maxWidth: .infinity).padding().background(.teal, in: Capsule()).foregroundStyle(.black)
                }.padding(.horizontal, 40).padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingStory { let title: String; let sub: String; let icon: String }
