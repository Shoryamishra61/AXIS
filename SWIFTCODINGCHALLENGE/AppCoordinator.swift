// AppCoordinator.swift
// Axis - The Invisible Posture Companion
// Central State Management for Swift Student Challenge 2026

import SwiftUI
import Combine

// MARK: - App State
enum AppState: Equatable {
    case idle
    case setup
    case alignmentCheck
    case sessionRunning
    case summary
}

// MARK: - App Coordinator
class AppCoordinator: ObservableObject {
    // MARK: - Published State
    @Published var appState: AppState = .idle
    @Published var selectedPosture: String = "Sitting"
    @Published var selectedDuration: Double = 2.0  // Default 2 min for quick demo
    @Published var selectedGuidanceMode: GuidanceMode = .audioOnly  // Default to audio since it always works
    @Published var isWheelchairUser: Bool = false
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    // MARK: - Session History
    @Published var lastSessionDate: Date?
    @Published var totalSessionsCompleted: Int = 0
    
    // MARK: - Initialization
    init() {
        // Check if user has seen the NEW 3-screen onboarding (v2)
        // If they only saw v1, reset to show new version
        let onboardingVersion = UserDefaults.standard.integer(forKey: "onboardingVersion")
        if onboardingVersion < 2 {
            // User hasn't seen the new 3-screen narrative, reset onboarding
            hasCompletedOnboarding = false
        } else {
            hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        }
        
        totalSessionsCompleted = UserDefaults.standard.integer(forKey: "totalSessionsCompleted")
        
        if let lastDate = UserDefaults.standard.object(forKey: "lastSessionDate") as? Date {
            lastSessionDate = lastDate
        }
    }
    
    /// Mark onboarding as complete (called from OnboardingView)
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(2, forKey: "onboardingVersion") // Mark v2 as seen
    }
    
    /// Reset onboarding to show again (for testing/debug)
    func resetOnboarding() {
        hasCompletedOnboarding = false
        UserDefaults.standard.removeObject(forKey: "onboardingVersion")
    }
    
    // MARK: - Navigation Methods
    
    /// Navigate to session setup
    func startSetup() {
        appState = .setup
    }
    
    /// Start the actual session with context
    func startSession(posture: String, duration: Double) {
        selectedPosture = posture
        selectedDuration = duration
        appState = .sessionRunning
        
        // Start motion tracking
        MotionManager.shared.startUpdates()
    }
    
    /// Navigate to alignment check (camera mirror)
    func showAlignmentCheck() {
        appState = .alignmentCheck
    }
    
    /// Complete session and show summary
    func completeSession() {
        // Stop sensors
        MotionManager.shared.stopUpdates()
        SpeechManager.shared.stop()
        
        // Update stats
        totalSessionsCompleted += 1
        lastSessionDate = Date()
        
        // Persist
        UserDefaults.standard.set(totalSessionsCompleted, forKey: "totalSessionsCompleted")
        UserDefaults.standard.set(lastSessionDate, forKey: "lastSessionDate")
        
        // Navigate
        appState = .summary
    }
    
    /// Return to home screen
    func returnHome() {
        // Stop sensors
        MotionManager.shared.stopUpdates()
        SpeechManager.shared.stop()
        
        // Navigate
        appState = .idle
    }
    
    // MARK: - Quick Actions
    
    /// Start a quick 2-minute focus session
    func startQuickSession() {
        selectedDuration = 2.0
        selectedPosture = "Sitting"
        appState = .sessionRunning
        MotionManager.shared.startUpdates()
    }
    
    /// Start eye relief session
    func startEyeRelief() {
        selectedDuration = 3.0
        selectedPosture = "Sitting"
        appState = .sessionRunning
        MotionManager.shared.startUpdates()
    }
    
    // MARK: - State Helpers
    
    var isInSession: Bool {
        appState == .sessionRunning
    }
    
    var canStartSession: Bool {
        appState == .idle || appState == .setup
    }
    
    var formattedLastSession: String? {
        guard let date = lastSessionDate else { return nil }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
