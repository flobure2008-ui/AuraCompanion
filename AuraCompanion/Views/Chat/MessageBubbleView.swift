import SwiftUI

public struct MessageBubbleView: View {
    public let message: ChatMessage
    public let profile: CompanionProfile
    public let onReadAloud: () -> Void
    
    public var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.sender == .companion {
                CompanionAvatarThumbnail(profile: profile, size: 32)
            } else {
                Spacer(minLength: 44)
            }
            
            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 5) {
                // Image attachée
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
                
                // Corps de la bulle
                if message.sender == .user {
                    Text(message.content)
                        .font(.system(size: 15.5))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "7C3AED"), Color(hex: "6366F1")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        if message.isStreaming && message.content.isEmpty {
                            HStack(spacing: 5) {
                                ForEach(0..<3) { _ in
                                    Circle()
                                        .fill(profile.currentMood.accentColors.first ?? .purple)
                                        .frame(width: 7, height: 7)
                                }
                            }
                            .padding(.vertical, 6)
                        } else {
                            MarkdownTextView(text: message.content, accentColor: profile.currentMood.accentColors.first ?? .purple)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    )
                }
                
                // Actions sous message compagnon
                if message.sender == .companion && !message.isStreaming && !message.content.isEmpty {
                    HStack(spacing: 12) {
                        if let mood = message.moodResonance {
                            HStack(spacing: 4) {
                                Text(mood.emoji)
                                Text(mood.rawValue)
                                    .font(.system(size: 10, weight: .semibold))
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            onReadAloud()
                            HapticsService.light()
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        
                        Button {
                            UIPasteboard.general.string = message.content
                            HapticsService.light()
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        
                        ShareLink(item: message.content) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            
            if message.sender != .user {
                Spacer(minLength: 36)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 3)
    }
}
