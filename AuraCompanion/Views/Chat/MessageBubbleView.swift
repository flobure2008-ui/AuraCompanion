import SwiftUI

public struct MessageBubbleView: View {
    public let message: ChatMessage
    public let profile: CompanionProfile
    public let onReadAloud: () -> Void
    
    public var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if message.sender == .companion {
                // Miniature du compagnon
                CompanionAvatarThumbnail(profile: profile, size: 36)
            } else {
                Spacer(minLength: 40)
            }
            
            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 6) {
                // Image attachée si présente
                if let imgData = message.imageData, let uiImage = UIImage(data: imgData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 240, maxHeight: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .strokeBorder(Color.white.opacity(0.3), lineWidth: 1.2)
                        )
                }
                
                // Bulle de message
                if message.sender == .user {
                    Text(message.content)
                        .font(.system(size: 15.5, weight: .regular))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            ZStack {
                                LinearGradient(
                                    colors: [Color(hex: "7C3AED"), Color(hex: "4F46E5")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                
                                LinearGradient(
                                    colors: [Color.white.opacity(0.2), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                        )
                        .shadow(color: Color(hex: "7C3AED").opacity(0.35), radius: 10, y: 4)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        if message.isStreaming && message.content.isEmpty {
                            // Pulsation de réflexion liquide
                            HStack(spacing: 6) {
                                ForEach(0..<3) { i in
                                    Circle()
                                        .fill(profile.currentMood.accentColors.first ?? Color.purple)
                                        .frame(width: 8, height: 8)
                                        .scaleEffect(1.1)
                                }
                            }
                            .padding(.vertical, 6)
                        } else {
                            MarkdownTextView(text: message.content, accentColor: profile.currentMood.accentColors.first ?? .purple)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .liquidGlass(cornerRadius: 20, glowColor: profile.currentMood.accentColors.first ?? Color(hex: "9D5CFF"), opacity: 0.12)
                }
                
                // Barre d'outils du compagnon
                if message.sender == .companion && !message.isStreaming && !message.content.isEmpty {
                    HStack(spacing: 14) {
                        if let mood = message.moodResonance {
                            HStack(spacing: 4) {
                                Text(mood.emoji)
                                Text(mood.rawValue)
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .liquidGlassPill(glowColor: mood.accentColors.first ?? .purple)
                        }
                        
                        Spacer()
                        
                        Button {
                            onReadAloud()
                            HapticsService.light()
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(6)
                                .liquidGlass(cornerRadius: 8, opacity: 0.08)
                        }
                        
                        Button {
                            UIPasteboard.general.string = message.content
                            HapticsService.light()
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(6)
                                .liquidGlass(cornerRadius: 8, opacity: 0.08)
                        }
                        
                        ShareLink(item: message.content) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(6)
                                .liquidGlass(cornerRadius: 8, opacity: 0.08)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            
            if message.sender != .user {
                Spacer(minLength: 30)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}
