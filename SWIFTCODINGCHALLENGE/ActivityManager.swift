// ActivityManager.swift
// Axis - The Invisible Posture Companion
// Context Auto-Detection for Swift Student Challenge 2026

import Foundation
import CoreMotion
import Combine

// MARK: - Activity Manager
class ActivityManager: ObservableObject {
    // MARK: - Core Motion
    private let activityManager = CMMotionActivityManager()
    private let motionManager = CMMotionManager()
    
    // MARK: - Published State
    @Published var detectedContext: String = "Sitting"
    @Published var isDetecting: Bool = false
    @Published var confidence: ActivityConfidence = .low
    
    // MARK: - Confidence Level
    enum ActivityConfidence: String {
        case high = "High"
        case medium = "Medium"
        case low = "Low"
    }
    
    // MARK: - Activity History
    private var recentActivities: [CMMotionActivity] = []
    private let historyLimit = 5
    
    // MARK: - Start Detection
    func startActivityDetection() {
        guard !isDetecting else { return }
        isDetecting = true
        
        // Check availability
        guard CMMotionActivityManager.isActivityAvailable() else {
            detectedContext = "Sitting" // Default fallback
            confidence = .low
            isDetecting = false
            return
        }
        
        // Start activity updates
        activityManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let self = self, let activity = activity else { return }
            self.processActivity(activity)
        }
        
        // Also use accelerometer for posture inference
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.5
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
                guard let self = self, let data = data else { return }
                self.inferPostureFromAccelerometer(data)
            }
        }
    }
    
    // MARK: - Stop Detection
    func stopActivityDetection() {
        isDetecting = false
        activityManager.stopActivityUpdates()
        motionManager.stopAccelerometerUpdates()
        recentActivities.removeAll()
    }
    
    // MARK: - Process Activity
    private func processActivity(_ activity: CMMotionActivity) {
        // Add to history
        recentActivities.append(activity)
        if recentActivities.count > historyLimit {
            recentActivities.removeFirst()
        }
        
        // Analyze recent activities for stable detection
        let context = analyzeActivityHistory()
        
        DispatchQueue.main.async {
            self.detectedContext = context.0
            self.confidence = context.1
        }
    }
    
    // MARK: - Analyze History
    private func analyzeActivityHistory() -> (String, ActivityConfidence) {
        guard !recentActivities.isEmpty else {
            return ("Sitting", .low)
        }
        
        var walkingCount = 0
        var runningCount = 0
        var stationaryCount = 0
        
        for activity in recentActivities {
            if activity.walking { walkingCount += 1 }
            if activity.running { runningCount += 1 }
            if activity.stationary { stationaryCount += 1 }
        }
        
        let total = recentActivities.count
        
        // Determine dominant activity
        if runningCount > total / 2 || walkingCount > total / 2 {
            let conf: ActivityConfidence = (walkingCount + runningCount) >= total - 1 ? .high : .medium
            return ("Standing", conf)
        } else if stationaryCount > total / 2 {
            let conf: ActivityConfidence = stationaryCount >= total - 1 ? .high : .medium
            return ("Sitting", conf)
        }
        
        return ("Sitting", .low)
    }
    
    // MARK: - Accelerometer Posture Inference
    private var gravityHistory: [Double] = []
    
    private func inferPostureFromAccelerometer(_ data: CMAccelerometerData) {
        // Get gravity vector (z-axis when phone is face up)
        let gravityZ = data.acceleration.z
        
        gravityHistory.append(gravityZ)
        if gravityHistory.count > 10 {
            gravityHistory.removeFirst()
        }
        
        // Average gravity
        let avgGravityZ = gravityHistory.reduce(0, +) / Double(gravityHistory.count)
        
        // Infer posture based on phone orientation
        // If phone is relatively flat (z close to -1), might be lying down
        DispatchQueue.main.async {
            if avgGravityZ < -0.8 {
                // Phone is face up and flat - possible lying down
                if self.detectedContext == "Sitting" && self.confidence == .low {
                    self.detectedContext = "Lying Down"
                    self.confidence = .medium
                }
            }
        }
    }
    
    // MARK: - Manual Override
    func setContext(_ context: String) {
        DispatchQueue.main.async {
            self.detectedContext = context
            self.confidence = .high // User-set is always high confidence
        }
    }
}
