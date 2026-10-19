import SwiftUI

public struct ChatView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ChatViewModel()
    @State private var showVoiceCall = false
    @State private var showSessionList = false
    
    public var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackgroundView(
                    primaryColor: appState.theme.primaryAccent,
                    secondaryColor: appState.theme.secondaryAccent
                )
                
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if appState.currentSession.messages.isEmpty {
                                emptyStateStarters
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
                        .padding(.vertical, 14)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: appState.currentSession.messages.count) { _ in
                        if let lastId = appState.currentSession.messages.last?.id {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) {
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
            }
            // Saisie dockée de façon native avec le clavier Apple
            .safeAreaInset(edge: .bottom) {
                ChatInputBar(viewModel: viewModel, appState: appState)
                    .background(.ultraThinMaterial.opacity(0.85))
            }
            .navigationTitle(appState.companionProfile.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 8) {
                        LivingCompanionOrb(
                            mood: appState.companionProfile.currentMood,
                            size: 32
                        )
                        
                        // Badge d'humeur natif Apple
                        Text(appState.companionProfile.currentMood.emoji)
                            .font(.system(size: 13))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 8) {
                        // Bouton Appel Vocal direct
                        Button {
                            HapticsService.medium()
                            showVoiceCall = true
                        } label: {
                            Image(systemName: "phone.bubble.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(hex: "00F0FF"))
                                .padding(8)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        
                        // Bouton Historique des conversations
                        Button {
                            HapticsService.light()
                            showSessionList = true
                        } label: {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                }
            }
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
    
    // MARK: - Écran d'accueil de conversation Apple ContentUnavailableView
    private var emptyStateStarters: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 30)
            
            LivingCompanionOrb(
                mood: appState.companionProfile.currentMood,
                size: 110
            )
            
            VStack(spacing: 6) {
                Text(appState.companionProfile.name)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Text(appState.companionProfile.bio)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
            }
            
            VStack(spacing: 10) {
                starterCard(icon: "sparkles", text: "Dis-moi une réflexion philosophique pour débuter la journée")
                starterCard(icon: "heart.fill", text: "Comment te sens-tu dans notre relation aujourd'hui ?")
                starterCard(icon: "brain.head.profile", text: "Fais-moi un récapitulatif de ce que tu retiens sur moi")
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
    
    private func starterCard(icon: String, text: String) -> some View {
        Button {
            viewModel.inputText = text
            Task {
                await viewModel.sendMessage(appState: appState)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(appState.theme.primaryAccent)
                
                Text(text)
                    .font(.system(size: 13.5, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(14)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Session History Sheet Apple Native
public struct SessionHistorySheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        _ = appState.createNewSession()
                        HapticsService.medium()
                        dismiss()
                    } label: {
                        Label("Nouvelle conversation", systemImage: "plus.bubble.fill")
                            .font(.headline)
                            .foregroundColor(appState.theme.primaryAccent)
                    }
                }
                
                Section("Historique") {
                    ForEach(appState.sessions) { session in
                        Button {
                            appState.currentSessionId = session.id
                            HapticsService.light()
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 3) {
                                HStack {
                                    Text(session.title)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if session.id == appState.currentSessionId {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(appState.theme.primaryAccent)
                                    }
                                }
                                Text(session.previewSnippet)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            .padding(.vertical, 3)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            appState.deleteSession(appState.sessions[index])
                        }
                    }
                }
            }
            .navigationTitle("Conversations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }
}
