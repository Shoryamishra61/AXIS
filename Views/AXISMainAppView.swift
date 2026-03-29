// AXISMainAppView.swift

// Main Application entry point handling the sequence of launch animation -> core flow.

import SwiftUI

// MARK: - Main App View
// Launch animation → 3-minute guided flow.

struct AXISMainAppView: View {
    @State private var launchAnimationComplete = false

    var body: some View {
        Group {
            if !launchAnimationComplete {
                AXISLaunchAnimation {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        launchAnimationComplete = true
                    }
                }
            } else {
                AXISCoreFlowView()
            }
        }
    }
}
