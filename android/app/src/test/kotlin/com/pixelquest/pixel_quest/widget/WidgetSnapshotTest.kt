package com.pixelquest.pixel_quest.widget

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test

class WidgetSnapshotTest {
    // Shape of HomeWidgetSnapshot.build output. 2026-11-25 is a Wednesday;
    // "a" is due every day, "b" Mon/Wed only (mask 0b0000101), "c" has no mask.
    private val json = """
    {"version":1,"lang":"vi","skin":"gameBoy","generatedAt":"2026-11-25T10:00:00Z",
     "today":"2026-11-25","level":3,"xp":40,"targetXp":100,"streak":5,
     "habits":[
      {"id":"a","name":"Read","colorHex":"#FF7675","icon":"book","type":"counter","progress":2,"target":2,"unit":"","done":true,"dueToday":true,"scheduleDays":127,"streak":3},
      {"id":"b","name":"Gym","colorHex":"#2DE38E","icon":"fitness","type":"checklist","progress":0,"target":1,"unit":"","done":false,"dueToday":true,"scheduleDays":5,"streak":0},
      {"id":"c","name":"Old","colorHex":"#00D2FF","icon":"book","type":"counter","progress":0,"target":1,"unit":"","done":false,"dueToday":false,"streak":0}
     ],
     "todayTotal":2,"todayDone":1,
     "skyline":[{"date":"2026-11-24","weekday":2,"colors":["#FF7675"]},{"date":"2026-11-25","weekday":3,"colors":["#FF7675","#2DE38E"]}],
     "tower":[{"date":"2026-11-24","weekday":2,"colors":[]},{"date":"2026-11-25","weekday":3,"colors":["#FF7675"]}],
     "weekNumber":48,"weekStart":"2026-11-23","weekEnd":"2026-11-29","weekBlocks":3}
    """.trimIndent()

    private fun parsed() = WidgetSnapshot.parse(json)!!

    @Test fun parsesFields() {
        val s = parsed()
        assertEquals("vi", s.lang)
        assertEquals("gameBoy", s.skin)
        assertEquals(3, s.habits.size)
        assertEquals(5, s.habits[1].scheduleDays)
        assertNull(s.habits[2].scheduleDays)
        assertEquals(50, s.flowPercent)
        assertEquals(2, s.dueHabits.size)
    }

    @Test fun garbageReturnsNull() {
        assertNull(WidgetSnapshot.parse(null))
        assertNull(WidgetSnapshot.parse(""))
        assertNull(WidgetSnapshot.parse("not json"))
        assertNull(WidgetSnapshot.parse("{\"today\":\"2026-11-25\"}"))
    }

    @Test fun sameDayIsUnchanged() {
        val s = parsed()
        assertSame(s, s.rolledTo("2026-11-25"))
    }

    @Test fun nextDayResetsProgressAndFollowsSchedule() {
        // Thursday: "b" (Mon/Wed) is not due; "c" without a mask keeps its dueToday.
        val r = parsed().rolledTo("2026-11-26")
        assertEquals("2026-11-26", r.today)
        assertEquals(0, r.todayDone)
        assertFalse(r.habits.any { it.done || it.progress != 0 })
        assertEquals(listOf("a"), r.dueHabits.map { it.id })
        assertEquals(1, r.todayTotal)
        assertEquals("2026-11-23", r.weekStart)
        assertEquals(3, r.weekBlocks)
        assertEquals(listOf("2026-11-25", "2026-11-26"), r.skyline.map { it.date })
        assertEquals(listOf("#FF7675", "#2DE38E"), r.skyline[0].colors)
        assertTrue(r.skyline[1].colors.isEmpty())
        assertEquals(4, r.skyline[1].weekday)
    }

    @Test fun nextWeekStartsEmpty() {
        // Monday 2026-11-30 is after weekEnd (Sunday 11-29).
        val r = parsed().rolledTo("2026-11-30")
        assertEquals("2026-11-30", r.weekStart)
        assertEquals("2026-12-06", r.weekEnd)
        assertEquals(0, r.weekBlocks)
        assertEquals(setOf("a", "b"), r.dueHabits.map { it.id }.toSet())
    }

    @Test fun invalidTodayKeyIsIgnored() {
        assertNotNull(parsed().rolledTo("garbage"))
        assertEquals("2026-11-25", parsed().rolledTo("garbage").today)
    }
}
