import SwiftUI

public struct WaveformView: View {
    public var audioLevel: Float
    public var tint: Color
    public var barCount: Int = 18
    
    @State private var phase: Double = 0
    
    public init(audioLevel: Float, tint: Color = .purple, barCount: Int = 18) {
        self.audioLevel = audioLevel
        self.tint = tint
        self.barCount = barCount
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<barCount, id: \.self) { index in
                let normalizedIndex = Double(index) / Double(barCount)
                let heightMultiplier = sin(normalizedIndex * .pi)
                let dynamicHeight = max(4.0, CGFloat(audioLevel * 45) * CGFloat(heightMultiplier) + CGFloat.random(in: 3...8))
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.6), tint],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 3.5, height: dynamicHeight)
                    .animation(.spring(response: 0.15, dampingFraction: 0.6), value: audioLevel)
            }
        }
        .frame(height: 50)
    }
}
