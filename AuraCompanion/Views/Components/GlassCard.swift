import SwiftUI

public struct GlassCardModifier: ViewModifier {
    public var cornerRadius: CGFloat = 20
    public var strokeColor: Color = Color.white.opacity(0.15)
    
    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(strokeColor, lineWidth: 1)
            )
    }
}

extension View {
    public func glassCard(cornerRadius: CGFloat = 20, strokeColor: Color = Color.white.opacity(0.15)) -> some View {
        self.modifier(GlassCardModifier(cornerRadius: cornerRadius, strokeColor: strokeColor))
    }
}
