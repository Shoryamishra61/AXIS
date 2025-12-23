import Foundation

// 1. Define the possible movements (The "Menu")
enum ExerciseType: String {
    case chinTuck = "Jalandhara Bandha (Chin Tuck)"
    case axialExtension = "Axial Extension (Grow Tall)"
    case isometricPress = "Isometric Press (Head Back)"
    case leftTilt = "Left Scalene Release"
    case rightTilt = "Right Scalene Release"
    case leftRotate = "Brahma Mudra (Left)"
    case rightRotate = "Brahma Mudra (Right)"
    case deepRest = "Shavasana Reset"
    
    // The specific audio guidance for each move
    var instruction: String {
        switch self {
        case .chinTuck: return "Draw your chin straight back, like making a double chin. Feel the back of your neck lengthen."
        case .axialExtension: return "Root your feet down. Lift the crown of your head toward the sky. Decompress your spine."
        case .isometricPress: return "Gently press the back of your head into your pillow. Activate the deep neck muscles."
        case .leftTilt: return "Drop your left ear to your shoulder. Keep your right shoulder heavy and down."
        case .rightTilt: return "Drop your right ear to your shoulder. Breathe into the side of your neck."
        case .leftRotate: return "Slowly turn your head left. Look as far as is comfortable."
        case .rightRotate: return "Slowly turn your head right. Lubricate the vertebrae."
        case .deepRest: return "Close your eyes. Let gravity hold your head completely. Do nothing."
        }
    }
    
    // The sensor target (What MotionManager looks for)
    // Returns (Axis, TargetValue, Comparator)
    var target: (axis: String, value: Double, compare: (Double, Double) -> Bool) {
        switch self {
        case .chinTuck: return ("pitch", -10, { $0 < $1 })       // Look down/back
        case .axialExtension: return ("pitch", 5, { $0 > $1 })   // Slight lift
        case .isometricPress: return ("pitch", 5, { $0 > $1 })   // Press back (similar sensor reading to lift)
        case .leftTilt: return ("roll", -25, { $0 < $1 })
        case .rightTilt: return ("roll", 25, { $0 > $1 })
        case .leftRotate: return ("yaw", 35, { $0 > $1 })
        case .rightRotate: return ("yaw", -35, { $0 < $1 })
        case .deepRest: return ("none", 0, { _,_ in true })      // No movement required
        }
    }
}

// 2. The Engine that generates the routine
class ProtocolEngine {
    static let shared = ProtocolEngine()
    
    func generateRoutine(posture: String, durationMinutes: Double) -> [ExerciseType] {
        var routine: [ExerciseType] = []
        
        // A. Select Base Protocol based on Posture
        switch posture {
        case "Sitting":
            // Focus: Anti-Slump
            routine = [.chinTuck, .chinTuck, .leftTilt, .rightTilt, .leftRotate, .rightRotate]
            
        case "Standing":
            // Focus: Alignment & Balance
            routine = [.axialExtension, .leftRotate, .rightRotate, .leftTilt, .rightTilt]
            
        case "Lying Down":
            // Focus: Decompression & Isometric
            routine = [.isometricPress, .isometricPress, .leftRotate, .rightRotate, .deepRest]
            
        default:
            routine = [.chinTuck, .leftRotate, .rightRotate]
        }
        
        // B. Adjust for Duration
        if durationMinutes >= 5 {
            // Add a second set or deeper holds for longer sessions
            routine.append(contentsOf: routine) 
            // For lying down, we add extra rest
            if posture == "Lying Down" { routine.append(.deepRest) }
        }
        
        return routine
    }
}
