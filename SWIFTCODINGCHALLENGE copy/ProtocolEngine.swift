import Foundation

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

class ProtocolEngine {
    static let shared = ProtocolEngine()
    func generateRoutine(posture: String, durationMinutes: Double, isWheelchair: Bool) -> [ExerciseType] {
        if isWheelchair { return [.deepRest, .seatedScapularRetraction, .chinTuck, .deepRest] }
        return [.deepRest, .chinTuck, .leftTurn, .rightTurn, .deepRest]
    }
}
