import Foundation

/// Mirrors the JSON written by `HomeWidgetSnapshot` on the Flutter side.
struct WidgetHabit: Codable, Identifiable {
    let id: String
    let name: String
    let colorHex: String
    let icon: String
    let type: String
    var progress: Int
    let target: Int
    let unit: String
    var done: Bool
    var dueToday: Bool
    let streak: Int
    /// Due weekdays bitmask (bit 0 = Monday); nil in snapshots written
    /// before the field existed.
    var scheduleDays: Int? = nil

    func isDue(isoWeekday: Int) -> Bool {
        guard let mask = scheduleDays else { return dueToday }
        return mask & (1 << (isoWeekday - 1)) != 0
    }
}

struct WidgetDay: Codable {
    let date: String
    let weekday: Int
    let colors: [String]
}

struct WidgetSnapshot: Codable {
    static let appGroupId = "group.com.nnluong.pixelquest"
    static let storageKey = "pixelquest_snapshot"

    let version: Int
    /// App language code ("en" / "vi"); nil in older snapshots.
    var lang: String? = nil

    /// Equipped skin id (`CosmeticId.name`); nil in older snapshots.
    var skin: String? = nil
    let generatedAt: String
    var today: String
    let level: Int
    let xp: Int
    let targetXp: Int
    let streak: Int
    var habits: [WidgetHabit]
    var todayTotal: Int
    var todayDone: Int
    var skyline: [WidgetDay]
    var tower: [WidgetDay]
    var weekNumber: Int
    var weekStart: String
    var weekEnd: String
    var weekBlocks: Int

    /// Reads the snapshot saved by the app; nil when the app never synced
    /// or the payload cannot be decoded.
    static func load() -> WidgetSnapshot? {
        guard let json = UserDefaults(suiteName: appGroupId)?.string(forKey: storageKey),
              let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }

    var strings: WidgetStrings { WidgetStrings(lang: lang) }

    /// Percentage of today's due habits that are done (0 when none are due).
    var flowPercent: Int {
        todayTotal == 0 ? 0 : Int((Double(todayDone) / Double(todayTotal) * 100).rounded())
    }

    var dueHabits: [WidgetHabit] { habits.filter { $0.dueToday } }

    /// Snapshot shown when the day changed since the app last synced: today's
    /// progress is reset, due habits follow today's weekday, the day strips
    /// slide forward and a new week starts empty.
    func rolled(to todayKey: String, calendar: Calendar = .current) -> WidgetSnapshot {
        guard todayKey != today, let todayDate = DateKey.date(todayKey, calendar: calendar) else {
            return self
        }
        let weekday = DateKey.isoWeekday(todayDate, calendar: calendar)
        var copy = self
        copy.today = todayKey
        copy.todayDone = 0
        copy.habits = habits.map { h in
            var h = h
            h.progress = 0
            h.done = false
            h.dueToday = h.isDue(isoWeekday: weekday)
            return h
        }
        copy.todayTotal = copy.habits.filter { $0.dueToday }.count
        if todayKey > weekEnd,
           let monday = calendar.date(byAdding: .day, value: 1 - weekday, to: todayDate),
           let sunday = calendar.date(byAdding: .day, value: 6, to: monday) {
            copy.weekStart = DateKey.string(monday, calendar: calendar)
            copy.weekEnd = DateKey.string(sunday, calendar: calendar)
            copy.weekNumber = Calendar(identifier: .iso8601).component(.weekOfYear, from: todayDate)
            copy.weekBlocks = 0
        }
        copy.skyline = Self.slide(skyline, to: todayKey, calendar: calendar)
        copy.tower = Self.slide(tower, to: todayKey, calendar: calendar)
        return copy
    }

    private static func slide(_ days: [WidgetDay], to todayKey: String, calendar: Calendar) -> [WidgetDay] {
        guard let count = Optional(days.count), count > 0,
              let end = DateKey.date(todayKey, calendar: calendar) else { return days }
        return (0..<count).map { i in
            let date = calendar.date(byAdding: .day, value: i - (count - 1), to: end) ?? end
            let key = DateKey.string(date, calendar: calendar)
            let colors = days.first { $0.date == key }?.colors ?? []
            return WidgetDay(date: key, weekday: DateKey.isoWeekday(date, calendar: calendar), colors: colors)
        }
    }
}

enum DateKey {
    static func string(_ date: Date, calendar: Calendar = .current) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    static func date(_ key: String, calendar: Calendar = .current) -> Date? {
        let p = key.split(separator: "-").compactMap { Int($0) }
        guard p.count == 3 else { return nil }
        return calendar.date(from: DateComponents(year: p[0], month: p[1], day: p[2]))
    }

    /// ISO weekday: Monday = 1 ... Sunday = 7.
    static func isoWeekday(_ date: Date, calendar: Calendar = .current) -> Int {
        (calendar.component(.weekday, from: date) + 5) % 7 + 1
    }
}
