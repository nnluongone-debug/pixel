import SwiftUI

/// Neo-Matrix tokens from the design system (obsidian surfaces, phosphor accents).
enum Neo {
    static let mint = Color(hex: "2DE38E")
    static let cyan = Color(hex: "00D2FF")
    static let amber = Color(hex: "F9CA24")
    static let lavender = Color(hex: "A29BFE")
    static let rose = Color(hex: "FF7675")

    static let obsidian = Color(hex: "0B0C10")
    static let surface = Color(hex: "16181F")
    static let emptyCell = Color(hex: "1D1F27")
    static let textPrimary = Color(hex: "E8EAF0")
    static let textMuted = Color(hex: "8B90A0")

    static func mono(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }

    static var background: some View {
        LinearGradient(
            colors: [surface, obsidian],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension Color {
    /// Accepts "RRGGBB", "#RRGGBB" and "AARRGGBB"; falls back to mint when malformed.
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var value: UInt64 = 0
        guard Scanner(string: cleaned).scanHexInt64(&value), [6, 8].contains(cleaned.count) else {
            self = Color(red: 0.176, green: 0.89, blue: 0.557)
            return
        }
        let rgb = cleaned.count == 8 ? value & 0xFFFFFF : value
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}

/// Habit icon names stored by the app mapped to SF Symbols.
func habitSymbol(_ name: String) -> String {
    switch name {
    case "water_drop": return "drop.fill"
    case "fitness": return "dumbbell.fill"
    case "terminal": return "terminal.fill"
    case "book": return "book.fill"
    case "zen": return "figure.mind.and.body"
    case "walk": return "figure.walk"
    case "run": return "figure.run"
    case "bike": return "bicycle"
    case "swim": return "figure.pool.swim"
    case "sleep": return "moon.zzz.fill"
    case "pill": return "pills.fill"
    case "food": return "fork.knife"
    case "journal": return "square.and.pencil"
    case "heart": return "heart.fill"
    case "sun": return "sun.max.fill"
    case "money": return "banknote.fill"
    case "language": return "character.bubble.fill"
    case "clean": return "sparkles"
    case "phone_off": return "iphone.slash"
    default: return "scope"
    }
}

/// home_widget only forwards URLs carrying a `homeWidget` query item to
/// Flutter (`HomeWidget.widgetClicked`); every widget link must include it.
let pixelQuestOpenURL = URL(string: "pixelquest://open?homeWidget")!

func checkInURL(_ habitId: String) -> URL {
    var c = URLComponents()
    c.scheme = "pixelquest"
    c.host = "checkin"
    c.queryItems = [
        URLQueryItem(name: "habit", value: habitId),
        URLQueryItem(name: "homeWidget", value: nil),
    ]
    return c.url ?? pixelQuestOpenURL
}
