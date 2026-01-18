// ProtocolEngine.swift
// Axis - The Invisible Posture Companion
// Intelligent Routine Generation for Swift Student Challenge 2026

import Foundation

// MARK: - Protocol Engine
class ProtocolEngine {
    static let shared = ProtocolEngine()
    
    // MARK: - Routine Generation
    
    /// Generate an intelligent routine based on context, duration, and accessibility needs
    /// Uses the "Mobilize-Activate-Integrate" protocol via ExerciseTimeMapper
    func generateRoutine(
        posture: String,
        durationMinutes: Double,
        isWheelchair: Bool
    ) -> [Exercise] {
        let context = contextFrom(posture: posture, isWheelchair: isWheelchair)
        let sessionDuration = mapToSessionDuration(minutes: durationMinutes)
        
        // Use the pillar-based logic in ExerciseTimeMapper
        return ExerciseTimeMapper.buildSession(
            duration: sessionDuration,
            context: context
        )
    }
    
    // MARK: - Helper Logic
    
    private func contextFrom(posture: String, isWheelchair: Bool) -> PostureContext {
        if isWheelchair { return .wheelchair }
        
        switch posture.lowercased() {
        case "sitting": return .sitting
        case "standing": return .standing
        case "lying down": return .lyingDown
        default: return .sitting
        }
    }
    
    private func mapToSessionDuration(minutes: Double) -> SessionDuration {
        if minutes < 3 {
            return .twoMinutes
        } else if minutes <= 5 {
            return .fourMinutes
        } else if minutes <= 7 {
            return .sixMinutes
        } else if minutes <= 9 {
            return .eightMinutes
        } else {
            return .tenMinutes
        }
    }
    
    // MARK: - Quick Session Presets (Convenience Wrappers)
    
    /// Generate a quick 2-minute focus session
    func quickFocusSession() -> [Exercise] {
        return ExerciseTimeMapper.buildSession(duration: .twoMinutes, context: .sitting)
    }
    
    /// Generate a 5-minute deep restore session
    func deepRestoreSession(isWheelchair: Bool) -> [Exercise] {
        return ExerciseTimeMapper.buildSession(
            duration: .sixMinutes, // Closest to 5 min deep dive
            context: isWheelchair ? .wheelchair : .sitting,
            focusCategories: [.breathwork, .yogaStretch]
        )
    }
    
    /// Generate an eye-strain relief session
    func eyeReliefSession() -> [Exercise] {
        return ExerciseTimeMapper.buildSession(
            duration: .fourMinutes,
            context: .sitting,
            focusCategories: [.eyeVestibular, .neckMobility]
        )
    }
}
