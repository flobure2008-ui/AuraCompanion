import SwiftUI

public struct LiquidBackgroundView: View {
    public var primaryColor: Color
    public var secondaryColor: Color
    
    public init(
        primaryColor: Color = Color(hex: "9D5CFF"),
        secondaryColor: Color = Color(hex: "00F0FF")
    ) {
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
    }
    
    public var body: some View {
        ZStack {
            // Fond noir spatial profond Apple (OLED)
            Color.black
                .ignoresSafeArea()
            
            // Dégradé de fond fluide matériel Apple optimisé 120 FPS
            LinearGradient(
                colors: [
                    primaryColor.opacity(0.18),
                    Color(hex: "0B0814"),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Substrat de verre dépoli natif Apple
            Rectangle()
                .fill(.ultraThinMaterial.opacity(0.4))
                .ignoresSafeArea()
        }
    }
}
