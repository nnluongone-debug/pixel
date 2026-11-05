import SwiftUI
import WidgetKit

/// 2x4 SKYLINE & FAST STACK: 7-day skyline on the left, tappable habits on the right.
struct MediumWidgetView: View {
    @Environment(\.widgetSkin) private var skin
    let snapshot: WidgetSnapshot

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            skyline.frame(maxWidth: .infinity, alignment: .leading)
            Rectangle().fill(Color.white.opacity(0.08)).frame(width: 1)
            fastStack.frame(maxWidth: .infinity)
        }
        .padding(14)
    }

    private var skyline: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(snapshot.strings.skyline).font(Neo.mono(8)).foregroundStyle(skin.muted)
                Spacer(minLength: 0)
                Text(snapshot.strings.plusBlocks(snapshot.weekBlocks)).font(Neo.mono(8, .bold)).foregroundStyle(skin.accent(Neo.mint))
            }
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(snapshot.flowPercent)%").font(Neo.mono(22, .bold)).foregroundStyle(skin.text)
                Text(snapshot.strings.flow).font(Neo.mono(9)).foregroundStyle(skin.accent(Neo.cyan))
            }
            BlockGrid(
                columns: snapshot.skyline.map { Array($0.colors.prefix(6)) },
                rows: 6, spacing: 2, cornerRadius: 1.5, showEmpty: false
            )
            HStack(spacing: 2) {
                ForEach(snapshot.skyline.indices, id: \.self) { i in
                    let isToday = i == snapshot.skyline.count - 1
                    Text(snapshot.strings.weekdayLetters[(snapshot.skyline[i].weekday - 1) % 7])
                        .font(Neo.mono(7, isToday ? .bold : .regular))
                        .foregroundStyle(isToday ? skin.accent(Neo.mint) : skin.muted)
                        .frame(maxWidth: .infinity)
                }
            }
            Text(snapshot.strings.activeStreak(snapshot.streak))
                .font(Neo.mono(8, .bold)).foregroundStyle(skin.muted).lineLimit(1)
        }
    }

    private var fastStack: some View {
        let due = snapshot.dueHabits.sorted { !$0.done && $1.done }
        return VStack(alignment: .leading, spacing: 5) {
            Text(snapshot.strings.tapToStack).font(Neo.mono(8)).foregroundStyle(skin.muted)
            ForEach(due.prefix(3)) { habitRow($0) }
            Spacer(minLength: 0)
            HStack {
                Text(snapshot.strings.goal(snapshot.todayDone, snapshot.todayTotal))
                Spacer(minLength: 0)
                Text(snapshot.strings.remaining(max(snapshot.todayTotal - snapshot.todayDone, 0)))
            }
            .font(Neo.mono(7, .bold)).foregroundStyle(skin.muted)
        }
    }

    private func habitRow(_ h: WidgetHabit) -> some View {
        let color = skin.color(h.colorHex)
        return Link(destination: checkInURL(h.id)) {
            HStack(spacing: 6) {
                Image(systemName: habitSymbol(h.icon)).font(.system(size: 11)).foregroundStyle(color)
                VStack(alignment: .leading, spacing: 0) {
                    Text(h.name).font(Neo.mono(9, .bold)).foregroundStyle(skin.text).lineLimit(1)
                    Text("\(h.progress)/\(h.target)\(h.unit.isEmpty ? "" : " \(h.unit)")")
                        .font(Neo.mono(7)).foregroundStyle(color).lineLimit(1)
                }
                Spacer(minLength: 0)
                Image(systemName: h.done ? "checkmark.circle.fill" : "plus.circle")
                    .font(.system(size: 15)).foregroundStyle(h.done ? color : skin.muted)
            }
            .padding(.horizontal, 7).padding(.vertical, 4)
            .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(color.opacity(0.35), lineWidth: 0.5))
        }
    }
}
