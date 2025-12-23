//
//  ExerciseCategory.swift
//  SWIFTCODINGCHALLENGE
//
//  Created by admin67 on 15/01/26.
//


// Exercise.swift
// Axis - The Invisible Posture Companion
// Complete Exercise Model for Swift Student Challenge 2026

import Foundation

// MARK: - Exercise Category
enum ExerciseCategory: String, CaseIterable, Codable {
    case neckMobility = "Neck Mobility"
    case isometric = "Isometric Strength"
    case shoulderBack = "Shoulder & Back"
    case eyeVestibular = "Eye & Vestibular"
    case breathwork = "Breathwork"
    case yogaStretch = "Yoga Stretch"
    case wheelchair = "Wheelchair Adapted"
    case rest = "Rest & Recovery"
    
    var icon: String {
        switch self {
        case .neckMobility: return "arrow.triangle.2.circlepath"
        case .isometric: return "hand.raised.fill"
        case .shoulderBack: return "figure.arms.open"
        case .eyeVestibular: return "eye.fill"
        case .breathwork: return "wind"
        case .yogaStretch: return "figure.yoga"
        case .wheelchair: return "figure.roll"
        case .rest: return "leaf.fill"
        }
    }
    
    var color: String {
        switch self {
        case .neckMobility: return "teal"
        case .isometric: return "orange"
        case .shoulderBack: return "blue"
        case .eyeVestibular: return "purple"
        case .breathwork: return "mint"
        case .yogaStretch: return "indigo"
        case .wheelchair: return "cyan"
        case .rest: return "gray"
        }
    }
}

// MARK: - Tracking Type
enum TrackingType: String, Codable {
    case sensorTracked   // Uses AirPods/device motion - pitch, yaw, roll
    case timedHold       // User holds position for duration
    case guided          // Voice-guided, no tracking needed
    case pattern         // Complex movement pattern (circles, figure 8)
}

// MARK: - Posture Context
enum PostureContext: String, CaseIterable, Codable {
    case sitting = "Sitting"
    case standing = "Standing"
    case lyingDown = "Lying Down"
    case wheelchair = "Wheelchair"
    case all = "All"
    
    var displayName: String { rawValue }
}

// MARK: - Target Axis
enum TargetAxis: String, Codable {
    case pitch      // Forward/backward head tilt (nodding)
    case yaw        // Left/right head rotation (shaking no)
    case roll       // Ear to shoulder tilt
    case pitchYaw   // Combined movement (circles, diagonals)
    case none       // Timed exercises without tracking
}

// MARK: - Exercise Model
struct Exercise: Identifiable, Codable {
    let id: String
    let name: String
    let category: ExerciseCategory
    let instruction: String
    let calmingInstruction: String  // Softer version for voice
    let trackingType: TrackingType
    let targetAxis: TargetAxis
    let targetValue: Double         // Target angle in degrees
    let holdDuration: TimeInterval  // How long to hold at target
    let totalDuration: TimeInterval // Total exercise duration
    let tolerance: Double           // Acceptable deviation (±degrees)
    let supportedContexts: [PostureContext]
    let difficultyLevel: Int        // 1-3: Beginner, Intermediate, Advanced
    let reps: Int                   // Number of repetitions (1 for single hold)
    
    // Computed Properties
    var isTracked: Bool {
        trackingType == .sensorTracked || trackingType == .pattern
    }
    
    var estimatedSeconds: TimeInterval {
        totalDuration * Double(reps)
    }
    
    // Comparison function for target checking
    func checkTarget(currentValue: Double) -> Bool {
        switch targetAxis {
        case .yaw:
            if targetValue > 0 {
                return currentValue >= targetValue - tolerance
            } else {
                return currentValue <= targetValue + tolerance
            }
        case .pitch:
            if targetValue > 0 {
                return currentValue >= targetValue - tolerance
            } else {
                return currentValue <= targetValue + tolerance
            }
        case .roll:
            if targetValue > 0 {
                return currentValue >= targetValue - tolerance
            } else {
                return currentValue <= targetValue + tolerance
            }
        case .pitchYaw, .none:
            return true // Pattern or timed exercises always pass
        }
    }
    
    // Accuracy calculation (0.0 to 1.0)
    func calculateAccuracy(currentValue: Double) -> Double {
        guard targetAxis != .none && targetAxis != .pitchYaw else { return 1.0 }
        
        let error = abs(currentValue - targetValue)
        let maxError = abs(targetValue) + 20.0 // Beyond this is 0% accuracy
        let accuracy = max(0, 1.0 - (error / maxError))
        return accuracy
    }
}

// MARK: - Exercise Comparison for Target
extension Exercise {
    enum ComparisonResult {
        case underTarget
        case atTarget
        case overTarget
    }
    
    func compareToTarget(currentValue: Double) -> ComparisonResult {
        let diff = currentValue - targetValue
        
        if abs(diff) <= tolerance {
            return .atTarget
        } else if diff < 0 {
            return targetValue > 0 ? .underTarget : .overTarget
        } else {
            return targetValue > 0 ? .overTarget : .underTarget
        }
    }
}
