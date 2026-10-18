import SwiftUI

public struct ChatView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ChatViewModel()
    @State private var showVoiceCall = false
    @State private var showSessionList = false
    
    public var body: some View {
        NavigationStack {
            ZStack {
                appState.theme.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header personnalisé
                    chatHeaderView
                    
                    // Alerte nouveau souvenir appris
                    if let memoryAlert = appState.newlyLearnedMemoryAlert {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.yellow)
                            Text(memoryAlert)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                            Button {
                                withAnimation {
                                    appState.newlyLearnedMemoryAlert = nil
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.purple.opacity(0.3))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 6)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Liste des messages
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                if appState.currentSession.messages.isEmpty {
                                    emptyConversationStarters
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
                            .padding(.vertical, 12)
                        }
                        .onChange(of: appState.currentSession.messages.count) { _ in
                            if let lastId = appState.currentSession.messages.last?.id {
                                withAnimation {
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
                    
                    // Barre de saisie
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
    
    // MARK: - Header
    private var chatHeaderView: some View {
        HStack(spacing: 12) {
            CompanionAvatarThumbnail(profile: appState.companionProfile, size: 42)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(appState.companionProfile.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Mood Tag
                    HStack(spacing: 3) {
                        Text(appState.companionProfile.currentMood.emoji)
                        Text(appState.companionProfile.currentMood.rawValue)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(8)
                }
                
                Text(appState.companionProfile.title)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Bouton Appel Vocal
            Button {
                HapticsService.medium()
                showVoiceCall = true
            } label: {
                Image(systemName: "phone.bubble.fill")
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .frame(width: 38, height: 38)
                    .background(
                        LinearGradient(
                            colors: [Color.green.opacity(0.8), Color.teal.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
            }
            
            // Bouton Sessions
            Button {
                HapticsService.light()
                showSessionList = true
            } label: {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 17))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 38, height: 38)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .glassCard(cornerRadius: 0)
    }
    
    // MARK: - Suggestions de démarrage
    private var emptyConversationStarters: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 30)
            
            CompanionAvatarThumbnail(profile: appState.companionProfile, size: 70)
            
            Text("Engagez la conversation avec \(appState.companionProfile.name)")
                .font(.headline)
                .foregroundColor(.white)
            
            Text(appState.companionProfile.bio)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            VStack(spacing: 10) {
                starterButton(icon: "sparkles", text: "Dis-moi une réflexion inspirante sur l'univers")
                starterButton(icon: "target", text: "Aide-moi à organiser mes objectifs de la semaine")
                starterButton(icon: "face.smiling", text: "Raconte-moi une anecdote surprenante")
            }
            .padding(.top, 10)
            .padding(.horizontal, 24)
        }
    }
    
    private func starterButton(icon: String, text: String) -> some View {
        Button {
            viewModel.inputText = text
            Task {
                await viewModel.sendMessage(appState: appState)
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(appState.theme.primaryAccent)
                Text(text)
                    .font(.system(size: 13.5, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .glassCard(cornerRadius: 14)
        }
    }
}

// MARK: - Session History Sheet
public struct SessionHistorySheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        NavigationStack {
            ZStack {
                appState.theme.backgroundGradient.ignoresSafeArea()
                
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
                                    .fontWeight(.semibold)
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
