import SwiftUI

public struct MemoryCoreView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var selectedCategory: MemoryCategory?
    @State private var showAddSheet = false
    
    var filteredMemories: [MemoryItem] {
        appState.memories.filter { item in
            let matchesCategory = selectedCategory == nil || item.category == selectedCategory
            let matchesSearch = searchText.isEmpty ||
                item.key.localizedCaseInsensitiveContains(searchText) ||
                item.value.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackgroundView(
                    primaryColor: appState.theme.primaryAccent,
                    secondaryColor: appState.theme.secondaryAccent
                )
                
                VStack(spacing: 12) {
                    // Carte explicative
                    explanationBanner
                    
                    // Filtres par catégorie
                    categoryFilterBar
                    
                    // Liste des souvenirs
                    if filteredMemories.isEmpty {
                        emptyState
                    } else {
                        List {
                            ForEach(filteredMemories) { item in
                                memoryRow(item)
                                    .listRowBackground(Color.white.opacity(0.06))
                                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    let itemToDelete = filteredMemories[index]
                                    if let originalIdx = appState.memories.firstIndex(where: { $0.id == itemToDelete.id }) {
                                        appState.memories.remove(at: originalIdx)
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Rechercher dans les souvenirs...")
            .navigationTitle("Mémoire Centrale")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(appState.theme.primaryAccent)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddMemorySheet()
                    .environmentObject(appState)
            }
        }
    }
    
    private var explanationBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 24))
                .foregroundColor(appState.theme.primaryAccent)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Mémoire Évolutive Active")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                
                Text("\(appState.companionProfile.name) apprend et retient vos goûts et anecdotes au fil de vos échanges.")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
        }
        .padding(14)
        .liquidGlass(cornerRadius: 18, glowColor: appState.theme.primaryAccent, opacity: 0.1)
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }
    
    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    selectedCategory = nil
                    HapticsService.light()
                } label: {
                    Text("Tout (\(appState.memories.count))")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(selectedCategory == nil ? .white : .white.opacity(0.6))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedCategory == nil ? appState.theme.primaryAccent : Color.white.opacity(0.08))
                        .clipShape(Capsule())
                }
                
                ForEach(MemoryCategory.allCases) { cat in
                    let count = appState.memories.filter { $0.category == cat }.count
                    Button {
                        selectedCategory = cat
                        HapticsService.light()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: cat.iconName)
                            Text("\(cat.rawValue) (\(count))")
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(selectedCategory == cat ? .white : .white.opacity(0.6))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedCategory == cat ? appState.theme.primaryAccent : Color.white.opacity(0.08))
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func memoryRow(_ item: MemoryItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: item.category.iconName)
                .font(.system(size: 18))
                .foregroundColor(appState.theme.primaryAccent)
                .frame(width: 28, height: 28)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.key)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Text(item.value)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(item.category.rawValue)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            Spacer()
            
            Button {
                appState.toggleMemoryActive(item.id)
                HapticsService.light()
            } label: {
                Image(systemName: item.isActive ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(item.isActive ? .green : .white.opacity(0.3))
            }
        }
        .padding(.vertical, 4)
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "sparkles.rectangle.stack")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.3))
            Text("Aucun souvenir dans cette section")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            Text("Ajoutez des faits manuellement ou laissez \(appState.companionProfile.name) les découvrir au fil des discussions.")
                .font(.caption)
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }
}
