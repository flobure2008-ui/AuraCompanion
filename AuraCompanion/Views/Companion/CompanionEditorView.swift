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
                LiquidBackgroundView(
                    primaryColor: viewModel.profile.currentMood.accentColors.first ?? appState.theme.primaryAccent,
                    secondaryColor: appState.theme.secondaryAccent
                )
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Section Identité
                        identitySection
                        
                        // Section Archétypes
                        archetypesSection
                        
                        // Section Jauges de Personnalité
                        personalitySlidersSection
                        
                        // Section Voix & Synthèse
                        voiceSection
                        
                        // Section Directives Secrètes
                        instructionsSection
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Personnaliser Aura")
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
            Text("Identité & Rôle")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Prénom du compagnon").font(.caption).foregroundColor(.white.opacity(0.6))
                TextField("Nom", text: $viewModel.profile.name)
                    .padding(12)
                    .liquidGlass(cornerRadius: 14, opacity: 0.1)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Titre / Rôle").font(.caption).foregroundColor(.white.opacity(0.6))
                TextField("Titre", text: $viewModel.profile.title)
                    .padding(12)
                    .liquidGlass(cornerRadius: 14, opacity: 0.1)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Bio & Personnalité").font(.caption).foregroundColor(.white.opacity(0.6))
                TextField("Bio", text: $viewModel.profile.bio, axis: .vertical)
                    .lineLimit(2...4)
                    .padding(12)
                    .liquidGlass(cornerRadius: 14, opacity: 0.1)
                    .foregroundColor(.white)
            }
        }
        .padding(18)
        .liquidGlass(cornerRadius: 22, glowColor: appState.theme.primaryAccent, opacity: 0.1)
    }
    
    // MARK: - Archétypes
    private var archetypesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Archétypes Prédéfinis")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
            
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
                                    .foregroundColor(.white.opacity(0.75))
                                    .lineLimit(3)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(width: 190, height: 100)
                            .padding(14)
                            .liquidGlass(
                                cornerRadius: 18,
                                glowColor: viewModel.profile.archetype == archetype ? appState.theme.primaryAccent : Color.white.opacity(0.1),
                                opacity: viewModel.profile.archetype == archetype ? 0.25 : 0.08
                            )
                        }
                    }
                }
            }
            
            // Relation
            VStack(alignment: .leading, spacing: 6) {
                Text("Nature de la relation").font(.caption).foregroundColor(.white.opacity(0.6))
                Picker("Relation", selection: $viewModel.profile.relationshipType) {
                    ForEach(RelationshipType.allCases) { rel in
                        Text(rel.rawValue).tag(rel)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding(18)
        .liquidGlass(cornerRadius: 22, glowColor: appState.theme.primaryAccent, opacity: 0.1)
    }
    
    // MARK: - Jauges de Personnalité
    private var personalitySlidersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Jauges de Comportement")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
            
            sliderRow(title: "Chaleur & Proximité", value: $viewModel.profile.warmthLevel, icon: "heart.fill", color: .pink)
            sliderRow(title: "Humour & Ironie", value: $viewModel.profile.humorLevel, icon: "face.smiling.fill", color: .yellow)
            sliderRow(title: "Empathie & Écoute", value: $viewModel.profile.empathyLevel, icon: "sparkles", color: .purple)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Verbosité").font(.caption).foregroundColor(.white.opacity(0.6))
                Picker("Verbosité", selection: $viewModel.profile.verbosity) {
                    ForEach(VerbosityLevel.allCases) { v in
                        Text(v.rawValue).tag(v)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding(18)
        .liquidGlass(cornerRadius: 22, glowColor: appState.theme.primaryAccent, opacity: 0.1)
    }
    
    private func sliderRow(title: String, value: Binding<Double>, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: icon).foregroundColor(color)
                Text(title).font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                Spacer()
                Text("\(Int(value.wrappedValue * 100))%")
                    .font(.system(size: 13, weight: .bold))
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
                Text("Voix & Cadence")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                Button {
                    viewModel.testVoiceSample()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.isTestingVoice ? "stop.fill" : "play.fill")
                        Text(viewModel.isTestingVoice ? "Stop" : "Écouter")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .liquidGlass(cornerRadius: 14, glowColor: appState.theme.primaryAccent, opacity: 0.3)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Timbre vocal (Pitch)").font(.caption).foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text(String(format: "%.2f", viewModel.profile.voicePitch)).font(.caption.bold()).foregroundColor(.white)
                }
                Slider(value: $viewModel.profile.voicePitch, in: 0.7...1.4)
                    .tint(appState.theme.primaryAccent)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Vitesse de parole").font(.caption).foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text(String(format: "%.2f", viewModel.profile.voiceRate)).font(.caption.bold()).foregroundColor(.white)
                }
                Slider(value: $viewModel.profile.voiceRate, in: 0.35...0.7)
                    .tint(appState.theme.primaryAccent)
            }
        }
        .padding(18)
        .liquidGlass(cornerRadius: 22, glowColor: appState.theme.primaryAccent, opacity: 0.1)
    }
    
    // MARK: - Directives
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Consignes Secrètes")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
            
            Text("Instructions prioritaires injectées en permanence dans l'esprit du compagnon.")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            
            TextField("Ex: Appelle-moi toujours par mon surnom, réponds avec un ton mystérieux...", text: $viewModel.profile.customInstructions, axis: .vertical)
                .lineLimit(3...5)
                .padding(12)
                .liquidGlass(cornerRadius: 14, opacity: 0.1)
                .foregroundColor(.white)
        }
        .padding(18)
        .liquidGlass(cornerRadius: 22, glowColor: appState.theme.primaryAccent, opacity: 0.1)
    }
}
