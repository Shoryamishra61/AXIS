// ProtocolEngine.swift
// Axis - The Invisible Posture Companion
// Intelligent Routine Generation for Swift Student Challenge 2026

import Foundation

// MARK: - Protocol Engine
class ProtocolEngine {
    static let shared = ProtocolEngine()
    
    private let database = ExerciseDatabase.shared
    
    // MARK: - Routine Generation
    
    /// Generate an intelligent routine based on context, duration, and accessibility needs
    func generateRoutine(
        posture: String,
        durationMinutes: Double,
        isWheelchair: Bool
    ) -> [Exercise] {
        let context = contextFrom(posture: posture, isWheelchair: isWheelchair)
        let targetDuration = durationMinutes * 60.0 // Convert to seconds
        
        // Get available exercises for this context
        var availableExercises = database.exercises(for: context)
        
        // If wheelchair mode, prioritize wheelchair-specific exercises
        if isWheelchair {
            let wheelchairExercises = database.wheelchairExercises()
            availableExercises = wheelchairExercises + availableExercises.filter {
                $0.category != .wheelchair && $0.supportedContexts.contains(.sitting)
            }
        }
        
        // Build a balanced routine
        return buildBalancedRoutine(
            from: availableExercises,
            targetDuration: targetDuration,
            context: context
        )
    }
    
    // MARK: - Routine Building Logic
    
    private func buildBalancedRoutine(
        from exercises: [Exercise],
        targetDuration: TimeInterval,
        context: PostureContext
    ) -> [Exercise] {
        var routine: [Exercise] = []
        var currentDuration: TimeInterval = 0.0
        var usedCategories: Set<ExerciseCategory> = []
        
        // Phase 1: Start with a calming breath (always)
        if let breathStart = exercises.first(where: { $0.id == "breath_05" }) { // Breath Awareness
            routine.append(breathStart)
            currentDuration += breathStart.estimatedSeconds
            usedCategories.insert(.breathwork)
        }
        
        // Phase 2: Core neck mobility (the main purpose of the app)
        let neckExercises = exercises.filter { $0.category == .neckMobility }
        let selectedNeck = selectBalanced(
            from: neckExercises,
            count: min(4, neckExercises.count),
            targetDuration: targetDuration * 0.4 // 40% neck mobility
        )
        routine.append(contentsOf: selectedNeck)
        currentDuration += selectedNeck.reduce(0) { $0 + $1.estimatedSeconds }
        usedCategories.insert(.neckMobility)
        
        // Phase 3: Add variety based on remaining time
        let remainingTime = targetDuration - currentDuration
        
        // Priority order for variety
        let varietyCategories: [ExerciseCategory] = [
            .isometric,
            .shoulderBack,
            .eyeVestibular,
            .yogaStretch
        ]
        
        for category in varietyCategories {
            guard currentDuration < targetDuration else { break }
            
            let categoryExercises = exercises.filter { $0.category == category }
            guard !categoryExercises.isEmpty else { continue }
            
            // Add 1-2 exercises from each category
            let count = min(2, categoryExercises.count)
            let selected = selectBalanced(
                from: categoryExercises,
                count: count,
                targetDuration: remainingTime / Double(varietyCategories.count)
            )
            
            routine.append(contentsOf: selected)
            currentDuration += selected.reduce(0) { $0 + $1.estimatedSeconds }
            usedCategories.insert(category)
        }
        
        // Phase 4: End with rest/calming (always)
        if let restEnd = exercises.first(where: { $0.id == "yoga_05" }) { // Deep Rest
            routine.append(restEnd)
        } else if let sighEnd = exercises.first(where: { $0.id == "breath_02" }) { // Physiological Sigh
            routine.append(sighEnd)
        }
        
        // Ensure minimum content
        if routine.count < 3 {
            routine = ensureMinimumRoutine(context: context)
        }
        
        return routine
    }
    
    private func selectBalanced(
        from exercises: [Exercise],
        count: Int,
        targetDuration: TimeInterval
    ) -> [Exercise] {
        guard !exercises.isEmpty else { return [] }
        
        var selected: [Exercise] = []
        var currentDuration: TimeInterval = 0.0
        var shuffled = exercises.shuffled()
        
        // Prioritize tracked exercises (more engaging)
        shuffled.sort { $0.isTracked && !$1.isTracked }
        
        for exercise in shuffled {
            guard selected.count < count else { break }
            guard currentDuration + exercise.estimatedSeconds <= targetDuration * 1.2 else { continue }
            
            // Avoid duplicates by axis (variety)
            let existingAxes = Set(selected.compactMap { $0.targetAxis })
            if existingAxes.contains(exercise.targetAxis) && exercise.targetAxis != .none {
                continue
            }
            
            selected.append(exercise)
            currentDuration += exercise.estimatedSeconds
        }
        
        return selected
    }
    
    private func ensureMinimumRoutine(context: PostureContext) -> [Exercise] {
        // Fallback: Return essential exercises
        let essentialIDs: [String]
        
        switch context {
        case .wheelchair:
            essentialIDs = ["breath_05", "wheel_02", "neck_01", "neck_02", "neck_03", "yoga_05"]
        case .lyingDown:
            essentialIDs = ["breath_05", "neck_01", "neck_07", "yoga_06", "yoga_05"]
        case .standing:
            essentialIDs = ["breath_05", "yoga_01", "neck_02", "neck_03", "shoulder_01", "yoga_05"]
        default: // Sitting
            essentialIDs = ["breath_05", "neck_01", "neck_02", "neck_03", "shoulder_01", "yoga_05"]
        }
        
        return essentialIDs.compactMap { id in
            database.allExercises.first { $0.id == id }
        }
    }
    
    // MARK: - Context Resolution
    
    private func contextFrom(posture: String, isWheelchair: Bool) -> PostureContext {
        if isWheelchair { return .wheelchair }
        
        switch posture.lowercased() {
        case "sitting": return .sitting
        case "standing": return .standing
        case "lying down": return .lyingDown
        default: return .sitting
        }
    }
    
    // MARK: - Quick Session Presets
    
    /// Generate a quick 2-minute focus session
    func quickFocusSession() -> [Exercise] {
        let essentialIDs = ["breath_02", "neck_01", "neck_02", "neck_03", "breath_05"]
        return essentialIDs.compactMap { id in
            database.allExercises.first { $0.id == id }
        }
    }
    
    /// Generate a 5-minute deep restore session
    func deepRestoreSession(isWheelchair: Bool) -> [Exercise] {
        return generateRoutine(posture: "Sitting", durationMinutes: 5.0, isWheelchair: isWheelchair)
    }
    
    /// Generate an eye-strain relief session
    func eyeReliefSession() -> [Exercise] {
        let eyeIDs = ["eye_02", "eye_03", "eye_06", "eye_01", "breath_05"]
        return eyeIDs.compactMap { id in
            database.allExercises.first { $0.id == id }
        }
    }
}

// MARK: - Legacy Support (for existing code compatibility)
enum ExerciseType: String, CaseIterable {
    case chinTuck = "Chin Tuck"
    case leftTurn = "Left Rotation"
    case rightTurn = "Right Rotation"
    case seatedScapularRetraction = "Scapular Retraction"
    case deepRest = "Deep Rest"
    
    var instruction: String {
        switch self {
        case .chinTuck: return "Draw your chin straight back slowly."
        case .leftTurn: return "Turn your head slowly to the left."
        case .rightTurn: return "Turn your head slowly to the right."
        case .seatedScapularRetraction: return "Squeeze your shoulder blades together."
        case .deepRest: return "Do absolutely nothing. Let gravity have your head."
        }
    }
    
    var target: (axis: String, value: Double, compare: (Double, Double) -> Bool, holdTime: Double) {
        switch self {
        case .chinTuck: return ("pitch", -15, { $0 < $1 }, 2.0)
        case .leftTurn: return ("yaw", 30, { $0 > $1 }, 1.0)
        case .rightTurn: return ("yaw", -30, { $0 < $1 }, 1.0)
        default: return ("none", 0, { _,_ in true }, 8.0)
        }
    }
}
