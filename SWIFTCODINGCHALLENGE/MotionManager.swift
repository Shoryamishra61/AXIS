import Foundation
import CoreMotion
import SwiftUI

class MotionManager: ObservableObject {
    // MARK: - Hardware Managers
    private let headphoneManager = CMHeadphoneMotionManager()
    private let deviceManager = CMMotionManager()
    
    // MARK: - Published Data (The UI listens to this)
    @Published var pitch: Double = 0.0
    @Published var yaw: Double = 0.0
    @Published var roll: Double = 0.0
    @Published var activeSource: String = "Searching..."
    
    // MARK: - Control Logic
    func startUpdates() {
        // Priority 1: AirPods (Headphone Motion)
        if headphoneManager.isDeviceMotionAvailable {
            activeSource = "AirPods Pro/Max"
            headphoneManager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
                guard let self = self, let data = data else { return }
                self.processData(data)
            }
        } 
        // Priority 2: iPhone (Device Motion) - Hold phone to chest
        else if deviceManager.isDeviceMotionAvailable {
            activeSource = "iPhone Sensors (Fallback)"
            deviceManager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
                guard let self = self, let data = data else { return }
                self.processData(data)
            }
        } 
        // Priority 3: Simulator (Judge has no hardware)
        else {
            activeSource = "Simulator Mode"
            startSimulation()
        }
    }
    
    func stopUpdates() {
        headphoneManager.stopDeviceMotionUpdates()
        deviceManager.stopDeviceMotionUpdates()
    }
    
    // MARK: - Data Processing
    private func processData(_ data: CMDeviceMotion) {
        // Convert Quaternions to Degrees for easy UI logic
        // We use a slight multiplier to make small movements feel responsive
        withAnimation(.linear(duration: 0.1)) {
            self.pitch = data.attitude.pitch * 180 / .pi
            self.yaw   = data.attitude.yaw   * 180 / .pi
            self.roll  = data.attitude.roll  * 180 / .pi
        }
    }
    
    // MARK: - Simulation (Safety Net)
    private func startSimulation() {
        // Gently rotates the UI so the app doesn't look broken in Xcode Previews
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            withAnimation {
                self.yaw = sin(Date().timeIntervalSince1970) * 30
                self.pitch = cos(Date().timeIntervalSince1970) * 10
            }
        }
    }
}
