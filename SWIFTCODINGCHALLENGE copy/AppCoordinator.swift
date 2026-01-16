import SwiftUI
import AVFoundation
import Combine

class AppCoordinator: ObservableObject {
    @Published var appState: AppState = .idle
    @Published var selectedPosture: String = "Sitting"
    @Published var selectedDuration: Double = 3.0
    @Published var isWheelchairUser: Bool = false // Required for Task 5
    
    enum AppState {
        case idle
        case setup
        case alignmentCheck
        case sessionRunning
        case summary
    }
    
    func startSetup() {
        stopSensors()
        withAnimation { appState = .setup }
    }
    
    func startSession(posture: String, duration: Double) {
        self.selectedPosture = posture
        self.selectedDuration = duration
        withAnimation { appState = .sessionRunning }
    }
    
    func returnHome() {
        stopSensors()
        withAnimation { appState = .idle }
    }
    
    func completeSession() {
        stopSensors()
        withAnimation { appState = .summary }
    }

    private func stopSensors() {
        MotionManager.shared.stopUpdates()
        SpeechManager.shared.stop()
        // Fixed: Correct capitalization to match AudioManager
        AudioManager.shared.stopSynth()
    }
}
