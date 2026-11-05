import SwiftUI

/// One block of the matrix drawn in the active skin.
struct SkinBlock: View {
    @Environment(\.widgetSkin) private var skin
    let hex: String
    let radius: CGFloat

    /// Fixed star specks as (x, y) fractions of the brick, so they never shimmer.
    private static let stars: [(CGFloat, CGFloat)] = [(0.2, 0.25), (0.75, 0.15), (0.55, 0.6)]

    private static func blend(_ baseHex: String, _ hex: String, _ t: Double) -> Color {
        let a = RGB(hex: baseHex), b = RGB(hex: hex)
        return Color(red: a.r + (b.r - a.r) * t, green: a.g + (b.g - a.g) * t, blue: a.b + (b.b - a.b) * t)
    }

    var body: some View {
        switch skin {
        case .neon:
            RoundedRectangle(cornerRadius: radius).fill(Color(hex: hex))
        case .gameBoy:
            gameBoyBrick
        case .cyberpunk:
            ZStack {
                RoundedRectangle(cornerRadius: 1).stroke(Color(hex: "00F0FF"), lineWidth: 0.8).offset(x: 0.8, y: 0.8)
                RoundedRectangle(cornerRadius: 1).stroke(Color(hex: "FF2BD6"), lineWidth: 0.8).offset(x: -0.8, y: -0.8)
                RoundedRectangle(cornerRadius: 1).fill(Color(hex: "150E24"))
                RoundedRectangle(cornerRadius: 1).fill(Color(hex: hex).opacity(0.5))
            }
        case .gemstone:
            let rgb = RGB(hex: hex)
            ZStack {
                rgb.shaded(-0.3)
                FacetTriangle().fill(rgb.shaded(0.35))
            }
            .clipShape(RoundedRectangle(cornerRadius: max(radius - 1, 1)))
            .overlay(RoundedRectangle(cornerRadius: max(radius - 1, 1)).stroke(Color.white.opacity(0.3), lineWidth: 0.5))
        case .pureGold:
            // Gold Relic & Obsidian: obsidian body, bevel bright top/left and
            // dark bottom/right, gold-framed habit-color inlay.
            ZStack {
                RoundedRectangle(cornerRadius: radius)
                    .fill(LinearGradient(colors: [Color(hex: "2A2630"), Color(hex: "0B090D")],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                RelicFrame(highlight: false).stroke(Color(hex: "8A5A0A"), lineWidth: 1.2)
                RelicFrame(highlight: true).stroke(Color(hex: "FFE9A0"), lineWidth: 1.2)
                RoundedRectangle(cornerRadius: max(radius - 1, 0))
                    .inset(by: 2.2).stroke(Color(hex: "E6B422").opacity(0.35), lineWidth: 0.7)
                GeometryReader { g in
                    let side = min(max(g.size.height * 0.42, 2), g.size.width)
                    Rectangle().fill(Color(hex: hex))
                        .frame(width: side, height: side)
                        .padding(1.2)
                        .background(Color(hex: "E6B422"))
                        .position(x: g.size.width / 2, y: g.size.height / 2)
                }
            }
        case .nebula:
            // Indigo-to-violet brick tinted by the habit color, habit-colored
            // glow strip along the bottom edge and three fixed star specks.
            ZStack {
                RoundedRectangle(cornerRadius: radius)
                    .fill(LinearGradient(colors: [Self.blend("1A1052", hex, 0.18), Self.blend("6A35C8", hex, 0.3)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                RoundedRectangle(cornerRadius: radius).stroke(Color(hex: "B79CFF").opacity(0.4), lineWidth: 0.6)
                GeometryReader { g in
                    Rectangle().fill(Color(hex: hex).opacity(0.75))
                        .frame(width: max(g.size.width - 4, 0), height: 2)
                        .position(x: g.size.width / 2, y: g.size.height - 2)
                    ForEach(Array(Self.stars.enumerated()), id: \.offset) { _, p in
                        Rectangle().fill(Color.white.opacity(0.8))
                            .frame(width: 1, height: 1)
                            .position(x: 2 + (g.size.width - 5) * p.0, y: 2 + (g.size.height - 7) * p.1)
                    }
                }
            }
        }
    }
}

extension SkinBlock {
    /// Flat LCD brick: hard outline, shaded lower half on the lightest shade,
    /// and a 2px highlight on all but the darkest (matches the app skin).
    @ViewBuilder
    fileprivate var gameBoyBrick: some View {
        let shadeHex = WidgetSkin.gameBoyGreen(hex)
        let darkest = Color(hex: "0F380F")
        ZStack {
            Rectangle().fill(Color(hex: shadeHex))
            if shadeHex == "9BBC0F" {
                GeometryReader { g in
                    Rectangle().fill(Color(hex: "8BAC0F"))
                        .frame(width: max(g.size.width - 2, 0), height: max(g.size.height / 2 - 1, 0))
                        .position(x: g.size.width / 2, y: g.size.height * 0.75 - 0.5)
                }
            }
            if shadeHex != "0F380F" {
                GeometryReader { _ in
                    Rectangle().fill(Color(hex: "9BBC0F").opacity(0.8)).frame(width: 2, height: 2)
                        .position(x: 3, y: 3)
                }
            }
            Rectangle().stroke(darkest, lineWidth: 1)
        }
    }
}

/// Polyline along two edges of the square: top+left for the highlight,
/// bottom+right for the shadow.
private struct RelicFrame: Shape {
    let highlight: Bool

    func path(in rect: CGRect) -> Path {
        let r = rect.insetBy(dx: 0.6, dy: 0.6)
        var p = Path()
        if highlight {
            p.move(to: CGPoint(x: r.minX, y: r.maxY))
            p.addLine(to: CGPoint(x: r.minX, y: r.minY))
            p.addLine(to: CGPoint(x: r.maxX, y: r.minY))
        } else {
            p.move(to: CGPoint(x: r.minX, y: r.maxY))
            p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
            p.addLine(to: CGPoint(x: r.maxX, y: r.minY))
        }
        return p
    }
}

/// Upper-left half of a square, the light side of a gem facet.
private struct FacetTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}
