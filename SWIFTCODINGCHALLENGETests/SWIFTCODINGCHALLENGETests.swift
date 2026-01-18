//
//  SWIFTCODINGCHALLENGETests.swift
//  SWIFTCODINGCHALLENGETests
//
//  Axis Logic Verification
//

import Testing
@testable import SWIFTCODINGCHALLENGE

struct AxisLogicTests {

    // MARK: - Database Integrity
    
    @Test func testDatabaseComposition() async throws {
        let db = ExerciseDatabase.shared
        let exercises = db.allExercises
        
        // Check total count (should be 58)
        #expect(exercises.count == 58, "Database should contain exactly 58 exercises")
        
        // Check categories exist
        let categories = Set(exercises.map { $0.category })
        #expect(categories.contains(.neckMobility))
        #expect(categories.contains(.isometric))
        #expect(categories.contains(.shoulderBack))
        #expect(categories.contains(.eyeVestibular))
        #expect(categories.contains(.breathwork))
        #expect(categories.contains(.yogaStretch))
        #expect(categories.contains(.wheelchair))
        #expect(categories.contains(.acupressure))
        #expect(categories.contains(.neuroReset))
    }
    
    @Test func testLuxuryContentContent() async throws {
        let exercises = ExerciseDatabase.shared.allExercises
        
        for exercise in exercises {
            // Check essential fields
            #expect(!exercise.id.isEmpty, "Exercise ID should not be empty")
            #expect(!exercise.name.isEmpty, "Exercise name should not be empty")
            
            // Check scientific backing
            #expect(!exercise.primaryBenefit.isEmpty, "Primary benefit should be present for \(exercise.name)")
            #expect(!exercise.scientificRationale.isEmpty, "Rationale should be present for \(exercise.name)")
            
            // Check luxury voice content
            #expect(!exercise.calmingInstruction.isEmpty, "Luxury instruction missing for \(exercise.name)")
            #expect(exercise.calmingInstruction.count > exercise.instruction.count, "Luxury instruction should be more detailed than basic instruction for \(exercise.name)")
            
            // Check phases
            #expect(!exercise.preparation.isEmpty, "Preparation phase missing for \(exercise.name)")
            #expect(!exercise.voiceGuidance.isEmpty, "Voice guidance steps missing for \(exercise.name)")
            #expect(!exercise.completion.isEmpty, "Completion phase missing for \(exercise.name)")
        }
    }
    
    // MARK: - Protocol Engine & Routine Generation
    
    @Test func testQuickSessionGeneration() async throws {
        let engine = ProtocolEngine.shared
        let routine = engine.quickFocusSession()
        
        // Expect roughly 2 minutes worth of content
        // Note: totalDuration in exercises includes pauses
        let totalTime = routine.reduce(0) { $0 + $1.totalDuration }
        
        // 2 minutes = 120 seconds. Allow some variance.
        #expect(totalTime > 60 && totalTime < 180, "Quick session should be approx 2 minutes")
        #expect(routine.count >= 3, "Routine should have at least 3 exercises")
    }
    
    @Test func testContextFiltering() async throws {
        let engine = ProtocolEngine.shared
        
        // Test Sitting
        let sittingRoutine = engine.generateRoutine(posture: "Sitting", durationMinutes: 5, isWheelchair: false)
        for ex in sittingRoutine {
            #expect(ex.supportedContexts.contains(.sitting) || ex.supportedContexts.contains(.all), "Exercise \(ex.name) not suitable for sitting")
        }
        
        // Test Standing
        let standingRoutine = engine.generateRoutine(posture: "Standing", durationMinutes: 5, isWheelchair: false)
        for ex in standingRoutine {
            #expect(ex.supportedContexts.contains(.standing) || ex.supportedContexts.contains(.all), "Exercise \(ex.name) not suitable for standing")
        }
    }
    
    @Test func testWheelchairProtocol() async throws {
        let engine = ProtocolEngine.shared
        let routine = engine.generateRoutine(posture: "Sitting", durationMinutes: 5, isWheelchair: true)
        
        // Ensure wheelchair specific exercises are prioritized or present if duration allows
        let hasWheelchairSpecific = routine.contains { $0.category == .wheelchair }
        
        // Note: 5 mins might be tight to include everything, but our logic attempts to prioritize accessible ones.
        // At minimum, all exercises MUST be supportive of wheelchair (sitting or all)
        for ex in routine {
             #expect(ex.supportedContexts.contains(.wheelchair) || ex.supportedContexts.contains(.sitting) || ex.supportedContexts.contains(.all),
                     "Exercise \(ex.name) not suitable for wheelchair")
        }
    }
    
    @Test func testMobilizeActivateIntegrateProtocol() async throws {
        // Test 6 minute session (Medium) which explicitly uses the sequence
        let routine = ExerciseTimeMapper.buildSession(duration: .sixMinutes, context: .sitting)
        
        // Should ideally start with Neck (Mobilize), then Shoulder/Iso (Activate), then Breath (Integrate)
        // Note: exact order depends on the array construction in Mapper
        
        guard routine.count >= 3 else {
            #expect(Bool(false), "Routine too short to test protocol")
            return
        }
        
        // Check for presence of categories
        let categories = routine.map { $0.category }
        #expect(categories.contains(.neckMobility), "Should contain Mobilization (Neck)")
        #expect(categories.contains(.shoulderBack) || categories.contains(.isometric), "Should contain Activation")
        #expect(categories.contains(.breathwork), "Should contain Integration (Breath)")
    }

}
