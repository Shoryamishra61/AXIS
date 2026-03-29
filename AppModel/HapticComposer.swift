// HapticComposer.swift

// CoreHaptics bridging engine for continuous synchronized tactile feedback.

import Foundation
import CoreHaptics
import Observation

// MARK: - HapticComposer (Direct Hardware Synergy)

/// Manages a continuous `CHHapticEngine` designed to run in sync with the `AxisSplineVisualizer`.
/// Translates the 3-phase breathing cycle into physical, tactile feedback.
@Observable
class HapticComposer {
    private var engine: CHHapticEngine?
    private var continuousPlayer: CHHapticAdvancedPatternPlayer?

    var isSupported: Bool = false

    init() {
        createEngine()
    }

    private func createEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        isSupported = true

        do {
            engine = try CHHapticEngine()
            try engine?.start()

            // Handle interruptions (e.g., app goes to background)
            engine?.resetHandler = { [weak self] in
                do {
                    try self?.engine?.start()
                } catch {
                    print("Failed to restart engine: \(error)")
                }
            }
        } catch {
            print("Failed to initialize CHHapticEngine: \(error)")
        }
    }

    /// Translates the `BreathingPhase` into a dynamic physical sensation
    func playBreathingHaptic(for phase: BreathingPhase) {
        guard isSupported, let engine = engine else { return }

        // Stop any currently playing continuous pattern
        do {
            try continuousPlayer?.stop(atTime: 0)
        } catch {
            // Ignored, just means nothing was playing
        }

        do {
            let pattern = try buildPattern(for: phase)
            continuousPlayer = try engine.makeAdvancedPlayer(with: pattern)
            continuousPlayer?.loopEnabled = true
            try continuousPlayer?.start(atTime: 0)
        } catch {
            print("Failed to play breathing haptic: \(error)")
        }
    }

    func stopHaptics() {
        try? continuousPlayer?.stop(atTime: 0)
    }

    private func buildPattern(for phase: BreathingPhase) throws -> CHHapticPattern {
        var events = [CHHapticEvent]()
        var curves = [CHHapticParameterCurve]()

        switch phase {
        case .setup:
            // Gentle, rhythmic pulsing
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 1.8)

            let controlPoint = CHHapticParameterCurve.ControlPoint(relativeTime: 0.9, value: 0.1)
            let curve = CHHapticParameterCurve(parameterID: .hapticIntensityControl, controlPoints: [
                CHHapticParameterCurve.ControlPoint(relativeTime: 0.0, value: 0.4),
                controlPoint,
                CHHapticParameterCurve.ControlPoint(relativeTime: 1.8, value: 0.4)
            ], relativeTime: 0)

            events.append(event)
            curves.append(curve)

        case .hold:
            // Near-silence / low tension hum
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.1)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 2.0)
            events.append(event)

        case .release:
            // Deep, sweeping sweep (exhalation)
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 2.5)

            let curve = CHHapticParameterCurve(parameterID: .hapticIntensityControl, controlPoints: [
                CHHapticParameterCurve.ControlPoint(relativeTime: 0.0, value: 0.2),
                CHHapticParameterCurve.ControlPoint(relativeTime: 1.0, value: 0.8),
                CHHapticParameterCurve.ControlPoint(relativeTime: 2.5, value: 0.1)
            ], relativeTime: 0)

            events.append(event)
            curves.append(curve)
        }

        return try CHHapticPattern(events: events, parameterCurves: curves)
    }
}
