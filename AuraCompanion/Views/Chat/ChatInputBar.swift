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
                            .frame(width: 58, height: 58)
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
                                .background(Circle().fill(Color.black.opacity(0.7)))
                        }
                        .offset(x: 5, y: -5)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
            }
            
            // Visualiseur vocal
            if viewModel.speechService.isRecording {
                HStack(spacing: 12) {
                    WaveformView(audioLevel: viewModel.speechService.audioLevel, tint: appState.theme.primaryAccent)
                    
                    Text("À votre écoute...")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button {
                        viewModel.toggleVoiceDictation()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 16)
            }
            
            // Barre principale
            HStack(alignment: .bottom, spacing: 8) {
                // Bouton Photo Apple PhotosPicker
                PhotosPicker(
                    selection: $viewModel.selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(width: 38, height: 38)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .onChange(of: viewModel.selectedItem) { newItem in
                    Task {
                        await viewModel.handleSelectedPhoto(newItem)
                    }
                }
                
                // Champ texte adaptatif
                TextField("Message à \(appState.companionProfile.name)...", text: $viewModel.inputText, axis: .vertical)
                    .lineLimit(1...5)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(18)
                
                // Bouton Dictée vocale
                Button {
                    viewModel.toggleVoiceDictation()
                } label: {
                    Image(systemName: viewModel.speechService.isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(viewModel.speechService.isRecording ? .red : .secondary)
                        .frame(width: 38, height: 38)
                        .background(.ultraThinMaterial)
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
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 38, height: 38)
                    .background(
                        LinearGradient(
                            colors: [appState.theme.primaryAccent, appState.theme.secondaryAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                }
                .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && viewModel.selectedImageData == nil || viewModel.isGenerating)
                .opacity((viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && viewModel.selectedImageData == nil) ? 0.4 : 1.0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
    }
}
