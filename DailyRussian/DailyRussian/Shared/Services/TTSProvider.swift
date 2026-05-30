import AVFoundation

/// Provides Russian text-to-speech using the system synthesizer.
/// No API keys, no network — works offline.
struct TTSProvider {
    private let synthesizer = AVSpeechSynthesizer()

    /// Speaks Russian text with a default Russian voice.
    func speak(_ text: String, language: String = "ru-RU") {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        synthesizer.speak(utterance)
    }

    /// Stop any ongoing speech.
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
