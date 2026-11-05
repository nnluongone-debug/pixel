import SwiftUI
import WidgetKit

/// 2x2 MICRO MATRIX: badge, today chip, 5x5 block matrix, progress + streak.
struct SmallWidgetView: View {
    @Environment(\.widgetSkin) private var skin
    let snapshot: WidgetSnapshot
    private let size = 5

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 3).fill(skin.accent(Neo.mint)).frame(width: 12, height: 12)
                    Text("PixelQuest").font(Neo.mono(9, .bold)).foregroundStyle(skin.text)
                }
                Spacer(minLength: 0)
                NeoChip(text: snapshot.strings.today, color: skin.accent(Neo.mint), size: 7)
            }
            BlockGrid(
                columns: snapshot.tower.suffix(size).map { Array($0.colors.prefix(size)) },
                rows: size, spacing: 3, cornerRadius: 3
            )
            .frame(maxWidth: .infinity)
            HStack {
                HStack(spacing: 3) {
                    Circle().fill(skin.accent(Neo.mint)).frame(width: 5, height: 5)
                    Text(snapshot.strings.done(snapshot.todayDone, snapshot.todayTotal))
                        .font(Neo.mono(8, .bold)).foregroundStyle(skin.muted)
                }
                Spacer(minLength: 0)
                NeoChip(text: snapshot.strings.streakShort(snapshot.streak), color: skin.accent(Neo.amber), size: 8)
            }
        }
        .padding(14)
        .widgetURL(pixelQuestOpenURL)
    }
}
