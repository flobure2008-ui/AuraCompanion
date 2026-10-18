import Foundation
import Speech
import AVFoundation

@MainActor
public final class SpeechService: NSObject, ObservableObject {
    public static let shared = SpeechService()
    
    @Published public var isRecording = false
    @Published public var transcribedText = ""
    @Published public var audioLevel: Float = 0.0
    @Published public var permissionGranted = false
    @Published public var errorMessage: String?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "fr-FR"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    public override init() {
        super.init()
    }
    
    public func requestPermissions() async -> Bool {
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
        
        let micStatus = await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        
        let granted = speechStatus && micStatus
        self.permissionGranted = granted
        return granted
    }
    
    public func startListening() throws {
        stopListening()
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "SpeechService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Impossible d'initialiser la requête de reconnaissance"])
        }
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
            self?.calculateAudioLevel(buffer: buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        isRecording = true
        transcribedText = ""
        errorMessage = nil
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                Task { @MainActor in
                    self.transcribedText = result.bestTranscription.formattedString
                }
            }
            
            if error != nil || (result?.isFinal ?? false) {
                Task { @MainActor in
                    self.stopListening()
                }
            }
        }
    }
    
    public func stopListening() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
        audioLevel = 0.0
    }
    
    private func calculateAudioLevel(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let channelDataArray = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
        
        var sumSquares: Float = 0
        for sample in channelDataArray {
            sumSquares += sample * sample
        }
        
        let rms = sqrt(sumSquares / Float(buffer.frameLength))
        // Normaliser entre 0 et 1
        let normalized = min(max(rms * 10, 0.0), 1.0)
        
        Task { @MainActor in
            self.audioLevel = normalized
        }
    }
}
