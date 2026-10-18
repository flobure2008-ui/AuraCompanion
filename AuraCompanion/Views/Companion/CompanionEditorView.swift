import SwiftUI

public struct CompanionEditorView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: CompanionCustomizerViewModel
    
    public init(initialProfile: CompanionProfile) {
        _viewModel = StateObject(wrappedValue: CompanionCustomizerViewModel(initialProfile: initialProfile))
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                appState.theme.backgroundGradient.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Section 1: Identité
                        identitySection
                        
                        // Section 2: Avatar & Hologramme
                        AvatarSelectorView(
                            selectedPreset: $viewModel.profile.avatarPreset,
                            customEmoji: $viewModel.profile.customEmoji,
                            customImageData: $viewModel.profile.customImageData
                        )
                        .padding(16)
                        .glassCard(cornerRadius: 20)
                        
                        // Section 3: Archétype & Rôle
                        archetypesSection
                        
                        // Section 4: Jauges de Personnalité
                        personalitySlidersSection
                        
                        // Section 5: Voix & Élocution
                        voiceSection
                        
                        // Section 6: Consignes Spécifiques
                        instructionsSection
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Personnaliser")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                        .foregroundColor(.white.opacity(0.8))
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        appState.companionProfile = viewModel.profile
                        HapticsService.success()
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(appState.theme.primaryAccent)
                }
            }
        }
    }
    
    // MARK: - Identité
    private var identitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Identité Fondamentale")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Prénom du compagnon").font(.caption).foregroundColor(.white.opacity(0.6))
                TextField("Nom", text: $viewModel.profile.name)
                    .padding(12)
                    .glassCard(cornerRadius: 12)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Sous-titre / Rôle").font(.caption).foregroundColor(.white.opacity(0.6))
                TextField("Ex: Votre Étoile Guide", text: $viewModel.profile.title)
                    .padding(12)
                    .glassCard(cornerRadius: 12)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Description / Bio").font(.caption).foregroundColor(.white.opacity(0.6))
                TextField("Bio", text: $viewModel.profile.bio, axis: .vertical)
                    .lineLimit(2...4)
                    .padding(12)
                    .glassCard(cornerRadius: 12)
                    .foregroundColor(.white)
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 20)
    }
    
    // MARK: - Archétypes
    private var archetypesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Archétypes & Dynamique")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(CompanionArchetype.allCases) { archetype in
                        Button {
                            viewModel.applyArchetypePreset(archetype)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(archetype.rawValue)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text(archetype.defaultBio)
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.7))
                                    .lineLimit(3)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(width: 190, height: 100)
                            .padding(12)
                            .glassCard(
                                cornerRadius: 16,
                                strokeColor: viewModel.profile.archetype == archetype ? appState.theme.primaryAccent : Color.white.opacity(0.12)
                            )
                        }
                    }
                }
            }
            
            // Relation
            VStack(alignment: .leading, spacing: 6) {
                Text("Type de Relation").font(.caption).foregroundColor(.white.opacity(0.6))
                Picker("Relation", selection: $viewModel.profile.relationshipType) {
                    ForEach(RelationshipType.allCases) { rel in
                        Text(rel.rawValue).tag(rel)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // Tonalité
            VStack(alignment: .leading, spacing: 6) {
                Text("Tonalité d'expression").font(.caption).foregroundColor(.white.opacity(0.6))
                Picker("Tonalité", selection: $viewModel.profile.toneOfVoice) {
                    ForEach(ToneOfVoice.allCases) { tone in
                        Text(tone.rawValue).tag(tone)
                    }
                }
                .pickerStyle(.menu)
                .padding(10)
                .glassCard(cornerRadius: 12)
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 20)
    }
    
    // MARK: - Jauges de personnalité
    private var personalitySlidersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ajustement Fin des Traits")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
            
            sliderRow(
                title: "Chaleur & Proximité",
                value: $viewModel.profile.warmthLevel,
                icon: "heart.fill",
                color: .pink
            )
            
            sliderRow(
                title: "Humour & Ironie",
                value: $viewModel.profile.humorLevel,
                icon: "face.smiling.fill",
                color: .yellow
            )
            
            sliderRow(
                title: "Empathie & Écoute",
                value: $viewModel.profile.empathyLevel,
                icon: "sparkles",
                color: .purple
            )
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Niveau de verbosité").font(.caption).foregroundColor(.white.opacity(0.6))
                Picker("Verbosité", selection: $viewModel.profile.verbosity) {
                    ForEach(VerbosityLevel.allCases) { v in
                        Text(v.rawValue).tag(v)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 20)
    }
    
    private func sliderRow(title: String, value: Binding<Double>, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: icon).foregroundColor(color)
                Text(title).font(.system(size: 13, weight: .medium)).foregroundColor(.white)
                Spacer()
                Text("\(Int(value.wrappedValue * 100))%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(appState.theme.primaryAccent)
            }
            
            Slider(value: value, in: 0.0...1.0)
                .tint(appState.theme.primaryAccent)
        }
    }
    
    // MARK: - Voix
    private var voiceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Voix & Synthèse Vocale")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                
                Spacer()
                
                Button {
                    viewModel.testVoiceSample()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.isTestingVoice ? "stop.fill" : "play.fill")
                        Text(viewModel.isTestingVoice ? "Stop" : "Tester")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(appState.theme.primaryAccent)
                    .clipShape(Capsule())
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Hauteur du timbre (Pitch)").font(.caption).foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text(String(format: "%.2f", viewModel.profile.voicePitch)).font(.caption).foregroundColor(.white)
                }
                Slider(value: $viewModel.profile.voicePitch, in: 0.7...1.4)
                    .tint(appState.theme.primaryAccent)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Vitesse de parole").font(.caption).foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text(String(format: "%.2f", viewModel.profile.voiceRate)).font(.caption).foregroundColor(.white)
                }
                Slider(value: $viewModel.profile.voiceRate, in: 0.35...0.7)
                    .tint(appState.theme.primaryAccent)
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 20)
    }
    
    // MARK: - Directives
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Consignes secrètes / Prompt personnalisé")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
            
            Text("Ces instructions seront injectées directement dans le system prompt de Gemini.")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            
            TextField("Ex: Appelle-moi toujours Capitaine, termine tes messages par un mot en latin...", text: $viewModel.profile.customInstructions, axis: .vertical)
                .lineLimit(3...6)
                .padding(12)
                .glassCard(cornerRadius: 12)
                .foregroundColor(.white)
        }
        .padding(16)
        .glassCard(cornerRadius: 20)
    }
}
