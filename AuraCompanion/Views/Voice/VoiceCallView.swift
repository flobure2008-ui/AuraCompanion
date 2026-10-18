import SwiftUI

public struct VoiceCallView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = VoiceCallViewModel()
    
    public var body: some View {
        ZStack {
            // Arrière-plan spatial sombre
            appState.theme.backgroundGradient
                .ignoresSafeArea()
            
            VStack {
                // Barre supérieure
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(viewModel.state == .listening ? Color.green : Color.purple)
                                .frame(width: 8, height: 8)
                            
                            Text(viewModel.state.label)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Text(appState.companionProfile.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button {
                        viewModel.endCall()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                // Orbe Cosmique Interactif
                AmbientOrbView(
                    colors: appState.companionProfile.avatarPreset.gradientColors,
                    state: viewModel.state,
                    scale: viewModel.orbScale
                )
                
                Spacer()
                
                // Sous-titres dynamiques
                VStack(spacing: 12) {
                    if !viewModel.lastUserSpeech.isEmpty && viewModel.state == .listening {
                        Text("\"\(viewModel.lastUserSpeech)\"")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)
                            .transition(.opacity)
                    }
                    
                    if !viewModel.lastCompanionSpeech.isEmpty && viewModel.state == .speaking {
                        Text(viewModel.lastCompanionSpeech)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(4)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .glassCard(cornerRadius: 16)
                            .padding(.horizontal, 16)
                    }
                }
                .frame(minHeight: 80)
                
                // Barre de contrôles d'appel
                HStack(spacing: 32) {
                    // Mute / Reprise
                    Button {
                        viewModel.isMuted.toggle()
                        HapticsService.medium()
                        if viewModel.isMuted {
                            viewModel.speechService.stopListening()
                        } else {
                            viewModel.startListeningTurn(appState: appState)
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: viewModel.isMuted ? "mic.slash.fill" : "mic.fill")
                                .font(.system(size: 20))
                                .foregroundColor(viewModel.isMuted ? .red : .white)
                                .frame(width: 56, height: 56)
                                .background(Color.white.opacity(0.12))
                                .clipShape(Circle())
                            
                            Text(viewModel.isMuted ? "Muet" : "Actif")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    // Raccrocher
                    Button {
                        HapticsService.heavy()
                        viewModel.endCall()
                        dismiss()
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "phone.down.fill")
                                .font(.system(size: 26))
                                .foregroundColor(.white)
                                .frame(width: 68, height: 68)
                                .background(Color.red)
                                .clipShape(Circle())
                                .shadow(color: Color.red.opacity(0.5), radius: 10, x: 0, y: 4)
                            
                            Text("Terminer")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    // Mode dialogue continu
                    Button {
                        viewModel.continuousDialogue.toggle()
                        HapticsService.light()
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: viewModel.continuousDialogue ? "repeat.circle.fill" : "repeat.circle")
                                .font(.system(size: 20))
                                .foregroundColor(viewModel.continuousDialogue ? appState.theme.primaryAccent : .white.opacity(0.5))
                                .frame(width: 56, height: 56)
                                .background(Color.white.opacity(0.12))
                                .clipShape(Circle())
                            
                            Text("Continu")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                .padding(.bottom, 36)
            }
        }
        .task {
            await viewModel.startSession(appState: appState)
        }
        .onDisappear {
            viewModel.endCall()
        }
    }
}
