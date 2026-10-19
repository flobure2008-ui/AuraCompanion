import SwiftUI

public struct VoiceCallView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = VoiceCallViewModel()
    
    public var body: some View {
        ZStack {
            LiquidBackgroundView(
                primaryColor: appState.companionProfile.currentMood.accentColors.first ?? Color(hex: "00F0FF"),
                secondaryColor: appState.theme.primaryAccent
            )
            
            VStack {
                // Barre Supérieure
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(viewModel.state == .listening ? Color.green : Color.purple)
                                .frame(width: 8, height: 8)
                            
                            Text(viewModel.state.label)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white.opacity(0.85))
                        }
                        
                        Text(appState.companionProfile.name)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button {
                        viewModel.endCall()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 40, height: 40)
                            .liquidGlass(cornerRadius: 20, opacity: 0.15)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                // Orbe Vivant Réactif
                LivingCompanionOrb(
                    mood: appState.companionProfile.currentMood,
                    isSpeaking: viewModel.state == .speaking,
                    isListening: viewModel.state == .listening,
                    audioLevel: viewModel.speechService.audioLevel,
                    size: 210
                )
                
                Spacer()
                
                // Sous-titres en Verre Liquide
                VStack(spacing: 12) {
                    if !viewModel.lastUserSpeech.isEmpty && viewModel.state == .listening {
                        Text("\"\(viewModel.lastUserSpeech)\"")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    
                    if !viewModel.lastCompanionSpeech.isEmpty && viewModel.state == .speaking {
                        Text(viewModel.lastCompanionSpeech)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(4)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .liquidGlass(cornerRadius: 20, glowColor: appState.companionProfile.currentMood.accentColors.first ?? .purple, opacity: 0.15)
                            .padding(.horizontal, 20)
                    }
                }
                .frame(minHeight: 90)
                
                // Contrôles en Verre Liquide
                HStack(spacing: 30) {
                    // Muet / Actif
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
                                .frame(width: 60, height: 60)
                                .liquidGlass(cornerRadius: 30, glowColor: viewModel.isMuted ? .red : .white, opacity: 0.15)
                            
                            Text(viewModel.isMuted ? "Muet" : "Actif")
                                .font(.caption2.bold())
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .buttonStyle(LiquidButtonStyle())
                    
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
                                .frame(width: 72, height: 72)
                                .background(Color.red)
                                .clipShape(Circle())
                                .shadow(color: Color.red.opacity(0.55), radius: 14, y: 6)
                            
                            Text("Terminer")
                                .font(.caption2.bold())
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .buttonStyle(LiquidButtonStyle())
                    
                    // Dialogue Continu
                    Button {
                        viewModel.continuousDialogue.toggle()
                        HapticsService.light()
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: viewModel.continuousDialogue ? "repeat.circle.fill" : "repeat.circle")
                                .font(.system(size: 22))
                                .foregroundColor(viewModel.continuousDialogue ? appState.theme.primaryAccent : .white.opacity(0.5))
                                .frame(width: 60, height: 60)
                                .liquidGlass(cornerRadius: 30, glowColor: appState.theme.primaryAccent, opacity: 0.15)
                            
                            Text("Continu")
                                .font(.caption2.bold())
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .buttonStyle(LiquidButtonStyle())
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
