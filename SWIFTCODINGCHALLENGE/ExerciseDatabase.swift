//
//  ExerciseDatabase.swift
//  SWIFTCODINGCHALLENGE
//
//  Created by admin67 on 15/01/26.
//


// ExerciseDatabase.swift
// Axis - The Invisible Posture Companion
// Comprehensive 58-Exercise Database for Swift Student Challenge 2026

import Foundation

struct ExerciseDatabase {
    static let shared = ExerciseDatabase()
    
    // MARK: - All Exercises (58 Total)
    let allExercises: [Exercise]
    
    private init() {
        allExercises = Self.buildDatabase()
    }
    
    // MARK: - Query Methods
    
    /// Get exercises filtered by context and category
    func exercises(for context: PostureContext, categories: [ExerciseCategory]? = nil) -> [Exercise] {
        allExercises.filter { exercise in
            let contextMatch = exercise.supportedContexts.contains(context) || 
                               exercise.supportedContexts.contains(.all)
            let categoryMatch = categories == nil || categories!.contains(exercise.category)
            return contextMatch && categoryMatch
        }
    }
    
    /// Get exercises for wheelchair users
    func wheelchairExercises() -> [Exercise] {
        allExercises.filter { 
            $0.supportedContexts.contains(.wheelchair) || 
            $0.category == .wheelchair 
        }
    }
    
    /// Get exercises by difficulty
    func exercises(difficulty: Int) -> [Exercise] {
        allExercises.filter { $0.difficultyLevel == difficulty }
    }
    
    /// Get sensor-tracked exercises only
    func trackedExercises() -> [Exercise] {
        allExercises.filter { $0.isTracked }
    }
    
    // MARK: - Database Builder
    private static func buildDatabase() -> [Exercise] {
        var exercises: [Exercise] = []
        
        // ═══════════════════════════════════════════════════════════════
        // NECK MOBILITY (12 exercises) - Sensor Tracked
        // ═══════════════════════════════════════════════════════════════
        
        exercises.append(Exercise(
            id: "neck_01",
            name: "Chin Tuck",
            category: .neckMobility,
            instruction: "Draw your chin straight back, making a double chin.",
            calmingInstruction: "Gently draw your chin back... like you're giving yourself a double chin. Feel the stretch in your neck.",
            trackingType: .sensorTracked,
            targetAxis: .pitch,
            targetValue: -15.0,
            holdDuration: 3.0,
            totalDuration: 5.0,
            tolerance: 5.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "neck_02",
            name: "Left Rotation",
            category: .neckMobility,
            instruction: "Turn your head slowly to the left.",
            calmingInstruction: "Slowly turn your head to the left... feel the gentle stretch on the right side of your neck.",
            trackingType: .sensorTracked,
            targetAxis: .yaw,
            targetValue: 35.0,
            holdDuration: 2.0,
            totalDuration: 4.0,
            tolerance: 5.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "neck_03",
            name: "Right Rotation",
            category: .neckMobility,
            instruction: "Turn your head slowly to the right.",
            calmingInstruction: "Now slowly turn your head to the right... matching the stretch on your left side.",
            trackingType: .sensorTracked,
            targetAxis: .yaw,
            targetValue: -35.0,
            holdDuration: 2.0,
            totalDuration: 4.0,
            tolerance: 5.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "neck_04",
            name: "Left Ear Tilt",
            category: .neckMobility,
            instruction: "Tilt your left ear toward your left shoulder.",
            calmingInstruction: "Gently drop your left ear toward your shoulder... let gravity do the work.",
            trackingType: .sensorTracked,
            targetAxis: .roll,
            targetValue: 25.0,
            holdDuration: 3.0,
            totalDuration: 5.0,
            tolerance: 5.0,
            supportedContexts: [.sitting, .standing],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "neck_05",
            name: "Right Ear Tilt",
            category: .neckMobility,
            instruction: "Tilt your right ear toward your right shoulder.",
            calmingInstruction: "Now the other side... drop your right ear toward your shoulder.",
            trackingType: .sensorTracked,
            targetAxis: .roll,
            targetValue: -25.0,
            holdDuration: 3.0,
            totalDuration: 5.0,
            tolerance: 5.0,
            supportedContexts: [.sitting, .standing],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "neck_06",
            name: "Sky Gaze",
            category: .neckMobility,
            instruction: "Gently look up toward the ceiling.",
            calmingInstruction: "Slowly lift your gaze toward the sky... feel your throat open.",
            trackingType: .sensorTracked,
            targetAxis: .pitch,
            targetValue: 25.0,
            holdDuration: 3.0,
            totalDuration: 5.0,
            tolerance: 5.0,
            supportedContexts: [.sitting, .standing],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "neck_07",
            name: "Floor Gaze",
            category: .neckMobility,
            instruction: "Lower your chin toward your chest.",
            calmingInstruction: "Let your head hang forward... chin moving toward your chest. Feel the stretch in the back of your neck.",
            trackingType: .sensorTracked,
            targetAxis: .pitch,
            targetValue: -30.0,
            holdDuration: 3.0,
            totalDuration: 5.0,
            tolerance: 5.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "neck_08",
            name: "Nose Circles Clockwise",
            category: .neckMobility,
            instruction: "Draw small circles with your nose, clockwise.",
            calmingInstruction: "Imagine your nose is a pencil... draw slow, smooth circles clockwise.",
            trackingType: .pattern,
            targetAxis: .pitchYaw,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 8.0,
            tolerance: 10.0,
            supportedContexts: [.all],
            difficultyLevel: 2,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "neck_09",
            name: "Nose Circles Counter-Clockwise",
            category: .neckMobility,
            instruction: "Draw circles with your nose, counter-clockwise.",
            calmingInstruction: "Now reverse direction... smooth counter-clockwise circles with your nose.",
            trackingType: .pattern,
            targetAxis: .pitchYaw,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 8.0,
            tolerance: 10.0,
            supportedContexts: [.all],
            difficultyLevel: 2,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "neck_10",
            name: "Diagonal Left Up",
            category: .neckMobility,
            instruction: "Look up and to the left corner.",
            calmingInstruction: "Turn your gaze up and to the left... like looking at the top corner of a room.",
            trackingType: .sensorTracked,
            targetAxis: .pitchYaw,
            targetValue: 25.0, // Combined target
            holdDuration: 3.0,
            totalDuration: 5.0,
            tolerance: 8.0,
            supportedContexts: [.sitting, .standing],
            difficultyLevel: 2,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "neck_11",
            name: "Diagonal Right Up",
            category: .neckMobility,
            instruction: "Look up and to the right corner.",
            calmingInstruction: "Now the opposite... gaze up and to the right corner.",
            trackingType: .sensorTracked,
            targetAxis: .pitchYaw,
            targetValue: 25.0,
            holdDuration: 3.0,
            totalDuration: 5.0,
            tolerance: 8.0,
            supportedContexts: [.sitting, .standing],
            difficultyLevel: 2,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "neck_12",
            name: "Figure 8 Trace",
            category: .neckMobility,
            instruction: "Trace a figure 8 with your nose slowly.",
            calmingInstruction: "Trace the shape of an eight with your nose... slow and fluid like water.",
            trackingType: .pattern,
            targetAxis: .pitchYaw,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 12.0,
            tolerance: 15.0,
            supportedContexts: [.all],
            difficultyLevel: 3,
            reps: 1
        ))
        
        // ═══════════════════════════════════════════════════════════════
        // ISOMETRIC EXERCISES (10 exercises) - Timed Hold
        // ═══════════════════════════════════════════════════════════════
        
        exercises.append(Exercise(
            id: "iso_01",
            name: "Forward Resist",
            category: .isometric,
            instruction: "Press your forehead into your palm. Hold steady.",
            calmingInstruction: "Place your palm on your forehead... press gently but firmly. Feel your neck muscles engage.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 5.0,
            totalDuration: 6.0,
            tolerance: 0.0,
            supportedContexts: [.sitting, .standing],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "iso_02",
            name: "Back Resist",
            category: .isometric,
            instruction: "Press the back of your head into your palm.",
            calmingInstruction: "Hand behind your head now... press back against your palm. Hold steady.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 5.0,
            totalDuration: 6.0,
            tolerance: 0.0,
            supportedContexts: [.sitting, .standing],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "iso_03",
            name: "Left Side Resist",
            category: .isometric,
            instruction: "Press your left temple into your left palm.",
            calmingInstruction: "Left hand to left temple... push sideways but don't let your head move.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 5.0,
            totalDuration: 6.0,
            tolerance: 0.0,
            supportedContexts: [.sitting, .standing],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "iso_04",
            name: "Right Side Resist",
            category: .isometric,
            instruction: "Press your right temple into your right palm.",
            calmingInstruction: "Right hand to right temple... equal pressure, no movement.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 5.0,
            totalDuration: 6.0,
            tolerance: 0.0,
            supportedContexts: [.sitting, .standing],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "iso_05",
            name: "Chin Tuck Hold",
            category: .isometric,
            instruction: "Tuck your chin and hold. Engage the front of your neck.",
            calmingInstruction: "Tuck your chin back... now hold it there. Feel the front of your neck working.",
            trackingType: .sensorTracked,
            targetAxis: .pitch,
            targetValue: -12.0,
            holdDuration: 8.0,
            totalDuration: 10.0,
            tolerance: 5.0,
            supportedContexts: [.all],
            difficultyLevel: 2,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "iso_06",
            name: "Neck Extension Hold",
            category: .isometric,
            instruction: "Gently lift your head and hold.",
            calmingInstruction: "While lying down, lift your head slightly off the surface... hold it there.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 6.0,
            totalDuration: 8.0,
            tolerance: 0.0,
            supportedContexts: [.lyingDown],
            difficultyLevel: 2,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "iso_07",
            name: "Prone Y Lift",
            category: .isometric,
            instruction: "Arms in Y position, lift slightly and squeeze back.",
            calmingInstruction: "Arms overhead in a Y shape... lift them slightly and squeeze your shoulder blades together.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 8.0,
            totalDuration: 10.0,
            tolerance: 0.0,
            supportedContexts: [.lyingDown],
            difficultyLevel: 2,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "iso_08",
            name: "Wall Push",
            category: .isometric,
            instruction: "Press the back of your head into the wall.",
            calmingInstruction: "Stand against a wall... press the back of your head gently into it.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 5.0,
            totalDuration: 6.0,
            tolerance: 0.0,
            supportedContexts: [.standing],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "iso_09",
            name: "Suboccipital Press",
            category: .isometric,
            instruction: "Fingers at skull base, gently press and hold.",
            calmingInstruction: "Find the base of your skull... fingers there... apply gentle pressure and breathe.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 5.0,
            totalDuration: 6.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "iso_10",
            name: "Jaw Clench Release",
            category: .isometric,
            instruction: "Clench your jaw briefly, then release completely.",
            calmingInstruction: "Clench your jaw... feel the tension... now release completely. Let your jaw hang loose.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 4.0,
            totalDuration: 6.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1
        ))
        
        // ═══════════════════════════════════════════════════════════════
        // SHOULDER & UPPER BACK (10 exercises)
        // ═══════════════════════════════════════════════════════════════
        
        exercises.append(Exercise(
            id: "shoulder_01",
            name: "Scapular Squeeze",
            category: .shoulderBack,
            instruction: "Squeeze your shoulder blades together.",
            calmingInstruction: "Imagine holding a pencil between your shoulder blades... squeeze and hold.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 5.0,
            totalDuration: 7.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "shoulder_02",
            name: "Shoulder Shrug",
            category: .shoulderBack,
            instruction: "Lift your shoulders to your ears, then drop.",
            calmingInstruction: "Lift your shoulders up toward your ears... hold... and let them drop completely.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 3.0,
            totalDuration: 5.0,
            tolerance: 0.0,
            supportedContexts: [.sitting, .standing],
            difficultyLevel: 1,
            reps: 3
        ))
        
        exercises.append(Exercise(
            id: "shoulder_03",
            name: "Shoulder Rolls Forward",
            category: .shoulderBack,
            instruction: "Roll your shoulders forward in slow circles.",
            calmingInstruction: "Roll your shoulders forward... big, slow circles... feel the movement.",
            trackingType: .guided,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 10.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "shoulder_04",
            name: "Shoulder Rolls Backward",
            category: .shoulderBack,
            instruction: "Roll your shoulders backward in slow circles.",
            calmingInstruction: "Now reverse... roll your shoulders backward. Open up your chest.",
            trackingType: .guided,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 10.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "shoulder_05",
            name: "Chest Opener",
            category: .shoulderBack,
            instruction: "Clasp hands behind back, lift and open chest.",
            calmingInstruction: "Interlace your fingers behind your back... lift your hands and open your chest wide.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 8.0,
            totalDuration: 10.0,
            tolerance: 0.0,
            supportedContexts: [.sitting, .standing],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "shoulder_06",
            name: "Seated Chest Press",
            category: .shoulderBack,
            instruction: "Hands on chair arms, gently push chest forward.",
            calmingInstruction: "Push down on your armrests and lift your chest up and forward. Feel the stretch.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 10.0,
            totalDuration: 12.0,
            tolerance: 0.0,
            supportedContexts: [.sitting, .wheelchair],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "shoulder_07",
            name: "Cat-Cow Seated",
            category: .shoulderBack,
            instruction: "Arch your back, then round it. Like a cat stretching.",
            calmingInstruction: "Arch your back... look up... now round your spine... chin to chest. Repeat slowly.",
            trackingType: .sensorTracked,
            targetAxis: .pitch,
            targetValue: 15.0,
            holdDuration: 2.0,
            totalDuration: 12.0,
            tolerance: 8.0,
            supportedContexts: [.sitting],
            difficultyLevel: 1,
            reps: 3
        ))
        
        exercises.append(Exercise(
            id: "shoulder_08",
            name: "Thread the Needle",
            category: .shoulderBack,
            instruction: "Reach one arm under your body, rotating your spine.",
            calmingInstruction: "Reach your right arm under your body... let your shoulder drop... feel the twist in your spine.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 8.0,
            totalDuration: 10.0,
            tolerance: 0.0,
            supportedContexts: [.lyingDown],
            difficultyLevel: 2,
            reps: 2
        ))
        
        exercises.append(Exercise(
            id: "shoulder_09",
            name: "Eagle Arms",
            category: .shoulderBack,
            instruction: "Wrap your arms, lift elbows, feel the stretch.",
            calmingInstruction: "Cross your right arm over left... wrap forearms if you can... lift your elbows and breathe.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 10.0,
            totalDuration: 12.0,
            tolerance: 0.0,
            supportedContexts: [.sitting, .standing],
            difficultyLevel: 2,
            reps: 2
        ))
        
        exercises.append(Exercise(
            id: "shoulder_10",
            name: "Seated Twist",
            category: .shoulderBack,
            instruction: "Place hand on opposite knee, twist gently.",
            calmingInstruction: "Right hand on left knee... left hand behind you... twist gently and look back.",
            trackingType: .sensorTracked,
            targetAxis: .yaw,
            targetValue: 40.0,
            holdDuration: 8.0,
            totalDuration: 10.0,
            tolerance: 10.0,
            supportedContexts: [.sitting],
            difficultyLevel: 1,
            reps: 2
        ))
        
        // ═══════════════════════════════════════════════════════════════
        // EYE & VESTIBULAR (8 exercises)
        // ═══════════════════════════════════════════════════════════════
        
        exercises.append(Exercise(
            id: "eye_01",
            name: "VOR Fixation",
            category: .eyeVestibular,
            instruction: "Focus on your thumb while slowly turning your head.",
            calmingInstruction: "Hold your thumb at arm's length... keep your eyes locked on it while slowly moving your head side to side.",
            trackingType: .pattern,
            targetAxis: .yaw,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 12.0,
            tolerance: 15.0,
            supportedContexts: [.all],
            difficultyLevel: 2,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "eye_02",
            name: "Palming",
            category: .eyeVestibular,
            instruction: "Cup your palms over closed eyes. Notice the darkness.",
            calmingInstruction: "Cup your warm palms over your closed eyes... no pressure... just darkness and rest.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 15.0,
            totalDuration: 18.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "eye_03",
            name: "Near-Far Focus",
            category: .eyeVestibular,
            instruction: "Focus on your thumb, then a distant object. Alternate.",
            calmingInstruction: "Look at your thumb... now something far away... back to your thumb... relax your focus each time.",
            trackingType: .guided,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 15.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "eye_04",
            name: "Figure 8 Eyes",
            category: .eyeVestibular,
            instruction: "Trace a figure 8 with your eyes, head still.",
            calmingInstruction: "Keep your head perfectly still... trace a sideways 8 with just your eyes.",
            trackingType: .sensorTracked,
            targetAxis: .pitch,
            targetValue: 0.0,
            holdDuration: 8.0,
            totalDuration: 10.0,
            tolerance: 3.0,
            supportedContexts: [.all],
            difficultyLevel: 2,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "eye_05",
            name: "Peripheral Scan",
            category: .eyeVestibular,
            instruction: "Without moving your head, scan your peripheral vision.",
            calmingInstruction: "Eyes forward... without moving your head, notice what's in your peripheral vision. Scan slowly.",
            trackingType: .sensorTracked,
            targetAxis: .pitch,
            targetValue: 0.0,
            holdDuration: 10.0,
            totalDuration: 12.0,
            tolerance: 3.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "eye_06",
            name: "20-20-20 Gaze",
            category: .eyeVestibular,
            instruction: "Look at something 20 feet away for 20 seconds.",
            calmingInstruction: "Find something about 20 feet away... rest your gaze there... let your eyes relax completely.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 20.0,
            totalDuration: 22.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "eye_07",
            name: "Eye Circles",
            category: .eyeVestibular,
            instruction: "Slowly circle your eyes clockwise, then reverse.",
            calmingInstruction: "Head still... roll your eyes in slow circles... clockwise... now the other way.",
            trackingType: .sensorTracked,
            targetAxis: .pitch,
            targetValue: 0.0,
            holdDuration: 8.0,
            totalDuration: 10.0,
            tolerance: 3.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "eye_08",
            name: "Convergence Hold",
            category: .eyeVestibular,
            instruction: "Slowly bring your thumb toward your nose, maintaining focus.",
            calmingInstruction: "Thumb at arm's length... slowly bring it toward your nose... keep it in focus as long as you can.",
            trackingType: .guided,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 10.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 2,
            reps: 1
        ))
        
        // ═══════════════════════════════════════════════════════════════
        // BREATHWORK (6 exercises)
        // ═══════════════════════════════════════════════════════════════
        
        exercises.append(Exercise(
            id: "breath_01",
            name: "Box Breathing",
            category: .breathwork,
            instruction: "Inhale 4... Hold 4... Exhale 4... Hold 4...",
            calmingInstruction: "Breathe in for four... hold for four... breathe out for four... hold empty for four. A perfect box.",
            trackingType: .guided,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 32.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 2
        ))
        
        exercises.append(Exercise(
            id: "breath_02",
            name: "Physiological Sigh",
            category: .breathwork,
            instruction: "Double inhale through nose, long exhale through mouth.",
            calmingInstruction: "Breathe in through your nose... now take another quick sip of air... now exhale slowly through your mouth.",
            trackingType: .guided,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 8.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 3
        ))
        
        exercises.append(Exercise(
            id: "breath_03",
            name: "Diaphragmatic Breath",
            category: .breathwork,
            instruction: "Hand on belly. Breathe so your belly rises, not chest.",
            calmingInstruction: "One hand on your belly, one on your chest... breathe so only your belly hand moves outward.",
            trackingType: .guided,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 20.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "breath_04",
            name: "4-7-8 Calming",
            category: .breathwork,
            instruction: "Inhale 4... Hold 7... Exhale slowly 8...",
            calmingInstruction: "Breathe in for four... hold your breath for seven... exhale slowly for eight counts. This calms your nervous system.",
            trackingType: .guided,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 38.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 2,
            reps: 2
        ))
        
        exercises.append(Exercise(
            id: "breath_05",
            name: "Breath Awareness",
            category: .breathwork,
            instruction: "Simply notice your breath without changing it.",
            calmingInstruction: "Just notice your breath... don't try to change it... simply observe. Where do you feel it most?",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 15.0,
            totalDuration: 18.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "breath_06",
            name: "Tension Release Breath",
            category: .breathwork,
            instruction: "Inhale and tense shoulders. Exhale and release completely.",
            calmingInstruction: "Breathe in deeply and shrug your shoulders up tight... now exhale and let everything drop. Feel the release.",
            trackingType: .guided,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 10.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 3
        ))
        
        // ═══════════════════════════════════════════════════════════════
        // YOGA STRETCHES (8 exercises)
        // ═══════════════════════════════════════════════════════════════
        
        exercises.append(Exercise(
            id: "yoga_01",
            name: "Mountain Pose",
            category: .yogaStretch,
            instruction: "Stand tall, weight even, crown reaching skyward.",
            calmingInstruction: "Feet hip width... weight balanced... imagine a string pulling the crown of your head toward the sky.",
            trackingType: .sensorTracked,
            targetAxis: .pitch,
            targetValue: 0.0,
            holdDuration: 15.0,
            totalDuration: 18.0,
            tolerance: 5.0,
            supportedContexts: [.standing],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "yoga_02",
            name: "Standing Forward Fold",
            category: .yogaStretch,
            instruction: "Hinge at hips, let head hang heavy.",
            calmingInstruction: "Bend forward from your hips... let your head hang like a heavy fruit. Feel your spine lengthen.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 12.0,
            totalDuration: 15.0,
            tolerance: 0.0,
            supportedContexts: [.standing],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "yoga_03",
            name: "Neck Release",
            category: .yogaStretch,
            instruction: "Let your head hang forward. Feel the weight stretching.",
            calmingInstruction: "Drop your chin to your chest... let gravity do all the work... breathe into the back of your neck.",
            trackingType: .sensorTracked,
            targetAxis: .pitch,
            targetValue: -35.0,
            holdDuration: 10.0,
            totalDuration: 12.0,
            tolerance: 8.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "yoga_04",
            name: "Wrist Circles",
            category: .yogaStretch,
            instruction: "Rotate your wrists slowly in both directions.",
            calmingInstruction: "Circle your wrists slowly... clockwise... now counter-clockwise. Release tension in your hands.",
            trackingType: .guided,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 12.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "yoga_05",
            name: "Deep Rest",
            category: .rest,
            instruction: "Do nothing. Let gravity hold your head.",
            calmingInstruction: "There is nothing to do right now. Just let your body be heavy. Let gravity support you completely.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 30.0,
            totalDuration: 35.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "yoga_06",
            name: "Constructive Rest",
            category: .rest,
            instruction: "Knees bent, feet flat, arms relaxed. Just breathe.",
            calmingInstruction: "Knees up, feet flat on the floor... arms resting by your sides... simply breathe and let go.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 45.0,
            totalDuration: 50.0,
            tolerance: 0.0,
            supportedContexts: [.lyingDown],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "yoga_07",
            name: "Supine Twist",
            category: .yogaStretch,
            instruction: "Knees together, drop to one side, arms wide.",
            calmingInstruction: "Knees together... let them fall to one side... arms spread wide. Breathe into the twist.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 15.0,
            totalDuration: 18.0,
            tolerance: 0.0,
            supportedContexts: [.lyingDown],
            difficultyLevel: 1,
            reps: 2
        ))
        
        exercises.append(Exercise(
            id: "yoga_08",
            name: "Child's Pose Modified",
            category: .yogaStretch,
            instruction: "Fold forward over your legs, reach arms ahead.",
            calmingInstruction: "Sit back on your heels if you can... fold forward... let your forehead rest and arms extend.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 20.0,
            totalDuration: 25.0,
            tolerance: 0.0,
            supportedContexts: [.sitting, .lyingDown],
            difficultyLevel: 1,
            reps: 1
        ))
        
        // ═══════════════════════════════════════════════════════════════
        // WHEELCHAIR-SPECIFIC (4 exercises)
        // ═══════════════════════════════════════════════════════════════
        
        exercises.append(Exercise(
            id: "wheel_01",
            name: "Seated Chest Expansion",
            category: .wheelchair,
            instruction: "Hands on wheels, push chest forward gently.",
            calmingInstruction: "Grip your wheels lightly... push your chest forward and up. Open up the front of your body.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 8.0,
            totalDuration: 10.0,
            tolerance: 0.0,
            supportedContexts: [.wheelchair],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "wheel_02",
            name: "Trunk Rotation",
            category: .wheelchair,
            instruction: "Keeping hips stable, rotate upper body left, then right.",
            calmingInstruction: "Keep your hips facing forward... rotate your upper body to the left... now to the right.",
            trackingType: .sensorTracked,
            targetAxis: .yaw,
            targetValue: 30.0,
            holdDuration: 5.0,
            totalDuration: 20.0,
            tolerance: 8.0,
            supportedContexts: [.wheelchair],
            difficultyLevel: 1,
            reps: 2
        ))
        
        exercises.append(Exercise(
            id: "wheel_03",
            name: "Overhead Reach",
            category: .wheelchair,
            instruction: "Interlace fingers, push palms toward ceiling.",
            calmingInstruction: "Interlace your fingers... flip your palms up and push toward the ceiling. Stretch your whole side body.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 8.0,
            totalDuration: 10.0,
            tolerance: 0.0,
            supportedContexts: [.wheelchair, .sitting],
            difficultyLevel: 1,
            reps: 1
        ))
        
        exercises.append(Exercise(
            id: "wheel_04",
            name: "Lateral Side Lean",
            category: .wheelchair,
            instruction: "Lean sideways, stretching the side of your torso.",
            calmingInstruction: "Lean to your left... feel the stretch along your right side. Now switch.",
            trackingType: .sensorTracked,
            targetAxis: .roll,
            targetValue: 20.0,
            holdDuration: 8.0,
            totalDuration: 20.0,
            tolerance: 5.0,
            supportedContexts: [.wheelchair],
            difficultyLevel: 1,
            reps: 2
        ))
        
        return exercises
    }
}
