// SpeechManager.swift
// Axis - The Invisible Posture Companion
// Premium Voice Guidance for Swift Student Challenge 2026

import AVFoundation
import SwiftUI
import Combine

// MARK: - Speech Manager
class SpeechManager: NSObject, ObservableObject {
    static let shared = SpeechManager()
    
    // MARK: - Properties
    private let synthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking: Bool = false
    
    // MARK: - Voice Configuration
    private var preferredVoice: AVSpeechSynthesisVoice?
    private var speechRate: Float = 0.48  // Calm, measured pace
    private var pitchMultiplier: Float = 0.95  // Slightly lower for warmth
    
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
            try session.setCategory(.playback, mode: .default, options: [.duckOthers, .mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }
    
    // MARK: - Voice Selection
    private func selectBestVoice() {
        // Priority order for natural-sounding voices
        let preferredNames = [
            "Samantha (Premium)",  // US Female - Enhanced
            "Alex (US English)",   // US Male - High quality
            "Samantha",            // US Female
            "Daniel",              // UK Male
            "Karen",               // AU Female
            "Moira",               // IE Female
            "Arthur"               // UK Male - Enhanced
        ]
        
        // Get all available voices
        let voices = AVSpeechSynthesisVoice.speechVoices()
        
        // Try enhanced voices first
        for voice in voices {
            if voice.quality == .enhanced && voice.language.starts(with: "en") {
                preferredVoice = voice
                print("Selected enhanced voice: \(voice.name)")
                return
            }
        }
        
        // Try preferred names
        for name in preferredNames {
            if let voice = voices.first(where: { $0.name.contains(name) }) {
                preferredVoice = voice
                print("Selected voice: \(voice.name)")
                return
            }
        }
        
        // Final fallback: any English voice
        preferredVoice = voices.first(where: { $0.language.starts(with: "en") })
        print("Using fallback voice: \(preferredVoice?.name ?? "default")")
    }
    
    // MARK: - Speak
    func speak(text: String) {
        // Stop any current speech
        stop()
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = preferredVoice
        utterance.rate = speechRate
        utterance.pitchMultiplier = pitchMultiplier
        utterance.preUtteranceDelay = 0.2  // Brief pause before speaking
        utterance.postUtteranceDelay = 0.3  // Brief pause after
        utterance.volume = 0.9
        
        isSpeaking = true
        synthesizer.speak(utterance)
    }
    
    // MARK: - Speak with Emphasis
    func speakWithEmphasis(_ text: String, rate: Float? = nil, pitch: Float? = nil) {
        stop()
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = preferredVoice
        utterance.rate = rate ?? speechRate * 0.9  // Slightly slower for emphasis
        utterance.pitchMultiplier = pitch ?? pitchMultiplier * 1.05
        utterance.volume = 1.0
        
        isSpeaking = true
        synthesizer.speak(utterance)
    }
    
    // MARK: - Speak Countdown
    func speakCountdown(from number: Int, interval: TimeInterval = 1.0, completion: @escaping () -> Void) {
        var current = number
        
        func speakNext() {
            if current > 0 {
                speak(text: "\(current)")
                current -= 1
                DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                    speakNext()
                }
            } else {
                completion()
            }
        }
        
        speakNext()
    }
    
    // MARK: - Speak Success
    func speakSuccess() {
        let phrases = [
            "Perfect.",
            "Well done.",
            "Excellent.",
            "That's it.",
            "Great work."
        ]
        
        if let phrase = phrases.randomElement() {
            speakWithEmphasis(phrase, rate: speechRate * 0.85)
        }
    }
    
    // MARK: - Speak Encouragement
    func speakEncouragement() {
        let phrases = [
            "Keep going.",
            "Almost there.",
            "You're doing well.",
            "Stay with it."
        ]
        
        if let phrase = phrases.randomElement() {
            speak(text: phrase)
        }
    }
    
    // MARK: - Stop
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }
    
    // MARK: - Adjust Settings
    func setRate(_ rate: Float) {
        speechRate = max(0.3, min(0.6, rate))
    }
    
    func setPitch(_ pitch: Float) {
        pitchMultiplier = max(0.8, min(1.2, pitch))
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
