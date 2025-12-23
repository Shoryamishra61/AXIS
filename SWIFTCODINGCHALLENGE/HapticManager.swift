import CoreHaptics
import UIKit

class HapticManager {
    static let shared = HapticManager()
    private var engine: CHHapticEngine?
    private var continuousPlayer: CHHapticAdvancedPatternPlayer?

    init() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch { print("Haptic Engine Error: \(error)") }
    }

    func updateGravelTexture(intensity: Float, sharpness: Float) {
        guard let engine = engine else { return }
        
        // If intensity is near zero, stop the player
        if intensity < 0.1 {
            try? continuousPlayer?.stop(atTime: 0)
            continuousPlayer = nil
            return
        }

        if continuousPlayer == nil {
            startContinuousPlayer()
        }

        // Modulate intensity and sharpness based on posture error
        let iParam = CHHapticDynamicParameter(parameterID: .hapticIntensityControl, value: intensity, relativeTime: 0)
        let sParam = CHHapticDynamicParameter(parameterID: .hapticSharpnessControl, value: sharpness, relativeTime: 0)
        try? continuousPlayer?.sendParameters([iParam, sParam], atTime: 0)
    }

    private func startContinuousPlayer() {
        guard let engine = engine else { return }
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 100)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            continuousPlayer = try engine.makeAdvancedPlayer(with: pattern)
            try continuousPlayer?.start(atTime: 0)
        } catch { print("Haptic Player Error: \(error)") }
    }
}