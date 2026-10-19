import SwiftUI

public struct LiquidBackgroundView: View {
    public var primaryColor: Color
    public var secondaryColor: Color
    
    @State private var animateBlob1 = false
    @State private var animateBlob2 = false
    @State private var animateBlob3 = false
    
    public init(
        primaryColor: Color = Color(hex: "9D5CFF"),
        secondaryColor: Color = Color(hex: "00F0FF")
    ) {
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
    }
    
    public var body: some View {
        ZStack {
            // Fond noir profond
            Color(hex: "080811")
                .ignoresSafeArea()
            
            // Goutte liquide 1 (Haut-gauche)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [primaryColor.opacity(0.35), primaryColor.opacity(0.0)],
                        center: .center,
                        startRadius: 20,
                        endRadius: 220
                    )
                )
                .frame(width: 380, height: 380)
                .offset(
                    x: animateBlob1 ? -60 : 40,
                    y: animateBlob1 ? -120 : -40
                )
                .blur(radius: 60)
            
            // Goutte liquide 2 (Milieu-droite)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [secondaryColor.opacity(0.25), secondaryColor.opacity(0.0)],
                        center: .center,
                        startRadius: 20,
                        endRadius: 240
                    )
                )
                .frame(width: 420, height: 420)
                .offset(
                    x: animateBlob2 ? 80 : -40,
                    y: animateBlob2 ? 60 : 160
                )
                .blur(radius: 70)
            
            // Goutte liquide 3 (Bas)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [primaryColor.opacity(0.28), Color.purple.opacity(0.0)],
                        center: .center,
                        startRadius: 10,
                        endRadius: 200
                    )
                )
                .frame(width: 340, height: 340)
                .offset(
                    x: animateBlob3 ? -40 : 60,
                    y: animateBlob3 ? 240 : 320
                )
                .blur(radius: 65)
            
            // Voile givré fluide
            Rectangle()
                .fill(.ultraThinMaterial.opacity(0.35))
                .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 9.0).repeatForever(autoreverses: true)) {
                animateBlob1.toggle()
            }
            withAnimation(.easeInOut(duration: 11.0).repeatForever(autoreverses: true)) {
                animateBlob2.toggle()
            }
            withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
                animateBlob3.toggle()
            }
        }
    }
}
