import Foundation
import AVFoundation

@MainActor
public final class AudioPlaybackService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    public static let shared = AudioPlaybackService()
    
    @Published public var isSpeaking = false
    @Published public var currentWord: String = ""
    
    private let synthesizer = AVSpeechSynthesizer()
    private var onFinishedCallback: (() -> Void)?
    
    public override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    public func speak(
        text: String,
        voiceIdentifier: String = "fr-FR",
        pitch: Float = 1.0,
        rate: Float = 0.52,
        onFinished: (() -> Void)? = nil
    ) {
        stop()
        self.onFinishedCallback = onFinished
        
        let utterance = AVSpeechUtterance(string: text)
        
        if let voice = AVSpeechSynthesisVoice(identifier: voiceIdentifier) ?? AVSpeechSynthesisVoice(language: "fr-FR") {
            utterance.voice = voice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: Locale.current.identifier)
        }
        
        utterance.pitchMultiplier = pitch
        utterance.rate = rate
        utterance.preUtteranceDelay = 0.05
        utterance.postUtteranceDelay = 0.05
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Erreur audio session: \(error)")
        }
        
        isSpeaking = true
        synthesizer.speak(utterance)
    }
    
    public func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
        currentWord = ""
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    public nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.currentWord = ""
            self.onFinishedCallback?()
            self.onFinishedCallback = nil
        }
    }
    
    public nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.currentWord = ""
            self.onFinishedCallback = nil
        }
    }
    
    public nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let string = utterance.speechString as NSString
        let word = string.substring(with: characterRange)
        Task { @MainActor in
            self.currentWord = word
        }
    }
    
    public static func availableVoices(forLanguage language: String = "fr") -> [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix(language) }
    }
}
