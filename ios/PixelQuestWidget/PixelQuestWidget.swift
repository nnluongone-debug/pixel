import SwiftUI
import WidgetKit

struct PixelQuestEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot?
}

struct PixelQuestProvider: TimelineProvider {
    func placeholder(in context: Context) -> PixelQuestEntry {
        PixelQuestEntry(date: Date(), snapshot: .galleryPreview)
    }

    func getSnapshot(in context: Context, completion: @escaping (PixelQuestEntry) -> Void) {
        // The widget gallery gets the sample entry; a real snapshot request
        // (e.g. after adding the widget) shows live data when available.
        let snapshot: WidgetSnapshot? = context.isPreview ? .galleryPreview : Self.currentSnapshot()
        completion(PixelQuestEntry(date: Date(), snapshot: snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PixelQuestEntry>) -> Void) {
        let now = Date()
        let entry = PixelQuestEntry(date: now, snapshot: Self.currentSnapshot(now))
        let midnight = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 5),
            matchingPolicy: .nextTime
        ) ?? now.addingTimeInterval(3600 * 6)
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }

    private static func currentSnapshot(_ now: Date = Date()) -> WidgetSnapshot? {
        WidgetSnapshot.load()?.rolled(to: DateKey.string(now))
    }
}

struct PixelQuestWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: PixelQuestEntry

    private var skin: WidgetSkin { WidgetSkin(id: entry.snapshot?.skin) }

    var body: some View {
        Group {
            if let snapshot = entry.snapshot, !snapshot.habits.isEmpty {
                switch family {
                case .systemMedium: MediumWidgetView(snapshot: snapshot)
                case .systemLarge: LargeWidgetView(snapshot: snapshot)
                default: SmallWidgetView(snapshot: snapshot)
                }
            } else {
                EmptyStateView(
                    hasSnapshot: entry.snapshot != nil,
                    strings: entry.snapshot?.strings ?? WidgetStrings(lang: nil)
                )
            }
        }
        .environment(\.widgetSkin, skin)
        .containerBackground(for: .widget) { skin.background }
    }
}

struct PixelQuestWidget: Widget {
    let kind = "PixelQuestWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PixelQuestProvider()) { entry in
            PixelQuestWidgetView(entry: entry)
        }
        .configurationDisplayName("Habit Tracker - Pixel")
        .description(WidgetStrings(lang: nil).galleryDescription)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}

@main
struct PixelQuestWidgetBundle: WidgetBundle {
    var body: some Widget {
        PixelQuestWidget()
    }
}
