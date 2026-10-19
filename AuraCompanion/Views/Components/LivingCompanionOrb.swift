import SwiftUI

public struct LivingCompanionOrb: View {
    public var mood: CompanionMood
    public var isSpeaking: Bool = false
    public var isListening: Bool = false
    public var audioLevel: Float = 0.0
    public var size: CGFloat = 160
    
    @State private var phase: Double = 0
    @State private var innerPulse: CGFloat = 1.0
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
            // Halo de lueur diffuse liquide
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            mood.accentColors.first?.opacity(0.45) ?? Color.purple.opacity(0.4),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: size * 1.1
                    )
                )
                .scaleEffect(dynamicScale * 1.3)
                .blur(radius: 25)
            
            // Anneau liquide extérieur ondulant
            Circle()
                .strokeBorder(
                    AngularGradient(
                        gradient: Gradient(colors: mood.accentColors + [mood.accentColors.first ?? .purple]),
                        center: .center,
                        angle: .degrees(phase * 60)
                    ),
                    lineWidth: isSpeaking ? 6 : 3
                )
                .frame(width: size * 1.18, height: size * 1.18)
                .scaleEffect(dynamicScale * (isSpeaking ? 1.08 : 1.0))
                .opacity(0.7)
            
            // Cœur liquide principal
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
                    // Reflet liquide de verre supérieur
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.7), Color.white.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: mood.accentColors.first?.opacity(0.6) ?? .purple, radius: 24, x: 0, y: 0)
                .scaleEffect(dynamicScale)
            
            // Goutte de réfraction spéculaire (Effet Verre Liquide)
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.65), Color.white.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.55, height: size * 0.28)
                .offset(y: -size * 0.24)
                .scaleEffect(dynamicScale)
            
            // Symbole de présence vivante au centre
            VStack(spacing: 4) {
                Text(mood.emoji)
                    .font(.system(size: size * 0.28))
                    .shadow(color: .black.opacity(0.3), radius: 4)
                
                if isSpeaking || isListening {
                    HStack(spacing: 3) {
                        ForEach(0..<4, id: \.self) { i in
                            Capsule()
                                .fill(Color.white)
                                .frame(width: 3, height: CGFloat.random(in: 6...18))
                        }
                    }
                    .transition(.opacity)
                }
            }
        }
        .onTapGesture {
            HapticsService.medium()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isTapped = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    isTapped = false
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                phase = 6.28
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                innerPulse = 1.06
            }
        }
    }
    
    private var dynamicScale: CGFloat {
        var base = innerPulse
        if isTapped { base *= 1.15 }
        if isListening { base += CGFloat(audioLevel) * 0.35 }
        if isSpeaking { base += 0.05 }
        return base
    }
}
