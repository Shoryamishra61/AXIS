import AVFoundation

class SpeechManager {
    static let shared = SpeechManager()
    private let synthesizer = AVSpeechSynthesizer()
    
    func speak(text: String) {
        // 1. Stop any current speech immediately (prevents overlap)
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // 2. Configure the Utterance
        let utterance = AVSpeechUtterance(string: text)
        
        // RATE: 0.45 is the "Sweet Spot" for calming instructions
        utterance.rate = 0.45
        
        // PITCH: 0.95 adds a slight depth, removing the "tinny" AI sound
        utterance.pitchMultiplier = 0.95
        
        // VOICE: Select the best human-sounding voice available
        utterance.voice = getBestVoice()
        
        // 3. Speak
        synthesizer.speak(utterance)
    }
    
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    // INTELLIGENT VOICE SELECTOR
    private func getBestVoice() -> AVSpeechSynthesisVoice? {
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        
        // OPTION A: Look for specific high-quality "Therapist" voices
        // "Gordon" (Australian) and "Arthur" (British) are favorites for meditation apps.
        // "Samantha" (US) is the classic high-quality Siri voice.
        let preferredNames = ["Gordon", "Arthur", "Daniel", "Samantha", "Aaron"]
        
        for name in preferredNames {
            if let voice = allVoices.first(where: { $0.name.contains(name) }) {
                return voice
            }
        }
        
        // OPTION B: Fallback to any "Enhanced" quality English voice
        // (These are large file-size voices downloaded by users)
        if let enhanced = allVoices.first(where: {
            $0.language.starts(with: "en") && $0.quality == .enhanced
        }) {
            return enhanced
        }
        
        // OPTION C: Fallback to standard US English
        return AVSpeechSynthesisVoice(language: "en-US")
    }
}
