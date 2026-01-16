// HapticManager.swift
// Axis - The Invisible Posture Companion
// Custom Haptic Patterns for Swift Student Challenge 2026

import UIKit
import CoreHaptics

// MARK: - Haptic Manager
class HapticManager {
    static let shared = HapticManager()
    
    // MARK: - Engine State
    private var engine: CHHapticEngine?
    private var continuousPlayer: CHHapticAdvancedPatternPlayer?
    private var isEngineRunning: Bool = false
    
    // MARK: - Haptic Support
    private var supportsHaptics: Bool {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }
    
    // MARK: - Initialization
    init() {
        prepareHaptics()
    }
    
    private func prepareHaptics() {
        guard supportsHaptics else {
            print("Haptics not supported on this device")
            return
        }
        
        do {
            engine = try CHHapticEngine()
            
            // Handle engine reset
            engine?.resetHandler = { [weak self] in
                print("Haptic engine reset")
                do {
                    try self?.engine?.start()
                    self?.isEngineRunning = true
                } catch {
                    print("Failed to restart haptic engine: \(error)")
                    self?.isEngineRunning = false
                }
            }
            
            // Handle engine stopped
            engine?.stoppedHandler = { [weak self] reason in
                print("Haptic engine stopped: \(reason.rawValue)")
                self?.isEngineRunning = false
            }
            
            try engine?.start()
            isEngineRunning = true
            
        } catch {
            print("Haptic Engine Error: \(error)")
        }
    }
    
    // MARK: - Pattern 1: Success Thud
    /// A satisfying heavy thud for hitting targets
    func playSuccessThud() {
        guard supportsHaptics, let engine = engine else {
            // Fallback to basic haptic
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            return
        }
        
        do {
            // Create a "thud" pattern: quick sharp hit followed by warm decay
            let sharpHit = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                ],
                relativeTime: 0
            )
            
            let warmDecay = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 0.02,
                duration: 0.15
            )
            
            let pattern = try CHHapticPattern(events: [sharpHit, warmDecay], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
            
        } catch {
            print("Success thud error: \(error)")
            // Fallback
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
    }
    
    // MARK: - Pattern 2: Gravel Texture
    /// Dynamic texture that intensifies with misalignment
    func updateGravelTexture(intensity: Float, sharpness: Float) {
        guard supportsHaptics, let engine = engine, intensity > 0 else {
            stopContinuous()
            return
        }
        
        // Clamp values
        let clampedIntensity = max(0.0, min(1.0, intensity))
        let clampedSharpness = max(0.0, min(1.0, sharpness))
        
        do {
            if continuousPlayer == nil {
                // Create continuous gravel pattern
                let event = CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: clampedIntensity),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: clampedSharpness)
                    ],
                    relativeTime: 0,
                    duration: 100
                )
                
                let pattern = try CHHapticPattern(events: [event], parameters: [])
                continuousPlayer = try engine.makeAdvancedPlayer(with: pattern)
                try continuousPlayer?.start(atTime: 0)
            }
            
            // Update parameters dynamically
            let intensityParam = CHHapticDynamicParameter(
                parameterID: .hapticIntensityControl,
                value: clampedIntensity,
                relativeTime: 0
            )
            let sharpnessParam = CHHapticDynamicParameter(
                parameterID: .hapticSharpnessControl,
                value: clampedSharpness,
                relativeTime: 0
            )
            
            try continuousPlayer?.sendParameters([intensityParam, sharpnessParam], atTime: 0)
            
        } catch {
            print("Gravel texture error: \(error)")
        }
    }
    
    // MARK: - Pattern 3: Notch Click
    /// Crisp click for hitting angle increments (10°, 20°, etc.)
    func playNotchClick() {
        guard supportsHaptics, let engine = engine else {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            return
        }
        
        do {
            let click = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ],
                relativeTime: 0
            )
            
            let pattern = try CHHapticPattern(events: [click], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
            
        } catch {
            print("Notch click error: \(error)")
        }
    }
    
    // MARK: - Pattern 4: Flow Release
    /// Smooth, calming haptic for returning to alignment
    func playFlowRelease() {
        guard supportsHaptics, let engine = engine else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            return
        }
        
        do {
            // Gentle fade-in, soft hold, fade-out
            let events: [CHHapticEvent] = [
                // Fade in
                CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
                    ],
                    relativeTime: 0,
                    duration: 0.1
                ),
                // Peak
                CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                    ],
                    relativeTime: 0.1,
                    duration: 0.1
                ),
                // Fade out
                CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.2),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.05)
                    ],
                    relativeTime: 0.2,
                    duration: 0.15
                )
            ]
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
            
        } catch {
            print("Flow release error: \(error)")
        }
    }
    
    // MARK: - Pattern 5: Heartbeat Pulse
    /// Calming double-beat for breathing exercises
    func playHeartbeatPulse() {
        guard supportsHaptics, let engine = engine else {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                generator.impactOccurred()
            }
            return
        }
        
        do {
            let events: [CHHapticEvent] = [
                // First beat (stronger)
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                    ],
                    relativeTime: 0
                ),
                // Second beat (softer)
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                    ],
                    relativeTime: 0.12
                )
            ]
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
            
        } catch {
            print("Heartbeat pulse error: \(error)")
        }
    }
    
    // MARK: - Pattern 6: Warning Buzz
    /// Alert haptic for errors or warnings
    func playWarningBuzz() {
        guard supportsHaptics, let engine = engine else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            return
        }
        
        do {
            let events: [CHHapticEvent] = [
                CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                    ],
                    relativeTime: 0,
                    duration: 0.05
                ),
                CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                    ],
                    relativeTime: 0.1,
                    duration: 0.05
                ),
                CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                    ],
                    relativeTime: 0.2,
                    duration: 0.05
                )
            ]
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
            
        } catch {
            print("Warning buzz error: \(error)")
        }
    }
    
    // MARK: - Pattern 7: Calibration Complete
    /// Rising confirmation for successful calibration
    func playCalibrationComplete() {
        guard supportsHaptics, let engine = engine else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            return
        }
        
        do {
            let events: [CHHapticEvent] = [
                // Rising intensity
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                    ],
                    relativeTime: 0
                ),
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                    ],
                    relativeTime: 0.08
                ),
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                    ],
                    relativeTime: 0.16
                ),
                // Final bloom
                CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                    ],
                    relativeTime: 0.24,
                    duration: 0.2
                )
            ]
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
            
        } catch {
            print("Calibration complete error: \(error)")
        }
    }
    
    // MARK: - Stop Continuous
    
    func stopContinuous() {
        do {
            try continuousPlayer?.stop(atTime: 0)
        } catch {
            print("Stop continuous error: \(error)")
        }
        continuousPlayer = nil
    }
    
    // MARK: - Stop All
    
    func stopAll() {
        stopContinuous()
        engine?.stop()
        isEngineRunning = false
    }
    
    // MARK: - Restart Engine
    
    func restartEngine() {
        guard supportsHaptics else { return }
        
        do {
            try engine?.start()
            isEngineRunning = true
        } catch {
            print("Failed to restart engine: \(error)")
        }
    }
}
