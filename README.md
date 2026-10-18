# ✨ Aura — Compagnon IA Personnalisable pour iOS

**Aura** est une application iOS de pointe conçue en **SwiftUI moderne (iOS 17+ / iOS 18+)**, offrant l'expérience d'un compagnon d'intelligence artificielle hautement personnalisable, sensible et intime, propulsé par la famille de modèles **Google Gemini (1.5 Flash, 1.5 Pro et 2.0 Flash)**.

---

## 🌟 Points Forts & Fonctionnalités Clés

### 1. 🧠 Intégration Native de l'API Google Gemini
- **Streaming ultra-fluide en temps réel** : Décodage SSE direct des flux de tokens avec rendu machine à écrire sans blocage d'interface.
- **Multimodalité Vision** : Analysez instantanément des photos de votre pellicule ou de l'appareil photo avec Gemini 1.5.
- **Support multi-modèles** :
  - `Gemini 1.5 Flash` : Idéal pour les échanges quotidiens et les temps de réponse instantanés.
  - `Gemini 1.5 Pro` : Pour un raisonnement philosophique, complexe ou littéraire.
  - `Gemini 2.0 Flash (Experimental)` : Vitesse de pointe nouvelle génération.
- **Gestion sécurisée des clés** : Enregistrement local sécurisé sur l'appareil avec outil de validation / test en 1 clic.

### 2. 🎭 Personnalisation Extrême du Compagnon
- **Archétypes prédéfinis & sur-mesure** :
  - *Aura* : Bienveillante, empathique et à l'écoute.
  - *Nexus* : Esprit scientifique polymath et codeur de génie.
  - *Kael* : Sarcastique, ironique et doté d'une répartie affûtée.
  - *Sol* : Maître zen et stoïque apportant la sérénité.
  - *Vesper* : Conteur poétique cyberpunk.
  - *Ares* : Coach de vie exigeant qui combat la procrastination.
- **Jauges de personnalité fines (0 à 100%)** :
  - Chaleur & Proximité relationnelle
  - Humour & Ironie
  - Empathie & Écoute active
  - Verbosité (Concis, Équilibré ou Détaillé)
- **Hologrammes & Avatars procéduraux** : 8 presets dynamiques (Cosmic Nebula, Cyber Pulse, Quantum Core, Zen Blossom...) ou upload de photo personnalisée / émoji personnalisé.
- **Humeurs dynamiques en temps réel** : Joyeux, Pensif, Espiègle, Empathique, Concentré ou Calme, avec adaptation automatique des couleurs de l'aura.

### 3. 💾 Cœur de Mémoire Évolutive (LTM - Long Term Memory)
- **Extraction automatique intelligente** : Pendant vos échanges, un processus d'arrière-plan extrait les faits marquants (prénom, anecdotes, goûts, passions, objectifs) et les ajoute à la mémoire de votre compagnon.
- **Gestion totale par l'utilisateur** : Consultez, modifiez, désactivez ou supprimez des souvenirs à tout moment.
- **Injection contextuelle dynamique** : Les souvenirs actifs sont automatiquement injectés dans le *System Instruction* de Gemini pour assurer une continuité relationnelle parfaite.

### 4. 🎙️ Mode Appel Vocal Ambiant (Type Gemini Live / Siri)
- **Orbe holographique interactif** : Rendu graphique multicouche en canvas avec pulsation réactive au niveau audio en temps réel.
- **Reconnaissance vocale Speech-to-Text (`SFSpeechRecognizer`)** : Transcription en français et multilingue.
- **Synthèse Vocale (`AVSpeechSynthesizer`)** : Voix naturelle avec contrôle du pitch (timbre) et du débit de parole.
- **Dialogue continu mains-libres** : Relance automatique de l'écoute après chaque prise de parole du compagnon.

### 5. 🎨 Design Spatial & Expérience iOS Moderne
- Interface **Glassmorphism** avec flou d'arrière-plan `ultraThinMaterial`, lueurs néon subtiles et dégradés profonds.
- **5 Thèmes visuels complets** : *Cosmic Violet*, *Cyber Neon*, *Sunset Glow*, *Emerald Zen* et *Obsidian Noir (OLED)*.
- Formatage complet du **Markdown** avec coloration et copie de code en un tap.
- Retours haptiques immersifs (`UIImpactFeedbackGenerator`).
- Assistant de bienvenue (Onboarding) interactif en 3 étapes.
- Export et sauvegarde intégrale en format JSON.

---

## 📂 Architecture du Projet

```
AuraCompanion/
├── AuraCompanion.xcodeproj/            # Projet Xcode préconfiguré
├── Package.swift                       # Support Swift Package Manager
├── AuraCompanion/
│   ├── App/
│   │   ├── AuraCompanionApp.swift      # Point d'entrée de l'application
│   │   └── AppState.swift              # État global réactif
│   ├── Models/
│   │   ├── CompanionProfile.swift      # Profil, archétypes, humeurs & prompt builder
│   │   ├── ChatMessage.swift           # Messages & sessions de conversation
│   │   ├── MemoryItem.swift            # Modèle de mémoire à long terme
│   │   ├── GeminiModels.swift          # Enums & structures de requête / réponse Gemini
│   │   └── ThemeConfiguration.swift    # Moteur de thèmes visuels & hex colors
│   ├── Services/
│   │   ├── GeminiService.swift         # Client API Gemini (SSE Streaming + extraction)
│   │   ├── SpeechService.swift         # SFSpeechRecognizer + visualiseur de niveau audio
│   │   ├── AudioPlaybackService.swift  # AVSpeechSynthesizer pour la voix du compagnon
│   │   ├── StorageService.swift        # Persistance UserDefaults, JSON & export
│   │   └── HapticsService.swift        # Retours haptiques
│   ├── ViewModels/
│   │   ├── ChatViewModel.swift         # Gestion du chat, photos, dictée & streaming
│   │   ├── CompanionCustomizerViewModel.swift # Édition de la personnalité & test vocal
│   │   └── VoiceCallViewModel.swift    # Orchestration du mode appel vocal ambiant
│   ├── Views/
│   │   ├── MainTabView.swift           # Conteneur des 4 onglets principaux
│   │   ├── Chat/                       # Vue du chat, bulles, saisie & markdown
│   │   ├── Voice/                      # Vue plein écran d'appel vocal ambiant
│   │   ├── Companion/                  # Profil & éditeur de personnalité
│   │   ├── Memory/                     # Base de données des souvenirs
│   │   ├── Settings/                   # Configuration clé API, modèle & thèmes
│   │   ├── Onboarding/                 # Assistant de configuration initiale
│   │   └── Components/                 # Orbe animé, cartes de verre, visualiseur audio
│   └── Resources/
│       ├── Info.plist                  # Permissions Micro, Dictée vocale & Photos
│       └── Assets.xcassets             # Icône d'app & couleurs d'accent
└── README.md
```

---

## 🚀 Comment Lancer le Projet dans Xcode

1. Ouvrez le projet en double-cliquant sur :
   - `AuraCompanion.xcodeproj` **OU**
   - Ouvrez le dossier dans Xcode (`File > Open... > AuraCompanion`).
2. Sélectionnez un simulateur iOS (ex: iPhone 16 Pro sous iOS 17 ou iOS 18) ou votre iPhone physique.
3. Appuyez sur **Cmd + R** pour lancer l'application.
4. Au premier lancement, l'assistant d'onboarding vous guidera :
   - Choisissez l'archétype initial de votre compagnon.
   - Saisissez votre clé API Google Gemini (disponible gratuitement sur [Google AI Studio](https://aistudio.google.com/app/apikey)).
   - Vous êtes prêt(e) à discuter !
