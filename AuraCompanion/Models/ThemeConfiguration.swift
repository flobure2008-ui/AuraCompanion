import SwiftUI

public enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case cosmicViolet = "Cosmic Violet"
    case cyberPulse = "Cyber Neon"
    case sunsetGlow = "Sunset Glow"
    case emeraldZen = "Emerald Zen"
    case obsidianOled = "Obsidian Noir"
    
    public var id: String { rawValue }
    
    public var backgroundGradient: LinearGradient {
        switch self {
        case .cosmicViolet:
            return LinearGradient(
                colors: [Color(hex: "0D0814"), Color(hex: "170D28"), Color(hex: "090511")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .cyberPulse:
            return LinearGradient(
                colors: [Color(hex: "080D1A"), Color(hex: "0A1628"), Color(hex: "050810")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .sunsetGlow:
            return LinearGradient(
                colors: [Color(hex: "1C0B12"), Color(hex: "271217"), Color(hex: "0F050A")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .emeraldZen:
            return LinearGradient(
                colors: [Color(hex: "061412"), Color(hex: "0A221E"), Color(hex: "040C0B")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .obsidianOled:
            return LinearGradient(
                colors: [Color.black, Color(hex: "111111"), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    public var primaryAccent: Color {
        switch self {
        case .cosmicViolet: return Color(hex: "9D5CFF")
        case .cyberPulse: return Color(hex: "00F0FF")
        case .sunsetGlow: return Color(hex: "FF6584")
        case .emeraldZen: return Color(hex: "00E5A3")
        case .obsidianOled: return Color(hex: "FFFFFF")
        }
    }
    
    public var secondaryAccent: Color {
        switch self {
        case .cosmicViolet: return Color(hex: "E056FD")
        case .cyberPulse: return Color(hex: "FF007F")
        case .sunsetGlow: return Color(hex: "FF9F43")
        case .emeraldZen: return Color(hex: "00B4D8")
        case .obsidianOled: return Color(hex: "888888")
        }
    }
    
    public var cardBackground: Color {
        Color.white.opacity(0.06)
    }
    
    public var cardBorder: Color {
        primaryAccent.opacity(0.2)
    }
}

// MARK: - Color Hex Initializer
extension Color {
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
