import SwiftUI

public struct AddMemorySheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var category: MemoryCategory = .userFact
    @State private var key: String = ""
    @State private var value: String = ""
    
    public var body: some View {
        NavigationStack {
            ZStack {
                appState.theme.backgroundGradient.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Catégorie").font(.caption).foregroundColor(.white.opacity(0.7))
                        Picker("Catégorie", selection: $category) {
                            ForEach(MemoryCategory.allCases) { cat in
                                Text(cat.rawValue).tag(cat)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(12)
                        .glassCard(cornerRadius: 12)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Sujet / Clé").font(.caption).foregroundColor(.white.opacity(0.7))
                        TextField("Ex: Ville d'enfance, Auteur préféré...", text: $key)
                            .padding(12)
                            .glassCard(cornerRadius: 12)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Détail / Souvenir").font(.caption).foregroundColor(.white.opacity(0.7))
                        TextField("Ex: Passionné d'astrophysique et adore la science-fiction", text: $value, axis: .vertical)
                            .lineLimit(3...5)
                            .padding(12)
                            .glassCard(cornerRadius: 12)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Nouveau Souvenir")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") {
                        let newItem = MemoryItem(
                            category: category,
                            key: key.trimmingCharacters(in: .whitespacesAndNewlines),
                            value: value.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        appState.addMemory(newItem)
                        HapticsService.success()
                        dismiss()
                    }
                    .disabled(key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .foregroundColor(appState.theme.primaryAccent)
                }
            }
        }
    }
}
