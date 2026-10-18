import SwiftUI
import AVFoundation

@MainActor
public final class CompanionCustomizerViewModel: ObservableObject {
    @Published public var profile: CompanionProfile
    @Published public var isTestingVoice: Bool = false
    @Published public var availableVoices: [AVSpeechSynthesisVoice] = []
    
    public let playbackService = AudioPlaybackService.shared
    
    public init(initialProfile: CompanionProfile) {
        self.profile = initialProfile
        self.availableVoices = AudioPlaybackService.availableVoices(forLanguage: "fr")
    }
    
    public func applyArchetypePreset(_ archetype: CompanionArchetype) {
        profile.archetype = archetype
        profile.bio = archetype.defaultBio
        
        switch archetype {
        case .compassionate:
            profile.toneOfVoice = .warmAndCaring
            profile.warmthLevel = 0.90
            profile.humorLevel = 0.50
            profile.empathyLevel = 0.95
            profile.verbosity = .balanced
            profile.avatarPreset = .nebula
            profile.currentMood = .compassionate
        case .polymath:
            profile.toneOfVoice = .intellectualAndPrecise
            profile.warmthLevel = 0.60
            profile.humorLevel = 0.40
            profile.empathyLevel = 0.70
            profile.verbosity = .detailed
            profile.avatarPreset = .quantumCore
            profile.currentMood = .focused
        case .witty:
            profile.toneOfVoice = .playfulAndCasual
            profile.warmthLevel = 0.75
            profile.humorLevel = 0.95
            profile.empathyLevel = 0.65
            profile.verbosity = .concise
            profile.avatarPreset = .cyberPulse
            profile.currentMood = .playful
        case .zen:
            profile.toneOfVoice = .poeticAndAtmospheric
            profile.warmthLevel = 0.80
            profile.humorLevel = 0.30
            profile.empathyLevel = 0.90
            profile.verbosity = .balanced
            profile.avatarPreset = .zenBlossom
            profile.currentMood = .calm
        case .storyteller:
            profile.toneOfVoice = .poeticAndAtmospheric
            profile.warmthLevel = 0.80
            profile.humorLevel = 0.70
            profile.empathyLevel = 0.80
            profile.verbosity = .detailed
            profile.avatarPreset = .solarFlare
            profile.currentMood = .contemplative
        case .coach:
            profile.toneOfVoice = .sharpAndDirect
            profile.warmthLevel = 0.70
            profile.humorLevel = 0.60
            profile.empathyLevel = 0.75
            profile.verbosity = .concise
            profile.avatarPreset = .emeraldMind
            profile.currentMood = .focused
        case .custom:
            break
        }
        
        HapticsService.medium()
    }
    
    public func testVoiceSample() {
        if playbackService.isSpeaking {
            playbackService.stop()
            isTestingVoice = false
            return
        }
        
        isTestingVoice = true
        let sample = "Bonjour ! Voici comment résonne ma voix quand je m'adresse à toi avec ce timbre et cette cadence."
        
        playbackService.speak(
            text: sample,
            voiceIdentifier: profile.voiceIdentifier,
            pitch: profile.voicePitch,
            rate: profile.voiceRate
        ) { [weak self] in
            self?.isTestingVoice = false
        }
    }
}
