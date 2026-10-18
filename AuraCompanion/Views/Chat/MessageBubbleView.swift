import SwiftUI

public struct MessageBubbleView: View {
    public let message: ChatMessage
    public let profile: CompanionProfile
    public let onReadAloud: () -> Void
    
    @State private var showActions = false
    
    public var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if message.sender == .companion {
                // Avatar vignette
                CompanionAvatarThumbnail(profile: profile, size: 34)
            } else {
                Spacer(minLength: 40)
            }
            
            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 6) {
                // Aperçu de l'image si attachée
                if let imgData = message.imageData, let uiImage = UIImage(data: imgData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 240, maxHeight: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
                
                // Corps du message
                if message.sender == .user {
                    Text(message.content)
                        .font(.system(size: 15.5))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "7C3AED"), Color(hex: "6366F1")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(18, corners: [.topLeft, .topRight, .bottomLeft])
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        if message.isStreaming && message.content.isEmpty {
                            // Indicateur de réflexion
                            HStack(spacing: 5) {
                                Circle().fill(Color.purple).frame(width: 7, height: 7)
                                Circle().fill(Color.pink).frame(width: 7, height: 7)
                                Circle().fill(Color.blue).frame(width: 7, height: 7)
                            }
                            .padding(.vertical, 8)
                        } else {
                            MarkdownTextView(text: message.content)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .glassCard(cornerRadius: 18, strokeColor: Color.white.opacity(0.12))
                    .cornerRadius(18, corners: [.topLeft, .topRight, .bottomRight])
                }
                
                // Barre d'actions sous le message du compagnon
                if message.sender == .companion && !message.isStreaming && !message.content.isEmpty {
                    HStack(spacing: 14) {
                        if let mood = message.moodResonance {
                            HStack(spacing: 4) {
                                Text(mood.emoji)
                                Text(mood.rawValue)
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .foregroundColor(.white.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        Button {
                            onReadAloud()
                            HapticsService.light()
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Button {
                            UIPasteboard.general.string = message.content
                            HapticsService.light()
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        ShareLink(item: message.content) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            
            if message.sender == .user {
                // Espace vide à droite
            } else {
                Spacer(minLength: 30)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

// MARK: - Companion Avatar Thumbnail
public struct CompanionAvatarThumbnail: View {
    public let profile: CompanionProfile
    public var size: CGFloat = 36
    
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
                    .font(.system(size: size * 0.55))
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
                            .font(.system(size: size * 0.45, weight: .semibold))
                            .foregroundColor(.white)
                    )
            }
        }
        .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Rounded Corner Helper
extension View {
    public func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
}

public struct RoundedCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
