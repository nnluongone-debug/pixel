import SwiftUI
import WidgetKit

/// 4x4 FULL ARCADE HUD: week header, progression tower, streak tiles.
struct LargeWidgetView: View {
    @Environment(\.widgetSkin) private var skin
    let snapshot: WidgetSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
            tower
            HStack(spacing: 6) {
                ForEach(streakHabits) { streakTile($0) }
            }
            Text(snapshot.strings.tapToOpen)
                .font(Neo.mono(8, .bold)).foregroundStyle(skin.accent(Neo.cyan))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(14)
        .widgetURL(pixelQuestOpenURL)
    }

    private var streakHabits: [WidgetHabit] {
        Array(snapshot.habits.sorted { $0.streak > $1.streak }.prefix(4))
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(snapshot.strings.weekMatrix(snapshot.weekNumber))
                    .font(Neo.mono(15, .bold)).foregroundStyle(skin.text)
                Text("\(snapshot.strings.shortDate(snapshot.weekStart)) - \(snapshot.strings.shortDate(snapshot.weekEnd))")
                    .font(Neo.mono(8, .bold)).foregroundStyle(skin.accent(Neo.cyan))
            }
            Spacer(minLength: 0)
            Text(snapshot.strings.weekBlocks(snapshot.weekBlocks))
                .font(Neo.mono(11, .bold)).foregroundStyle(skin.accent(Neo.mint))
        }
    }

    private var tower: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(snapshot.strings.tower).font(Neo.mono(8, .bold)).foregroundStyle(skin.muted)
                Spacer(minLength: 0)
                ForEach(snapshot.habits.prefix(4)) { h in
                    HStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 1).fill(skin.color(h.colorHex)).frame(width: 5, height: 5)
                        Text(String(h.name.uppercased().prefix(6))).font(Neo.mono(6)).foregroundStyle(skin.muted)
                    }
                }
            }
            BlockGrid(
                columns: snapshot.tower.map { Array($0.colors.prefix(8)) },
                rows: 8, spacing: 2.5, cornerRadius: 2
            )
        }
        .padding(10)
        .frame(maxHeight: .infinity)
        .background(skin.panel, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(skin.panelBorder, lineWidth: skin == .gameBoy ? 1 : 0.5))
    }

    private func streakTile(_ h: WidgetHabit) -> some View {
        let color = skin.color(h.colorHex)
        return VStack(alignment: .leading, spacing: 2) {
            Image(systemName: habitSymbol(h.icon)).font(.system(size: 11)).foregroundStyle(color)
            Text(snapshot.strings.streakTile(h.streak))
                .font(Neo.mono(16, .bold)).foregroundStyle(skin.text)
            Text(h.name.uppercased()).font(Neo.mono(6, .bold)).foregroundStyle(color).lineLimit(1)
        }
        .padding(7)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(color.opacity(0.4), lineWidth: 0.5))
    }
}
