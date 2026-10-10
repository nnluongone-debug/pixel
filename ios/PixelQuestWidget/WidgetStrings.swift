import Foundation

/// Widget labels in the app's language. The app writes its language code
/// into the snapshot (`lang`), so the widget always matches the app even
/// when the user picked a language different from the device.
struct WidgetStrings {
    let isVietnamese: Bool

    init(lang: String?) {
        let code = lang ?? Locale.current.language.languageCode?.identifier
        isVietnamese = code == "vi"
    }

    private func t(_ en: String, _ vi: String) -> String { isVietnamese ? vi : en }

    // Gallery
    var galleryDescription: String {
        t("Your habit matrix, streaks and quick check-ins.",
          "Ma trận thói quen, chuỗi ngày và check-in nhanh.")
    }

    // Empty state
    var noHabitsTitle: String { t("NO HABITS YET", "CHƯA CÓ THÓI QUEN") }
    var noHabitsHint: String { t("ADD ONE TO START STACKING", "THÊM MỘT ĐỂ BẮT ĐẦU XẾP GẠCH") }
    var openAppTitle: String { t("OPEN PIXEL QUEST", "MỞ PIXEL QUEST") }
    var openAppHint: String { t("TO START STACKING", "ĐỂ BẮT ĐẦU XẾP GẠCH") }

    // Small
    var today: String { t("TODAY", "HÔM NAY") }
    func done(_ done: Int, _ total: Int) -> String { t("\(done)/\(total) DONE", "XONG \(done)/\(total)") }
    func streakShort(_ days: Int) -> String { t("★ \(days)D", "★ \(days)N") }

    // Medium
    var skyline: String { t("7-DAY SKYLINE", "7 NGÀY QUA") }
    func plusBlocks(_ n: Int) -> String { t("+\(n) BLOCKS", "+\(n) GẠCH") }
    var flow: String { t("flow", "đạt") }
    func activeStreak(_ days: Int) -> String { t("ACTIVE STREAK: \(days) DAYS", "CHUỖI: \(days) NGÀY") }
    var tapToStack: String { t("TAP TO STACK", "CHẠM ĐỂ XẾP") }
    func goal(_ done: Int, _ total: Int) -> String { t("GOAL: \(done)/\(total)", "MỤC TIÊU: \(done)/\(total)") }
    func remaining(_ n: Int) -> String { t("\(n) REMAINING", "CÒN \(n)") }
    /// Monday-first short weekday labels.
    var weekdayLetters: [String] {
        isVietnamese ? ["T2", "T3", "T4", "T5", "T6", "T7", "CN"] : ["M", "T", "W", "T", "F", "S", "S"]
    }

    // Large
    var tapToOpen: String { t("TAP TO OPEN MATRIX", "CHẠM ĐỂ MỞ MA TRẬN") }
    func weekMatrix(_ week: Int) -> String { t("WEEK \(week) MATRIX", "MA TRẬN TUẦN \(week)") }
    func weekBlocks(_ n: Int) -> String { t("⚡ \(n) BLOCKS", "⚡ \(n) GẠCH") }
    var tower: String { t("LIVE PROGRESSION TOWER", "THÁP TIẾN ĐỘ") }
    func streakTile(_ days: Int) -> String {
        String(format: isVietnamese ? "%02dN" : "%02dD", days)
    }

    /// "OCT 12" / "12 THG 10" label for a `YYYY-MM-DD` key.
    func shortDate(_ key: String) -> String {
        guard let d = DateKey.date(key) else { return key }
        let f = DateFormatter()
        f.locale = Locale(identifier: isVietnamese ? "vi_VN" : "en_US_POSIX")
        f.dateFormat = isVietnamese ? "d 'THG' M" : "MMM d"
        return f.string(from: d).uppercased()
    }
}
