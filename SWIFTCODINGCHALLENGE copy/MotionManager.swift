import Foundation
import CoreMotion
import SwiftUI
import Combine

class MotionManager: ObservableObject {
    static let shared = MotionManager()
    
    private let headphoneManager = CMHeadphoneMotionManager()
    private let deviceManager = CMMotionManager()
    
    @Published var pitch: Double = 0.0
    @Published var yaw: Double = 0.0
    @Published var roll: Double = 0.0
    @Published var activeSource: String = "Initializing..."
    
    private var referenceQuaternion: CMQuaternion?
    
    func startUpdates() {
        // Fallback Hierarchy: AirPods -> iPhone Gyro
        if headphoneManager.isDeviceMotionAvailable {
            activeSource = "AirPods Pro/Max"
            headphoneManager.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
                guard let self = self, let data = data else { return }
                self.processMotion(data.attitude)
            }
        } else if deviceManager.isDeviceMotionAvailable {
            activeSource = "iPhone Sensors"
            deviceManager.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
                guard let self = self, let data = data else { return }
                self.processMotion(data.attitude)
            }
        }
    }
    
    func calibrate() {
        // Tare Function: Captures current attitude as Reference Quaternion
        if headphoneManager.isDeviceMotionAvailable {
            referenceQuaternion = headphoneManager.deviceMotion?.attitude.quaternion
        } else {
            referenceQuaternion = deviceManager.deviceMotion?.attitude.quaternion
        }
    }
    
    private func processMotion(_ attitude: CMAttitude) {
        let currentQ = attitude.quaternion
        
        if let refQ = referenceQuaternion {
            // Q_delta = Q_curr * Q_ref^-1 to prevent Gimbal Lock
            let refInverse = CMQuaternion(x: -refQ.x, y: -refQ.y, z: -refQ.z, w: refQ.w)
            let deltaQ = multiplyQuaternions(currentQ, refInverse)
            
            // Euler Conversion for UI mapping
            let pitchVal = asin(2 * (deltaQ.w * deltaQ.y - deltaQ.z * deltaQ.x))
            let yawVal = atan2(2 * (deltaQ.w * deltaQ.z + deltaQ.x * deltaQ.y), 1 - 2 * (deltaQ.y * deltaQ.y + deltaQ.z * deltaQ.z))
            let rollVal = atan2(2 * (deltaQ.w * deltaQ.x + deltaQ.y * deltaQ.z), 1 - 2 * (deltaQ.x * deltaQ.x + deltaQ.y * deltaQ.y))
            
            DispatchQueue.main.async {
                withAnimation(.linear(duration: 0.1)) {
                    self.pitch = pitchVal * 180 / .pi
                    self.yaw = yawVal * 180 / .pi
                    self.roll = rollVal * 180 / .pi
                }
            }
        }
    }
    
    private func multiplyQuaternions(_ q1: CMQuaternion, _ q2: CMQuaternion) -> CMQuaternion {
        return CMQuaternion(
            x: q1.w * q2.x + q1.x * q2.w + q1.y * q2.z - q1.z * q2.y,
            y: q1.w * q2.y - q1.x * q2.z + q1.y * q2.w + q1.z * q2.x,
            z: q1.w * q2.z + q1.x * q2.y - q1.y * q2.x + q1.z * q2.w,
            w: q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z
        )
    }
    
    func stopUpdates() {
        headphoneManager.stopDeviceMotionUpdates()
        deviceManager.stopDeviceMotionUpdates()
    }
}
