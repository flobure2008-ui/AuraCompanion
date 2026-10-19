import SwiftUI
import PhotosUI

public struct ChatInputBar: View {
    @ObservedObject var viewModel: ChatViewModel
    @ObservedObject var appState: AppState
    
    public var body: some View {
        VStack(spacing: 8) {
            // Aperçu de la photo attachée
            if let imgData = viewModel.selectedImageData, let uiImage = UIImage(data: imgData) {
                HStack {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.white.opacity(0.4), lineWidth: 1))
                        
                        Button {
                            withAnimation {
                                viewModel.selectedImageData = nil
                                viewModel.selectedItem = nil
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.black.opacity(0.7)))
                        }
                        .offset(x: 6, y: -6)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            
            // Visualiseur vocal si enregistrement actif
            if viewModel.speechService.isRecording {
                HStack(spacing: 12) {
                    WaveformView(audioLevel: viewModel.speechService.audioLevel, tint: appState.theme.primaryAccent)
                    
                    Text("À votre écoute...")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        viewModel.toggleVoiceDictation()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .liquidGlass(cornerRadius: 18, glowColor: .green, opacity: 0.15)
                .padding(.horizontal, 14)
            }
            
            // Capsule principale de saisie en verre liquide
            HStack(alignment: .bottom, spacing: 10) {
                // Bouton Photo
                PhotosPicker(
                    selection: $viewModel.selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 19, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .frame(width: 42, height: 42)
                        .liquidGlass(cornerRadius: 21, opacity: 0.1)
                }
                .onChange(of: viewModel.selectedItem) { newItem in
                    Task {
                        await viewModel.handleSelectedPhoto(newItem)
                    }
                }
                
                // Champ texte
                TextField("Parlez avec \(appState.companionProfile.name)...", text: $viewModel.inputText, axis: .vertical)
                    .lineLimit(1...5)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    )
                
                // Bouton Micro
                Button {
                    viewModel.toggleVoiceDictation()
                } label: {
                    Image(systemName: viewModel.speechService.isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 17))
                        .foregroundColor(viewModel.speechService.isRecording ? .red : .white.opacity(0.85))
                        .frame(width: 42, height: 42)
                        .liquidGlass(
                            cornerRadius: 21,
                            glowColor: viewModel.speechService.isRecording ? .red : appState.theme.primaryAccent,
                            opacity: viewModel.speechService.isRecording ? 0.25 : 0.1
                        )
                }
                
                // Bouton Envoyer
                Button {
                    Task {
                        await viewModel.sendMessage(appState: appState)
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [appState.theme.primaryAccent, appState.theme.secondaryAccent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 42, height: 42)
                            .shadow(color: appState.theme.primaryAccent.opacity(0.5), radius: 10, y: 3)
                        
                        if viewModel.isGenerating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && viewModel.selectedImageData == nil || viewModel.isGenerating)
                .opacity((viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && viewModel.selectedImageData == nil) ? 0.45 : 1.0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .liquidGlass(cornerRadius: 28, glowColor: appState.theme.primaryAccent, opacity: 0.12)
            .padding(.horizontal, 12)
            .padding(.bottom, 6)
        }
    }
}
