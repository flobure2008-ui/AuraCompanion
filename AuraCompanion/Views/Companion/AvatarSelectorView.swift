import SwiftUI
import PhotosUI

public struct AvatarSelectorView: View {
    @Binding var selectedPreset: AvatarPreset
    @Binding var customEmoji: String
    @Binding var customImageData: Data?
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    let columns = [
        GridItem(.adaptive(minimum: 75), spacing: 14)
    ]
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Apparence & Hologramme")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
            
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(AvatarPreset.allCases) { preset in
                    Button {
                        selectedPreset = preset
                        HapticsService.light()
                    } label: {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: preset.gradientColors,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 54, height: 54)
                                
                                Image(systemName: preset.symbolIcon)
                                    .font(.system(size: 22))
                                    .foregroundColor(.white)
                            }
                            .overlay(
                                Circle()
                                    .stroke(selectedPreset == preset ? Color.white : Color.clear, lineWidth: 2.5)
                            )
                            .shadow(color: selectedPreset == preset ? preset.gradientColors.first!.opacity(0.6) : .clear, radius: 8)
                            
                            Text(preset.rawValue)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(selectedPreset == preset ? 1.0 : 0.6))
                                .lineLimit(1)
                        }
                    }
                }
            }
            
            // Si Emoji personnalisé
            if selectedPreset == .customEmoji {
                HStack {
                    Text("Choisissez un émoji :")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.8))
                    
                    TextField("Emoji", text: $customEmoji)
                        .font(.system(size: 24))
                        .frame(width: 60)
                        .multilineTextAlignment(.center)
                        .padding(6)
                        .glassCard(cornerRadius: 10)
                }
                .padding(.top, 6)
            }
            
            // Si Photo personnalisée
            if selectedPreset == .customPhoto {
                HStack(spacing: 12) {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        HStack(spacing: 6) {
                            Image(systemName: "photo")
                            Text("Choisir une image")
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .glassCard(cornerRadius: 12)
                    }
                    .onChange(of: selectedPhotoItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                customImageData = data
                            }
                        }
                    }
                    
                    if let data = customImageData, let uiImg = UIImage(data: data) {
                        Image(uiImage: uiImg)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                    }
                }
                .padding(.top, 6)
            }
        }
    }
}
