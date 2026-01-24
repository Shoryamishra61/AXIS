// SpeechManager.swift
// Axis - The Invisible Posture Companion
// Premium Voice Guidance for Swift Student Challenge 2026

import AVFoundation
import SwiftUI
import Combine

// MARK: - Instruction Phase
enum InstructionPhase {
    case preparation  // "Place your palm..."
    case guidance     // "Press gently..."
    case completion   // "Release..."
}

// MARK: - Speech Manager
class SpeechManager: NSObject, ObservableObject {
    static let shared = SpeechManager()
    
    // MARK: - Properties
    private let synthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking: Bool = false
    
    // MARK: - Voice Configuration
    private var preferredVoice: AVSpeechSynthesisVoice?
    
    // Luxury Pacing Configuration - faster for a snappier feel
    private let baseRate: Float = 0.52      // Faster than before for concise guidance
    private let basePitch: Float = 0.95     // Slightly warmer tone
    private let baseVolume: Float = 1.0
    
    // MARK: - Initialization
    override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
        selectBestVoice()
    }
    
    // MARK: - Audio Session
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .voicePrompt, options: [.duckOthers, .mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }
    
    // MARK: - Voice Selection
    private func selectBestVoice() {
        // Priority: Enhanced quality English voices for "luxury" feel
        let preferredNames = [
            "Samantha (Premium)",
            "Ava (Premium)",
            "Siri", // Often very high quality
            "Alex",
            "Samantha"
        ]
        
        let voices = AVSpeechSynthesisVoice.speechVoices()
        
        // 1. Try to find a specialized premium voice
        for name in preferredNames {
            if let voice = voices.first(where: { $0.name.contains(name) }) {
                preferredVoice = voice
                print("Selected voice: \(voice.name)")
                return
            }
        }
        
        // 2. Fallback to any enhanced English voice
        if let enhanced = voices.first(where: { $0.language.starts(with: "en") && $0.quality == .enhanced }) {
            preferredVoice = enhanced
            return
        }
        
        // 3. Default fallback
        preferredVoice = AVSpeechSynthesisVoice(language: "en-US")
    }
    
    // MARK: - Primary Speak Methods
    
    /// Speak a simple string with luxury settings
    func speak(text: String) {
        stop()
        let utterance = AVSpeechUtterance(string: text)
        configureUtterance(utterance)
        synthesizer.speak(utterance)
        isSpeaking = true
    }
    
    /// Speak using SSML for precise control
    func speakSSML(_ ssmlString: String) {
        stop()
        if let utterance = AVSpeechUtterance(ssmlRepresentation: ssmlString) {
            utterance.voice = preferredVoice
            // Note: rate/pitch are often overridden by SSML tags, but we set defaults just in case
            utterance.rate = baseRate
            utterance.pitchMultiplier = basePitch
            utterance.volume = baseVolume
            
            synthesizer.speak(utterance)
            isSpeaking = true
        } else {
            // Fallback if SSML parsing fails
            print("SSML parsing failed, falling back to plain text.")
            // Strip tags roughly and speak
            let stripped = ssmlString.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            speak(text: stripped)
        }
    }
    
    // MARK: - Multi-Phase Delivery
    
    /// Speak a specific phase of an exercise
    func speakPhase(_ phase: InstructionPhase, from exercise: Exercise) {
        stop()
        
        var content = ""
        
        switch phase {
        case .preparation:
            // "Let's get ready..." tone
            content = formatLuxurySSML(exercise.preparation, rate: "95%", volume: "medium")
            
        case .guidance:
            // The main "Velvet" instruction
            // Combine the calming instruction or the guidance steps
            // For the main phase, we prioritize the rich `calmingInstruction` if available,
            // or perform the sequence of `voiceGuidance`
            
            if !exercise.calmingInstruction.isEmpty {
                content = formatLuxurySSML(exercise.calmingInstruction)
            } else {
                // Construct from array
                let steps = exercise.voiceGuidance.joined(separator: " <break time=\"1.0s\"/> ")
                content = formatLuxurySSML(steps)
            }
            
        case .completion:
            // "And relax..." tone
            content = formatLuxurySSML(exercise.completion, rate: "90%", pitch: "-5%")
        }
        
        speakSSML(content)
    }
    
    /// Play the full sequence of voice guidance tags
    func speakGuidanceSequence(_ steps: [String]) {
        stop()
        // Join with significant pauses
        let combined = steps.joined(separator: " <break time=\"2.0s\"/> ")
        let ssml = formatLuxurySSML(combined)
        speakSSML(ssml)
    }
    
    // MARK: - SSML Helper
    
    /// Wraps text in standard "Axis Luxury" SSML tags
    private func formatLuxurySSML(_ text: String, rate: String = "90%", pitch: String = "default", volume: String = "loud") -> String {
        return """
        <speak>
            <voice name="\(preferredVoice?.identifier ?? "com.apple.ttsbundle.Samantha-compact")">
                <prosody rate="\(rate)" pitch="\(pitch)" volume="\(volume)">
                    \(text)
                </prosody>
            </voice>
        </speak>
        """
    }
    
    // MARK: - Utility
    
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }
    
    private func configureUtterance(_ utterance: AVSpeechUtterance) {
        utterance.voice = preferredVoice
        utterance.rate = baseRate
        utterance.pitchMultiplier = basePitch
        utterance.volume = baseVolume
        utterance.preUtteranceDelay = 0.1
        utterance.postUtteranceDelay = 0.1
    }
    
    // MARK: - Feedback Sounds
    
    func speakSuccess() {
        // Short, encouraging, slightly higher pitch for energy
        let phrases = ["Perfect", "There it is", "Good", "Release"]
        if let phrase = phrases.randomElement() {
             let utterance = AVSpeechUtterance(string: phrase)
             utterance.voice = preferredVoice
             utterance.rate = baseRate
             utterance.pitchMultiplier = basePitch * 1.1 // Slightly brighter
             utterance.volume = 0.8
             synthesizer.speak(utterance)
        }
    }
}

// MARK: - Delegate
extension SpeechManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
}
