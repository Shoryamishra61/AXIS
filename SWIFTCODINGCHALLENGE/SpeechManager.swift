import AVFoundation

class SpeechManager {
    static let shared = SpeechManager()
    private let synthesizer = AVSpeechSynthesizer()
    
    // Commands Axis can say
    enum VoiceCommand: String {
        case welcome = "Align your head comfortably. Close your eyes if you wish."
        case rotateLeft = "Gently rotate your head to the left."
        case rotateRight = "Now, gently rotate to the right."
        case tiltLeft = "Slowly tilt your left ear to your shoulder."
        case tiltRight = "Now, tilt your right ear to your shoulder."
        case center = "Return to center."
        case complete = "Session complete. Well done."
        case good = "Good." // Feedback when they hit the angle
    }
    
    func speak(_ command: VoiceCommand) {
        // Stop any current speech so commands don't pile up
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: command.rawValue)
        utterance.rate = 0.4  // Slow, calming speed (Default is 0.5)
        utterance.pitchMultiplier = 1.0 // Natural pitch
        utterance.volume = 1.0
        
        // Use a high-quality voice if available
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        synthesizer.speak(utterance)
    }
}
