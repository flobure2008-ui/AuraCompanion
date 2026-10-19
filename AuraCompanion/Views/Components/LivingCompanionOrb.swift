import SwiftUI

public struct LivingCompanionOrb: View {
    public var mood: CompanionMood
    public var isSpeaking: Bool = false
    public var isListening: Bool = false
    public var audioLevel: Float = 0.0
    public var size: CGFloat = 160
    
    @State private var isTapped = false
    
    public init(
        mood: CompanionMood = .joyful,
        isSpeaking: Bool = false,
        isListening: Bool = false,
        audioLevel: Float = 0.0,
        size: CGFloat = 160
    ) {
        self.mood = mood
        self.isSpeaking = isSpeaking
        self.isListening = isListening
        self.audioLevel = audioLevel
        self.size = size
    }
    
    public var body: some View {
        ZStack {
            // Halo de lueur diffuse fluide
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            mood.accentColors.first?.opacity(0.35) ?? Color.purple.opacity(0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: size * 0.95
                    )
                )
                .scaleEffect(dynamicScale * 1.15)
            
            // Cœur de Verre Liquide
            Circle()
                .fill(
                    LinearGradient(
                        colors: mood.accentColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    // Reflet spéculaire Apple
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.75), Color.white.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: mood.accentColors.first?.opacity(0.5) ?? .purple, radius: 18)
                .scaleEffect(dynamicScale)
            
            // Reflet supérieur de verre liquide
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.55), Color.white.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.52, height: size * 0.26)
                .offset(y: -size * 0.24)
                .scaleEffect(dynamicScale)
            
            // Emoji d'humeur vivant
            Text(mood.emoji)
                .font(.system(size: size * 0.3))
                .shadow(color: Color.black.opacity(0.3), radius: 3)
        }
        .contentShape(Circle())
        .onTapGesture {
            HapticsService.medium()
            withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                isTapped = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                    isTapped = false
                }
            }
        }
    }
    
    private var dynamicScale: CGFloat {
        var base: CGFloat = 1.0
        if isTapped { base *= 1.12 }
        if isListening { base += CGFloat(audioLevel) * 0.25 }
        if isSpeaking { base += 0.04 }
        return base
    }
}
