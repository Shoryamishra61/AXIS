// MotionManager.swift
// Axis - The Invisible Posture Companion
// Enhanced Motion Tracking for Swift Student Challenge 2026

import Foundation
import CoreMotion
import SwiftUI
import Combine

// MARK: - Motion Manager
class MotionManager: ObservableObject {
    static let shared = MotionManager()
    
    // MARK: - Motion Sources
    private let headphoneManager = CMHeadphoneMotionManager()
    private let deviceManager = CMMotionManager()
    
    // MARK: - Published Properties
    @Published var pitch: Double = 0.0
    @Published var yaw: Double = 0.0
    @Published var roll: Double = 0.0
    @Published var activeSource: String = "Initializing..."
    @Published var isConnected: Bool = false
    @Published var isCalibrated: Bool = false
    @Published var connectionQuality: ConnectionQuality = .unknown
    
    /// Returns true ONLY if AirPods with motion sensors are actually connected and available
    var isAirPodsActuallyConnected: Bool {
        return headphoneManager.isDeviceMotionAvailable
    }
    
    // MARK: - Calibration State
    private var referenceQuaternion: CMQuaternion?
    private var calibrationAttempts: Int = 0
    private let maxCalibrationAttempts = 5
    
    // MARK: - Update Timer
    private var updateTimer: Timer?
    private let updateInterval: TimeInterval = 1.0 / 60.0 // 60 Hz
    
    // MARK: - Connection Quality
    enum ConnectionQuality: String {
        case excellent = "Excellent"
        case good = "Good"
        case fair = "Fair"
        case poor = "Poor"
        case unknown = "Unknown"
        
        var icon: String {
            switch self {
            case .excellent: return "wifi"
            case .good: return "wifi"
            case .fair: return "wifi.exclamationmark"
            case .poor: return "wifi.slash"
            case .unknown: return "questionmark.circle"
            }
        }
    }
    
    // MARK: - Connection Monitoring
    private var connectionMonitorTimer: Timer?
    private var wasHeadphoneAvailable: Bool = false
    
    // MARK: - Initialization
    private init() {
        wasHeadphoneAvailable = headphoneManager.isDeviceMotionAvailable
    }
    
    /// Start monitoring for sensor availability changes (call on app appear)
    func startConnectionMonitoring() {
        // Check immediately
        checkSensorAvailability()
        
        // Then poll every 2 seconds for connection changes
        connectionMonitorTimer?.invalidate()
        connectionMonitorTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkSensorAvailability()
        }
    }
    
    /// Stop connection monitoring (call on app disappear)
    func stopConnectionMonitoring() {
        connectionMonitorTimer?.invalidate()
        connectionMonitorTimer = nil
    }
    
    private func checkSensorAvailability() {
        let isHeadphoneNowAvailable = headphoneManager.isDeviceMotionAvailable
        
        // Detect connection change
        if isHeadphoneNowAvailable && !wasHeadphoneAvailable {
            // AirPods just connected
            handleHeadphoneConnect()
        } else if !isHeadphoneNowAvailable && wasHeadphoneAvailable {
            // AirPods just disconnected
            handleHeadphoneDisconnect()
        }
        
        wasHeadphoneAvailable = isHeadphoneNowAvailable
    }
    
    // MARK: - Start Updates
    func startUpdates() {
        stopUpdates() // Ensure clean state
        
        // Prefer AirPods for highest precision
        if headphoneManager.isDeviceMotionAvailable {
            startHeadphoneUpdates()
        } else if deviceManager.isDeviceMotionAvailable {
            startDeviceUpdates()
        } else {
            activeSource = "No Motion Sensors"
            isConnected = false
            connectionQuality = .poor
        }
    }
    
    private func startHeadphoneUpdates() {
        activeSource = "AirPods Pro/Max"
        isConnected = true
        connectionQuality = .excellent
        
        headphoneManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else {
                if let error = error {
                    print("Headphone Motion Error: \(error.localizedDescription)")
                    self?.handleHeadphoneDisconnect()
                }
                return
            }
            self.processMotion(motion.attitude)
        }
    }
    
    private func startDeviceUpdates() {
        activeSource = "iPhone Sensors"
        isConnected = true
        connectionQuality = .good
        
        deviceManager.deviceMotionUpdateInterval = updateInterval
        deviceManager.startDeviceMotionUpdates(
            using: .xArbitraryZVertical,
            to: .main
        ) { [weak self] motion, error in
            guard let self = self, let motion = motion else {
                if let error = error {
                    print("Device Motion Error: \(error.localizedDescription)")
                }
                return
            }
            self.processMotion(motion.attitude)
        }
    }
    
    // MARK: - Connection Handlers
    
    private func handleHeadphoneConnect() {
        print("AirPods connected - switching to headphone motion")
        stopUpdates()
        startHeadphoneUpdates()
        
        // Recalibrate after connection
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.calibrate()
        }
    }
    
    private func handleHeadphoneDisconnect() {
        print("AirPods disconnected - falling back to device sensors")
        
        // Graceful fallback
        if deviceManager.isDeviceMotionAvailable {
            startDeviceUpdates()
            
            // Recalibrate for device sensors
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.calibrate()
            }
        } else {
            activeSource = "Disconnected"
            isConnected = false
            connectionQuality = .poor
        }
    }
    
    // MARK: - Calibration
    
    /// Calibrate the sensor to treat current position as "zero"
    func calibrate() {
        calibrationAttempts = 0
        attemptCalibration()
    }
    
    private func attemptCalibration() {
        calibrationAttempts += 1
        
        let quaternion: CMQuaternion?
        
        if headphoneManager.isDeviceMotionAvailable {
            quaternion = headphoneManager.deviceMotion?.attitude.quaternion
        } else {
            quaternion = deviceManager.deviceMotion?.attitude.quaternion
        }
        
        if let q = quaternion, isValidQuaternion(q) {
            referenceQuaternion = q
            isCalibrated = true
            
            // Reset angles to zero
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.2)) {
                    self.pitch = 0.0
                    self.yaw = 0.0
                    self.roll = 0.0
                }
            }
            print("Calibration successful on attempt \(calibrationAttempts)")
        } else if calibrationAttempts < maxCalibrationAttempts {
            // Retry after short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.attemptCalibration()
            }
        } else {
            print("Calibration failed after \(maxCalibrationAttempts) attempts")
            isCalibrated = false
        }
    }
    
    private func isValidQuaternion(_ q: CMQuaternion) -> Bool {
        // Check for NaN or zero quaternion
        let sum = abs(q.x) + abs(q.y) + abs(q.z) + abs(q.w)
        return sum > 0.1 && !q.x.isNaN && !q.y.isNaN && !q.z.isNaN && !q.w.isNaN
    }
    
    // MARK: - Motion Processing
    
    private func processMotion(_ attitude: CMAttitude) {
        let currentQ = attitude.quaternion
        
        // Use reference frame if calibrated
        if let refQ = referenceQuaternion {
            // Calculate relative quaternion: Q_delta = Q_curr * Q_ref^-1
            let refInverse = CMQuaternion(
                x: -refQ.x,
                y: -refQ.y,
                z: -refQ.z,
                w: refQ.w
            )
            let deltaQ = multiplyQuaternions(currentQ, refInverse)
            
            // Convert to Euler angles (avoiding gimbal lock)
            let angles = quaternionToEuler(deltaQ)
            
            // Smooth update with animation
            DispatchQueue.main.async {
                withAnimation(.linear(duration: 0.08)) {
                    self.pitch = angles.pitch * 180.0 / .pi
                    self.yaw = angles.yaw * 180.0 / .pi
                    self.roll = angles.roll * 180.0 / .pi
                }
            }
        } else {
            // Fallback: Use raw Euler angles (less accurate)
            DispatchQueue.main.async {
                withAnimation(.linear(duration: 0.08)) {
                    self.pitch = attitude.pitch * 180.0 / .pi
                    self.yaw = attitude.yaw * 180.0 / .pi
                    self.roll = attitude.roll * 180.0 / .pi
                }
            }
        }
        
        // Update connection quality based on update frequency
        updateConnectionQuality()
    }
    
    // MARK: - Quaternion Math
    
    private func multiplyQuaternions(_ q1: CMQuaternion, _ q2: CMQuaternion) -> CMQuaternion {
        return CMQuaternion(
            x: q1.w * q2.x + q1.x * q2.w + q1.y * q2.z - q1.z * q2.y,
            y: q1.w * q2.y - q1.x * q2.z + q1.y * q2.w + q1.z * q2.x,
            z: q1.w * q2.z + q1.x * q2.y - q1.y * q2.x + q1.z * q2.w,
            w: q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z
        )
    }
    
    private func quaternionToEuler(_ q: CMQuaternion) -> (pitch: Double, yaw: Double, roll: Double) {
        // Pitch (x-axis rotation)
        let sinp = 2.0 * (q.w * q.y - q.z * q.x)
        let pitch: Double
        if abs(sinp) >= 1 {
            pitch = copysign(.pi / 2, sinp) // Use 90 degrees if out of range
        } else {
            pitch = asin(sinp)
        }
        
        // Yaw (y-axis rotation)
        let siny_cosp = 2.0 * (q.w * q.z + q.x * q.y)
        let cosy_cosp = 1.0 - 2.0 * (q.y * q.y + q.z * q.z)
        let yaw = atan2(siny_cosp, cosy_cosp)
        
        // Roll (z-axis rotation)
        let sinr_cosp = 2.0 * (q.w * q.x + q.y * q.z)
        let cosr_cosp = 1.0 - 2.0 * (q.x * q.x + q.y * q.y)
        let roll = atan2(sinr_cosp, cosr_cosp)
        
        return (pitch, yaw, roll)
    }
    
    // MARK: - Connection Quality
    
    private var lastUpdateTime: Date = Date()
    private var updateCount: Int = 0
    
    private func updateConnectionQuality() {
        updateCount += 1
        
        let now = Date()
        let elapsed = now.timeIntervalSince(lastUpdateTime)
        
        if elapsed >= 1.0 {
            let fps = Double(updateCount) / elapsed
            
            DispatchQueue.main.async {
                if fps >= 55 {
                    self.connectionQuality = .excellent
                } else if fps >= 40 {
                    self.connectionQuality = .good
                } else if fps >= 25 {
                    self.connectionQuality = .fair
                } else {
                    self.connectionQuality = .poor
                }
            }
            
            updateCount = 0
            lastUpdateTime = now
        }
    }
    
    // MARK: - Stop Updates
    
    func stopUpdates() {
        headphoneManager.stopDeviceMotionUpdates()
        deviceManager.stopDeviceMotionUpdates()
        updateTimer?.invalidate()
        updateTimer = nil
        stopConnectionMonitoring()
    }
    
    // MARK: - Debug Info
    
    var debugInfo: String {
        """
        Source: \(activeSource)
        Connected: \(isConnected)
        Calibrated: \(isCalibrated)
        Quality: \(connectionQuality.rawValue)
        Pitch: \(String(format: "%.1f", pitch))°
        Yaw: \(String(format: "%.1f", yaw))°
        Roll: \(String(format: "%.1f", roll))°
        """
    }
}
