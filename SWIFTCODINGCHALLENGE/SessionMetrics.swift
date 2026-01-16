//
//  SessionMetrics.swift
//  SWIFTCODINGCHALLENGE
//
//  Created by admin67 on 15/01/26.
//


// SessionMetrics.swift
// Axis - The Invisible Posture Companion
// Real-time session tracking for Swift Student Challenge 2026

import Combine
import Foundation

// MARK: - Session Metrics
class SessionMetrics: ObservableObject {
    static let shared = SessionMetrics()
    
    // MARK: - Published Properties
    @Published var exercisesCompleted: Int = 0
    @Published var totalExercises: Int = 0
    @Published var currentAccuracy: Double = 0.0
    @Published var timeInTarget: TimeInterval = 0.0
    @Published var sessionDuration: TimeInterval = 0.0
    @Published var challengingExercises: [String] = []
    
    // MARK: - Internal Tracking
    private var accuracyScores: [Double] = []
    private var exerciseAccuracies: [String: Double] = [:]
    private var sessionStartTime: Date?
    private var targetStartTime: Date?
    private var isInTarget: Bool = false
    
    // MARK: - Computed Properties
    var averageAccuracy: Double {
        guard !accuracyScores.isEmpty else { return 0.0 }
        return accuracyScores.reduce(0, +) / Double(accuracyScores.count)
    }
    
    var formattedAccuracy: String {
        String(format: "%.0f%%", averageAccuracy * 100)
    }
    
    var formattedTimeInTarget: String {
        let minutes = Int(timeInTarget) / 60
        let seconds = Int(timeInTarget) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedDuration: String {
        let minutes = Int(sessionDuration) / 60
        let seconds = Int(sessionDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var mostChallenging: String {
        guard let hardest = exerciseAccuracies.min(by: { $0.value < $1.value }) else {
            return "None"
        }
        return hardest.key
    }
    
    // MARK: - Session Lifecycle
    func startSession(totalExerciseCount: Int) {
        reset()
        totalExercises = totalExerciseCount
        sessionStartTime = Date()
    }
    
    func reset() {
        exercisesCompleted = 0
        totalExercises = 0
        currentAccuracy = 0.0
        timeInTarget = 0.0
        sessionDuration = 0.0
        accuracyScores = []
        exerciseAccuracies = [:]
        challengingExercises = []
        sessionStartTime = nil
        targetStartTime = nil
        isInTarget = false
    }
    
    func endSession() {
        if let start = sessionStartTime {
            sessionDuration = Date().timeIntervalSince(start)
        }
        
        // Find challenging exercises (accuracy < 70%)
        challengingExercises = exerciseAccuracies
            .filter { $0.value < 0.7 }
            .sorted { $0.value < $1.value }
            .prefix(3)
            .map { $0.key }
    }
    
    // MARK: - Real-time Tracking
    func recordAccuracy(_ accuracy: Double, for exerciseName: String) {
        currentAccuracy = accuracy
        accuracyScores.append(accuracy)
        
        // Track per-exercise accuracy
        if let existing = exerciseAccuracies[exerciseName] {
            exerciseAccuracies[exerciseName] = (existing + accuracy) / 2.0
        } else {
            exerciseAccuracies[exerciseName] = accuracy
        }
    }
    
    func enterTarget() {
        guard !isInTarget else { return }
        isInTarget = true
        targetStartTime = Date()
    }
    
    func exitTarget() {
        guard isInTarget, let start = targetStartTime else { return }
        isInTarget = false
        timeInTarget += Date().timeIntervalSince(start)
        targetStartTime = nil
    }
    
    func completeExercise(name: String, accuracy: Double) {
        exercisesCompleted += 1
        recordAccuracy(accuracy, for: name)
        exitTarget()
    }
    
    // MARK: - Summary Data
    func getSummary() -> SessionSummary {
        return SessionSummary(
            totalExercises: exercisesCompleted,
            averageAccuracy: averageAccuracy,
            timeInTarget: timeInTarget,
            sessionDuration: sessionDuration,
            mostChallenging: mostChallenging,
            challengingExercises: challengingExercises
        )
    }
}

// MARK: - Session Summary
struct SessionSummary {
    let totalExercises: Int
    let averageAccuracy: Double
    let timeInTarget: TimeInterval
    let sessionDuration: TimeInterval
    let mostChallenging: String
    let challengingExercises: [String]
    
    var formattedAccuracy: String {
        String(format: "%.0f%%", averageAccuracy * 100)
    }
    
    var formattedTimeInTarget: String {
        let minutes = Int(timeInTarget) / 60
        let seconds = Int(timeInTarget) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedDuration: String {
        let minutes = Int(sessionDuration) / 60
        let seconds = Int(sessionDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var performanceLevel: PerformanceLevel {
        switch averageAccuracy {
        case 0.9...: return .excellent
        case 0.75..<0.9: return .good
        case 0.5..<0.75: return .fair
        default: return .needsPractice
        }
    }
}

// MARK: - Performance Level
enum PerformanceLevel: String {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case needsPractice = "Needs Practice"
    
    var emoji: String {
        switch self {
        case .excellent: return "🌟"
        case .good: return "✨"
        case .fair: return "👍"
        case .needsPractice: return "💪"
        }
    }
    
    var message: String {
        switch self {
        case .excellent: return "Outstanding! Your alignment is exceptional."
        case .good: return "Great work! Keep building that awareness."
        case .fair: return "Nice effort! Practice makes perfect."
        case .needsPractice: return "Good start! The more you practice, the easier it gets."
        }
    }
}
