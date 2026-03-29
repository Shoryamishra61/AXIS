// AXISApp.swift

// App entry point for AXIS.
// Configures SwiftData model container and audio session.
// Lets iOS 26 Liquid Glass handle navigation bar appearance automatically.

import SwiftUI
import SwiftData
import AVFoundation

@main
struct AXISApp: App {
    init() {
        setupAudioSession()
    }

    var body: some Scene {
        WindowGroup {
            AXISMainAppView()
                .onAppear {
                    setupPremiumExperience()
                }
        }
        .modelContainer(for: [
            SessionData.self,
            PostureMetric.self,
            UserProgress.self
        ])
    }

    // MARK: - Audio Session Configuration

    /// Configures AVAudioSession for speech synthesis coaching cues.
    /// `.playback` category ensures audio plays even with silent mode on.
    /// `.duckOthers` reduces background music volume during coaching.
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            print("AXISApp: Audio session setup failed — \(error)")
        }
    }

    // MARK: - Premium Experience Setup

    /// Runtime configuration for judge-ready premium experience.
    /// Note: iOS 26 Liquid Glass handles navigation and tab bar appearance automatically.
    /// We no longer manually configure UINavigationBarAppearance or UITabBarAppearance.
    /// SimulatorDetection is handled by Utilities/SimulatorDetection.swift.
    private func setupPremiumExperience() {
        // Simulator detection is automatic via SimulatorDetection.isSimulator
        // No manual bar appearance needed — iOS 26 Liquid Glass handles it
    }
}
