import SwiftUI

public struct CompanionAvatarThumbnail: View {
    public let profile: CompanionProfile
    public var size: CGFloat
    
    public init(profile: CompanionProfile, size: CGFloat = 36) {
        self.profile = profile
        self.size = size
    }
    
    public var body: some View {
        Group {
            if let imgData = profile.customImageData, let uiImg = UIImage(data: imgData) {
                Image(uiImage: uiImg)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else if profile.avatarPreset == .customEmoji {
                Text(profile.customEmoji)
                    .font(.system(size: size * 0.52))
                    .frame(width: size, height: size)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: profile.avatarPreset.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                    .overlay(
                        Image(systemName: profile.avatarPreset.symbolIcon)
                            .font(.system(size: size * 0.44, weight: .semibold))
                            .foregroundColor(.white)
                    )
            }
        }
        .overlay(
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.6), Color.white.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: profile.currentMood.accentColors.first?.opacity(0.4) ?? Color.purple.opacity(0.4), radius: 6)
    }
}
