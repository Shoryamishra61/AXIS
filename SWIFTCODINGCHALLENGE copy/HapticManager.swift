import UIKit
import CoreHaptics

class HapticManager {
    static let shared = HapticManager()
    private var engine: CHHapticEngine?
    private var continuousPlayer: CHHapticAdvancedPatternPlayer?
    
    init() {
        prepareHaptics()
    }
    
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch { print("Haptic Error: \(error)") }
    }
    
    func playSuccessThud() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func updateGravelTexture(intensity: Float, sharpness: Float) {
        guard let engine = engine, intensity > 0 else {
            stopContinuous()
            return
        }
        
        // Fix: Use CHHapticDynamicParameter for real-time modulation
        let intensityParam = CHHapticDynamicParameter(parameterID: .hapticIntensityControl, value: intensity, relativeTime: 0)
        let sharpnessParam = CHHapticDynamicParameter(parameterID: .hapticSharpnessControl, value: sharpness, relativeTime: 0)
        
        do {
            if continuousPlayer == nil {
                let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 0, duration: 100)
                let pattern = try CHHapticPattern(events: [event], parameters: [])
                continuousPlayer = try engine.makeAdvancedPlayer(with: pattern)
                try continuousPlayer?.start(atTime: 0)
            }
            try continuousPlayer?.sendParameters([intensityParam, sharpnessParam], atTime: 0)
        } catch { print("Haptic Update Error: \(error)") }
    }
    
    private func stopContinuous() {
        try? continuousPlayer?.stop(atTime: 0)
        continuousPlayer = nil
    }
}
