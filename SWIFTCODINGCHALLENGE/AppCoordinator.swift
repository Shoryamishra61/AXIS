import SwiftUI
import AVFoundation

// THE SINGLE SOURCE OF TRUTH
// This class controls the entire app flow. It prevents "Misflow" by enforcing strict states.
class AppCoordinator: ObservableObject {
    @Published var appState: AppState = .idle
    @Published var selectedPosture: String = "Sitting"
    @Published var selectedDuration: Double = 3.0
    
    // The specific states the app can exist in
    enum AppState {
        case idle               // Home Screen
        case setup              // Choosing Sit/Stand
        case alignmentCheck     // Camera active
        case sessionRunning     // Audio/Motion active
        case summary            // Finished
    }
    
    // MARK: - Transitions (Crash Prevention)
    
    func startSetup() {
        // CLEANUP: Ensure no sensors are running before starting setup
        stopSensors()
        withAnimation { appState = .setup }
    }
    
    func cancelSetup() {
        withAnimation { appState = .idle }
    }
    
    func startAlignment() {
        // SAFETY: Check Camera Permission before switching state
        checkCameraPermission { granted in
            if granted {
                DispatchQueue.main.async {
                    withAnimation { self.appState = .alignmentCheck }
                }
            } else {
                // If denied, do nothing (or show alert). DO NOT CRASH.
                print("Camera permission denied. Staying on Home.")
            }
        }
    }
    
    func startSession(posture: String, duration: Double) {
        self.selectedPosture = posture
        self.selectedDuration = duration
        
        // SAFETY: Check Motion Permission
        // Since we can't strictly "check" motion permission like camera without triggering it,
        // we start the session state, and the MotionManager handles the fallback internally.
        withAnimation { appState = .sessionRunning }
    }
    
    func completeSession() {
        stopSensors()
        withAnimation { appState = .summary }
    }
    
    func returnHome() {
        stopSensors()
        withAnimation { appState = .idle }
    }
    
    // MARK: - Helpers
    
    private func stopSensors() {
        // Force kill everything to prevent memory leaks/crashes
        MotionManager.shared.stopUpdates()
        SpeechManager.shared.stop()
        AudioManager.shared.stopSynth()
    }
    
    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        default:
            completion(false)
        }
    }
}
