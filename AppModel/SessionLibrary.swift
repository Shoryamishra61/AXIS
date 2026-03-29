// SessionLibrary.swift
// AXIS — Exercise definitions, session view model, and audio engine
// Each exercise specifies a motionAxis (.pitch/.roll/.yaw) so the spine
// visualizer always tracks the correct sensor dimension.
// Tech neck = primarily pitch. Lateral + rotational exercises round out mobility.
// ALL exercise cues are short, clear, one-action instructions.

import SwiftUI
import Combine
import AVFoundation
import Observation

// ─────────────────────────────────────────────────────────────
// MARK: - Motion Axis
// ─────────────────────────────────────────────────────────────

enum MotionAxis: String, Equatable, Sendable {
    case pitch   // Forward/back nod
    case roll    // Side tilt (ear to shoulder)
    case yaw     // Left/right rotation

    var label: String {
        switch self {
        case .pitch: return "Forward · Back"
        case .roll:  return "Side · Tilt"
        case .yaw:   return "Left · Right"
        }
    }

    var sfSymbol: String {
        switch self {
        case .pitch: return "arrow.up.arrow.down"
        case .roll:  return "arrow.left.arrow.right"
        case .yaw:   return "arrow.triangle.2.circlepath"
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Exercise
// ─────────────────────────────────────────────────────────────

struct Exercise: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let motionAxis: MotionAxis

    // Three timed coaching cues:
    //   setupCue   → spoken at 0% (beginning)
    //   holdCue    → spoken at ~35%
    //   breatheCue → spoken at ~65%
    let setupCue: String
    let holdCue: String
    let breatheCue: String

    let durationSeconds: Int
    let targetDeg: Double      // target angle on motionAxis
    let toleranceDeg: Double   // ± degrees for "in zone"

    /// One-line explanation of why this exercise helps — shown on the coaching card.
    let benefit: String
}

// ─────────────────────────────────────────────────────────────
// MARK: - User Position
// ─────────────────────────────────────────────────────────────

enum UserPosition: String, CaseIterable, Identifiable, Equatable {
    case sitting  = "Sitting"
    case standing = "Standing"
    case lying    = "Lying Down"

    var id: String { rawValue }

    var sfSymbol: String {
        switch self {
        case .sitting:  return "chair.lounge.fill"
        case .standing: return "figure.stand"
        case .lying:    return "bed.double.fill"
        }
    }

    var accentColor: String {
        switch self {
        case .sitting:  return "007AFF"
        case .standing: return "34C759"
        case .lying:    return "FF9500"
        }
    }

    var sessionTitle: String {
        switch self {
        case .sitting:  return "Desk Reset"
        case .standing: return "Posture Check"
        case .lying:    return "Deep Restore"
        }
    }

    var duration: Int {
        SessionLibrary.exercises(for: self).reduce(0) { $0 + $1.durationSeconds }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Session Library
// ─────────────────────────────────────────────────────────────

enum SessionLibrary {

    /// Returns exercises for a given position and duration (in minutes).
    /// Selects `duration * 3` exercises (3 per minute at ~20s each).
    static func exercises(for position: UserPosition, duration: Int = 2) -> [Exercise] {
        let pool = fullPool(for: position)
        let count = min(duration * 3, pool.count)
        return Array(pool.prefix(count))
    }

    // MARK: - Full Exercise Pools (30 per position)

    private static func fullPool(for position: UserPosition) -> [Exercise] {
        switch position {
        case .sitting:  return sittingPool
        case .standing: return standingPool
        case .lying:    return lyingPool
        }
    }

    // ── SITTING — 30 exercises ──────────────────────────────
    private static let sittingPool: [Exercise] = [
        // -- Warm-up block (exercises 1-6, used in 2-min session) --
        Exercise(name: "Chin Tuck", motionAxis: .pitch,
                 setupCue: "Sit tall. Gently pull your chin straight back, creating a double chin.",
                 holdCue: "Hold this position. Keep your eyes level and jaw relaxed.",
                 breatheCue: "Breathe slowly. Feel the length in the back of your neck.",
                 durationSeconds: 20, targetDeg: -8, toleranceDeg: 7,
                 benefit: "Strengthens deep neck flexors — reverses forward head posture."),
        Exercise(name: "Neck Rotation Right", motionAxis: .yaw,
                 setupCue: "Sit tall and slowly turn your head to look over your right shoulder.",
                 holdCue: "Hold this stretch. Keep your chin parallel to the floor.",
                 breatheCue: "Exhale deeply. Now, slowly return to the center.",
                 durationSeconds: 20, targetDeg: 25, toleranceDeg: 15,
                 benefit: "Restores rotational range of motion lost from screen fixation."),
        Exercise(name: "Neck Rotation Left", motionAxis: .yaw,
                 setupCue: "Slowly turn your head to look over your left shoulder.",
                 holdCue: "Hold this stretch. Maintain a tall spine.",
                 breatheCue: "Exhale deeply. Slowly return your head to the center.",
                 durationSeconds: 20, targetDeg: -25, toleranceDeg: 15,
                 benefit: "Balances rotation symmetry — reduces one-sided neck tension."),
        Exercise(name: "Lateral Tilt Right", motionAxis: .roll,
                 setupCue: "Gently tilt your right ear toward your right shoulder.",
                 holdCue: "Hold this position. Leave your shoulders completely heavy.",
                 breatheCue: "Breathe into the side of your neck, and slowly return upright.",
                 durationSeconds: 20, targetDeg: 20, toleranceDeg: 10,
                 benefit: "Releases upper trapezius tightness that causes shoulder-neck pain."),
        Exercise(name: "Lateral Tilt Left", motionAxis: .roll,
                 setupCue: "Now, gently tilt your left ear toward your left shoulder.",
                 holdCue: "Hold. Focus on the stretch along the right side of your neck.",
                 breatheCue: "Breathe deeply, and bring your head back upright.",
                 durationSeconds: 20, targetDeg: -20, toleranceDeg: 10,
                 benefit: "Stretches the scalene muscles — relieves nerve compression symptoms."),
        Exercise(name: "Neutral Reset", motionAxis: .pitch,
                 setupCue: "Find your neutral spine. Head perfectly stacked over your shoulders.",
                 holdCue: "Memorize this alignment. This is your foundation.",
                 breatheCue: "Take a deep breath. Let your shoulders completely drop.",
                 durationSeconds: 20, targetDeg: -5, toleranceDeg: 6,
                 benefit: "Trains postural muscle memory — your body learns its ideal position."),

        // -- Active block (exercises 7-12, added at 4 min) --
        Exercise(name: "Chin Tuck with Hold", motionAxis: .pitch,
                 setupCue: "Repeat the chin tuck. This time, press two fingers against your chin for resistance.",
                 holdCue: "Push gently against your fingers. Feel deeper activation.",
                 breatheCue: "Release the pressure slowly. Return to neutral.",
                 durationSeconds: 20, targetDeg: -10, toleranceDeg: 6,
                 benefit: "Isometric resistance builds strength faster than passive stretching."),
        Exercise(name: "Diagonal Look Right-Up", motionAxis: .pitch,
                 setupCue: "Turn your head slightly right, then look up diagonally.",
                 holdCue: "Hold this diagonal stretch. Feel the left front of your neck open.",
                 breatheCue: "Breathe in deeply. Slowly return to center.",
                 durationSeconds: 20, targetDeg: 12, toleranceDeg: 10,
                 benefit: "Targets oblique cervical muscles missed by straight movements."),
        Exercise(name: "Diagonal Look Left-Up", motionAxis: .pitch,
                 setupCue: "Turn slightly left, then look up diagonally.",
                 holdCue: "Hold. Feel the right front of your neck stretching open.",
                 breatheCue: "Exhale and slowly bring your head back to center.",
                 durationSeconds: 20, targetDeg: 12, toleranceDeg: 10,
                 benefit: "Balances diagonal chain flexibility for natural head movement."),
        Exercise(name: "Shoulder Check Right", motionAxis: .yaw,
                 setupCue: "Turn your head right as if checking your blind spot while driving.",
                 holdCue: "Hold at your comfortable maximum. Don't force past tension.",
                 breatheCue: "Exhale and sweep slowly back to center.",
                 durationSeconds: 20, targetDeg: 35, toleranceDeg: 15,
                 benefit: "Improves functional rotation needed for daily activities."),
        Exercise(name: "Shoulder Check Left", motionAxis: .yaw,
                 setupCue: "Turn your head left as if checking your other blind spot.",
                 holdCue: "Hold at your comfortable end range.",
                 breatheCue: "Exhale and return to center.",
                 durationSeconds: 20, targetDeg: -35, toleranceDeg: 15,
                 benefit: "Ensures symmetric cervical rotation for safe movement patterns."),
        Exercise(name: "Seated Forward Nod", motionAxis: .pitch,
                 setupCue: "Slowly lower your chin toward your chest. Stop when you feel a stretch.",
                 holdCue: "Hold there. Feel the stretch along the back of your neck.",
                 breatheCue: "Breathe deeply. Slowly lift your head back up.",
                 durationSeconds: 20, targetDeg: -15, toleranceDeg: 10,
                 benefit: "Stretches the suboccipital muscles that trigger tension headaches."),

        // -- Intermediate block (exercises 13-18, added at 6 min) --
        Exercise(name: "Gentle Extension", motionAxis: .pitch,
                 setupCue: "Slowly look up toward the ceiling. Keep your mouth closed.",
                 holdCue: "Hold. Feel the front of your neck lengthening.",
                 breatheCue: "Inhale deeply, then slowly bring your head level.",
                 durationSeconds: 20, targetDeg: 15, toleranceDeg: 10,
                 benefit: "Counteracts hours of downward screen posture."),
        Exercise(name: "Ear to Shoulder Right with Reach", motionAxis: .roll,
                 setupCue: "Tilt right ear to right shoulder. Reach your left hand toward the floor.",
                 holdCue: "Hold. The reaching hand intensifies the stretch.",
                 breatheCue: "Release the reach. Slowly return upright.",
                 durationSeconds: 20, targetDeg: 22, toleranceDeg: 10,
                 benefit: "Deepens the lateral stretch by engaging the full kinetic chain."),
        Exercise(name: "Ear to Shoulder Left with Reach", motionAxis: .roll,
                 setupCue: "Tilt left ear to left shoulder. Reach your right hand toward the floor.",
                 holdCue: "Hold. Feel the deep stretch on the right side.",
                 breatheCue: "Release and return to center.",
                 durationSeconds: 20, targetDeg: -22, toleranceDeg: 10,
                 benefit: "Addresses lateral imbalances common in single-monitor setups."),
        Exercise(name: "Slow Rotation Sweep Right", motionAxis: .yaw,
                 setupCue: "Very slowly sweep your head from center to the right over five seconds.",
                 holdCue: "Hold at your end range. Notice any tight spots.",
                 breatheCue: "Breathe into the tightness. Slowly sweep back.",
                 durationSeconds: 20, targetDeg: 30, toleranceDeg: 15,
                 benefit: "Controlled tempo mobilizes cervical facet joints more effectively."),
        Exercise(name: "Slow Rotation Sweep Left", motionAxis: .yaw,
                 setupCue: "Now slowly sweep your head from center to the left.",
                 holdCue: "Hold at your comfortable end range.",
                 breatheCue: "Breathe and slowly return to center.",
                 durationSeconds: 20, targetDeg: -30, toleranceDeg: 15,
                 benefit: "Symmetric slow-tempo rotation reduces joint stiffness bilaterally."),
        Exercise(name: "Posture Check Hold", motionAxis: .pitch,
                 setupCue: "Sit at the edge of your chair. Stack your head over your spine.",
                 holdCue: "This is perfect desk posture. Memorize how this feels.",
                 breatheCue: "Breathe naturally. Keep this position effortless.",
                 durationSeconds: 20, targetDeg: -5, toleranceDeg: 5,
                 benefit: "Endurance hold trains the muscles to maintain posture unconsciously."),

        // -- Advanced block (exercises 19-24, added at 8 min) --
        Exercise(name: "Resisted Rotation Right", motionAxis: .yaw,
                 setupCue: "Place your right hand on the right side of your face. Turn right against your hand.",
                 holdCue: "Hold the resistance. Your neck muscles are strengthening.",
                 breatheCue: "Release slowly. Return to center.",
                 durationSeconds: 20, targetDeg: 15, toleranceDeg: 12,
                 benefit: "Isometric resistance builds rotational strength safely."),
        Exercise(name: "Resisted Rotation Left", motionAxis: .yaw,
                 setupCue: "Place your left hand on the left side of your face. Turn left against resistance.",
                 holdCue: "Hold firmly. Feel the deep neck stabilizers working.",
                 breatheCue: "Release gently. Return to neutral.",
                 durationSeconds: 20, targetDeg: -15, toleranceDeg: 12,
                 benefit: "Balanced isometric work prevents rotational asymmetry."),
        Exercise(name: "Resisted Lateral Tilt Right", motionAxis: .roll,
                 setupCue: "Place your right hand above your right ear. Tilt into your hand.",
                 holdCue: "Hold the resistance. Keep your shoulders level.",
                 breatheCue: "Slowly release. Return upright.",
                 durationSeconds: 20, targetDeg: 10, toleranceDeg: 8,
                 benefit: "Strengthens lateral stabilizers that prevent head-forward drift."),
        Exercise(name: "Resisted Lateral Tilt Left", motionAxis: .roll,
                 setupCue: "Place your left hand above your left ear. Tilt into your hand.",
                 holdCue: "Hold. Keep your breathing steady throughout.",
                 breatheCue: "Release and return to center.",
                 durationSeconds: 20, targetDeg: -10, toleranceDeg: 8,
                 benefit: "Builds the lateral neck strength needed for heavy-head syndrome."),
        Exercise(name: "Deep Chin Tuck", motionAxis: .pitch,
                 setupCue: "Perform a strong chin tuck. Imagine making five double chins.",
                 holdCue: "Hold at maximum retraction. Feel deep muscles firing.",
                 breatheCue: "Release halfway. Hold the partial position.",
                 durationSeconds: 20, targetDeg: -12, toleranceDeg: 6,
                 benefit: "Maximum retraction activates the deepest cervical stabilizers."),
        Exercise(name: "Micro-Nod Yes", motionAxis: .pitch,
                 setupCue: "Make tiny yes-nods. Move only one centimeter up and down.",
                 holdCue: "Continue these micro-movements. Stay controlled.",
                 breatheCue: "Slow down to a stop in neutral.",
                 durationSeconds: 20, targetDeg: -5, toleranceDeg: 8,
                 benefit: "Activates deep cranio-cervical flexors through precision control."),

        // -- Cool-down block (exercises 25-30, added at 10 min) --
        Exercise(name: "Gentle Head Circles Right", motionAxis: .roll,
                 setupCue: "Make slow, small circles with your head, moving to the right.",
                 holdCue: "Keep circles small and controlled. No rushing.",
                 breatheCue: "Slow to a stop. Find your center.",
                 durationSeconds: 20, targetDeg: 10, toleranceDeg: 15,
                 benefit: "Multi-plane mobilization lubricates all cervical joints."),
        Exercise(name: "Gentle Head Circles Left", motionAxis: .roll,
                 setupCue: "Now circle gently to the left. Small, easy movements.",
                 holdCue: "Keep it smooth. Notice which direction feels tighter.",
                 breatheCue: "Slow to a stop at center.",
                 durationSeconds: 20, targetDeg: -10, toleranceDeg: 15,
                 benefit: "Reverse circles balance joint lubrication bilaterally."),
        Exercise(name: "Relaxed Forward Hang", motionAxis: .pitch,
                 setupCue: "Let your head drop forward gently. Let gravity do the stretching.",
                 holdCue: "Stay completely relaxed. No muscle effort.",
                 breatheCue: "Breathe deeply. Slowly roll up to seated.",
                 durationSeconds: 20, targetDeg: -18, toleranceDeg: 12,
                 benefit: "Passive stretch releases residual tension after active work."),
        Exercise(name: "Shoulder Drop Reset", motionAxis: .pitch,
                 setupCue: "Shrug your shoulders to your ears, then let them fall completely.",
                 holdCue: "Keep your shoulders heavy. Head tall and light.",
                 breatheCue: "exhale fully. Feel the weight leaving your shoulders.",
                 durationSeconds: 20, targetDeg: -5, toleranceDeg: 8,
                 benefit: "Releases upper trapezius tension accumulated during the session."),
        Exercise(name: "Eyes-Closed Alignment", motionAxis: .pitch,
                 setupCue: "Close your eyes. Feel where your head naturally wants to sit.",
                 holdCue: "Without visual input, your body reveals its true posture.",
                 breatheCue: "Open your eyes. Adjust if needed. This is your new baseline.",
                 durationSeconds: 20, targetDeg: -5, toleranceDeg: 6,
                 benefit: "Proprioceptive training — teaches posture without visual dependency."),
        Exercise(name: "Final Neutral Hold", motionAxis: .pitch,
                 setupCue: "Find your best posture. Head light, shoulders down, spine tall.",
                 holdCue: "This is your target alignment for the rest of your day.",
                 breatheCue: "Take three deep breaths. Carry this posture with you.",
                 durationSeconds: 20, targetDeg: -5, toleranceDeg: 6,
                 benefit: "Closing hold reinforces the neural pattern for ideal alignment."),
    ]

    // ── STANDING — 30 exercises ─────────────────────────────
    private static let standingPool: [Exercise] = [
        Exercise(name: "Forward Flexion", motionAxis: .pitch,
                 setupCue: "Stand proudly and slowly lower your chin down toward your chest.",
                 holdCue: "Hold there. Feel the gentle stretch up the back of your neck.",
                 breatheCue: "Breathe slowly, and raise your head back up.",
                 durationSeconds: 20, targetDeg: -10, toleranceDeg: 10,
                 benefit: "Stretches the posterior cervical muscles — eases tension headaches."),
        Exercise(name: "Gentle Extension", motionAxis: .pitch,
                 setupCue: "Slowly tilt your head back to look up at the ceiling.",
                 holdCue: "Hold this extension. This reverses your downward screen posture.",
                 breatheCue: "Breathe in deeply, opening the front of your neck.",
                 durationSeconds: 20, targetDeg: 15, toleranceDeg: 10,
                 benefit: "Counteracts hours of forward-flexion screen posture."),
        Exercise(name: "Standing Chin Tuck", motionAxis: .pitch,
                 setupCue: "Stand with your heels, shoulders, and head completely aligned.",
                 holdCue: "Draw your chin straight back. Feel your deep neck muscles working.",
                 breatheCue: "Maintain the tuck and take slow, calm breaths.",
                 durationSeconds: 20, targetDeg: -10, toleranceDeg: 8,
                 benefit: "Activates deep cervical flexors with gravity assistance."),
        Exercise(name: "Head Roll Right", motionAxis: .yaw,
                 setupCue: "Slowly turn your head to the right side, sweeping your gaze.",
                 holdCue: "Hold the end of the motion. Don't force past tension.",
                 breatheCue: "Exhale and gently sweep your head back to the center.",
                 durationSeconds: 20, targetDeg: 25, toleranceDeg: 20,
                 benefit: "Lubricates cervical facet joints — reduces stiffness."),
        Exercise(name: "Head Roll Left", motionAxis: .yaw,
                 setupCue: "Now, very slowly turn your head to the left side.",
                 holdCue: "Hold there. Feel the stretch on the right side of your neck.",
                 breatheCue: "Exhale, bringing your head gently back to the center.",
                 durationSeconds: 20, targetDeg: -25, toleranceDeg: 20,
                 benefit: "Balances bilateral mobility — prevents compensatory strain."),
        Exercise(name: "Tall Posture", motionAxis: .pitch,
                 setupCue: "Stand comfortably, locking your head directly over your spine.",
                 holdCue: "Ears directly over your shoulders. This is perfect alignment.",
                 breatheCue: "Breathe and completely relax your arms by your sides.",
                 durationSeconds: 20, targetDeg: -5, toleranceDeg: 6,
                 benefit: "Builds the postural endurance your spine needs all day."),

        // 4-min additions
        Exercise(name: "Standing Lateral Tilt Right", motionAxis: .roll,
                 setupCue: "Standing tall, tilt your right ear toward your right shoulder.",
                 holdCue: "Hold. Let gravity deepen the stretch.",
                 breatheCue: "Breathe into the stretch. Return upright.",
                 durationSeconds: 20, targetDeg: 20, toleranceDeg: 10,
                 benefit: "Gravity-assisted lateral stretch is deeper than seated version."),
        Exercise(name: "Standing Lateral Tilt Left", motionAxis: .roll,
                 setupCue: "Tilt your left ear toward your left shoulder.",
                 holdCue: "Hold. Keep both shoulders level and relaxed.",
                 breatheCue: "Breathe deeply. Return slowly to center.",
                 durationSeconds: 20, targetDeg: -20, toleranceDeg: 10,
                 benefit: "Balances lateral chain flexibility while standing."),
        Exercise(name: "Wall Chin Tuck", motionAxis: .pitch,
                 setupCue: "Stand with your back against a wall. Press the back of your head to the wall.",
                 holdCue: "Hold this retraction. The wall gives you perfect feedback.",
                 breatheCue: "Breathe. Maintain the head-wall contact.",
                 durationSeconds: 20, targetDeg: -10, toleranceDeg: 7,
                 benefit: "Wall provides tactile biofeedback for perfect chin tuck form."),
        Exercise(name: "Standing Shoulder Check Right", motionAxis: .yaw,
                 setupCue: "Rotate your head to look over your right shoulder as far as comfortable.",
                 holdCue: "Hold at your maximum. Keep your torso perfectly still.",
                 breatheCue: "Exhale and return to center.",
                 durationSeconds: 20, targetDeg: 35, toleranceDeg: 15,
                 benefit: "Full-range rotation with postural control challenge."),
        Exercise(name: "Standing Shoulder Check Left", motionAxis: .yaw,
                 setupCue: "Now rotate to look over your left shoulder.",
                 holdCue: "Hold. Notice any differences between sides.",
                 breatheCue: "Return to center on the exhale.",
                 durationSeconds: 20, targetDeg: -35, toleranceDeg: 15,
                 benefit: "Identifies and corrects rotational asymmetry."),
        Exercise(name: "Gravity-Assisted Nod", motionAxis: .pitch,
                 setupCue: "Let your head drop forward slowly. Let gravity pull it down.",
                 holdCue: "Hang there with zero effort. Let gravity stretch you.",
                 breatheCue: "Slowly stack your head back up, one vertebra at a time.",
                 durationSeconds: 20, targetDeg: -15, toleranceDeg: 10,
                 benefit: "Passive traction decompresses the entire cervical spine."),

        // 6-min additions
        Exercise(name: "Diagonal Look Right-Up", motionAxis: .pitch,
                 setupCue: "Turn slightly right, then look up diagonally.",
                 holdCue: "Hold. Feel the left front of your throat open.",
                 breatheCue: "Return to center on the exhale.",
                 durationSeconds: 20, targetDeg: 12, toleranceDeg: 10,
                 benefit: "Diagonal planes target muscles missed by cardinal movements."),
        Exercise(name: "Diagonal Look Left-Up", motionAxis: .pitch,
                 setupCue: "Turn slightly left, then look up diagonally.",
                 holdCue: "Hold. Feel the right front open up.",
                 breatheCue: "Return slowly and smoothly.",
                 durationSeconds: 20, targetDeg: 12, toleranceDeg: 10,
                 benefit: "Completes the diagonal stretch pattern bilaterally."),
        Exercise(name: "Resisted Forward Push", motionAxis: .pitch,
                 setupCue: "Place both hands on your forehead. Push your head into your hands.",
                 holdCue: "Hold the resistance. Your head should not move.",
                 breatheCue: "Release slowly. Feel the muscles relax.",
                 durationSeconds: 20, targetDeg: -5, toleranceDeg: 8,
                 benefit: "Isometric flexion strengthens anterior cervical muscles."),
        Exercise(name: "Resisted Back Push", motionAxis: .pitch,
                 setupCue: "Clasp your hands behind your head. Push backward into your hands.",
                 holdCue: "Hold the isometric contraction. Keep breathing.",
                 breatheCue: "Release and relax your arms down.",
                 durationSeconds: 20, targetDeg: -5, toleranceDeg: 8,
                 benefit: "Strengthens posterior neck muscles for sustained upright posture."),
        Exercise(name: "Standing Micro-Nods", motionAxis: .pitch,
                 setupCue: "Make tiny yes-nods. Only one centimeter of movement.",
                 holdCue: "Continue these micro-movements. Pure control.",
                 breatheCue: "Slow to a stop in your best neutral.",
                 durationSeconds: 20, targetDeg: -5, toleranceDeg: 8,
                 benefit: "Precision control activates deep cranio-cervical flexors."),
        Exercise(name: "Posture Endurance Hold", motionAxis: .pitch,
                 setupCue: "Find your absolute best standing posture.",
                 holdCue: "Hold it. This builds the endurance your spine craves.",
                 breatheCue: "Breathe deeply. Maintain effortlessly.",
                 durationSeconds: 20, targetDeg: -5, toleranceDeg: 5,
                 benefit: "Extended holds build the slow-twitch fibers that maintain posture."),

        // 8-min additions
        Exercise(name: "Slow Roll Right to Left", motionAxis: .yaw,
                 setupCue: "Slowly sweep from far right to far left in one smooth motion.",
                 holdCue: "Move continuously. Feel each degree of rotation.",
                 breatheCue: "Return to center. Rest.",
                 durationSeconds: 20, targetDeg: 0, toleranceDeg: 25,
                 benefit: "Full-range continuous motion identifies and releases tight spots."),
        Exercise(name: "Standing Tilt with Arm Reach Right", motionAxis: .roll,
                 setupCue: "Tilt right ear to shoulder. Reach your left arm toward the floor.",
                 holdCue: "Hold. The arm reach deepens the lateral stretch.",
                 breatheCue: "Release the reach. Return upright.",
                 durationSeconds: 20, targetDeg: 22, toleranceDeg: 10,
                 benefit: "Full kinetic chain engagement maximizes lateral stretch depth."),
        Exercise(name: "Standing Tilt with Arm Reach Left", motionAxis: .roll,
                 setupCue: "Tilt left. Reach your right arm down.",
                 holdCue: "Hold. Feel the entire right side stretching.",
                 breatheCue: "Release and return.",
                 durationSeconds: 20, targetDeg: -22, toleranceDeg: 10,
                 benefit: "Balanced lateral work prevents compensatory scoliotic patterns."),
        Exercise(name: "Resisted Rotation Right", motionAxis: .yaw,
                 setupCue: "Place your right hand on your right cheek. Turn right against it.",
                 holdCue: "Hold the isometric contraction. Head stays still.",
                 breatheCue: "Release slowly.",
                 durationSeconds: 20, targetDeg: 15, toleranceDeg: 12,
                 benefit: "Builds rotational strength for daily functional movements."),
        Exercise(name: "Resisted Rotation Left", motionAxis: .yaw,
                 setupCue: "Place your left hand on your left cheek. Turn left against resistance.",
                 holdCue: "Hold firmly. Keep breathing.",
                 breatheCue: "Release and relax.",
                 durationSeconds: 20, targetDeg: -15, toleranceDeg: 12,
                 benefit: "Symmetric rotational strength prevents neck strain."),
        Exercise(name: "Extension with Jaw Relax", motionAxis: .pitch,
                 setupCue: "Look up at the ceiling. Let your jaw hang completely open.",
                 holdCue: "Hold. The open jaw intensifies the anterior stretch.",
                 breatheCue: "Close your mouth. Return to level.",
                 durationSeconds: 20, targetDeg: 15, toleranceDeg: 10,
                 benefit: "Open-jaw extension releases submental and hyoid muscle tension."),

        // 10-min additions (cool-down)
        Exercise(name: "Standing Head Circles Right", motionAxis: .roll,
                 setupCue: "Make slow, gentle circles with your head to the right.",
                 holdCue: "Keep circles small and smooth.",
                 breatheCue: "Slow to a stop.",
                 durationSeconds: 20, targetDeg: 10, toleranceDeg: 15,
                 benefit: "Multi-plane cool-down mobilizes all cervical segments."),
        Exercise(name: "Standing Head Circles Left", motionAxis: .roll,
                 setupCue: "Now circle gently to the left.",
                 holdCue: "Smooth and controlled. No rushing.",
                 breatheCue: "Come to a gentle stop at center.",
                 durationSeconds: 20, targetDeg: -10, toleranceDeg: 15,
                 benefit: "Reverse circles ensure balanced cool-down."),
        Exercise(name: "Gravity Drop Reset", motionAxis: .pitch,
                 setupCue: "Let your head hang completely forward with zero effort.",
                 holdCue: "Pure gravity. No muscle work.",
                 breatheCue: "Slowly roll up. Head comes up last.",
                 durationSeconds: 20, targetDeg: -18, toleranceDeg: 12,
                 benefit: "Passive decompression after an intense strengthening session."),
        Exercise(name: "Eyes-Closed Balance Check", motionAxis: .pitch,
                 setupCue: "Close your eyes. Feel where your head sits naturally.",
                 holdCue: "Without vision, your body reveals true posture.",
                 breatheCue: "Open your eyes. Adjust if needed.",
                 durationSeconds: 20, targetDeg: -5, toleranceDeg: 6,
                 benefit: "Proprioceptive calibration for lasting postural change."),
        Exercise(name: "Final Tall Posture", motionAxis: .pitch,
                 setupCue: "Stand at your tallest. Head floating above your spine.",
                 holdCue: "This is the posture you're building toward every day.",
                 breatheCue: "Three deep breaths. Carry this with you.",
                 durationSeconds: 20, targetDeg: -5, toleranceDeg: 6,
                 benefit: "Closing hold encodes the session's postural improvements."),
    ]

    // ── LYING — 30 exercises ────────────────────────────────
    private static let lyingPool: [Exercise] = [
        Exercise(name: "Supine Resting", motionAxis: .pitch,
                 setupCue: "Lie flat on your back, face up. Let your neck relax into the floor.",
                 holdCue: "Allow gravity to undo the tension in your spine.",
                 breatheCue: "Breathe deeply into your stomach. Let the floor support your head.",
                 durationSeconds: 20, targetDeg: 5, toleranceDeg: 12,
                 benefit: "Decompresses cervical discs — gravity does the work for you."),
        Exercise(name: "Supine Chin Tuck", motionAxis: .pitch,
                 setupCue: "Looking straight up, gently press the back of your head into the floor.",
                 holdCue: "Hold this gentle pressure. You are building neck endurance safely.",
                 breatheCue: "Keep holding securely. Take slow, even breaths.",
                 durationSeconds: 20, targetDeg: -10, toleranceDeg: 8,
                 benefit: "Isometric strengthening — builds endurance without risky movement."),
        Exercise(name: "Head Turn Right", motionAxis: .yaw,
                 setupCue: "Keeping your head resting heavily, turn it slowly to the right.",
                 holdCue: "Hold the stretch. Feel the muscles along the left side release.",
                 breatheCue: "Exhale deeply, and slowly roll your head back to the center.",
                 durationSeconds: 20, targetDeg: 25, toleranceDeg: 20,
                 benefit: "Gentle rotation under gravity — safe for sensitive necks."),
        Exercise(name: "Head Turn Left", motionAxis: .yaw,
                 setupCue: "Now, turn your resting head slowly to the left.",
                 holdCue: "Hold. Allow the right side of your neck to completely release.",
                 breatheCue: "Inhale, then exhale and slowly roll back to center.",
                 durationSeconds: 20, targetDeg: -25, toleranceDeg: 20,
                 benefit: "Releases sternocleidomastoid tension from prolonged screen use."),
        Exercise(name: "Tiny Head Lift", motionAxis: .pitch,
                 setupCue: "Tuck your chin slightly, and lift your head just barely off the floor.",
                 holdCue: "Hold your head suspended. Front stabilizing muscles are activating.",
                 breatheCue: "Hold for one deep breath, then gently lower your head back down.",
                 durationSeconds: 20, targetDeg: 0, toleranceDeg: 10,
                 benefit: "Targets the longus colli — the key stabilizer for forward head posture."),
        Exercise(name: "Final Rest", motionAxis: .pitch,
                 setupCue: "Let your head sink heavily back into the floor or pillow.",
                 holdCue: "Remain completely still. Allow the decompression to settle in.",
                 breatheCue: "Take a deep breath in. Exhale completely, releasing all effort.",
                 durationSeconds: 20, targetDeg: 0, toleranceDeg: 15,
                 benefit: "Allows cervical muscles to relax and absorb the session's benefits."),

        // 4-min
        Exercise(name: "Supine Chin Tuck with Press", motionAxis: .pitch,
                 setupCue: "Press the back of your head firmly into the floor. Create a strong double chin.",
                 holdCue: "Hold maximum pressure. Feel deep muscles firing.",
                 breatheCue: "Release slowly. Let your neck relax.",
                 durationSeconds: 20, targetDeg: -12, toleranceDeg: 7,
                 benefit: "Increased resistance builds cervical flexor endurance."),
        Exercise(name: "Supine Lateral Tilt Right", motionAxis: .roll,
                 setupCue: "Roll your head gently to bring your right ear closer to your right shoulder.",
                 holdCue: "Hold. Feel the left side of your neck lengthen.",
                 breatheCue: "Roll back to center on the exhale.",
                 durationSeconds: 20, targetDeg: 15, toleranceDeg: 12,
                 benefit: "Gravity-supported lateral stretch — safe for acute neck pain."),
        Exercise(name: "Supine Lateral Tilt Left", motionAxis: .roll,
                 setupCue: "Roll your head gently left. Right ear toward right shoulder.",
                 holdCue: "Hold. The floor supports you completely.",
                 breatheCue: "Return to center.",
                 durationSeconds: 20, targetDeg: -15, toleranceDeg: 12,
                 benefit: "Completes lateral decompression bilaterally."),
        Exercise(name: "Slow Head Sweep Right", motionAxis: .yaw,
                 setupCue: "Slowly sweep your head from center to far right over five seconds.",
                 holdCue: "Hold at your maximum comfortable range.",
                 breatheCue: "Sweep slowly back to center.",
                 durationSeconds: 20, targetDeg: 30, toleranceDeg: 18,
                 benefit: "Slow-tempo rotation gently mobilizes each cervical segment."),
        Exercise(name: "Slow Head Sweep Left", motionAxis: .yaw,
                 setupCue: "Now sweep slowly from center to far left.",
                 holdCue: "Hold at your end range.",
                 breatheCue: "Sweep back to center on the exhale.",
                 durationSeconds: 20, targetDeg: -30, toleranceDeg: 18,
                 benefit: "Bilateral slow sweeps ensure symmetric joint mobility."),
        Exercise(name: "Resting Integration", motionAxis: .pitch,
                 setupCue: "Face straight up. Let all the muscles in your neck completely relax.",
                 holdCue: "Scan for any remaining tension. Let it go.",
                 breatheCue: "Breathe deeply. Feel the floor fully supporting you.",
                 durationSeconds: 20, targetDeg: 0, toleranceDeg: 12,
                 benefit: "Integration pauses allow the nervous system to absorb gains."),

        // 6-min
        Exercise(name: "Isometric Side Press Right", motionAxis: .roll,
                 setupCue: "Place your right hand on the right side of your head. Press into it.",
                 holdCue: "Hold. Your head stays still against the resistance.",
                 breatheCue: "Release slowly.",
                 durationSeconds: 20, targetDeg: 5, toleranceDeg: 10,
                 benefit: "Builds lateral stabilizer strength in a safe supine position."),
        Exercise(name: "Isometric Side Press Left", motionAxis: .roll,
                 setupCue: "Place your left hand on the left side. Press into resistance.",
                 holdCue: "Hold firmly. Keep breathing steadily.",
                 breatheCue: "Release and rest.",
                 durationSeconds: 20, targetDeg: -5, toleranceDeg: 10,
                 benefit: "Balanced lateral strengthening prevents head-tilt patterns."),
        Exercise(name: "Supine Diagonal Right", motionAxis: .yaw,
                 setupCue: "Turn your head slightly right and tuck your chin diagonally.",
                 holdCue: "Hold this combined position.",
                 breatheCue: "Release. Return face-up.",
                 durationSeconds: 20, targetDeg: 15, toleranceDeg: 12,
                 benefit: "Diagonal patterns activate oblique cervical muscle chains."),
        Exercise(name: "Supine Diagonal Left", motionAxis: .yaw,
                 setupCue: "Turn slightly left and tuck diagonally.",
                 holdCue: "Hold. Feel the deep muscles on the right side.",
                 breatheCue: "Release to center.",
                 durationSeconds: 20, targetDeg: -15, toleranceDeg: 12,
                 benefit: "Completes the diagonal activation pattern bilaterally."),
        Exercise(name: "Head Lift with Rotation Right", motionAxis: .yaw,
                 setupCue: "Lift your head slightly off the floor and turn right.",
                 holdCue: "Hold this combined lift and rotation.",
                 breatheCue: "Lower and return to center.",
                 durationSeconds: 20, targetDeg: 20, toleranceDeg: 15,
                 benefit: "Combined movement challenges coordination and strength."),
        Exercise(name: "Head Lift with Rotation Left", motionAxis: .yaw,
                 setupCue: "Lift slightly and turn left.",
                 holdCue: "Hold. Both sides of your neck are working.",
                 breatheCue: "Lower gently to center.",
                 durationSeconds: 20, targetDeg: -20, toleranceDeg: 15,
                 benefit: "Balanced combined movement builds functional neck control."),

        // 8-min
        Exercise(name: "Sustained Head Float", motionAxis: .pitch,
                 setupCue: "Lift your head barely off the floor and hold it floating.",
                 holdCue: "Endurance hold. Stay as still as possible.",
                 breatheCue: "Lower slowly. Rest on the floor.",
                 durationSeconds: 20, targetDeg: 0, toleranceDeg: 10,
                 benefit: "Extended isometric hold builds critical neck endurance."),
        Exercise(name: "Supine Resisted Extension", motionAxis: .pitch,
                 setupCue: "Place your hands behind your head. Push backward into them.",
                 holdCue: "Hold. The floor prevents movement — pure isometric work.",
                 breatheCue: "Release. Let your head rest heavy.",
                 durationSeconds: 20, targetDeg: 5, toleranceDeg: 8,
                 benefit: "Strengthens posterior chain in the safest possible position."),
        Exercise(name: "Full Range Turn Right", motionAxis: .yaw,
                 setupCue: "Turn your head as far right as comfortable. Use the floor for support.",
                 holdCue: "Hold at your maximum. The floor makes this safe.",
                 breatheCue: "Return to center.",
                 durationSeconds: 20, targetDeg: 35, toleranceDeg: 18,
                 benefit: "Maximum range rotation with full gravitational support."),
        Exercise(name: "Full Range Turn Left", motionAxis: .yaw,
                 setupCue: "Turn fully left. The floor supports your head throughout.",
                 holdCue: "Hold your maximum range.",
                 breatheCue: "Return to face-up.",
                 durationSeconds: 20, targetDeg: -35, toleranceDeg: 18,
                 benefit: "Full bilateral rotation restores complete cervical mobility."),
        Exercise(name: "Supine Micro-Nods", motionAxis: .pitch,
                 setupCue: "Make tiny yes-nods against the floor. Barely visible movement.",
                 holdCue: "Continue these precise micro-movements.",
                 breatheCue: "Stop at neutral. Rest.",
                 durationSeconds: 20, targetDeg: -5, toleranceDeg: 8,
                 benefit: "Precision control retrains the deep cranio-cervical junction."),
        Exercise(name: "Deep Relaxation Hold", motionAxis: .pitch,
                 setupCue: "Let every muscle in your neck completely switch off.",
                 holdCue: "Scan from jaw to shoulders. Release anything you find.",
                 breatheCue: "Breathe. Pure passive recovery.",
                 durationSeconds: 20, targetDeg: 0, toleranceDeg: 15,
                 benefit: "Deep relaxation allows tissue remodeling after strengthening work."),

        // 10-min (cool-down)
        Exercise(name: "Supine Gentle Roll Right", motionAxis: .roll,
                 setupCue: "Rock your head very gently to the right, like a pendulum.",
                 holdCue: "Smooth and rhythmic. No sharp movements.",
                 breatheCue: "Slow to a stop.",
                 durationSeconds: 20, targetDeg: 10, toleranceDeg: 15,
                 benefit: "Gentle rocking stimulates parasympathetic nervous system relaxation."),
        Exercise(name: "Supine Gentle Roll Left", motionAxis: .roll,
                 setupCue: "Rock gently to the left now.",
                 holdCue: "Same smooth rhythm. Like a metronome.",
                 breatheCue: "Come to rest at center.",
                 durationSeconds: 20, targetDeg: -10, toleranceDeg: 15,
                 benefit: "Bilateral rocking completes the neurological cool-down."),
        Exercise(name: "Body Scan", motionAxis: .pitch,
                 setupCue: "Face straight up. Scan from your jaw to your toes.",
                 holdCue: "Notice any remaining tension. Breathe into it.",
                 breatheCue: "Let everything go. Complete relaxation.",
                 durationSeconds: 20, targetDeg: 0, toleranceDeg: 15,
                 benefit: "Mindful body scan consolidates physical and mental benefits."),
        Exercise(name: "Gratitude Rest", motionAxis: .pitch,
                 setupCue: "Rest completely. Appreciate what your body just did for you.",
                 holdCue: "You invested in your health. That matters.",
                 breatheCue: "When ready, gently roll to one side to sit up.",
                 durationSeconds: 20, targetDeg: 0, toleranceDeg: 15,
                 benefit: "Positive psychological closure enhances long-term habit formation."),
        Exercise(name: "Final Supine Integration", motionAxis: .pitch,
                 setupCue: "Remain still. Let the decompression integrate fully.",
                 holdCue: "Your cervical spine just received deep therapeutic work.",
                 breatheCue: "Three final breaths. Session complete.",
                 durationSeconds: 20, targetDeg: 0, toleranceDeg: 15,
                 benefit: "Extended rest period maximizes tissue recovery and neural adaptation."),
    ]
}

// ─────────────────────────────────────────────────────────────
// MARK: - Session Summary
// ─────────────────────────────────────────────────────────────

struct SessionSummary: Equatable, Sendable {
    let position: UserPosition
    let alignmentScore: Int   // 0–100
    let totalSeconds: Int
}

// ─────────────────────────────────────────────────────────────
// MARK: - Breathing Phase (syncs spine to coaching cues)
// ─────────────────────────────────────────────────────────────

/// Tracks which coaching phase the exercise is in, so the spine
/// visualizer can match its breathing animation to the user's actual breathing.
enum BreathingPhase: Sendable {
    case setup    // Getting into position — gentle, natural breathing
    case hold     // "Hold this position" — spine holds its breath (freezes)
    case release  // "Breathe deeply" — spine does a slow, deep exhale
}

// ─────────────────────────────────────────────────────────────
// MARK: - Session Phase (UX Ceremony States)
// ─────────────────────────────────────────────────────────────

/// Controls the high-level UX phase of the session experience.
enum SessionPhase: Equatable, Sendable {
    case countdown(Int)                    // 3, 2, 1 pre-session countdown
    case exercising                        // Active exercise in progress
    case transition(completed: String, next: String) // Between exercises: celebrates completion, previews next
    case complete                          // Session finished
}

// ─────────────────────────────────────────────────────────────
// MARK: - Session View Model
// ─────────────────────────────────────────────────────────────

@MainActor
@Observable
final class SessionViewModel {

    var currentExerciseIndex: Int = 0
    var exerciseTimeRemaining: Int = 0
    var sessionComplete: Bool = false
    var summary: SessionSummary?
    var currentCueText: String = ""
    var breathingPhase: BreathingPhase = .setup
    var hapticComposer = HapticComposer()

    // UX Ceremony States
    var sessionPhase: SessionPhase = .countdown(3)
    var inZoneSeconds: Int = 0                     // Live in-zone counter for current hold
    var totalInZoneSeconds: Int = 0                // Cumulative for entire session

    // Directional guidance
    var guidanceText: String = ""                  // "Tilt more right" etc.

    let position: UserPosition
    let exercises: [Exercise]
    let motionManager: MotionManager

    private var exerciseTimer: AnyCancellable?
    private var countdownTimer: AnyCancellable?
    private var deviationSamples: [Double] = []
    private var elapsedSeconds: Int = 0
    private var exerciseElapsedSeconds: Int = 0
    private let audio = AudioCueEngine()

    private var firedHold = false
    private var firedBreathe = false

    init(position: UserPosition, motionManager: MotionManager, duration: Int = 2) {
        self.position = position
        self.exercises = SessionLibrary.exercises(for: position, duration: duration)
        self.motionManager = motionManager
        self.exerciseTimeRemaining = exercises.first?.durationSeconds ?? 20
    }

    var currentExercise: Exercise {
        exercises[min(currentExerciseIndex, exercises.count - 1)]
    }

    var isHolding: Bool {
        let dur = currentExercise.durationSeconds
        let pct = dur > 0 ? Double(dur - exerciseTimeRemaining) / Double(dur) : 1.0
        return pct >= 0.30 && pct < 0.70
    }

    var sessionProgress: Double {
        let total = exercises.reduce(0) { $0 + $1.durationSeconds }
        let done = exercises.prefix(currentExerciseIndex).reduce(0) { $0 + $1.durationSeconds }
                 + exerciseElapsedSeconds
        return total > 0 ? Double(done) / Double(total) : 0
    }

    var isLastExercise: Bool {
        currentExerciseIndex == exercises.count - 1
    }

    // MARK: - Session Lifecycle

    func startSession() {
        sessionPhase = .countdown(DesignSystem.countdownDuration)
        startCountdown()
    }

    func stopSession() {
        exerciseTimer?.cancel()
        countdownTimer?.cancel()
        audio.stop()
        hapticComposer.stopHaptics()
        motionManager.stopSession()
    }

    // MARK: - Countdown (3-2-1)

    private func startCountdown() {
        var remaining = DesignSystem.countdownDuration

        countdownTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                remaining -= 1

                if remaining > 0 {
                    self.sessionPhase = .countdown(remaining)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } else {
                    self.countdownTimer?.cancel()
                    self.countdownTimer = nil
                    // Final countdown haptic — stronger "go!" tap
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    self.beginExercising()
                }
            }
    }

    private func beginExercising() {
        sessionPhase = .exercising
        let ex = currentExercise
        motionManager.startSession(demoAxis: ex.motionAxis, demoTarget: ex.targetDeg, duration: Double(ex.durationSeconds))
        currentCueText = ex.setupCue
        audio.speak(ex.setupCue)
        hapticComposer.playBreathingHaptic(for: .setup)
        startTimer()
    }

    // MARK: - Directional Guidance

    func updateGuidance(currentAngle: Double) {
        let ex = currentExercise
        let diff = ex.targetDeg - currentAngle
        let absDiff = abs(diff)

        if absDiff <= ex.toleranceDeg {
            guidanceText = ""
            return
        }

        let intensity = absDiff > 15 ? "more" : "slightly"

        switch ex.motionAxis {
        case .pitch:
            guidanceText = diff < 0 ? "Tuck chin \(intensity)" : "Lift \(intensity)"
        case .yaw:
            guidanceText = diff > 0 ? "Turn right \(intensity)" : "Turn left \(intensity)"
        case .roll:
            guidanceText = diff > 0 ? "Tilt right \(intensity)" : "Tilt left \(intensity)"
        }
    }

    // MARK: - Exercise Timer

    private func startTimer() {
        exerciseTimer?.cancel()
        let ex = currentExercise
        exerciseTimeRemaining = ex.durationSeconds
        exerciseElapsedSeconds = 0
        firedHold = false
        firedBreathe = false
        breathingPhase = .setup
        inZoneSeconds = 0
        hapticComposer.playBreathingHaptic(for: .setup)

        exerciseTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }

                // Sample deviation
                let angle = motionManager.angle(for: currentExercise.motionAxis)
                let dev = min(abs(angle - currentExercise.targetDeg) / 40.0, 1.0)
                deviationSamples.append(dev)

                // Update directional guidance
                updateGuidance(currentAngle: angle)

                // Track in-zone time
                let inZone = abs(angle - currentExercise.targetDeg) <= currentExercise.toleranceDeg
                if inZone {
                    inZoneSeconds += 1
                    totalInZoneSeconds += 1
                } else {
                    inZoneSeconds = 0
                }

                // Scaled Haptic Guidance: intensity proportional to deviation (Causality principle)
                if dev > 0.40 {
                    let scaledIntensity = min(1.0, dev)
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: scaledIntensity)
                }

                elapsedSeconds += 1
                exerciseElapsedSeconds += 1

                let dur = currentExercise.durationSeconds
                let remaining = exerciseTimeRemaining
                let pct = dur > 0 ? Double(dur - remaining) / Double(dur) : 1

                // Timed coaching
                if pct >= 0.35 && !firedHold {
                    firedHold = true
                    breathingPhase = .hold
                    hapticComposer.playBreathingHaptic(for: .hold)
                    currentCueText = currentExercise.holdCue
                    audio.speak(currentExercise.holdCue)
                } else if pct >= 0.65 && !firedBreathe {
                    firedBreathe = true
                    breathingPhase = .release
                    hapticComposer.playBreathingHaptic(for: .release)
                    currentCueText = currentExercise.breatheCue
                    audio.speak(currentExercise.breatheCue)
                }

                exerciseTimeRemaining -= 1
                if exerciseTimeRemaining <= 0 { advance() }
            }
    }

    // MARK: - Exercise Transitions

    private func advance() {
        exerciseTimer?.cancel()
        if currentExerciseIndex < exercises.count - 1 {
            let completedName = currentExercise.name
            let nextIndex = currentExerciseIndex + 1
            let nextName = exercises[nextIndex].name

            // Ghost Haptic priming before transition
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.3)
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(50))
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }

            // Show transition checkpoint
            withAnimation(DesignSystem.springSmooth) {
                sessionPhase = .transition(completed: completedName, next: nextName)
            }

            // Auto-advance after transition duration
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(DesignSystem.exerciseTransitionDuration))
                self.currentExerciseIndex = nextIndex
                let ex = self.currentExercise
                self.motionManager.updateDemo(axis: ex.motionAxis, target: ex.targetDeg, duration: Double(ex.durationSeconds))
                self.currentCueText = ex.setupCue
                self.audio.speak(ex.setupCue)
                withAnimation(DesignSystem.springSmooth) {
                    self.sessionPhase = .exercising
                }
                self.startTimer()
            }
        } else {
            finish()
        }
    }

    private func finish() {
        motionManager.stopSession()
        let good = deviationSamples.filter { $0 < 0.3 }.count
        let score = deviationSamples.isEmpty ? 50
            : Int(Double(good) / Double(deviationSamples.count) * 100)

        // Ghost Haptic — priming tap before the main notification
        UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.3)
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(60))
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        audio.speak("Session complete. Well done.")

        summary = SessionSummary(position: position, alignmentScore: score, totalSeconds: elapsedSeconds)
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            sessionPhase = .complete
            sessionComplete = true
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Audio Cue Engine
// ─────────────────────────────────────────────────────────────

final class AudioCueEngine {
    private let synth = AVSpeechSynthesizer()

    init() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            print("AudioCueEngine: session setup failed: \(error)")
        }
    }

    func speak(_ text: String) {
        synth.stopSpeaking(at: .immediate)
        let u = AVSpeechUtterance(string: text)
        u.voice = AVSpeechSynthesisVoice(language: "en-US")
        u.rate = 0.48
        u.pitchMultiplier = 1.0
        u.volume = 1.0
        u.preUtteranceDelay = 0.15
        synth.speak(u)
    }

    func stop() { synth.stopSpeaking(at: .immediate) }
}
