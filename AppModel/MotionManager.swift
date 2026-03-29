// MotionManager.swift
// AXIS — Head-pose data from AirPods (CMHeadphoneMotionManager)
// Multi-axis: publishes pitch, yaw, roll independently.
// Exercise-aware demo: when no AirPods present, simulates the motion
// axis and target of the CURRENT exercise, so the Axis Spline shows
// authentic-looking movement that matches the coaching text.
// Uses CMHeadphoneMotionManagerDelegate for reliable AirPods
// connect / disconnect detection (inspired by Neckle approach).

import SwiftUI
import CoreMotion
import Combine
import Observation

// MARK: - Delegate (wraps CMHeadphoneMotionManagerDelegate)

/// Non-isolated delegate that forwards connect/disconnect events on main.
/// Marked @unchecked Sendable — access is safe because callbacks always
/// dispatch to main actor before touching any mutable state.
private final class HeadphoneDelegate: NSObject, CMHeadphoneMotionManagerDelegate, @unchecked Sendable {
    var onConnect: (@Sendable () -> Void)?
    var onDisconnect: (@Sendable () -> Void)?

    func headphoneMotionManagerDidConnect(_ manager: CMHeadphoneMotionManager) {
        let action = onConnect
        DispatchQueue.main.async { action?() }
    }

    func headphoneMotionManagerDidDisconnect(_ manager: CMHeadphoneMotionManager) {
        let action = onDisconnect
        DispatchQueue.main.async { action?() }
    }
}

// MARK: - MotionManager

@MainActor
@Observable
final class MotionManager {

    // ── Published state ──────────────────────────────────────

    /// Pitch in degrees. + = forward head (tech neck). – = chin tucked (good).
    var pitch: Double = 0.0
    /// Yaw in degrees. + = turned right. – = turned left.
    var yaw:   Double = 0.0
    /// Roll in degrees. + = tilted right. – = tilted left.
    var roll:  Double = 0.0

    /// True while CMHeadphoneMotionManager delivers live data.
    var isConnected: Bool = false

    /// True when the system reports compatible headphones are present,
    /// regardless of whether a session is in progress.
    var headphonesAvailable: Bool = false

    // ── Private ──────────────────────────────────────────────

    private let manager = CMHeadphoneMotionManager()
    private let delegate = HeadphoneDelegate()
    private let hapticEngine = UIImpactFeedbackGenerator(style: .rigid)

    // Demo state
    private var demoTimer: AnyCancellable?
    private var demoPhase: Double = 0          // 0→1 over the exercise duration
    private var demoAxis: MotionAxis = .pitch
    private var demoTarget: Double = -8.0
    private var demoDuration: Double = 20.0    // exercise length in seconds
    private var isInDemoMode: Bool = false

    // Track whether a session was requested, so we can auto-resume
    // live tracking if headphones reconnect mid-session.
    private var sessionActive: Bool = false

    // ── Init ─────────────────────────────────────────────────

    init() {

        // Wire up delegate for live connect/disconnect
        delegate.onConnect = { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.headphonesAvailable = true
                // If a session was already running in demo, switch to live
                if self.sessionActive && self.isInDemoMode {
                    self.demoTimer?.cancel()
                    self.demoTimer = nil
                    self.isInDemoMode = false
                    self.beginLiveUpdates()
                }
            }
        }
        delegate.onDisconnect = { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.headphonesAvailable = false
                self.isConnected = false
                // Fall back to demo if session is running
                if self.sessionActive && !self.isInDemoMode {
                    self.manager.stopDeviceMotionUpdates()
                    self.startDemoMode()
                }
            }
        }
        manager.delegate = delegate

        // Initial availability check
        headphonesAvailable = manager.isDeviceMotionAvailable
    }

    // ── Public API ───────────────────────────────────────────

    /// Read the relevant angle for a given motion axis.
    func angle(for axis: MotionAxis) -> Double {
        switch axis {
        case .pitch: return pitch
        case .roll:  return roll
        case .yaw:   return yaw
        }
    }

    /// Start sensor updates. Falls back to exercise-matched demo mode if no AirPods.
    func startSession(demoAxis: MotionAxis = .pitch, demoTarget: Double = -8.0, duration: Double = 20.0) {
        self.demoAxis = demoAxis
        self.demoTarget = demoTarget
        self.demoDuration = duration
        self.sessionActive = true

        guard manager.isDeviceMotionAvailable else {
            startDemoMode()
            return
        }

        beginLiveUpdates()
    }

    func stopSession() {
        sessionActive = false
        manager.stopDeviceMotionUpdates()
        demoTimer?.cancel()
        demoTimer = nil
        isConnected = false
        isInDemoMode = false
    }

    // ── Live AirPods updates ─────────────────────────────────

    private func beginLiveUpdates() {
        guard !manager.isDeviceMotionActive else { return }
        
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self else { return }
            
            if let error = error {
                print("AirPods motion error: \(error.localizedDescription)")
                self.manager.stopDeviceMotionUpdates()
                if !self.isInDemoMode {
                    self.startDemoMode()
                }
                return
            }
            
            guard let motion = motion else { return }

            self.isConnected = true
            self.headphonesAvailable = true

            // CMMotion → degrees. –12° offset so "neutral upright" ≈ 0°.
            self.pitch = (motion.attitude.pitch * 180.0 / .pi) - 12.0
            self.yaw   =  motion.attitude.yaw   * 180.0 / .pi
            self.roll  =  motion.attitude.roll  * 180.0 / .pi
        }
    }

    /// Called when the current exercise changes. Updates demo mode to simulate
    /// the new exercise's axis and target so the spine matches the coaching.
    func updateDemo(axis: MotionAxis, target: Double, duration: Double = 20.0) {
        demoAxis = axis
        demoTarget = target
        demoDuration = duration
        // Reset phase so the new exercise starts its own motion arc
        // from neutral → target → hold → neutral
        demoPhase = 0
    }

    // ── Demo / fallback mode ─────────────────────────────────
    //
    // Each exercise follows a 3-phase motion arc that matches the
    // coaching cues:
    //
    //   Phase 1 (0%–30%):   Ease from neutral (0°) toward the target.
    //                        Matches the "setup" cue.
    //
    //   Phase 2 (30%–70%):  Hold near the target with subtle breathing.
    //                        Matches the "hold" cue.
    //
    //   Phase 3 (70%–100%): Ease back from target to neutral.
    //                        Matches the "breathe/return" cue.
    //
    // So "Neck Rotation Right" (+25°) → center → right → hold → center.
    //    "Lateral Tilt Left"  (–20°) → center → left  → hold → center.
    //    "Chin Tuck"          (–8°)  → neutral → tucked → hold → neutral.
    //
    // All transitions use smooth ease-in-out curves — no snapping.

    private func startDemoMode() {
        manager.stopDeviceMotionUpdates()
        demoTimer?.cancel()
        demoTimer = nil
        
        isConnected = false
        isInDemoMode = true
        demoPhase = 0

        let interval = 1.0 / 60.0   // 60 fps

        demoTimer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }

                // Advance phase: 0 → 1 over the exercise duration, then loop
                let phaseStep = interval / max(self.demoDuration, 1.0)
                self.demoPhase += phaseStep
                if self.demoPhase > 1.0 {
                    self.demoPhase -= 1.0  // seamless loop
                }

                let p = self.demoPhase  // 0…1

                // ── 3-phase motion curve ─────────────────────
                // Returns 0 at start/end, 1 at the peak (hold zone)
                let envelope: Double
                if p < 0.30 {
                    // Phase 1: ease-in from 0 to 1
                    let t = p / 0.30
                    envelope = smoothStep(t)
                } else if p < 0.70 {
                    // Phase 2: hold at 1 with gentle breathing
                    let breathe = sin(p * .pi * 8) * 0.04
                    envelope = 1.0 + breathe
                } else {
                    // Phase 3: ease-out from 1 back to 0
                    let t = (p - 0.70) / 0.30
                    envelope = smoothStep(1.0 - t)
                }

                // The target angle drives the direction and magnitude.
                // envelope=0 → neutral (0°), envelope=1 → at demoTarget.
                let demoValue = self.demoTarget * envelope

                // Small organic micro-sway so it doesn't look robotic
                let micro = sin(self.demoPhase * .pi * 14) * 0.8
                let finalValue = demoValue + micro

                // ── Apply to the correct axis ────────────────
                // Smoothly decay unused axes toward 0
                let decay = 0.93

                switch self.demoAxis {
                case .pitch:
                    self.pitch = finalValue
                    self.roll  = self.roll  * decay
                    self.yaw   = self.yaw   * decay
                case .roll:
                    self.roll  = finalValue
                    self.pitch = self.pitch * decay
                    self.yaw   = self.yaw   * decay
                case .yaw:
                    self.yaw   = finalValue
                    self.pitch = self.pitch * decay
                    self.roll  = self.roll  * decay
                }
            }
    }

    /// Hermite smooth-step: 0→1 with ease-in-ease-out (no sharp edges)
    private func smoothStep(_ x: Double) -> Double {
        let t = max(0, min(1, x))
        return t * t * (3.0 - 2.0 * t)
    }

    // ── Post-session scoring ─────────────────────────────────

    /// Returns 0–100: percentage of samples in the safe zone (<5° deviation).
    func computeAlignmentScore(samples: [Double]) -> Int {
        guard !samples.isEmpty else { return 0 }
        let good = samples.filter { $0 < 5.0 }.count
        return Int(Double(good) / Double(samples.count) * 100)
    }
}
