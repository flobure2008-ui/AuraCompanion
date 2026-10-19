import SwiftUI

// MARK: - Liquid Glass Modifier
public struct LiquidGlassModifier: ViewModifier {
    public var cornerRadius: CGFloat = 24
    public var glowColor: Color = Color(hex: "9D5CFF")
    public var opacity: Double = 0.08
    public var showBorderSheen: Bool = true
    
    public func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // 1. Base givrée ultra-douce
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    // 2. Teinte liquide translucide
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.white.opacity(opacity))
                    
                    // 3. Reflet spéculaire liquide supérieur
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.22),
                            Color.white.opacity(0.04),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                }
            )
            .overlay(
                // 4. Bordure chromatique iridescente / néon liquide
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.45),
                                glowColor.opacity(0.4),
                                Color.white.opacity(0.1),
                                glowColor.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: glowColor.opacity(0.18), radius: 16, x: 0, y: 8)
            .shadow(color: Color.black.opacity(0.35), radius: 10, x: 0, y: 4)
    }
}

// MARK: - View Extension
extension View {
    public func liquidGlass(
        cornerRadius: CGFloat = 24,
        glowColor: Color = Color(hex: "9D5CFF"),
        opacity: Double = 0.08
    ) -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: cornerRadius, glowColor: glowColor, opacity: opacity))
    }
    
    public func liquidGlassPill(glowColor: Color = Color(hex: "9D5CFF")) -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: 50, glowColor: glowColor, opacity: 0.12))
    }
}

// MARK: - Liquid Button Style
public struct LiquidButtonStyle: ButtonStyle {
    public var glowColor: Color = Color(hex: "9D5CFF")
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: configuration.isPressed)
    }
}
