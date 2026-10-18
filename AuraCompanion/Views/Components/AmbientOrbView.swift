import SwiftUI

public struct AmbientOrbView: View {
    public var colors: [Color]
    public var state: CallState
    public var scale: CGFloat
    
    @State private var rotateAngle: Double = 0
    @State private var innerPulse: CGFloat = 1.0
    
    public init(
        colors: [Color] = [.purple, .blue, .pink],
        state: CallState = .idle,
        scale: CGFloat = 1.0
    ) {
        self.colors = colors
        self.state = state
        self.scale = scale
    }
    
    public var body: some View {
        ZStack {
            // Halo de lueur diffuse externe
            Circle()
                .fill(
                    RadialGradient(
                        colors: [colors.first?.opacity(0.4) ?? .purple.opacity(0.4), .clear],
                        center: .center,
                        startRadius: 40,
                        endRadius: 160
                    )
                )
                .scaleEffect(scale * (state == .thinking ? 1.25 : 1.1))
                .blur(radius: 20)
            
            // Couche extérieure en rotation
            Circle()
                .fill(
                    AngularGradient(
                        gradient: Gradient(colors: colors + [colors.first ?? .purple]),
                        center: .center,
                        angle: .degrees(rotateAngle)
                    )
                )
                .frame(width: 190, height: 190)
                .mask(
                    Circle()
                        .stroke(lineWidth: 18)
                        .blur(radius: 6)
                )
                .scaleEffect(scale)
            
            // Cœur lumineux interne
            Circle()
                .fill(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 140, height: 140)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                        .blur(radius: 1)
                )
                .scaleEffect(innerPulse * scale)
                .shadow(color: colors.first?.opacity(0.8) ?? .purple, radius: 25, x: 0, y: 0)
            
            // Reflet spéculaire spatial supérieur
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.7), Color.white.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 70, height: 35)
                .offset(y: -40)
                .scaleEffect(scale)
            
            // Ondes concentriques lors de l'écoute ou de la parole
            if state == .listening || state == .speaking {
                Circle()
                    .stroke(colors.last?.opacity(0.5) ?? .pink, lineWidth: 2)
                    .frame(width: 220, height: 220)
                    .scaleEffect(scale * 1.15)
                    .opacity(state == .listening ? 0.8 : 0.4)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                rotateAngle = 360
            }
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                innerPulse = 1.08
            }
        }
    }
}
