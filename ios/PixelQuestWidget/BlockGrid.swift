import SwiftUI

/// Columns of stacked colored blocks, drawn bottom-up. Each column lists hex
/// colors from the base upward. Cell size adapts to the available space.
struct BlockGrid: View {
    @Environment(\.widgetSkin) private var skin
    let columns: [[String]]
    let rows: Int
    var spacing: CGFloat = 2
    var cornerRadius: CGFloat = 2
    var showEmpty = true

    var body: some View {
        GeometryReader { geo in
            let cols = max(columns.count, 1)
            let cell = min(
                (geo.size.width - spacing * CGFloat(cols - 1)) / CGFloat(cols),
                (geo.size.height - spacing * CGFloat(rows - 1)) / CGFloat(rows)
            )
            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(columns.indices, id: \.self) { c in
                    VStack(spacing: spacing) {
                        ForEach((0..<rows).reversed(), id: \.self) { r in
                            cellView(columns[c], r)
                                .frame(width: cell, height: cell)
                        }
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
        }
    }

    @ViewBuilder
    private func cellView(_ colors: [String], _ row: Int) -> some View {
        if row < colors.count {
            SkinBlock(hex: colors[row], radius: cornerRadius)
        } else if showEmpty {
            if skin == .gameBoy {
                Rectangle().stroke(skin.emptyCell, lineWidth: 1)
            } else {
                RoundedRectangle(cornerRadius: cornerRadius).fill(skin.emptyCell)
            }
        } else {
            Color.clear
        }
    }
}

struct NeoChip: View {
    @Environment(\.widgetSkin) private var skin
    let text: String
    var color: Color = Neo.mint
    var size: CGFloat = 8

    var body: some View {
        let color = skin.accent(self.color)
        return Text(text)
            .font(Neo.mono(size, .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.12), in: Capsule())
            .overlay(Capsule().stroke(color.opacity(0.4), lineWidth: 0.5))
    }
}

/// Shown instead of data when the app has not synced or has no habits.
struct EmptyStateView: View {
    @Environment(\.widgetSkin) private var skin
    let hasSnapshot: Bool
    var strings = WidgetStrings(lang: nil)

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "square.grid.3x3.fill").foregroundStyle(skin.accent(Neo.mint))
            Text(hasSnapshot ? strings.noHabitsTitle : strings.openAppTitle)
                .font(Neo.mono(11, .bold)).foregroundStyle(skin.text)
            Text(hasSnapshot ? strings.noHabitsHint : strings.openAppHint)
                .font(Neo.mono(8)).foregroundStyle(skin.muted)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetURL(pixelQuestOpenURL)
    }
}
