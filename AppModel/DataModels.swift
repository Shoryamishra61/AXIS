// DataModels.swift
// AXIS — Persistent data models for SwiftData

import Foundation
import SwiftData

// MARK: - Session Data

@Model
class SessionData {
    var id: UUID
    var date: Date
    var duration: TimeInterval
    var completionRate: Double
    var confidence: Double
    var phase: String
    var exercises: [String]

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        duration: TimeInterval,
        completionRate: Double,
        confidence: Double,
        phase: String,
        exercises: [String]
    ) {
        self.id = id
        self.date = date
        self.duration = duration
        self.completionRate = completionRate
        self.confidence = confidence
        self.phase = phase
        self.exercises = exercises
    }
}

// MARK: - Posture Metric

@Model
class PostureMetric {
    var id: UUID
    var date: Date
    var score: Double
    var exercises: [String]
    var duration: TimeInterval

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        score: Double,
        exercises: [String],
        duration: TimeInterval
    ) {
        self.id = id
        self.date = date
        self.score = score
        self.exercises = exercises
        self.duration = duration
    }
}
