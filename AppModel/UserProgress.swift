// UserProgress.swift
// AXIS — Cumulative Progress Tracking
// Uses SwiftData for long-term psychological reward without toxic streak penalties.

import Foundation
import SwiftData

@Model
final class UserProgress {
    
    // Total lifetime seconds spent correctly aligned in the "In Zone" state.
    var totalSecondsInZone: Int
    
    // Whether the user has achieved their very first 1-minute cumulative milestone.
    // We track this specifically to fire a "Judge's Aha! Moment".
    var reachedFirstMilestone: Bool
    
    init(totalSecondsInZone: Int = 0, reachedFirstMilestone: Bool = false) {
        self.totalSecondsInZone = totalSecondsInZone
        self.reachedFirstMilestone = reachedFirstMilestone
    }
}
