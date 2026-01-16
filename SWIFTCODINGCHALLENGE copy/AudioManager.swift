import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let lowPassFilter = AVAudioUnitEQ(numberOfBands: 1)

    init() {
        setupEngine()
    }

    private func setupEngine() {
        let filterParameters = lowPassFilter.bands[0]
        filterParameters.filterType = .lowPass
        filterParameters.frequency = 20000.0 // Fully open
        filterParameters.bypass = false

        engine.attach(player)
        engine.attach(lowPassFilter)
        engine.connect(player, to: lowPassFilter, format: nil)
        engine.connect(lowPassFilter, to: engine.mainMixerNode, format: nil)
        
        try? engine.start()
    }

    func updateFilter(pitchError: Double) {
        let normalizedError = max(0, min(1, abs(pitchError) / 30.0))
        // Muffle audio (20kHz -> 400Hz) as posture degrades
        let frequency = 20000.0 - (19600.0 * Float(normalizedError))
        lowPassFilter.bands[0].frequency = frequency
    }

    func stopSynth() {
        player.stop()
        engine.stop()
    }
}
