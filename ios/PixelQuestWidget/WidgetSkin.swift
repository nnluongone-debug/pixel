import SwiftUI

/// Look of the widgets, chosen by the skin equipped in the app. Static only:
/// WidgetKit cannot animate continuously. Unknown or missing ids use Neon.
enum WidgetSkin: String {
    case neon, gameBoy, cyberpunk, gemstone, pureGold, nebula

    /// Maps the Dart `CosmeticId.name` stored in the snapshot.
    init(id: String?) {
        switch id {
        case "gameBoy": self = .gameBoy
        case "cyberpunk": self = .cyberpunk
        case "gemstone": self = .gemstone
        case "pureGold": self = .pureGold
        case "nebula": self = .nebula
        default: self = .neon
        }
    }

    // MARK: Surfaces and text

    @ViewBuilder
    var background: some View {
        switch self {
        case .neon: Neo.background
        case .gameBoy: Color(hex: "9BBC0F")
        case .cyberpunk:
            LinearGradient(colors: [Color(hex: "1A0B2E"), Color(hex: "070510")],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        case .gemstone:
            LinearGradient(colors: [Color(hex: "1B2340"), Color(hex: "0A0D1C")],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        case .pureGold:
            LinearGradient(colors: [Color(hex: "14100A"), Color(hex: "0A0808")],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        case .nebula:
            LinearGradient(colors: [Color(hex: "1A1052"), Color(hex: "060316")],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var text: Color {
        switch self {
        case .neon: return Neo.textPrimary
        case .gameBoy: return Color(hex: "0F380F")
        case .cyberpunk: return Color(hex: "F3E9FF")
        case .gemstone: return Color(hex: "EAF0FF")
        case .pureGold: return Color(hex: "FFF1C2")
        case .nebula: return Color(hex: "ECE6FF")
        }
    }

    var muted: Color {
        switch self {
        case .neon: return Neo.textMuted
        case .gameBoy: return Color(hex: "306230")
        case .cyberpunk: return Color(hex: "9C8FB8")
        case .gemstone: return Color(hex: "8C97BD")
        case .pureGold: return Color(hex: "B39B5E")
        case .nebula: return Color(hex: "9A8FD0")
        }
    }

    var panel: Color {
        switch self {
        case .gameBoy: return Color(hex: "9BBC0F")
        default: return Neo.obsidian.opacity(0.7)
        }
    }

    /// Hairline around the tower panel (hard outline for Game Boy).
    var panelBorder: Color {
        self == .gameBoy ? Color(hex: "0F380F") : Color.white.opacity(0.06)
    }

    var emptyCell: Color {
        switch self {
        case .neon: return Neo.emptyCell
        case .gameBoy: return Color(hex: "306230").opacity(0.22)
        case .cyberpunk: return Color(hex: "1B1430")
        case .gemstone: return Color(hex: "1B2442")
        case .pureGold: return Color(hex: "E6B422").opacity(0.2)
        case .nebula: return Color(hex: "1A1240")
        }
    }

    /// Replaces a Neo accent (mint, cyan, amber) with the skin's accent.
    func accent(_ base: Color) -> Color {
        switch self {
        case .neon: return base
        case .gameBoy: return Color(hex: "0F380F")
        case .cyberpunk: return base == Neo.amber ? Color(hex: "FF2BD6") : Color(hex: "00F0FF")
        case .gemstone: return base == Neo.amber ? Color(hex: "FFB4E6") : Color(hex: "7FD8FF")
        case .pureGold: return Color(hex: "F5C84B")
        case .nebula: return base == Neo.amber ? Color(hex: "FFD6F5") : Color(hex: "B9A6FF")
        }
    }

    /// Habit color as shown by this skin (Game Boy quantizes to its 4 greens).
    func color(_ hex: String) -> Color {
        guard self == .gameBoy else { return Color(hex: hex) }
        return Color(hex: Self.gameBoyGreen(hex))
    }

    /// Same luminance bands as the app's GameBoySkin.shadeFor.
    static func gameBoyGreen(_ hex: String) -> String {
        let l = RGB(hex: hex).relativeLuminance
        if l < 0.37 { return "0F380F" }
        if l < 0.45 { return "306230" }
        if l < 0.56 { return "8BAC0F" }
        return "9BBC0F"
    }
}

struct RGB {
    let r: Double, g: Double, b: Double

    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var v: UInt64 = 0
        let ok = Scanner(string: cleaned).scanHexInt64(&v) && [6, 8].contains(cleaned.count)
        let rgb = ok ? (cleaned.count == 8 ? v & 0xFFFFFF : v) : 0x2DE38E
        r = Double((rgb >> 16) & 0xFF) / 255
        g = Double((rgb >> 8) & 0xFF) / 255
        b = Double(rgb & 0xFF) / 255
    }

    /// WCAG relative luminance (linearized sRGB), as Flutter's computeLuminance.
    var relativeLuminance: Double {
        func lin(_ c: Double) -> Double { c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4) }
        return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)
    }

    /// Blends toward white (amount > 0) or black (amount < 0).
    func shaded(_ amount: Double) -> Color {
        let target = amount >= 0 ? 1.0 : 0.0
        let t = abs(amount)
        return Color(red: r + (target - r) * t, green: g + (target - g) * t, blue: b + (target - b) * t)
    }
}

private struct WidgetSkinKey: EnvironmentKey {
    static let defaultValue = WidgetSkin.neon
}

extension EnvironmentValues {
    var widgetSkin: WidgetSkin {
        get { self[WidgetSkinKey.self] }
        set { self[WidgetSkinKey.self] = newValue }
    }
}
