package com.pixelquest.pixel_quest.widget

import org.json.JSONArray
import org.json.JSONObject
import java.time.LocalDate
import java.time.temporal.IsoFields

/** One habit entry of the snapshot JSON written by the Flutter app. */
data class WidgetHabit(
    val id: String,
    val name: String,
    val colorHex: String,
    val progress: Int,
    val target: Int,
    val unit: String,
    /** Habit type name (`counter`, `checklist`, `timer`); timers cannot be checked in from the widget. */
    val type: String,
    val done: Boolean,
    val dueToday: Boolean,
    /** Due weekdays bitmask (bit 0 = Monday); null in snapshots without the field. */
    val scheduleDays: Int?,
) {
    fun isDue(isoWeekday: Int): Boolean =
        scheduleDays?.let { it and (1 shl (isoWeekday - 1)) != 0 } ?: dueToday
}

/** One day of the skyline/tower strips; [colors] are block hex colors, bottom-up. */
data class WidgetDay(val date: String, val weekday: Int, val colors: List<String>)

/** Kotlin port of the iOS `WidgetSnapshot` (payload version 1). */
data class WidgetSnapshot(
    val lang: String?,
    val skin: String?,
    val today: String,
    val streak: Int,
    val habits: List<WidgetHabit>,
    val todayTotal: Int,
    val todayDone: Int,
    val skyline: List<WidgetDay>,
    val tower: List<WidgetDay>,
    val weekStart: String,
    val weekEnd: String,
    val weekBlocks: Int,
) {
    /** Percentage of today's due habits that are done (0 when none are due). */
    val flowPercent: Int
        get() = if (todayTotal == 0) 0 else Math.round(todayDone * 100.0 / todayTotal).toInt()

    val dueHabits: List<WidgetHabit> get() = habits.filter { it.dueToday }

    /**
     * Snapshot to show when the day changed since the app last synced: progress
     * is reset, due habits follow today's weekday, day strips slide forward and a
     * new week starts empty.
     */
    fun rolledTo(todayKey: String): WidgetSnapshot {
        if (todayKey == today) return this
        val date = parseDate(todayKey) ?: return this
        val weekday = date.dayOfWeek.value
        val rolledHabits = habits.map {
            it.copy(progress = 0, done = false, dueToday = it.isDue(weekday))
        }
        val newWeek = todayKey > weekEnd
        val monday = date.minusDays((weekday - 1).toLong())
        return copy(
            today = todayKey,
            todayDone = 0,
            habits = rolledHabits,
            todayTotal = rolledHabits.count { it.dueToday },
            weekStart = if (newWeek) monday.toString() else weekStart,
            weekEnd = if (newWeek) monday.plusDays(6).toString() else weekEnd,
            weekBlocks = if (newWeek) 0 else weekBlocks,
            skyline = slide(skyline, date),
            tower = slide(tower, date),
        )
    }

    private fun slide(days: List<WidgetDay>, end: LocalDate): List<WidgetDay> {
        if (days.isEmpty()) return days
        return days.indices.map { i ->
            val d = end.minusDays((days.size - 1 - i).toLong())
            val key = d.toString()
            WidgetDay(key, d.dayOfWeek.value, days.firstOrNull { it.date == key }?.colors ?: emptyList())
        }
    }

    companion object {
        const val PREF_KEY = "pixelquest_snapshot"

        fun parseDate(key: String): LocalDate? = try {
            LocalDate.parse(key)
        } catch (_: Exception) {
            null
        }

        /** ISO week number, exposed for parity with the Dart payload. */
        fun isoWeek(date: LocalDate): Int = date.get(IsoFields.WEEK_OF_WEEK_BASED_YEAR)

        /** Returns null for missing or malformed JSON (never throws). */
        fun parse(json: String?): WidgetSnapshot? {
            if (json.isNullOrBlank()) return null
            return try {
                val o = JSONObject(json)
                WidgetSnapshot(
                    lang = o.optStringOrNull("lang"),
                    skin = o.optStringOrNull("skin"),
                    today = o.getString("today"),
                    streak = o.getInt("streak"),
                    habits = o.getJSONArray("habits").map { habit(it) },
                    todayTotal = o.getInt("todayTotal"),
                    todayDone = o.getInt("todayDone"),
                    skyline = o.getJSONArray("skyline").map { day(it) },
                    tower = o.getJSONArray("tower").map { day(it) },
                    weekStart = o.getString("weekStart"),
                    weekEnd = o.getString("weekEnd"),
                    weekBlocks = o.getInt("weekBlocks"),
                )
            } catch (_: Exception) {
                null
            }
        }

        private fun habit(o: JSONObject) = WidgetHabit(
            id = o.getString("id"),
            name = o.getString("name"),
            colorHex = o.getString("colorHex"),
            progress = o.getInt("progress"),
            target = o.getInt("target"),
            unit = o.optString("unit", ""),
            type = o.optString("type", "counter"),
            done = o.getBoolean("done"),
            dueToday = o.getBoolean("dueToday"),
            scheduleDays = if (o.has("scheduleDays") && !o.isNull("scheduleDays")) o.getInt("scheduleDays") else null,
        )

        private fun day(o: JSONObject) = WidgetDay(
            date = o.getString("date"),
            weekday = o.getInt("weekday"),
            colors = o.getJSONArray("colors").let { a -> (0 until a.length()).map { a.getString(it) } },
        )

        private fun JSONObject.optStringOrNull(key: String): String? =
            if (has(key) && !isNull(key)) getString(key) else null

        private fun <T> JSONArray.map(transform: (JSONObject) -> T): List<T> =
            (0 until length()).map { transform(getJSONObject(it)) }
    }
}
