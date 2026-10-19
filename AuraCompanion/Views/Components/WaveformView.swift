import SwiftUI

public struct WaveformView: View {
    public var audioLevel: Float
    public var tint: Color
    public var barCount: Int = 16
    
    public init(audioLevel: Float, tint: Color = .purple, barCount: Int = 16) {
        self.audioLevel = audioLevel
        self.tint = tint
        self.barCount = barCount
    }
    
    public var body: some View {
        HStack(spacing: 3.5) {
            ForEach(0..<barCount, id: \.self) { index in
                let factor = sin(Double(index) / Double(barCount - 1) * .pi)
                let height = max(4.0, CGFloat(audioLevel * 38) * CGFloat(factor) + CGFloat(factor * 6.0))
                
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.5), tint],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 3.5, height: height)
            }
        }
        .frame(height: 42)
        .animation(.spring(response: 0.18, dampingFraction: 0.7), value: audioLevel)
    }
}
