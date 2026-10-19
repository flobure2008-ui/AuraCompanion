import SwiftUI

public struct ChatView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ChatViewModel()
    @State private var showVoiceCall = false
    @State private var showSessionList = false
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Fond liquide animé dynamique
                LiquidBackgroundView(
                    primaryColor: appState.theme.primaryAccent,
                    secondaryColor: appState.theme.secondaryAccent
                )
                
                VStack(spacing: 0) {
                    // Header Verre Liquide
                    liquidHeader
                    
                    // Alerte nouveau souvenir mémorisé
                    if let memoryAlert = appState.newlyLearnedMemoryAlert {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.yellow)
                            Text(memoryAlert)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                            Spacer()
                            Button {
                                withAnimation { appState.newlyLearnedMemoryAlert = nil }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .liquidGlass(cornerRadius: 16, glowColor: .yellow, opacity: 0.15)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Flux de messages
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 14) {
                                if appState.currentSession.messages.isEmpty {
                                    liquidEmptyStarters
                                } else {
                                    ForEach(appState.currentSession.messages) { message in
                                        MessageBubbleView(
                                            message: message,
                                            profile: appState.companionProfile,
                                            onReadAloud: {
                                                viewModel.readAloud(message: message, profile: appState.companionProfile)
                                            }
                                        )
                                        .id(message.id)
                                    }
                                }
                            }
                            .padding(.vertical, 16)
                        }
                        .onChange(of: appState.currentSession.messages.count) { _ in
                            if let lastId = appState.currentSession.messages.last?.id {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    proxy.scrollTo(lastId, anchor: .bottom)
                                }
                            }
                        }
                        .onChange(of: appState.currentSession.messages.last?.content) { _ in
                            if let lastId = appState.currentSession.messages.last?.id {
                                proxy.scrollTo(lastId, anchor: .bottom)
                            }
                        }
                    }
                    
                    // Barre de saisie Verre Liquide
                    ChatInputBar(viewModel: viewModel, appState: appState)
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showVoiceCall) {
                VoiceCallView()
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showSessionList) {
                SessionHistorySheet()
                    .environmentObject(appState)
            }
            .alert("Notice", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    // MARK: - Header Verre Liquide
    private var liquidHeader: some View {
        HStack(spacing: 12) {
            // Orbe miniature vivant
            LivingCompanionOrb(
                mood: appState.companionProfile.currentMood,
                isSpeaking: viewModel.playbackService.isSpeaking,
                isListening: viewModel.speechService.isRecording,
                audioLevel: viewModel.speechService.audioLevel,
                size: 44
            )
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(appState.companionProfile.name)
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Capsule d'humeur en verre liquide
                    HStack(spacing: 4) {
                        Text(appState.companionProfile.currentMood.emoji)
                        Text(appState.companionProfile.currentMood.rawValue)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .liquidGlassPill(glowColor: appState.companionProfile.currentMood.accentColors.first ?? .purple)
                }
                
                Text(appState.provider == .freeBuiltIn ? "Mode Gratuit Actif (Sans Clé)" : appState.companionProfile.title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(appState.provider == .freeBuiltIn ? .green.opacity(0.9) : .white.opacity(0.6))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Bouton Appel Vocal Verre Liquide
            Button {
                HapticsService.medium()
                showVoiceCall = true
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "00F0FF"), Color(hex: "9D5CFF")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 42, height: 42)
                        .shadow(color: Color(hex: "00F0FF").opacity(0.4), radius: 10)
                    
                    Image(systemName: "phone.bubble.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(LiquidButtonStyle())
            
            // Bouton Historique
            Button {
                HapticsService.light()
                showSessionList = true
            } label: {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 17))
                    .foregroundColor(.white.opacity(0.85))
                    .frame(width: 42, height: 42)
                    .liquidGlass(cornerRadius: 21, glowColor: .white.opacity(0.2))
            }
            .buttonStyle(LiquidButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .liquidGlass(cornerRadius: 0, glowColor: appState.theme.primaryAccent, opacity: 0.1)
    }
    
    // MARK: - Suggestions Verre Liquide
    private var liquidEmptyStarters: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 20)
            
            LivingCompanionOrb(
                mood: appState.companionProfile.currentMood,
                size: 120
            )
            
            VStack(spacing: 6) {
                Text(appState.companionProfile.name)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                
                Text(appState.companionProfile.bio)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 32)
            }
            
            VStack(spacing: 12) {
                liquidStarterButton(icon: "sparkles", text: "Dis-moi ce que tu ressens en ce moment")
                liquidStarterButton(icon: "brain.head.profile", text: "Que te rappelles-tu sur moi jusqu'ici ?")
                liquidStarterButton(icon: "lightbulb.fill", text: "Propose-moi une idée créative pour ma journée")
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
    
    private func liquidStarterButton(icon: String, text: String) -> some View {
        Button {
            viewModel.inputText = text
            Task {
                await viewModel.sendMessage(appState: appState)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(appState.theme.primaryAccent)
                    .font(.system(size: 16))
                
                Text(text)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.92))
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .liquidGlass(cornerRadius: 18, glowColor: appState.theme.primaryAccent, opacity: 0.08)
        }
        .buttonStyle(LiquidButtonStyle())
    }
}

// MARK: - Session History Sheet
public struct SessionHistorySheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackgroundView(
                    primaryColor: appState.theme.primaryAccent,
                    secondaryColor: appState.theme.secondaryAccent
                )
                
                List {
                    Section {
                        Button {
                            _ = appState.createNewSession()
                            HapticsService.medium()
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "plus.bubble.fill")
                                    .foregroundColor(appState.theme.primaryAccent)
                                Text("Nouvelle conversation")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.08))
                    }
                    
                    Section("Conversations précédentes") {
                        ForEach(appState.sessions) { session in
                            Button {
                                appState.currentSessionId = session.id
                                HapticsService.light()
                                dismiss()
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(session.title)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.white)
                                        Spacer()
                                        if session.id == appState.currentSessionId {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(appState.theme.primaryAccent)
                                        }
                                    }
                                    Text(session.previewSnippet)
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.6))
                                        .lineLimit(1)
                                }
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(Color.white.opacity(0.06))
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                appState.deleteSession(appState.sessions[index])
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Conversations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
}
