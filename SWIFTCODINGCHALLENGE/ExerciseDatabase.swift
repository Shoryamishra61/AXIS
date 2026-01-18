//
//  ExerciseDatabase.swift
//  AXIS
//
//  Created by admin67 on 24/12/25.
//

import Foundation

// MARK: - Time Duration Framework
enum SessionDuration: Int, CaseIterable {
    case twoMinutes = 2
    case fourMinutes = 4
    case sixMinutes = 6
    case eightMinutes = 8
    case tenMinutes = 10
    
    var displayName: String {
        "\(rawValue) Minutes"
    }
}

struct ExerciseDatabase {
    static let shared = ExerciseDatabase()
    let allExercises: [Exercise]
    
    private init() {
        allExercises = Self.buildDatabase()
    }
    
    // MARK: - Database Builder
    private static func buildDatabase() -> [Exercise] {
        var exercises: [Exercise] = []
        
        // ═══════════════════════════════════════════════════════════════
        // NECK MOBILITY (The "Floating Head" Series)
        // ═══════════════════════════════════════════════════════════════
        
        exercises.append(Exercise(
            id: "neck_01",
            name: "Chin Tuck",
            category: .neckMobility,
            instruction: "Draw your chin straight back, making a double chin.",
            calmingInstruction: "Let’s begin by finding length. Gently nod your head, as if you're saying a slow, graceful 'yes.' Draw your chin straight back, creating an elegant, double-chin effect. Imagine the crown of your head is floating up toward the ceiling, creating glorious space between your vertebrae. Hold here for a moment. Breathe into the gentle stretch at the base of your skull. This simple movement is a powerful reset for your entire spine.",
            preparation: "Sit or stand tall with your shoulders relaxed.",
            voiceGuidance: [
                "Gently nod your head, as if you're saying a slow, graceful 'yes.'",
                "Draw your chin straight back, creating an elegant, double-chin effect.",
                "Imagine the crown of your head is floating up toward the ceiling.",
                "Create glorious space between your vertebrae.",
                "Breathe into the gentle stretch at the base of your skull."
            ],
            completion: "Release gently, keeping that sense of length in your neck.",
            trackingType: .sensorTracked,
            targetAxis: .pitch,
            targetValue: -15.0,
            holdDuration: 5.0,
            totalDuration: 15.0,
            tolerance: 10.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 3,
            primaryBenefit: "Strengthens deep cervical flexors",
            scientificRationale: "Activates longus colli muscles to counteract forward head posture."
        ))
        
        exercises.append(Exercise(
            id: "neck_02",
            name: "Left Rotation",
            category: .neckMobility,
            instruction: "Turn your head slowly to the left.",
            calmingInstruction: "Now, let’s invite some movement into your neck. Slowly turn your head to the left, leading with your gaze. Move only as far as is comfortable, feeling a gentle stretch along the right side of your neck. There’s no need to force it. Just explore your natural range of motion with curiosity.",
            preparation: "Center your head and relax your jaw.",
            voiceGuidance: [
                "Slowly turn your head to the left, leading with your gaze.",
                "Move only as far as is comfortable.",
                "Feel a gentle stretch along the right side of your neck.",
                "There’s no need to force it.",
                "Explore your natural range of motion with curiosity."
            ],
            completion: "Slowly return to center.",
            trackingType: .sensorTracked,
            targetAxis: .yaw,
            targetValue: 45.0,
            holdDuration: 5.0,
            totalDuration: 12.0,
            tolerance: 10.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 2,
            primaryBenefit: "Improves cervical rotation range of motion",
            scientificRationale: "Mobilizes the atlanto-axial joint and releases sternocleidomastoid tension."
        ))
        
        exercises.append(Exercise(
            id: "neck_03",
            name: "Right Rotation",
            category: .neckMobility,
            instruction: "Turn your head slowly to the right.",
            calmingInstruction: "Beautiful. Now, let’s flow back through center and over to the right. Turn your head slowly, gazing gently over your right shoulder. Feel the corresponding stretch on the left side. Notice how this movement releases any built-up tension. It’s like giving your neck a gentle, mindful wake-up call.",
            preparation: "Return to center, taking a breath.",
            voiceGuidance: [
                "Flow back through center and over to the right.",
                "Turn your head slowly, gazing gently over your right shoulder.",
                "Feel the corresponding stretch on the left side.",
                "Notice how this movement releases any built-up tension.",
                "It’s like giving your neck a gentle, mindful wake-up call."
            ],
            completion: "Gently float your head back to center.",
            trackingType: .sensorTracked,
            targetAxis: .yaw,
            targetValue: -45.0,
            holdDuration: 5.0,
            totalDuration: 12.0,
            tolerance: 10.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 2,
            primaryBenefit: "Improves cervical rotation range of motion",
            scientificRationale: "Mobilizes the atlanto-axial joint and releases sternocleidomastoid tension."
        ))
        
        exercises.append(Exercise(
            id: "neck_04",
            name: "Left Ear Tilt",
            category: .neckMobility,
            instruction: "Tilt your left ear toward your left shoulder.",
            calmingInstruction: "Releasing your neck back to center, let’s now take it into a side bend. Gently tilt your left ear down towards your left shoulder. Allow the weight of your head to create the stretch, rather than forcing it. Imagine your right shoulder melting away from your right ear, creating a long, open line along the side of your neck.",
            preparation: "Keep your shoulders low and relaxed.",
            voiceGuidance: [
                "Gently tilt your left ear down towards your left shoulder.",
                "Allow the weight of your head to create the stretch, rather than forcing it.",
                "Imagine your right shoulder melting away from your right ear.",
                "Create a long, open line along the side of your neck."
            ],
            completion: "Lift your head slowly back to vertical.",
            trackingType: .sensorTracked,
            targetAxis: .roll,
            targetValue: -30.0,
            holdDuration: 8.0,
            totalDuration: 15.0,
            tolerance: 10.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 2,
            primaryBenefit: "Stretches upper trapezius and scalenes",
            scientificRationale: "Elongates lateral neck muscles often tight from stress and shoulder elevation."
        ))
        
        exercises.append(Exercise(
            id: "neck_05",
            name: "Right Ear Tilt",
            category: .neckMobility,
            instruction: "Tilt your right ear toward your right shoulder.",
            calmingInstruction: "And now, let’s honor the other side. Slowly bring your head back through center and tilt your right ear towards your right shoulder. Feel that beautiful, opening stretch along the left side of your neck. Breathe into this space, sending your breath to any areas of tightness and inviting them to release.",
            preparation: "Breathe in, sitting tall.",
            voiceGuidance: [
                "Slowly bring your head back through center and tilt your right ear towards your right shoulder.",
                "Feel that beautiful, opening stretch along the left side of your neck.",
                "Breathe into this space.",
                "Send your breath to any areas of tightness and invite them to release."
            ],
            completion: "Return to center, feeling balanced.",
            trackingType: .sensorTracked,
            targetAxis: .roll,
            targetValue: 30.0,
            holdDuration: 8.0,
            totalDuration: 15.0,
            tolerance: 10.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 2,
            primaryBenefit: "Stretches upper trapezius and scalenes",
            scientificRationale: "Elongates lateral neck muscles often tight from stress and shoulder elevation."
        ))
        
        exercises.append(Exercise(
            id: "neck_06",
            name: "Sky Gaze",
            category: .neckMobility,
            instruction: "Gently look up toward the ceiling.",
            calmingInstruction: "From here, let’s gently lift your gaze towards the sky, or the ceiling above you. Allow your head to tilt back slightly, opening up the front of your throat and chest. This is a lovely heart-opening movement. Be mindful not to crunch the back of your neck; keep the movement smooth and controlled.",
            preparation: "Open your chest slightly.",
            voiceGuidance: [
                "Gently lift your gaze towards the sky.",
                "Allow your head to tilt back slightly, opening up the front of your throat.",
                "This is a lovely heart-opening movement.",
                "Be mindful not to crunch the back of your neck.",
                "Keep the movement smooth and controlled."
            ],
            completion: "Bring your gaze back to the horizon.",
            trackingType: .sensorTracked,
            targetAxis: .pitch,
            targetValue: -30.0,
            holdDuration: 5.0,
            totalDuration: 10.0,
            tolerance: 10.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 2,
            primaryBenefit: "Opens anterior neck and throat",
            scientificRationale: "Stretches the platysma and SCM, counteracting the downward gaze of screen time."
        ))

        exercises.append(Exercise(
            id: "neck_07",
            name: "Floor Gaze",
            category: .neckMobility,
            instruction: "Lower your chin toward your chest.",
            calmingInstruction: "Slowly and with control, lower your chin down towards your chest. Let your head hang heavy, releasing all the muscles in the back of your neck. This is a moment of complete surrender. Feel the gentle pull along your entire spine, a therapeutic stretch that can calm the mind and relieve tension.",
            preparation: "Inhale deeply.",
            voiceGuidance: [
                "Slowly and with control, lower your chin down towards your chest.",
                "Let your head hang heavy.",
                "Release all the muscles in the back of your neck.",
                "This is a moment of complete surrender.",
                "Feel the gentle pull along your entire spine."
            ],
            completion: "Slowly lift your head.",
            trackingType: .sensorTracked,
            targetAxis: .pitch,
            targetValue: 30.0,
            holdDuration: 8.0,
            totalDuration: 12.0,
            tolerance: 10.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 2,
            primaryBenefit: "Releases posterior cervical extensors",
            scientificRationale: "Stretches the suboccipital and paraspinal muscles."
        ))
        
        exercises.append(Exercise(
            id: "neck_08",
            name: "Nose Circles Clockwise",
            category: .neckMobility,
            instruction: "Draw small circles with your nose, clockwise.",
            calmingInstruction: "Now, let’s add a little fluidity. Imagine the tip of your nose is a paintbrush, and you’re going to paint small, smooth circles in the air. Begin by tracing these circles in a clockwise direction. Keep the movements tiny and controlled, feeling the subtle engagement all around your neck. It’s a wonderful way to lubricate the cervical joints.",
            preparation: "Imagine a canvas in front of your face.",
            voiceGuidance: [
                "Imagine the tip of your nose is a paintbrush.",
                "Paint small, smooth circles in the air.",
                "Begin by tracing these circles in a clockwise direction.",
                "Keep the movements tiny and controlled.",
                "Feel the subtle engagement all around your neck."
            ],
            completion: "Come to stillness in the center.",
            trackingType: .pattern,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 15.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 2,
            reps: 5,
            primaryBenefit: "Increases cervical proprioception",
            scientificRationale: "Refines fine motor control of the neck and lubricates facet joints."
        ))
        
        exercises.append(Exercise(
            id: "neck_09",
            name: "Nose Circles Counter-Clockwise",
            category: .neckMobility,
            instruction: "Draw circles with your nose, counter-clockwise.",
            calmingInstruction: "Let’s reverse the flow. Begin tracing small circles with your nose in the counter-clockwise direction. Notice how this feels different. Stay present with the sensation, exploring the full range of motion in every direction. This mindful movement helps to improve your proprioception, your body’s awareness of where it is in space.",
            preparation: "Prepare to reverse the direction.",
            voiceGuidance: [
                "Let’s reverse the flow.",
                "Begin tracing small circles with your nose in the counter-clockwise direction.",
                "Notice how this feels different.",
                "Stay present with the sensation.",
                "Explore the full range of motion in every direction."
            ],
            completion: "Rest in stillness.",
            trackingType: .pattern,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 15.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 2,
            reps: 5,
            primaryBenefit: "Increases cervical proprioception",
            scientificRationale: "Refines fine motor control of the neck and lubricates facet joints."
        ))
        
        exercises.append(Exercise(
            id: "neck_10",
            name: "Figure 8 Trace",
            category: .neckMobility,
            instruction: "Trace a figure 8 with your nose slowly.",
            calmingInstruction: "For our final neck mobility exercise, we’ll trace a figure-eight, or an infinity symbol, with our nose. Make the movement slow, fluid, and continuous, like water flowing in a stream. This integrates all the different directions of movement, leaving your neck feeling supple, free, and completely mobile.",
            preparation: "Imagine an infinity symbol in front of you.",
            voiceGuidance: [
                "Trace a figure-eight, or an infinity symbol, with your nose.",
                "Make the movement slow, fluid, and continuous.",
                "Like water flowing in a stream.",
                "Integrate all the different directions of movement."
            ],
            completion: "Relax your neck completely.",
            trackingType: .pattern,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 20.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 2,
            reps: 3,
            primaryBenefit: "Integrates multi-planar cervical movement",
            scientificRationale: "Enhances coordination and fluid movement across all cervical planes."
        ))
        
        // ... (Adding a subset to start, will continue in next chunks)
        
        // ═══════════════════════════════════════════════════════════════
        // ISOMETRIC (Strength Building)
        // ═══════════════════════════════════════════════════════════════
        
        exercises.append(Exercise(
            id: "iso_01",
            name: "Forward Resist",
            category: .isometric,
            instruction: "Press your forehead into your palm. Hold steady.",
            calmingInstruction: "Let’s move into some strengthening work. Bring your palm to your forehead. Gently press your head forward into your hand, while your hand provides an equal and opposite resistance. Your head should not actually move. Feel the deep muscles in the front of your neck engage. This is a powerful way to build stability without stressing the joints.",
            preparation: "Place your palm on your forehead.",
            voiceGuidance: [
                "Gently press your head forward into your hand.",
                "Your hand provides an equal and opposite resistance.",
                "Your head should not actually move.",
                "Feel the deep muscles in the front of your neck engage.",
                "Build stability without stressing the joints."
            ],
            completion: "Release the pressure slowly.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 8.0,
            totalDuration: 12.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 3,
            primaryBenefit: "Strengthens deep neck flexors",
            scientificRationale: "Isometric loading builds strength without joint shear."
        ))
        
        exercises.append(Exercise(
            id: "iso_02",
            name: "Back Resist",
            category: .isometric,
            instruction: "Press the back of your head into your palm.",
            calmingInstruction: "Now, bring your hand to the back of your head. Press gently backward into your palm, creating that same isometric resistance. You should feel the muscles at the back of your neck activate. This helps to counterbalance the forward head posture that so many of us develop from looking at screens.",
            preparation: "Place hand behind head.",
            voiceGuidance: [
                "Press gently backward into your palm.",
                "Create that same isometric resistance.",
                "Feel the muscles at the back of your neck activate.",
                "Counterbalance forward head posture."
            ],
            completion: "Relax your arm down.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 8.0,
            totalDuration: 12.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 3,
            primaryBenefit: "Strengthens cervical extensors",
            scientificRationale: "Restores posterior neck muscle tone."
        ))
        
        exercises.append(Exercise(
            id: "iso_03",
            name: "Left Side Resist",
            category: .isometric,
            instruction: "Press your left temple into your left palm.",
            calmingInstruction: "Placing your left palm against your left temple, gently press your head sideways into your hand. Again, no actual movement should occur. Just a steady, solid engagement of the muscles along the side of your neck. This builds lateral stability, which is crucial for supporting the head in all planes of movement.",
            preparation: "Left hand to left temple.",
            voiceGuidance: [
                "Gently press your head sideways into your hand.",
                "No actual movement should occur.",
                "Just a steady, solid engagement.",
                "Build lateral stability."
            ],
            completion: "Release gently.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 8.0,
            totalDuration: 12.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 2,
            primaryBenefit: "Strengthens lateral neck flexors",
            scientificRationale: "Balances lateral muscle symmetry."
        ))
        
        exercises.append(Exercise(
            id: "iso_04",
            name: "Right Side Resist",
            category: .isometric,
            instruction: "Press your right temple into your right palm.",
            calmingInstruction: "And now to the other side. Right palm to right temple, pressing gently sideways. Feel the engagement on this side. These isometric exercises are incredibly efficient at waking up muscles that may have become lazy and underused. It’s like sending a direct message to your brain to fire up these stabilizers.",
            preparation: "Right hand to right temple.",
            voiceGuidance: [
                "Pressing gently sideways.",
                "Feel the engagement on this side.",
                "Wake up muscles that may have become lazy.",
                "Send a direct message to fire up these stabilizers."
            ],
            completion: "Lower your hand and relax.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 8.0,
            totalDuration: 12.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 2,
            primaryBenefit: "Strengthens lateral neck flexors",
            scientificRationale: "Balances lateral muscle symmetry."
        ))
        
        exercises.append(Exercise(
            id: "iso_05",
            name: "Chin Tuck Hold",
            category: .isometric,
            instruction: "Tuck your chin and hold. Engage the front of your neck.",
            calmingInstruction: "This is one of the most important exercises for modern posture. Gently perform that chin tuck we practiced earlier, drawing your head back into alignment over your spine. Now, hold it there. You should feel the deep, flexor muscles in the front of your neck working. These are your postural ‘anti-gravity’ muscles.",
            preparation: "Find your tall spine.",
            voiceGuidance: [
                "Gently draw your head back into alignment over your spine.",
                "Now, hold it there.",
                "Feel the deep flexor muscles in the front of your neck working.",
                "These are your postural ‘anti-gravity’ muscles."
            ],
            completion: "Release the hold but keep the height.",
            trackingType: .sensorTracked,
            targetAxis: .pitch,
            targetValue: -10.0,
            holdDuration: 10.0,
            totalDuration: 15.0,
            tolerance: 5.0,
            supportedContexts: [.all],
            difficultyLevel: 2,
            reps: 3,
            primaryBenefit: "Endurance for deep cervical flexors",
            scientificRationale: "Builds static endurance to hold head position usually."
        ))
        
        exercises.append(Exercise(
            id: "iso_06",
            name: "Wall Push",
            category: .isometric,
            instruction: "Press the back of your head into the wall.",
            calmingInstruction: "Find a clear wall behind you. Gently press the back of your head into it. This provides a wonderful cue for what proper head alignment feels like. Hold this gentle pressure, allowing the muscles at the front of your neck to release and the back of your neck to lengthen.",
            preparation: "Stand with your back against a wall.",
            voiceGuidance: [
                "Gently press the back of your head into the wall.",
                "This provides a wonderful cue for proper alignment.",
                "Hold this gentle pressure.",
                "Allow the back of your neck to lengthen."
            ],
            completion: "Step away, keeping that alignment.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 10.0,
            totalDuration: 15.0,
            tolerance: 0.0,
            supportedContexts: [.standing, .sitting],
            difficultyLevel: 1,
            reps: 3,
            primaryBenefit: "Corrects forward head carriage",
            scientificRationale: "Proprioceptive feedback for neutral head position."
        ))
        
        // ═══════════════════════════════════════════════════════════════
        // SHOULDER & BACK (The "Heart Opener" Series)
        // ═══════════════════════════════════════════════════════════════
        
        exercises.append(Exercise(
            id: "sh_01",
            name: "Scapular Squeeze",
            category: .shoulderBack,
            instruction: "Squeeze your shoulder blades together.",
            calmingInstruction: "Bringing our awareness to our upper back, let’s gently squeeze our shoulder blades together and down. Imagine you’re trying to hold a small piece of paper between them. Hold this squeeze, feeling the muscles between your shoulder blades engage. This strengthens the rhomboids and middle trapezius, key muscles for good posture.",
            preparation: "Relax your arms by your sides.",
            voiceGuidance: [
                "Gently squeeze your shoulder blades together and down.",
                "Imagine you’re trying to hold a small piece of paper between them.",
                "Hold this squeeze.",
                "Feel the muscles between your shoulder blades engage."
            ],
            completion: "Release and let shoulders widen.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 5.0,
            totalDuration: 10.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 5,
            primaryBenefit: "Activates rhomboids and middle trapezius",
            scientificRationale: "Counteracts scapular protraction common in desk work."
        ))
        
        exercises.append(Exercise(
            id: "sh_02",
            name: "Shoulder Shrug",
            category: .shoulderBack,
            instruction: "Lift your shoulders to your ears, then drop.",
            calmingInstruction: "Now, let’s release tension. Inhale deeply as you lift your shoulders up towards your ears. Exhale powerfully through your mouth as you drop them down completely. Let’s do that a few more times. Inhale, lift… and exhale, drop. Feel the weight of your shoulders melting away from your ears with each repetition.",
            preparation: "Let your arms hang heavy.",
            voiceGuidance: [
                "Inhale deeply as you lift your shoulders up towards your ears.",
                "Exhale powerfully through your mouth as you drop them down completely.",
                "Feel the weight of your shoulders melting away from your ears."
            ],
            completion: "Let your shoulders settle low.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 3.0,
            totalDuration: 8.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 3,
            primaryBenefit: "Releases upper trapezius tension",
            scientificRationale: "Contract-relax technique for hypertonic muscles."
        ))
        
        exercises.append(Exercise(
            id: "sh_03",
            name: "Shoulder Rolls Forward",
            category: .shoulderBack,
            instruction: "Roll your shoulders forward in slow circles.",
            calmingInstruction: "Let’s add some fluid movement. Slowly roll your shoulders forward in big, smooth circles. Make the circles as large as is comfortable. This helps to lubricate the shoulder joints and release any stiffness in the upper back. Feel the muscles around your shoulder blades gliding over your ribcage.",
            preparation: "Arms relaxed.",
            voiceGuidance: [
                "Slowly roll your shoulders forward in big, smooth circles.",
                "Make the circles as large as is comfortable.",
                "Lubricate the shoulder joints.",
                "Feel the muscles around your shoulder blades gliding."
            ],
            completion: "Pause at the bottom.",
            trackingType: .pattern,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 15.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 5,
            primaryBenefit: "Mobilizes glenohumeral joint",
            scientificRationale: "Synovial fluid circulation and dynamic mobility."
        ))
        
        exercises.append(Exercise(
            id: "sh_04",
            name: "Shoulder Rolls Backward",
            category: .shoulderBack,
            instruction: "Roll your shoulders backward in slow circles.",
            calmingInstruction: "Now, let’s reverse the direction. Roll your shoulders backward and down. This direction is particularly good for opening up the chest and counteracting a forward-rounded posture. Imagine your shoulder blades are drawing down towards your back pockets, creating space across your chest.",
            preparation: "Reverse the direction.",
            voiceGuidance: [
                "Roll your shoulders backward and down.",
                "Open up the chest.",
                "Imagine your shoulder blades are drawing down towards your back pockets.",
                "Create space across your chest."
            ],
            completion: "Rest with shoulders back and down.",
            trackingType: .pattern,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 15.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 5,
            primaryBenefit: "Mobilizes glenohumeral joint",
            scientificRationale: "Encourages scapular retraction and depression."
        ))
        
        exercises.append(Exercise(
            id: "sh_05",
            name: "Chest Opener",
            category: .shoulderBack,
            instruction: "Clasp hands behind back, lift and open chest.",
            calmingInstruction: "For a deeper chest opening, interlace your fingers behind your back. If you can’t reach, you can hold onto a towel or strap. Straighten your arms and gently lift them up and away from your body. Feel your chest expand and your heart center lift. Breathe deeply into this open space.",
            preparation: "Reach behind you.",
            voiceGuidance: [
                "Interlace your fingers behind your back.",
                "Straighten your arms and gently lift them up and away.",
                "Feel your chest expand and your heart center lift.",
                "Breathe deeply into this open space."
            ],
            completion: "Release your hands gently.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 10.0,
            totalDuration: 15.0,
            tolerance: 0.0,
            supportedContexts: [.standing, .sitting],
            difficultyLevel: 2,
            reps: 2,
            primaryBenefit: "Stretches pectoralis major and minor",
            scientificRationale: "Reverses the shortening of anterior chest muscles from slump posture."
        ))
        
        exercises.append(Exercise(
            id: "sh_06",
            name: "Seated Chest Press",
            category: .shoulderBack,
            instruction: "Hands on chair arms, gently push chest forward.",
            calmingInstruction: "If you’re sitting, place your hands on the arms of your chair. Gently press down into the armrests as you lift your chest up and forward. This is a fantastic way to create space in your chest and strengthen your upper back while seated. It’s like a mini, seated push-up for your posture.",
            preparation: "Hands on armrests or seat edge.",
            voiceGuidance: [
                "Gently press down into the armrests.",
                "Lift your chest up and forward.",
                "Create space in your chest.",
                "Strengthen your upper back while seated."
            ],
            completion: "Relax back to neutral.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 8.0,
            totalDuration: 12.0,
            tolerance: 0.0,
            supportedContexts: [.sitting, .wheelchair],
            difficultyLevel: 1,
            reps: 3,
            primaryBenefit: "Thoracic extension",
            scientificRationale: "Mobilizes the thoracic spine into extension."
        ))
        
        exercises.append(Exercise(
            id: "sh_07",
            name: "Cat-Cow Seated",
            category: .shoulderBack,
            instruction: "Arch your back, then round it.",
            calmingInstruction: "Let’s flow with our breath. Sitting tall, place your hands on your knees. As you inhale, gently arch your back, lifting your chest and gaze up towards the ceiling. As you exhale, round your spine, tucking your chin to your chest and drawing your navel in. Continue this fluid motion, linking breath and movement.",
            preparation: "Hands on knees, spine tall.",
            voiceGuidance: [
                "Inhale, gently arch your back, lifting chest and gaze.",
                "Exhale, round your spine, tucking chin and drawing navel in.",
                "Flow with your breath.",
                "Awaken the entire spine."
            ],
            completion: "Find a neutral, tall spine.",
            trackingType: .pattern,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 20.0,
            tolerance: 0.0,
            supportedContexts: [.sitting, .wheelchair],
            difficultyLevel: 1,
            reps: 5,
            primaryBenefit: "Spinal flexibility",
            scientificRationale: "Flossing the spinal nerves and mobilizing intervertebral joints."
        ))
        
        exercises.append(Exercise(
            id: "sh_08",
            name: "Eagle Arms",
            category: .shoulderBack,
            instruction: "Wrap your arms, lift elbows, feel the stretch.",
            calmingInstruction: "Sitting or standing, extend your arms forward. Cross your right arm over your left, then bend your elbows so your palms come together (or as close as you can get them). Lift your elbows up and press your hands away from your face. You should feel a deep stretch in your upper back and the backs of your shoulders.",
            preparation: "Extend arms forward.",
            voiceGuidance: [
                "Cross right arm over left, bend elbows.",
                "Lift your elbows up and press hands away from your face.",
                "Feel a deep stretch in your upper back.",
                "Breathe into the space between your shoulders."
            ],
            completion: "Unravel and shake out your arms.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 10.0,
            totalDuration: 15.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 2,
            reps: 2,
            primaryBenefit: "Opens posterior shoulder capsule",
            scientificRationale: "Stretches rhomboids and posterior deltoids."
        ))

        // ... (Adding a subset to start, will continue in next chunks)
        
        // ═══════════════════════════════════════════════════════════════
        // EYE & VESTIBULAR (Tech Neck Relief)
        // ═══════════════════════════════════════════════════════════════
        
        exercises.append(Exercise(
            id: "eye_01",
            name: "VOR Fixation",
            category: .eyeVestibular,
            instruction: "Focus on your thumb while slowly turning your head.",
            calmingInstruction: "Our eyes and neck are deeply connected. Hold your thumb out at arm’s length. Keep your eyes locked on your thumbnail as you slowly turn your head from side to side. Your head moves, but your gaze stays fixed. This is called the vestibulo-ocular reflex and it’s fantastic for reducing dizziness and improving coordination.",
            preparation: "Thumb out, arm straight.",
            voiceGuidance: [
                "Keep your eyes locked on your thumbnail.",
                "Slowly turn your head from side to side.",
                "Your head moves, but your gaze stays fixed.",
                "Reduce dizziness and improve coordination."
            ],
            completion: "Relax your arm and eyes.",
            trackingType: .pattern,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 20.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 2,
            reps: 5,
            primaryBenefit: "Vestibulo-Ocular Reflex stability",
            scientificRationale: "Syncs vestibular input with visual fixation to reduce dizziness."
        ))
        
        exercises.append(Exercise(
            id: "eye_02",
            name: "Palming",
            category: .eyeVestibular,
            instruction: "Cup your palms over closed eyes. Notice the darkness.",
            calmingInstruction: "Let’s give our eyes a rest. Rub your palms together vigorously until they feel warm. Then, gently cup them over your closed eyes. Don’t press on your eyeballs; just create a dark, warm sanctuary. Notice the profound darkness and allow your eye muscles to completely relax. Stay here for as long as feels good.",
            preparation: "Rub hands together to warm them.",
            voiceGuidance: [
                "Gently cup them over your closed eyes.",
                "Create a dark, warm sanctuary.",
                "Notice the profound darkness.",
                "Allow your eye muscles to completely relax."
            ],
            completion: "Slowly lower your hands.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 20.0,
            totalDuration: 25.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1,
            primaryBenefit: "Relaxes extraocular muscles",
            scientificRationale: "Reduces visual stimuli and soothes optic nerve."
        ))
        
        exercises.append(Exercise(
            id: "eye_03",
            name: "Near-Far Focus",
            category: .eyeVestibular,
            instruction: "Focus on your thumb, then a distant object. Alternate.",
            calmingInstruction: "To exercise our eye muscles, hold your thumb up at arm’s length. Focus on it for a moment. Then, shift your gaze to an object far away in the distance. Focus on that. Now, back to your thumb. Continue this near-far focusing. This can help relieve eye strain from staring at screens for too long.",
            preparation: "Thumb up at arm's length.",
            voiceGuidance: [
                "Focus on your thumb for a moment.",
                "Shift your gaze to an object far away.",
                "Back to your thumb.",
                "Relieve eye strain from staring at screens."
            ],
            completion: "Close eyes briefly to rest.",
            trackingType: .pattern,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 20.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 5,
            primaryBenefit: "Accommodative flexibility",
            scientificRationale: "Exercises ciliary muscles responsible for lens focus."
        ))
        
        exercises.append(Exercise(
            id: "eye_04",
            name: "Figure 8 Eyes",
            category: .eyeVestibular,
            instruction: "Trace a figure 8 with your eyes, head still.",
            calmingInstruction: "Keeping your head perfectly still, trace a large figure-eight, or infinity symbol, with just your eyes. Move slowly and smoothly. This helps to strengthen the eye muscles in all directions and can improve visual tracking. It’s a wonderful way to wake up your eyes and your brain.",
            preparation: "Head still, eyes open.",
            voiceGuidance: [
                "Trace a large figure-eight with just your eyes.",
                "Move slowly and smoothly.",
                "Strengthen the eye muscles in all directions.",
                "Wake up your eyes and your brain."
            ],
            completion: "Close your eyes and relax.",
            trackingType: .pattern,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 15.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 2,
            reps: 3,
            primaryBenefit: "Visual tracking smoothness",
            scientificRationale: "Improves smooth pursuit eye movements."
        ))
        
        exercises.append(Exercise(
            id: "eye_05",
            name: "Peripheral Scan",
            category: .eyeVestibular,
            instruction: "Without moving your head, scan your peripheral vision.",
            calmingInstruction: "With your eyes facing forward, become aware of your peripheral vision. Without moving your head, slowly scan the edges of your visual field. Notice what you can see out of the corners of your eyes. This exercise expands your visual awareness and can help reduce tunnel vision from prolonged screen focus.",
            preparation: "Gaze soft ahead.",
            voiceGuidance: [
                "Become aware of your peripheral vision.",
                "Slowly scan the edges of your visual field.",
                "Notice what you can see out of the corners.",
                "Expand visual awareness."
            ],
            completion: "Return focus to center.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 10.0,
            totalDuration: 15.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 2,
            primaryBenefit: "Expands visual field awareness",
            scientificRationale: "Counteracts foveal tunnel vision from screens."
        ))
        
        exercises.append(Exercise(
            id: "eye_06",
            name: "20-20-20 Gaze",
            category: .eyeVestibular,
            instruction: "Look at something 20 feet away for 20 seconds.",
            calmingInstruction: "This is a classic rule for eye health. Every 20 minutes, look at something at least 20 feet away for at least 20 seconds. So, find an object in the distance—a tree, a building, a picture on the wall—and simply rest your gaze on it. Let your eye muscles fully relax.",
            preparation: "Find a distant object.",
            voiceGuidance: [
                "Look at something at least 20 feet away.",
                "Simply rest your gaze on it.",
                "Let your eye muscles fully relax."
            ],
            completion: "Blink a few times.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 20.0,
            totalDuration: 22.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1,
            primaryBenefit: "Reduces digital eye strain",
            scientificRationale: "Standard optometric recommendation for ciliary relaxation."
        ))
        
        exercises.append(Exercise(
            id: "eye_07",
            name: "Eye Circles",
            category: .eyeVestibular,
            instruction: "Slowly circle your eyes clockwise, then reverse.",
            calmingInstruction: "Gently roll your eyes in slow, controlled circles, first in a clockwise direction. Then, reverse and circle them counter-clockwise. Keep your head still and let only your eyes move. This helps to lubricate the eyes and release tension in the eye sockets.",
            preparation: "Head still.",
            voiceGuidance: [
                "Roll your eyes in slow, controlled circles.",
                "First clockwise... then counter-clockwise.",
                "Keep your head still.",
                "Release tension in the eye sockets."
            ],
            completion: "Close eyes and rest.",
            trackingType: .pattern,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 15.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 3,
            primaryBenefit: "Mobility of extraocular muscles",
            scientificRationale: "Stretches all six extraocular muscles."
        ))
        
        exercises.append(Exercise(
            id: "eye_08",
            name: "Convergence Hold",
            category: .eyeVestibular,
            instruction: "Slowly bring thumb to nose, keeping focus.",
            calmingInstruction: "Hold your thumb out at arm’s length. Keep it in focus as you slowly bring it towards your nose. Try to keep it in focus for as long as you can. When it becomes blurry, stop, and then slowly extend it back out. This strengthens the muscles that control eye convergence.",
            preparation: "Thumb out.",
            voiceGuidance: [
                "Keep thumb in focus as you bring it towards your nose.",
                "When it becomes blurry, stop.",
                "Slowly extend it back out.",
                "Strengthen muscles that control convergence."
            ],
            completion: "Look away to relax.",
            trackingType: .sensorTracked,
            targetAxis: .pitch, // Tracking head stillness technically
            targetValue: 0.0,
            holdDuration: 5.0,
            totalDuration: 15.0,
            tolerance: 5.0,
            supportedContexts: [.all],
            difficultyLevel: 2,
            reps: 3,
            primaryBenefit: "Convergence strength",
            scientificRationale: "Training for binocular vision, specifically near point convergence."
        ))
        
        // ═══════════════════════════════════════════════════════════════
        // BREATHWORK (Nervous System Regulation)
        // ═══════════════════════════════════════════════════════════════
        
        exercises.append(Exercise(
            id: "breath_01",
            name: "Box Breathing",
            category: .breathwork,
            instruction: "Inhale 4... Hold 4... Exhale 4... Hold 4...",
            calmingInstruction: "Let’s practice a simple but powerful breathing technique called Box Breathing. It’s excellent for calming the nervous system. Inhale slowly and smoothly for a count of four. Hold your breath gently for a count of four. Exhale completely for a count of four. And hold the breath out for a count of four. Let’s continue this perfect square of breath.",
            preparation: "Sit comfortably, exhale fully.",
            voiceGuidance: [
                "Inhale slowly and smoothly for a count of four.",
                "Hold your breath gently for a count of four.",
                "Exhale completely for a count of four.",
                "Hold the breath out for a count of four.",
                "Continue this perfect square of breath."
            ],
            completion: "Return to natural breathing.",
            trackingType: .guided,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 16.0,
            totalDuration: 60.0, // Should loop
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 4,
            primaryBenefit: "Parasympathetic activation",
            scientificRationale: "Equal ratio breathing regulates autonomic nervous system."
        ))
        
        exercises.append(Exercise(
            id: "breath_02",
            name: "Physiological Sigh",
            category: .breathwork,
            instruction: "Double inhale through nose, long exhale through mouth.",
            calmingInstruction: "This next technique is a natural way your body releases stress. It’s called a physiological sigh. Take a normal inhale through your nose. Then, take another quick, sharp sip of air on top of it. Now, exhale fully and slowly through your mouth, letting out a deep sigh. Feel the immediate release of tension.",
            preparation: "Prepare for double inhale.",
            voiceGuidance: [
                "Take a normal inhale through your nose.",
                "Take another quick, sharp sip of air on top of it.",
                "Exhale fully and slowly through your mouth.",
                "Feel the immediate release of tension."
            ],
            completion: "Breathe normally.",
            trackingType: .guided,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 20.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 3,
            primaryBenefit: "Rapid stress reduction",
            scientificRationale: "Re-inflates alveoli and offloads CO2 rapidly."
        ))
        
        exercises.append(Exercise(
            id: "breath_03",
            name: "Diaphragmatic Breath",
            category: .breathwork,
            instruction: "Hand on belly. Breathe so your belly rises, not chest.",
            calmingInstruction: "Let’s connect with our diaphragm. Place one hand on your chest and one on your belly. As you inhale through your nose, try to send the breath down into your belly so that your lower hand rises, while your upper hand stays relatively still. As you exhale, feel your belly gently fall back towards your spine.",
            preparation: "One hand on chest, one on belly.",
            voiceGuidance: [
                "Send the breath down into your belly.",
                "Lower hand rises, upper hand stays still.",
                "Exhale, feel your belly gently fall back.",
                "Connect with your diaphragm."
            ],
            completion: "Release hands.",
            trackingType: .guided,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 45.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 5,
            primaryBenefit: "Deep core stability",
            scientificRationale: "Increases intra-abdominal pressure for spinal support."
        ))
        
        exercises.append(Exercise(
            id: "breath_04",
            name: "4-7-8 Calming",
            category: .breathwork,
            instruction: "Inhale 4... Hold 7... Exhale slowly 8...",
            calmingInstruction: "This is a profoundly calming breath pattern. Inhale quietly through your nose for a count of four. Hold your breath for a count of seven. Now, exhale completely through your mouth, making a whooshing sound, for a count of eight. This longer exhale powerfully signals to your nervous system that it’s time to relax.",
            preparation: "Exhale fully.",
            voiceGuidance: [
                "Inhale quietly for four.",
                "Hold for seven.",
                "Exhale completely with a whoosh for eight.",
                "Signal your nervous system to relax."
            ],
            completion: "Return to normal breath.",
            trackingType: .guided,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 19.0,
            totalDuration: 60.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 2,
            reps: 3,
            primaryBenefit: "Sleep induction",
            scientificRationale: "Extended exhalation stimulates vagus nerve."
        ))
        
        exercises.append(Exercise(
            id: "breath_05",
            name: "Breath Awareness",
            category: .breathwork,
            instruction: "Simply notice your breath without changing it.",
            calmingInstruction: "For this exercise, there is nothing to do. Simply close your eyes and bring your awareness to your natural breath. Don’t try to change it in any way. Just observe it. Notice the sensation of the air entering your nostrils, filling your lungs, and then leaving your body. This simple act of observation can be deeply meditative.",
            preparation: "Close your eyes.",
            voiceGuidance: [
                "Bring awareness to your natural breath.",
                "Don't try to change it.",
                "Notice the air entering and leaving.",
                "This act of observation is meditative."
            ],
            completion: "Gently open your eyes.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 30.0,
            totalDuration: 35.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1,
            primaryBenefit: "Mindfulness",
            scientificRationale: "Develops interoception and reduces anxiety."
        ))
        
        exercises.append(Exercise(
            id: "breath_06",
            name: "Tension Release Breath",
            category: .breathwork,
            instruction: "Inhale and tense shoulders. Exhale and release completely.",
            calmingInstruction: "We can use our breath to consciously release tension. Take a deep breath in through your nose, and as you do, shrug your shoulders up towards your ears, squeezing them tightly. Now, as you exhale forcefully through your mouth, drop your shoulders down completely, releasing all the tension in one go.",
            preparation: "Prepare to squeeze.",
            voiceGuidance: [
                "Inhale, shrug shoulders up tight.",
                "Exhale forcefully, drop everything.",
                "Release all tension in one go."
            ],
            completion: "Feel the lightness.",
            trackingType: .guided,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 15.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 3,
            primaryBenefit: "Physical tension release",
            scientificRationale: "Combines muscle activation with forced exhalation release."
        ))

        // ... (Appending final batch)
        
        // ═══════════════════════════════════════════════════════════════
        // YOGA STRETCH (Restorative)
        // ═══════════════════════════════════════════════════════════════
        
        exercises.append(Exercise(
            id: "yoga_01",
            name: "Seated Spinal Twist",
            category: .yogaStretch,
            instruction: "Twist gently to the right, holding chair back.",
            calmingInstruction: "Sit tall and inhale to lengthen your spine. As you exhale, gently twist your torso to the right. Place your left hand on your right knee and your right hand on the back of your chair for support. Don’t force the twist; let it come from your core. Invite your spine to ring out tension like a sponge.",
            preparation: "Sit tall.",
            voiceGuidance: [
                "Inhale to lengthen your spine.",
                "Exhale, gently twist your torso to the right.",
                "Left hand on knee, right hand on chair.",
                "Ring out tension like a sponge."
            ],
            completion: "Slowly un-twist to center.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 15.0,
            totalDuration: 20.0,
            tolerance: 0.0,
            supportedContexts: [.sitting, .wheelchair],
            difficultyLevel: 1,
            reps: 2, // One per side
            primaryBenefit: "Spinal mobility",
            scientificRationale: "Decompresses intervertebral discs and stimulates digestion."
        ))
        
        exercises.append(Exercise(
            id: "yoga_02",
            name: "Seated Side Bend",
            category: .yogaStretch,
            instruction: "Reach right arm up and over to the left.",
            calmingInstruction: "Plant your sit-bones firmly into your chair. Inhale and reach your right arm up towards the ceiling, creating length. Exhale and lean gently to the left, opening up the entire right side of your body. Feel the space being created between your ribs. Keep your chest open to the front.",
            preparation: "Reach right arm up.",
            voiceGuidance: [
                "Inhale, reach up towards the ceiling.",
                "Exhale, lean gently to the left.",
                "Open up the entire side body.",
                "Feel space between your ribs."
            ],
            completion: "Float back up to vertical.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 15.0,
            totalDuration: 20.0,
            tolerance: 0.0,
            supportedContexts: [.sitting, .wheelchair],
            difficultyLevel: 1,
            reps: 2, // One per side
            primaryBenefit: "Lateral spine flexibility",
            scientificRationale: "Expands intercostal muscles improving breathing capacity."
        ))
        
        exercises.append(Exercise(
            id: "yoga_03",
            name: "Seated Pigeon",
            category: .yogaStretch,
            instruction: "Ankle on opposite knee, lean forward gently.",
            calmingInstruction: "While seated, cross your right ankle over your left knee. Flex your right foot to protect the knee. Place your hands on your legs and, keeping your spine straight, hinge forward slightly from your hips. You should feel a deep, pleasant stretch in your right hip and glute. This releases tension from sitting all day.",
            preparation: "Right ankle on left knee.",
            voiceGuidance: [
                "Flex your foot to protect the knee.",
                "Keep spine straight, hinge forward from hips.",
                "Feel a deep stretch in your hip.",
                "Release tension from sitting."
            ],
            completion: "Sit up and uncross legs.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 20.0,
            totalDuration: 30.0,
            tolerance: 0.0,
            supportedContexts: [.sitting, .wheelchair],
            difficultyLevel: 2,
            reps: 2,
            primaryBenefit: "Hip opener",
            scientificRationale: "Stretches piriformis, preventing sciatic compression."
        ))
        
        exercises.append(Exercise(
            id: "yoga_04",
            name: "Wrist Release",
            category: .yogaStretch,
            instruction: "Extend arm, gently pull fingers back.",
            calmingInstruction: "Extend your right arm forward with palm facing up. Use your left hand to gently pull your right fingers back and down towards the floor. Feel the stretch along your forearm and wrist flexors. This is essential for preventing strain from typing and mouse usage.",
            preparation: "Right arm forward, palm up.",
            voiceGuidance: [
                "Gently pull fingers back and down.",
                "Feel the stretch along your forearm.",
                "Prevent strain from typing.",
                "Keep shoulders relaxed."
            ],
            completion: "Shake out your hand.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 15.0,
            totalDuration: 20.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 2,
            primaryBenefit: "Forearm release",
            scientificRationale: "Stretches wrist flexors shortened by keyboard use."
        ))
        
        exercises.append(Exercise(
            id: "yoga_05",
            name: "Seated Forward Fold",
            category: .yogaStretch,
            instruction: "Fold torso over legs, let head hang heavy.",
            calmingInstruction: "Ensure your feet are flat on the floor. Take a deep breath in, and as you exhale, slowly fold your upper body over your legs. Let your arms hang down towards the floor and, most importantly, obtain a heavy, relaxed head. Shake your head yes and no gently. Let gravity decompress your neck/spine.",
            preparation: "Feet flat, sit on edge of chair.",
            voiceGuidance: [
                "Exhale, fold upper body over legs.",
                "Let arms hang, head heavy.",
                "Shake your head yes and no gently.",
                "Let gravity decompress your spine."
            ],
            completion: "Roll up slowly, vertebrae by vertebrae.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 20.0,
            totalDuration: 30.0,
            tolerance: 0.0,
            supportedContexts: [.sitting, .wheelchair],
            difficultyLevel: 1,
            reps: 1,
            primaryBenefit: "Posterior chain decompression",
            scientificRationale: "Reverses effects of spinal compression."
        ))
        
        exercises.append(Exercise(
            id: "yoga_06",
            name: "Open Book",
            category: .yogaStretch,
            instruction: "Hands behind head, open elbows wide.",
            calmingInstruction: "Interlace your fingers behind your head. Bring your elbows forward until they almost touch. Then, as you inhale deeply, open your elbows wide apart, expanding your chest and squeezing your shoulder blades. Look slightly up. Exhale and bring elbows back together. It’s a beautiful way to mobilize the upper back.",
            preparation: "Hands behind head.",
            voiceGuidance: [
                "Inhale, open elbows wide, expand chest.",
                "Look slightly up.",
                "Exhale, bring elbows back together.",
                "Mobilize the upper back."
            ],
            completion: "Relax arms down.",
            trackingType: .pattern,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 25.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 5,
            primaryBenefit: "Thoracic mobility",
            scientificRationale: "Dynamic pectoral stretch and thoracic extension."
        ))
        
        // ═══════════════════════════════════════════════════════════════
        // WHEELCHAIR ADAPTED (Specific Needs)
        // ═══════════════════════════════════════════════════════════════
        
        exercises.append(Exercise(
            id: "wc_01",
            name: "Chair Push-Up",
            category: .wheelchair,
            instruction: "Press hands into seat/wheels to lift weight off.",
            calmingInstruction: "Place your hands firmly on your armrests, wheels, or seat. Engage your arms and shoulders to press down, lifting your weight off the seat for a moment. This provides crucial pressure relief and re-establishes blood flow. Hold for a moment if you can, then lower with control.",
            preparation: "Hands on stable surface.",
            voiceGuidance: [
                "Press down to lift weight off the seat.",
                "Provide crucial pressure relief.",
                "Hold for a moment.",
                "Lower with control."
            ],
            completion: "Settle back into the seat.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 5.0,
            totalDuration: 15.0,
            tolerance: 0.0,
            supportedContexts: [.wheelchair, .sitting],
            difficultyLevel: 2,
            reps: 3,
            primaryBenefit: "Ischial pressure relief",
            scientificRationale: "Critical for preventing pressure sores and resetting circulation."
        ))
        
        exercises.append(Exercise(
            id: "wc_02",
            name: "Wheelchair Twist",
            category: .wheelchair,
            instruction: "Hold armrest, gentle rotation.",
            calmingInstruction: "Sitting centered, reach your right hand across to hold your left armrest or wheel. Use this grip to gently guide your torso into a leftward twist. Keep your hips stable and lengthen through the crown of your head. This movement helps maintain spinal mobility when the pelvis is fixed.",
            preparation: "Reach across body.",
            voiceGuidance: [
                "Gently guide torso into a twist.",
                "Keep hips stable.",
                "Lengthen through the crown of your head.",
                "Maintain spinal mobility."
            ],
            completion: "Return to center.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 15.0,
            totalDuration: 20.0,
            tolerance: 0.0,
            supportedContexts: [.wheelchair, .sitting],
            difficultyLevel: 1,
            reps: 2,
            primaryBenefit: "Axial rotation",
            scientificRationale: "Dissociates thoracic movement from fixed pelvis."
        ))
        
        exercises.append(Exercise(
            id: "wc_03",
            name: "Lateral Lean",
            category: .wheelchair,
            instruction: "Lean side to side, opening ribs.",
            calmingInstruction: "Anchor your hips. Reach your right arm up and over towards the left. Use your left hand on the chair for stability. Focus on breathing into the ribs on your right side, expanding them like an accordion. This helps prevent lateral stiffness.",
            preparation: "Right arm up.",
            voiceGuidance: [
                "Reach up and over.",
                "Use chair for stability.",
                "Breathe into the ribs.",
                "Expand like an accordion."
            ],
            completion: "Return to upright.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 10.0,
            totalDuration: 15.0,
            tolerance: 0.0,
            supportedContexts: [.wheelchair, .sitting],
            difficultyLevel: 1,
            reps: 2,
            primaryBenefit: "Lateral trunk stretching",
            scientificRationale: "Maintains quadratus lumborum length."
        ))
        
        exercises.append(Exercise(
            id: "wc_04",
            name: "Forward Reach",
            category: .wheelchair,
            instruction: "Reach hands forward, rounding back gently.",
            calmingInstruction: "Interlace fingers and push your palms forward, rounding your upper back. Drop your head between your arms. Feel the space opening up between your shoulder blades. This counters the tendency to collapse the chest.",
            preparation: "Interlace fingers.",
            voiceGuidance: [
                "Push palms forward.",
                "Round your upper back.",
                "Drop head between arms.",
                "Open space between shoulder blades."
            ],
            completion: "Release and open chest.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 10.0,
            totalDuration: 15.0,
            tolerance: 0.0,
            supportedContexts: [.wheelchair, .sitting],
            difficultyLevel: 1,
            reps: 3,
            primaryBenefit: "Scapular protraction",
            scientificRationale: "Stretches rhomboids and paraspinals."
        ))
        
        // ═══════════════════════════════════════════════════════════════
        // ACUPRESSURE (Energy Points)
        // ═══════════════════════════════════════════════════════════════
        
        exercises.append(Exercise(
            id: "acu_01",
            name: "GB20 (Neck Base)",
            category: .acupressure,
            instruction: "Press into the hollows at the base of skull.",
            calmingInstruction: "Locate the hollows at the base of your skull, just outside the large neck muscles. This is Gallbladder 20, or ‘Wind Pool’. Apply firm, circular pressure with your thumbs. It is profoundly effective for relieving neck stiffness, headaches, and eye fatigue. Close your eyes and breathe into the pressure.",
            preparation: "Thumbs to base of skull.",
            voiceGuidance: [
                "Find the hollows at base of skull.",
                "Apply firm, circular pressure.",
                "Relieve neck stiffness and eye fatigue.",
                "Breathe into the pressure."
            ],
            completion: "Release hands.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 20.0,
            totalDuration: 30.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1,
            primaryBenefit: "Headache relief",
            scientificRationale: "Releases tension in suboccipital muscles."
        ))
        
        exercises.append(Exercise(
            id: "acu_02",
            name: "LI4 (Hand Valley)",
            category: .acupressure,
            instruction: "Pinch the fleshy webbing between thumb and index.",
            calmingInstruction: "Find the fleshy webbing between your thumb and index finger. Squeeze this area firmly with the thumb and finger of your other hand. This is Large Intestine 4, a master point for pain relief in the head and face. Massage in small circles. It may feel tender, which is a sign you’ve found the right spot.",
            preparation: "Locate point on hand.",
            voiceGuidance: [
                "Squeeze firmly.",
                "Massage in small circles.",
                "Find the tender spot.",
                "Master point for head and face relief."
            ],
            completion: "Switch hands.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 20.0,
            totalDuration: 30.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 2,
            primaryBenefit: "General pain reduction",
            scientificRationale: "Stimulates release of endorphins."
        ))
        
        exercises.append(Exercise(
            id: "acu_03",
            name: "Yin Tang (Third Eye)",
            category: .acupressure,
            instruction: "Gently press the spot between eyebrows.",
            calmingInstruction: "Place the pad of your middle finger directly between your eyebrows. This is Yin Tang, or the ‘Hall of Impression’. Apply gentle, steady pressure or make tiny slow circles. This point is famous for calming the mind, clarifying vision, and relieving frontal headaches.",
            preparation: "Finger to forehead.",
            voiceGuidance: [
                "Apply gentle, steady pressure.",
                "Calm your mind.",
                "Clarify your vision.",
                "Relieve frontal tension."
            ],
            completion: "Lower your hand.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 20.0,
            totalDuration: 25.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1,
            primaryBenefit: "Mental clarity",
            scientificRationale: "Sedative effect on central nervous system."
        ))
        
        exercises.append(Exercise(
            id: "acu_04",
            name: "PC6 (Inner Wrist)",
            category: .acupressure,
            instruction: "Press inner wrist, 3 fingers down from palm.",
            calmingInstruction: "Measure three finger-widths down from your wrist crease, between the two tendons on your inner arm. Press here deeply. This is Pericardium 6. It opens the chest and regulates the heart and stomach. It creates a sense of openness if you tend to hunch protectively.",
            preparation: "Measure 3 fingers from wrist.",
            voiceGuidance: [
                "Press deeply between tendons.",
                "Open the chest.",
                "Regulate the heart.",
                "Release protective hunching."
            ],
            completion: "Release pressure.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 15.0,
            totalDuration: 25.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 2,
            primaryBenefit: "Anxiety relief",
            scientificRationale: "Regulates autonomic balance."
        ))
        
        exercises.append(Exercise(
            id: "acu_05",
            name: "GB21 (Shoulder Well)",
            category: .acupressure,
            instruction: "Press the highest point of your shoulder muscle.",
            calmingInstruction: "Reach your opposite hand across to the highest point of your shoulder muscle, halfway between neck and shoulder tip. Grip and massage this muscle firmly. This is Gallbladder 21, the ‘Shoulder Well’. It directly targets the upper trapezius tension we carry from stress.",
            preparation: "Reach across to shoulder.",
            voiceGuidance: [
                "Grip and massage firmly.",
                "Target upper trapezius tension.",
                "Release the weight of the world.",
                "Let the muscle soften."
            ],
            completion: "Switch sides.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 15.0,
            totalDuration: 25.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 2,
            primaryBenefit: "Trapezius release",
            scientificRationale: "Mechanical release of hypertonic muscle fibers."
        ))
        
        exercises.append(Exercise(
            id: "acu_06",
            name: "Ear Massage",
            category: .acupressure,
            instruction: "Massage outer rim of ears, top to bottom.",
            calmingInstruction: "Your ears are a microsystem of the whole body. Use your thumb and index fingers to massage the outer rim of your ears, starting from the top and working your way down to the lobes. Pull gently outward as you go. This ‘unfolds’ the ears and can give a surprising boost of clarity and energy.",
            preparation: "Hands to ears.",
            voiceGuidance: [
                "Massage the outer rim, top to bottom.",
                "Pull gently outward.",
                "Unfold the ears.",
                "Boost clarity and energy."
            ],
            completion: "Relax hands.",
            trackingType: .pattern,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 20.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 2,
            primaryBenefit: "Vagal stimulation",
            scientificRationale: "Auricular branches of vagus nerve stimulation."
        ))

        // ═══════════════════════════════════════════════════════════════
        // NEURO-RESET (Brain Balancing)
        // ═══════════════════════════════════════════════════════════════
        
        exercises.append(Exercise(
            id: "neuro_01",
            name: "Cross Crawl",
            category: .neuroReset,
            instruction: "Tap right hand to left knee, then left to right.",
            calmingInstruction: "Let’s re-synchronize the left and right hemispheres of the brain. Prominently tap your right hand to your left knee, then your left hand to your right knee. find a rhythm. This crossing of the midline integrates brain function and helps reset your coordination after long periods of static posture.",
            preparation: "Sit or stand tall.",
            voiceGuidance: [
                "Tap right hand to left knee.",
                "Tap left hand to right knee.",
                "Find a rhythm.",
                "Integrate brain function."
            ],
            completion: "Pause and feel the balance.",
            trackingType: .pattern,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 30.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 10,
            primaryBenefit: "Hemispheric integration",
            scientificRationale: "Activates corpus callosum for bilateral coordination."
        ))
        
        exercises.append(Exercise(
            id: "neuro_02",
            name: "Brain Tap",
            category: .neuroReset,
            instruction: "Tap fingertips all over scalp like rain.",
            calmingInstruction: "Take all ten fingertips and gently tap them all over your scalp, like a light rain shower. Tap the top, back, and sides of your head. This stimulates blood flow to the scalp and brain, waking up nerve endings and shaking off mental fog.",
            preparation: "Fingertips ready.",
            voiceGuidance: [
                "Tap gently like rain.",
                "Cover the top, back, and sides.",
                "Stimulate blood flow.",
                "Shake off mental fog."
            ],
            completion: "Stop and feel the tingle.",
            trackingType: .pattern,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 20.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1,
            primaryBenefit: "Scalp circulation",
            scientificRationale: "Proprioceptive awakening of cranial nerves."
        ))
        
        exercises.append(Exercise(
            id: "neuro_03",
            name: "Glute Squeeze",
            category: .neuroReset,
            instruction: "Squeeze glutes tight, then release.",
            calmingInstruction: "To combat ‘gluteal amnesia’ from sitting, squeeze your glute muscles tightly for a few seconds. Feel them engage. Then, completely release. Repeat this pulse. This reminds your body where its power center is and helps stabilize the pelvis.",
            preparation: "Sit or stand.",
            voiceGuidance: [
                "Squeeze glutes tight.",
                "Feel them engage.",
                "Completely release.",
                "Remind your body where its power is."
            ],
            completion: "Relax glutes.",
            trackingType: .timedHold,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 5.0,
            totalDuration: 15.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 3,
            primaryBenefit: "Gluteal activation",
            scientificRationale: "Neuromuscular re-education for inhibited glutes."
        ))
        
        exercises.append(Exercise(
            id: "neuro_04",
            name: "Shake Out",
            category: .neuroReset,
            instruction: "Shake hands and arms vigorously.",
            calmingInstruction: "Let’s finish with a full reset. Shake your hands vigorously at your wrists. Shake your arms. If you can, shake your shoulders slightly. Visualize shaking off any remaining stress or stagnation from your body. Let it all go.",
            preparation: "Hands ready.",
            voiceGuidance: [
                "Shake hands vigorously.",
                "Shake your arms.",
                "Shake off stress and stagnation.",
                "Let it all go."
            ],
            completion: "Come to stillness.",
            trackingType: .pattern,
            targetAxis: .none,
            targetValue: 0.0,
            holdDuration: 0.0,
            totalDuration: 15.0,
            tolerance: 0.0,
            supportedContexts: [.all],
            difficultyLevel: 1,
            reps: 1,
            primaryBenefit: "Nervous system discharge",
            scientificRationale: "Animalistic trembling response to discharge stress hormones."
        ))

        return exercises
    }
}

// MARK: - Exercise Time Mapper
struct ExerciseTimeMapper {
    
    static func buildSession(
        duration: SessionDuration,
        context: PostureContext,
        focusCategories: [ExerciseCategory]? = nil
    ) -> [Exercise] {
        
        let availableSeconds = Double(duration.rawValue * 60)
        let database = ExerciseDatabase.shared.allExercises
        
        // Filter by context
        var pool = database.filter { ex in
            ex.supportedContexts.contains(context) || ex.supportedContexts.contains(.all)
        }
        
        if let categories = focusCategories {
            pool = pool.filter { categories.contains($0.category) }
        }
        
        switch duration {
        case .twoMinutes:
            return buildQuickSession(pool: pool, seconds: availableSeconds)
        case .fourMinutes:
            return buildShortSession(pool: pool, seconds: availableSeconds)
        case .sixMinutes:
            return buildMediumSession(pool: pool, seconds: availableSeconds)
        case .eightMinutes:
            return buildExtendedSession(pool: pool, seconds: availableSeconds)
        case .tenMinutes:
            return buildComprehensiveSession(pool: pool, seconds: availableSeconds)
        }
    }
    
    // 2-Minute: Ultra-focused, high-impact movements
    private static func buildQuickSession(pool: [Exercise], seconds: Double) -> [Exercise] {
        var selected: [Exercise] = []
        var timeUsed: Double = 0
        
        // Priority: Neck mobility (tracked) + Deep breathing
        let neckExercises = pool.filter { $0.category == .neckMobility && $0.isTracked }
            .sorted { $0.difficultyLevel < $1.difficultyLevel }
            .prefix(2)
        
        for ex in neckExercises {
            if timeUsed + ex.totalDuration <= seconds {
                selected.append(ex)
                timeUsed += ex.totalDuration
            }
        }
        
        // Add breathing if time permits
        if let breathing = pool.first(where: { $0.category == .breathwork }) {
            if timeUsed + breathing.totalDuration <= seconds {
                selected.append(breathing)
            }
        }
        
        return selected
    }
    
    // 4-Minute: Core posture correction sequence
    private static func buildShortSession(pool: [Exercise], seconds: Double) -> [Exercise] {
        var selected: [Exercise] = []
        var timeUsed: Double = 0
        
        // Warmup: 1 neck mobility
        if let warmup = pool.first(where: { $0.category == .neckMobility && $0.difficultyLevel == 1 }) {
            selected.append(warmup)
            timeUsed += warmup.totalDuration
        }
        
        // Core: 2 shoulder/upper back exercises
        let shoulderWork = pool.filter { $0.category == .shoulderBack }
            .prefix(2)
        
        for ex in shoulderWork {
            if timeUsed + ex.totalDuration <= seconds {
                selected.append(ex)
                timeUsed += ex.totalDuration
            }
        }
        
        // Cooldown: Breathing
        if let cooldown = pool.first(where: { $0.category == .breathwork }) {
            if timeUsed + cooldown.totalDuration <= seconds {
                selected.append(cooldown)
            }
        }
        
        return selected
    }
    
    // 6-Minute: Balanced full-sequence
    private static func buildMediumSession(pool: [Exercise], seconds: Double) -> [Exercise] {
        var selected: [Exercise] = []
        var timeUsed: Double = 0
        
        let sequence: [ExerciseCategory] = [
            .neckMobility,
            .shoulderBack,
            .isometric,
            .breathwork
        ]
        
        for category in sequence {
            if let ex = pool.first(where: { $0.category == category && (timeUsed + $0.totalDuration) <= seconds }) {
                selected.append(ex)
                timeUsed += ex.totalDuration
            }
        }
        
        return selected
    }
    
    // 8-Minute: Therapeutic depth
    private static func buildExtendedSession(pool: [Exercise], seconds: Double) -> [Exercise] {
        var selected: [Exercise] = []
        var timeUsed: Double = 0
        
        let categories: [ExerciseCategory] = [
            .neckMobility,
            .shoulderBack,
            .isometric,
            .eyeVestibular,
            .breathwork,
            .yogaStretch
        ]
        
        for category in categories {
            if let ex = pool.first(where: { $0.category == category && (timeUsed + $0.totalDuration) <= seconds }) {
                selected.append(ex)
                timeUsed += ex.totalDuration
            }
        }
        
        return selected
    }
    
    // 10-Minute: Complete wellness session
    private static func buildComprehensiveSession(pool: [Exercise], seconds: Double) -> [Exercise] {
        var selected: [Exercise] = []
        var timeUsed: Double = 0
        
        // Full spectrum approach - take 1-2 from each category until full
        let allCategories: [ExerciseCategory] = [
            .breathwork, // Start with breath
            .neckMobility,
            .shoulderBack,
            .isometric,
            .yogaStretch,
            .neuroReset,
            .breathwork // End with breath
        ]
        
        for category in allCategories {
            let exercises = pool.filter { $0.category == category }
            
            if let ex = exercises.first(where: { (timeUsed + $0.totalDuration) <= seconds }) {
                  selected.append(ex)
                  timeUsed += ex.totalDuration
            }
        }
        
        return selected
    }
}
