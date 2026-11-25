package com.pixelquest.pixel_quest.widget

/** Widget labels in the app language (`snapshot.lang`), mirroring iOS `WidgetStrings`. */
class WidgetStrings(lang: String?) {
    private val vi = (lang ?: java.util.Locale.getDefault().language) == "vi"

    private fun t(en: String, vi: String) = if (this.vi) vi else en

    val noHabitsTitle get() = t("NO HABITS YET", "CHƯA CÓ THÓI QUEN")
    val noHabitsHint get() = t("ADD ONE TO START STACKING", "THÊM MỘT ĐỂ BẮT ĐẦU XẾP GẠCH")
    val openAppTitle get() = t("OPEN PIXEL QUEST", "MỞ PIXEL QUEST")
    val openAppHint get() = t("TO START STACKING", "ĐỂ BẮT ĐẦU XẾP GẠCH")

    val today get() = t("TODAY", "HÔM NAY")
    fun done(done: Int, total: Int) = t("$done/$total DONE", "XONG $done/$total")
    fun streakShort(days: Int) = t("★ ${days}D", "★ ${days}N")

    val skyline get() = t("7-DAY SKYLINE", "7 NGÀY QUA")
    fun plusBlocks(n: Int) = t("+$n BLOCKS", "+$n GẠCH")
    val flow get() = t("flow", "đạt")
    fun activeStreak(days: Int) = t("ACTIVE STREAK: $days DAYS", "CHUỖI: $days NGÀY")
    val tapToStack get() = t("TAP TO STACK", "CHẠM ĐỂ XẾP")
    fun goal(done: Int, total: Int) = t("GOAL: $done/$total", "MỤC TIÊU: $done/$total")
    fun remaining(n: Int) = t("$n REMAINING", "CÒN $n")
}
