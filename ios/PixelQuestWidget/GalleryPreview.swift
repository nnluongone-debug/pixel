import Foundation

extension WidgetSnapshot {
    /// SAMPLE DATA for the widget gallery and placeholder only. It is never
    /// used for a real timeline entry.
    static var galleryPreview: WidgetSnapshot {
        let palette = ["00D2FF", "2DE38E", "FF7675", "F9CA24", "A29BFE"]
        func days(_ n: Int) -> [WidgetDay] {
            (0..<n).map { i in
                let height = 2 + (i * 3) % 5
                return WidgetDay(
                    date: "2026-01-\(String(format: "%02d", i + 1))",
                    weekday: i % 7 + 1,
                    colors: (0..<height).map { palette[($0 + i) % palette.count] }
                )
            }
        }
        func habit(_ id: String, _ name: String, _ color: String, _ icon: String, _ p: Int, _ t: Int, _ s: Int) -> WidgetHabit {
            WidgetHabit(id: id, name: name, colorHex: color, icon: icon, type: "counter",
                        progress: p, target: t, unit: "", done: p >= t, dueToday: true, streak: s)
        }
        return WidgetSnapshot(
            version: 1, generatedAt: "", today: DateKey.string(Date()), level: 7, xp: 60, targetXp: 100,
            streak: 21,
            habits: [
                habit("w", "Hydrate", "00D2FF", "water_drop", 6, 8, 15),
                habit("f", "Gym Session", "2DE38E", "fitness", 1, 1, 12),
                habit("c", "Deep Read", "FF7675", "terminal", 0, 1, 8),
                habit("r", "Reading", "F9CA24", "book", 10, 25, 6),
            ],
            todayTotal: 4, todayDone: 3, skyline: days(7), tower: days(12),
            weekNumber: 42, weekStart: "2026-10-12", weekEnd: "2026-10-18", weekBlocks: 18
        )
    }
}
