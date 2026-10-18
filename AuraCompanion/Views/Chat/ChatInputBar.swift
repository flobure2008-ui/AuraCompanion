import SwiftUI
import PhotosUI

public struct ChatInputBar: View {
    @ObservedObject var viewModel: ChatViewModel
    @ObservedObject var appState: AppState
    
    public var body: some View {
        VStack(spacing: 8) {
            // Aperçu de la photo sélectionnée
            if let imgData = viewModel.selectedImageData, let uiImage = UIImage(data: imgData) {
                HStack {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.3), lineWidth: 1))
                        
                        Button {
                            withAnimation {
                                viewModel.selectedImageData = nil
                                viewModel.selectedItem = nil
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.black.opacity(0.6)))
                        }
                        .offset(x: 6, y: -6)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            
            // Visualiseur vocal si le micro enregistre
            if viewModel.speechService.isRecording {
                HStack(spacing: 12) {
                    WaveformView(audioLevel: viewModel.speechService.audioLevel, tint: appState.theme.primaryAccent)
                    
                    Text("Dictée vocale en cours...")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Button {
                        viewModel.toggleVoiceDictation()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .glassCard(cornerRadius: 16)
                .padding(.horizontal, 12)
            }
            
            // Barre principale
            HStack(alignment: .bottom, spacing: 10) {
                // Bouton Photo
                PhotosPicker(
                    selection: $viewModel.selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white.opacity(0.75))
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Circle())
                }
                .onChange(of: viewModel.selectedItem) { newItem in
                    Task {
                        await viewModel.handleSelectedPhoto(newItem)
                    }
                }
                
                // Champ texte
                TextField("Message à \(appState.companionProfile.name)...", text: $viewModel.inputText, axis: .vertical)
                    .lineLimit(1...5)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.07))
                    .cornerRadius(20)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                
                // Bouton Dictée vocale
                Button {
                    viewModel.toggleVoiceDictation()
                } label: {
                    Image(systemName: viewModel.speechService.isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 18))
                        .foregroundColor(viewModel.speechService.isRecording ? .red : .white.opacity(0.8))
                        .frame(width: 40, height: 40)
                        .background(viewModel.speechService.isRecording ? Color.red.opacity(0.2) : Color.white.opacity(0.08))
                        .clipShape(Circle())
                }
                
                // Bouton Envoyer
                Button {
                    Task {
                        await viewModel.sendMessage(appState: appState)
                    }
                } label: {
                    Group {
                        if viewModel.isGenerating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 40, height: 40)
                    .background(
                        LinearGradient(
                            colors: [appState.theme.primaryAccent, appState.theme.secondaryAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: appState.theme.primaryAccent.opacity(0.5), radius: 8, x: 0, y: 3)
                }
                .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && viewModel.selectedImageData == nil || viewModel.isGenerating)
                .opacity((viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && viewModel.selectedImageData == nil) ? 0.5 : 1.0)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .glassCard(cornerRadius: 26)
            .padding(.horizontal, 10)
            .padding(.bottom, 6)
        }
    }
}
